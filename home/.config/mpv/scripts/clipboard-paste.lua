mp.add_key_binding(nil, "load-clipboard", function()
    local res = mp.command_native({
        name = "subprocess",
        capture_stdout = true,
        args = {"wl-paste", "--no-newline"},
    })
    if res.status ~= 0 then return end
    local url = res.stdout:match("^%s*(.-)%s*$")
    if url ~= "" then
        mp.commandv("loadfile", url)
        mp.osd_message("加载: " .. url, 3)
    end
end)
