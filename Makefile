.PHONY: build test elm-test elm-verify-examples watch

build:
	elm make src/List/Focus.elm

elm-test: elm-verify-examples
	elm-test

elm-verify-examples:
	npx elm-verify-examples

test: build elm-test
	elm-test

watch:
	watchexec \
  --clear \
  --restart \
  --watch src \
  --watch elm.json \
  --watch README.md \
  "make test"
