BINARY   := tabya-attest
VERSION  ?= dev
LDFLAGS  := -X github.com/tabyaos/tabya-attest/cmd.Version=$(VERSION)

.PHONY: build test lint clean

build:
	go build -ldflags "$(LDFLAGS)" -o bin/$(BINARY) ./...

test:
	go test ./...

lint:
	golangci-lint run ./...

vet:
	go vet ./...

clean:
	rm -rf bin/
