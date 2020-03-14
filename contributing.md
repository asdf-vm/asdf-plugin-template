# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]
asdf plugin test gcloud https://github.com/<YOUR GITHUB USERNAME/asdf-<YOUR TOOL>.git <YOUR TOOL> --version
```

Tests are automatically run in GitHub Actions on push and PR.
