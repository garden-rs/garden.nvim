# garden.nvim

*garden.nvim* configures treesitter syntax highlighting for
[Garden](https://garden-rs.gitlab.io/) YAML files.


## Installation

You can install this plugin using your favorite vim package manager.

### Packer

```lua
use({'davvid/garden.nvim'})
```

### Lazy

```lua
{ 'davvid/garden.nvim' }
```


## Development

The [Garden file](garden.yaml) can be used to run lint checks using
[Garden](https://gitlab.com/garden-rs/garden).

```bash
# Run lint checks using "luacheck"
garden check -vv
```

The documentation is generated using [panvimdoc](https://github.com/kdheepak/panvimdoc.git).

```bash
garden setup -vv  # one-time setup
garden doc -vv
```

Use `garden fmt -vv` to apply code formatting using [stylua](https://github.com/JohnnyMorganz/StyLua).
