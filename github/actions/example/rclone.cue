package actions

// Github Actions build for rclone
// -*- compile-command: "yamllint -f parsable build.yml" -*-

rclone: Workflow & {
	name: "build"

	// Trigger the workflow on push or pull request
	on: {
		push: {
			branches: [
				"*",
			]
			tags: [
				"*",
			]
		}
		pull_request:
			null
	}
	jobs: {
		build: {
			"timeout-minutes": 60
			strategy: {
				"fail-fast": false
				matrix: {
					job_name: ["linux", "mac", "windows_amd64", "windows_386", "other_os", "modules_race", "go1.10", "go1.11", "go1.12"]

					include: [{
						job_name:    "linux"
						os:          "ubuntu-latest"
						go:          "1.13.x"
						modules:     "off"
						gotags:      "cmount"
						build_flags: "-include \"^linux/\""
						check:       true
						quicktest:   true
						deploy:      true
					}, {
						job_name:      "mac"
						os:            "macOS-latest"
						go:            "1.13.x"
						modules:       "off"
						gotags:        "" // cmount doesn't work on osx travis for some reason
						build_flags:   "-include \"^darwin/amd64\" -cgo"
						quicktest:     true
						racequicktest: true
						deploy:        true
					}, {
						job_name:      "windows_amd64"
						os:            "windows-latest"
						go:            "1.13.x"
						modules:       "off"
						gotags:        "cmount"
						build_flags:   "-include \"^windows/amd64\" -cgo"
						quicktest:     true
						racequicktest: true
						deploy:        true
					}, {
						job_name:    "windows_386"
						os:          "windows-latest"
						go:          "1.13.x"
						modules:     "off"
						gotags:      "cmount"
						goarch:      "386"
						cgo:         "1"
						build_flags: "-include \"^windows/386\" -cgo"
						quicktest:   true
						deploy:      true
					}, {
						job_name:    "other_os"
						os:          "ubuntu-latest"
						go:          "1.13.x"
						modules:     "off"
						build_flags: "-exclude \"^(windows/|darwin/amd64|linux/)\""
						compile_all: true
						deploy:      true
					}, {
						job_name:      "modules_race"
						os:            "ubuntu-latest"
						go:            "1.13.x"
						modules:       "on"
						quicktest:     true
						racequicktest: true
					}, {
						job_name:  "go1.10"
						os:        "ubuntu-latest"
						go:        "1.10.x"
						modules:   "off"
						quicktest: true
					}, {
						job_name:  "go1.11"
						os:        "ubuntu-latest"
						go:        "1.11.x"
						modules:   "off"
						quicktest: true
					}, {
						job_name:  "go1.12"
						os:        "ubuntu-latest"
						go:        "1.12.x"
						modules:   "off"
						quicktest: true
					}]
				}
			}

			name: "${{ matrix.job_name }}"

			"runs-on": "${{ matrix.os }}"

			steps: [{
				name: "Checkout"
				uses: "actions/checkout@master"
				with path: "./src/github.com/${{ github.repository }}"
			}, {
				name: "Install Go"
				uses: "actions/setup-go@v1"
				with "go-version": "${{ matrix.go }}"
			}, {
				name:  "Set environment variables"
				shell: "bash"
				run: """
			echo '::set-env name=GOPATH::${{ runner.workspace }}'
			echo '::add-path::${{ runner.workspace }}/bin'
			echo '::set-env name=GO111MODULE::${{ matrix.modules }}'
			echo '::set-env name=GOTAGS::${{ matrix.gotags }}'
			echo '::set-env name=BUILD_FLAGS::${{ matrix.build_flags }}'
			if [[ \"${{ matrix.goarch }}\" != \"\" ]]; then echo '::set-env name=GOARCH::${{ matrix.goarch }}' ; fi
			if [[ \"${{ matrix.cgo }}\" != \"\" ]]; then echo '::set-env name=CGO_ENABLED::${{ matrix.cgo }}' ; fi

			"""
			}, {
				name:  "Install Libraries on Linux"
				shell: "bash"
				run: """
			sudo modprobe fuse
			sudo chmod 666 /dev/fuse
			sudo chown root:$USER /etc/fuse.conf
			sudo apt-get install fuse libfuse-dev rpm pkg-config

			"""

				if: "matrix.os == 'ubuntu-latest'"
			}, {
				name:  "Install Libraries on macOS"
				shell: "bash"
				run: """
			brew update
			brew cask install osxfuse

			"""

				if: "matrix.os == 'macOS-latest'"
			}, {
				name:  "Install Libraries on Windows"
				shell: "powershell"
				run: """
			$ProgressPreference = 'SilentlyContinue'
			choco install -y winfsp zip
			Write-Host \"::set-env name=CPATH::C:\\Program Files\\WinFsp\\inc\\fuse;C:\\Program Files (x86)\\WinFsp\\inc\\fuse\"
			if ($env:GOARCH -eq \"386\") {
			  choco install -y mingw --forcex86 --force
			  Write-Host \"::add-path::C:\\\\ProgramData\\\\chocolatey\\\\lib\\\\mingw\\\\tools\\\\install\\\\mingw32\\\\bin\"
			}
			# Copy mingw32-make.exe to make.exe so the same command line
			# can be used on Windows as on macOS and Linux
			$path = (get-command mingw32-make.exe).Path
			Copy-Item -Path $path -Destination (Join-Path (Split-Path -Path $path) 'make.exe')

			"""

				if: "matrix.os == 'windows-latest'"
			}, {
				name:  "Print Go version and environment"
				shell: "bash"
				run: """
			printf \"Using go at: $(which go)\\n\"
			printf \"Go version: $(go version)\\n\"
			printf \"\\n\\nGo environment:\\n\\n\"
			go env
			printf \"\\n\\nRclone environment:\\n\\n\"
			make vars
			printf \"\\n\\nSystem environment:\\n\\n\"
			env

			"""
			}, {
				name:  "Run tests"
				shell: "bash"
				run: """
			make
			make quicktest

			"""

				if: "matrix.quicktest"
			}, {
				name:  "Race test"
				shell: "bash"
				run: """
			make racequicktest

			"""

				if: "matrix.racequicktest"
			}, {
				name:  "Code quality test"
				shell: "bash"
				run: """
			make build_dep
			make check

			"""

				if: "matrix.check"
			}, {
				name:  "Compile all architectures test"
				shell: "bash"
				run: """
			make
			make compile_all

			"""

				if: "matrix.compile_all"
			}, {
				name:  "Deploy built binaries"
				shell: "bash"
				run: """
			if [[ \"${{ matrix.os }}\" == \"ubuntu-latest\" ]]; then make release_dep ; fi
			make travis_beta

			"""

				env RCLONE_CONFIG_PASS: "${{ secrets.RCLONE_CONFIG_PASS }}"
				// working-directory: '$(modulePath)'
				if: "matrix.deploy && github.head_ref == ''"
			}]
		}

		xgo: {
			"timeout-minutes": 60
			name:              "xgo cross compile"
			"runs-on":         "ubuntu-latest"

			steps: [{
				name: "Checkout"
				uses: "actions/checkout@master"
				with path: "./src/github.com/${{ github.repository }}"
			}, {
				name:  "Set environment variables"
				shell: "bash"
				run: """
			echo '::set-env name=GOPATH::${{ runner.workspace }}'
			echo '::add-path::${{ runner.workspace }}/bin'

			"""
			}, {
				name: "Cross-compile rclone"
				run: """
			docker pull billziss/xgo-cgofuse
			go get -v github.com/karalabe/xgo
			xgo \\
			    -image=billziss/xgo-cgofuse \\
			    -targets=darwin/386,darwin/amd64,linux/386,linux/amd64,windows/386,windows/amd64 \\
			    -tags cmount \\
			    -dest build \\
			    .
			xgo \\
			    -image=billziss/xgo-cgofuse \\
			    -targets=android/*,ios/* \\
			    -dest build \\
			    .

			"""
			}, {
				name: "Build rclone"
				run: """
			docker pull golang
			docker run --rm -v \"$PWD\":/usr/src/rclone -w /usr/src/rclone golang go build -mod=vendor -v

			"""
			}, {
				name: "Upload artifacts"
				run: """
			make circleci_upload

			"""

				env RCLONE_CONFIG_PASS: "${{ secrets.RCLONE_CONFIG_PASS }}"
				if: "github.head_ref == ''"
			}]
		}
	}
}
