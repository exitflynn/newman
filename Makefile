# Exports.
export GO111MODULE=on

artefacts/quotes.json:
ifneq (,$(wildcard $@))
	rm $@
endif
	echo "{\"quotes\":[]}" > artefacts/quotes.json

cmd/quotes.json: artefacts/quotes.json
ifneq (,$(wildcard $@))
	rm $@
endif
	@go generate cmd/updater.go

internal/quotes.json: artefacts/quotes.json
ifneq (,$(wildcard $@))
	rm $@
endif
	@go generate internal/loader.go

# Generate quotes artefacts and update the original one.
populate: artefacts/quotes.json cmd/quotes.json internal/quotes.json
	@go run cmd/updater.go
	@go generate ./... >> /dev/null 2>&1
	@go generate core/functions.go >> core/help.json

# Remove all generated quotes artefacts and initialize the original one.
cleanup:
	@./convenience.sh

# Install the required dependencies.
install:
	@go mod tidy

# Container cleanup.
docker-clean:
	@docker kill mssql && docker rm mssql
# Start containers.
docker-run:
	@sudo docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Qwertyuiop1#" --name mssql -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest
	@sleep 10

# Run the bot.
run: 
	@go run ./...
