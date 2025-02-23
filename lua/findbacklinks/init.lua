local M = {}

-- findbacklinks by cjeholm
--
local function get_first_h1()
    local lines = vim.fn.readfile(vim.fn.expand("%"))
    for _, line in ipairs(lines) do
        local title = line:match("^#%s(.+)")
        if title then
            -- Convert to lowercase and replace spaces with dashes
            title = title:lower():gsub("%s+", "-")
            return title
        end
    end
    return nil
end

M.find_backlinks = function()
	local title = get_first_h1()
	if not title then
		print("No H1 title found in the current file!")
		return
	end

	local search_cmd = {
		"rg",
		"--with-filename",
		"--line-number",
		"--column",
		"--fixed-strings",
		"[[" .. title .. "]]",
		"--glob",
		"*.md",
		".",
	}

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local previewers = require("telescope.previewers")
	local sorters = require("telescope.config").values.generic_sorter
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Backlinks to " .. title,
			finder = finders.new_oneshot_job(search_cmd, {}),
			sorter = sorters({}),
			previewer = previewers.new_termopen_previewer({
				get_command = function(entry)
					local file, line = entry[1]:match("^(.-):(%d+):")
					return { "bat", "--style=numbers,grid", "--color=always", "--highlight-line=" .. line, file }
				end,
			}),
			attach_mappings = function(prompt_bufnr, map)
				local open_link = function()
					local selection = action_state.get_selected_entry()
					if selection then
						local file, line = selection[1]:match("^(.-):(%d+):")
						vim.api.nvim_command("new " .. file)
						vim.api.nvim_win_set_cursor(0, { tonumber(line), 0 })
            vim.api.nvim_command("stopinsert")
					end
          if picker then
					  actions.close(prompt_bufnr)
          end
				end
				map("i", "<CR>", open_link)
				map("n", "<CR>", open_link)
				return true
			end,
		})
		:find()
end

-- Function to find outgoing links in the current file
M.find_outlinks = function()
    local lines = vim.fn.readfile(vim.fn.expand("%"))
    local links = {}

    -- Extract wikilinks [[example]]
    for _, line in ipairs(lines) do
        for link in line:gmatch("%[%[(.-)%]%]") do
            -- Convert to lowercase and replace spaces with dashes
            local formatted_link = link:lower():gsub("%s+", "-")
            table.insert(links, formatted_link)
        end
    end

    if #links == 0 then
        print("No outgoing links found!")
        return
    end

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local previewers = require("telescope.previewers")
    local sorters = require("telescope.config").values.generic_sorter
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers
        .new({}, {
            prompt_title = "Outgoing Links",
            finder = finders.new_table({
                results = links,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = entry,
                        ordinal = entry,
                        filename = entry .. ".md", -- Assumes filenames match the link format
                    }
                end,
            }),
            sorter = sorters({}),
            previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry)
                    local file = entry.filename
                    if file and vim.fn.filereadable(file) == 1 then
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.fn.readfile(file))
                    else
                        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "File not found: " .. (file or "nil") })
                    end
                end,
            }),
            attach_mappings = function(prompt_bufnr, map)
                local open_link = function()
                    local selection = action_state.get_selected_entry()
                    if selection then
                        local file = selection.filename
                        vim.api.nvim_command("new " .. file)
                        vim.api.nvim_command("stopinsert")
                    end
                    if picker then
                      actions.close(prompt_bufnr)
                    end
                end
                map("i", "<CR>", open_link)
                map("n", "<CR>", open_link)
                return true
            end,
        })
        :find()
end

vim.api.nvim_create_user_command("FindBacklinks", M.find_backlinks, {})
vim.api.nvim_create_user_command("FindOutlinks", M.find_outlinks, {})

return M
