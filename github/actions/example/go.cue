package actions

go: Workflow & {
	on: ["push", "pull_request"]
	name: "Test"
	jobs test: {
		strategy matrix: {
			"go-version": ["1.12.x", "1.13.x"]
			platform: ["ubuntu-latest", "macos-latest", "windows-latest"]
		}
		"runs-on": "${{ matrix.platform }}"
		steps: [{
			name: "Install Go"
			uses: "actions/setup-go@v1"
			with "go-version": "${{ matrix.go-version }}"
		}, {
			name: "Checkout code"
			uses: "actions/checkout@v1"
		}, {
			name: "Test"
			run:  "go test ./..."
		}]
	}
}
