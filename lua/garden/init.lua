--- garden.nvim
---
--- Configure treesitter highlighting for garden ~ https://garden-rs.gitlab.io/
---
--- Enables syntax highlighting for files named "garden.yaml" or contain a
--- `# filetype: garden` comment on the first line.

local garden = {}

garden.setup = function()
    vim.filetype.add({
        filename = {
            ['garden.yaml'] = 'yaml.garden',
            ['garden.yml'] = 'yaml.garden',
        },
        pattern = {
            ['.*%.ya?ml'] = function(_, bufnr)
                local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
                    or ''
                if first_line:match('#%s*filetype:%s*garden') then
                    return 'yaml.garden'
                end
                return nil
            end,
        },
    })

    vim.treesitter.language.register('yaml', 'yaml.garden')

    vim.treesitter.query.add_predicate('is-filetype?', function(_, _, bufnr, predicate)
        local target_ft = predicate[2]
        return vim.bo[bufnr].filetype == target_ft
    end, { force = true })

    local treesitter_query = [[
        ; Block maps
        ((block_mapping_pair
            key: (flow_node (plain_scalar) @key)
            value: (block_node (block_scalar) @injection.content))
            (#is-filetype? "yaml.garden")
            (#not-eq? @key "description")
            (#set! injection.language "bash"))

        ; Flow maps
        ((block_mapping_pair
            key: (flow_node (plain_scalar) @key)
            value: (flow_node [
                (plain_scalar (string_scalar) @injection.content)
                (double_quote_scalar) @injection.content
                (single_quote_scalar) @injection.content
            ]))
            (#is-filetype? "yaml.garden")
            (#not-eq? @key "description")
            (#set! injection.language "bash"))

        ; Block Arrays inside a map
        ((block_mapping_pair
            key: (flow_node (plain_scalar) @key)
            value: (block_node
                (block_sequence
                (block_sequence_item [
                    (block_node (block_scalar) @injection.content)
                    (flow_node [
                        (plain_scalar (string_scalar) @injection.content)
                        (double_quote_scalar) @injection.content
                        (single_quote_scalar) @injection.content
                    ])
                ]))))
            (#is-filetype? "yaml.garden")
            (#not-eq? @key "description")
            (#set! injection.language "bash"))

        ; Flow Arrays inside a map
        ((block_mapping_pair
            key: (flow_node (plain_scalar) @key)
            value: (flow_node
                (flow_sequence [
                    (plain_scalar (string_scalar) @injection.content)
                    (double_quote_scalar) @injection.content
                    (single_quote_scalar) @injection.content
                ])))
            (#is-filetype? "yaml.garden")
            (#not-eq? @key "description")
            (#set! injection.language "bash"))
    ]]

    local garden_group =
        vim.api.nvim_create_augroup('GardenYamlSyntax', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = garden_group,
        pattern = 'yaml.garden',
        callback = function(args)
            vim.treesitter.query.set('yaml', 'injections', treesitter_query)

            -- Refresh treesitter
            vim.treesitter.stop(args.buf)
            vim.api.nvim_buf_clear_namespace(args.buf, -1, 0, -1)
            vim.treesitter.start(args.buf, 'yaml')
        end,
    })
end

return garden
