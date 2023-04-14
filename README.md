<div align="center">

# asdf-okta-aws-cli [![Build](https://github.com/bennythejudge/asdf-plugin-okta-aws-cli/actions/workflows/build.yml/badge.svg)](https://github.com/bennythejudge/asdf-okta-aws-cli/actions/workflows/build.yml) [![Lint](https://github.com/bennythejudge/asdf-plugin-okta-aws-cli/actions/workflows/lint.yml/badge.svg)](https://github.com/bennythejudge/asdf-okta-aws-cli/actions/workflows/lint.yml)


[okta-aws-cli](https://github.com/okta/okta-aws-cli) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add okta-aws-cli
# or
asdf plugin add okta-aws-cli https://github.com/bennythejudge/asdf-okta-aws-cli.git
```

okta-aws-cli:

```shell
# Show all installable versions
asdf list-all okta-aws-cli

# Install specific version
asdf install okta-aws-cli latest

# Set a version globally (on your ~/.tool-versions file)
asdf global okta-aws-cli latest

# Now okta-aws-cli commands are available
okta-aws-cli --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/bennythejudge/asdf-okta-aws-cli/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Benedetto Lo Giudice](https://github.com/bennythejudge/)
