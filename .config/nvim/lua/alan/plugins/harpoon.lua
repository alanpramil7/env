local map = vim.api.nvim_set_keymap

local function map_numeric_keys()
    local numeric_mappings = {}

    for i = 1, 9 do
        table.insert(numeric_mappings, {
            key = tostring(i),
            cmd = string.format('<cmd> lua require("harpoon.ui").nav_file(%d)<CR>', i),
            desc = string.format("Harpoon Bind #%d", i),
            options = { noremap = true, silent = true },
        })
    end

    for _, mapping in ipairs(numeric_mappings) do
        map("n", mapping.key, mapping.cmd, mapping.options)
    end
end

map_numeric_keys()

return {
    "nvim-lua/plenary.nvim",
    "ThePrimeagen/harpoon",
    enabled = true,
    opts = {
        map("n", "<leader>A", '<cmd> lua require("harpoon.ui").toggle_quick_menu()<CR>', {
            desc = "Harpoon Table",
        }),
        map("n", "<leader>a", '<cmd> lua require("harpoon.mark").add_file()<CR>', {
            desc = "Harpoon Add",
        }),
    },
    config = function()
        require("harpoon").setup({
            global_settings = {
                save_on_toggle = true,
                save_on_change = true,
            },
        })
    end,
}
