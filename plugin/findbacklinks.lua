
if vim.g.loaded_findbacklinks then
    return
end
vim.g.loaded_findbacklinks = true

require("findbacklinks")

vim.api.nvim_create_user_command("FindBacklinks", function()
    require("findbacklinks").find_backlinks()
end, { desc = "Find backlinks to the current note using Telescope" })
