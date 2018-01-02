shfmt:
	go get github.com/contiv-experimental/sh/cmd/shfmt
	find . -type f -name "*.sh" -exec shfmt -w -i 4 -p {} \;
