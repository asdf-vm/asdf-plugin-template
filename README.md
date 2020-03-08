# asdf-plugin-template

This is an [asdf-vm plugin](https://asdf-vm.com/#/plugins-create) template with CI to run [Shellcheck](https://github.com/koalaman/shellcheck) and testing with the [asdf test GitHub Action](https://github.com/asdf-vm/actions).

For more information about creating a plugin, see the [plugins create section of the docs](https://asdf-vm.com/#/plugins-create).

## Usage

1. [generate a template of this repo](https://github.com/asdf-vm/asdf-plugin-template/generate)
2. edit the following files/folders:

   - rename folder `GITHUB` to `.github`
   - `.github/workflows/build.yaml`
     - replace `<YOUR TOOLS COMMAND>`
   - `LICENSE`
     - replace `<YEAR>`
     - replace `<YOUR NAME>`
   - `contributing.md`
     - replace `<YOUR TOOL>`
     - replace `<YOUR GITHUB USERNAME>`
     - expand on this contributing guide as you see fit
   - `README_TEMPLATE.md`
     - replace `<YOUR TOOL>`
     - replace `<YOUR GITHUB USERNAME>`
     - replace `<REPO>`
     - replace the items in the `Dependencies` section
     - rename file to README.md overwriting this file

3. write your code in the `bin/install`, `bin/list-all` and `lib/utils.bash` files.

## Contributing

Contributions welcome!
