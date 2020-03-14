<div align="center">

# asdf-<YOUR TOOL> ![Build](https://github.com/<YOUR GITHUB USERNAME>/asdf-<REPO>/workflows/Build/badge.svg) ![Lint](https://github.com/<YOUR GITHUB USERNAME>/asdf-<REPO>/workflows/Lint/badge.svg)

[<YOUR TOOL>](https://) plugin for [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, `python`
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add <YOUR TOOL>
# or
asdf plugin add https://github.com/<YOUR GITHUB USERNAME>/asdf-<YOUR TOOL>.git
```

<YOUR TOOL>:

```shell
asdf install <YOUR TOOL> 283.0.0
```

Set global version:

```shell
asdf global <YOUR TOOL> 283.0.0
```

# Why?

The asdf config file, `.tool-versions`, allows pinning each tool in your project to a specific version. This ensures that ALL developers are using the same version of each tool. Same `python`, same `ruby`, same `gcloud`, same `terraform` etc.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/<YOUR GITHUB USERNAME>/asdf-<YOUR TOOL>/graphs/contributors)!

# License

[MIT License](LICENSE) © [<YOUR NAME>](https://github.com/<YOUR GITHUB USERNAME>/)
