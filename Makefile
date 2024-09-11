###########################################################
.PHONY: swag
swag:
	@swag init -g cmd/cm-ant/main.go --output api/
###########################################################

###########################################################
.PHONY: build
build:
	@go build -o ant ./cmd/cm-ant/...
###########################################################

###########################################################
.PHONY: run 
run:
	@go run cmd/cm-ant/main.go
###########################################################
