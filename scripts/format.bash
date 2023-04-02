#!/usr/bin/env bash

# format this repo
shfmt --language-dialect bash --write \
	setup.bash \
	scripts/*.bash

# format the template/
shfmt --language-dialect bash --write \
	template/**/*
