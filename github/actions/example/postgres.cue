package actions

workflow: Workflow & {
	name: "Postgres Service Example"

	on: {
		push branches: [
			"master",
		]
		pull_request branches: [
			"master",
		]
	}

	jobs: {
		"container-job": {
			"runs-on": "ubuntu-latest"

			// runs all of the steps inside the specified container rather than on the VM host.
			// Because of this the network configuration changes from host based network to a container network.
			container image: "node:10.16-jessie"

			services postgres: {
				image: "postgres:10.8"
				env: {
					POSTGRES_USER:     "postgres"
					POSTGRES_PASSWORD: "postgres"
					POSTGRES_DB:       "postgres"
				}
				ports: [
					"5432:5432",
				]
				// needed because the postgres container does not provide a healthcheck
				options: "--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5"
			}

			steps: [{
				uses: "actions/checkout@v1"
			}, {
				run:                 "npm ci"
				"working-directory": "./postgres"
			}, {
				run:                 "node client.js"
				"working-directory": "./postgres"
				env: {
					// use postgres for the host here because we have specified a container for the job.
					// If we were running the job on the VM this would be localhost
					POSTGRES_HOST: "postgres"
					POSTGRES_PORT: "${{ job.services.postgres.ports[5432] }}"
				}
			}]
		}

		// Runs all steps on the VM
		// The service containers will use host port binding instead of container networking so you access them via localhost rather than the service name
		"vm-job": {
			"runs-on": "ubuntu-latest"

			services postgres: {
				image: "postgres:10.8"
				env: {
					POSTGRES_USER:     "postgres"
					POSTGRES_PASSWORD: "postgres"
					POSTGRES_DB:       "postgres"
				}
				ports:
				// will assign a random free host port
				[
					"5432/tcp",
				]
				// needed because the postgres container does not provide a healthcheck
				options: "--health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5"
			}

			steps: [{
				uses: "actions/checkout@v1"
			}, {
				run:                 "npm ci"
				"working-directory": "./postgres"
			}, {
				run:                 "node client.js"
				"working-directory": "./postgres"
				env: {
					// use localhost for the host here because we are running the job on the VM.
					// If we were running the job on in a container this would be postgres
					POSTGRES_HOST: "localhost"
					POSTGRES_PORT: "${{ job.services.postgres.ports[5432] }}"
				}
			}]
		}
	}
}
