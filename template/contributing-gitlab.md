# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

#
asdf plugin test <YOUR TOOL> https://gitlab.com/<YOUR GITLAB USERNAME>/asdf-<YOUR TOOL>.git "<TOOL CHECK>"
```

Tests are automatically run in GitLab CI on push and merge request.
