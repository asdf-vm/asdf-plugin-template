# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test okta-aws-cli https://github.com/bennythejudge/asdf-okta-aws-cli.git "okta-aws-cli --help"
```

Tests are automatically run in GitHub Actions on push and PR.
