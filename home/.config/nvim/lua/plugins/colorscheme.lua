return {
  {
    -- DMS 官方 neovim 集成：colors/dms.lua（matugen 生成）依赖此插件，
    -- 把 github_light/dark 向壁纸主色调和后加载，换壁纸自动热重载
    "AvengeMedia/base46",
    lazy = false,
    priority = 1000,
    config = function()
      -- colors/dms.lua 每次加载都同步跑 `dms ipc call theme getMode`，实测阻塞 ~105ms（占启动 2/3）。
      -- 该文件由 matugen 模板生成不可改，这里在 vim.system 外包一层：命中这条 argv 时改读
      -- DMS 自己的 session.json（isLightMode），毫秒级返回；读不到再回落到真 IPC。
      local real_system = vim.system
      local session_file = vim.fs.joinpath(
        vim.env.XDG_STATE_HOME or vim.fs.joinpath(vim.env.HOME, ".local", "state"),
        "DankMaterialShell", "session.json"
      )
      local function dms_mode_from_session()
        local f = io.open(session_file, "r")
        if not f then return nil end
        local ok, data = pcall(vim.json.decode, f:read("*a"))
        f:close()
        if not ok or type(data) ~= "table" or data.isLightMode == nil then return nil end
        return data.isLightMode and "light" or "dark"
      end
      vim.system = function(cmd, opts, on_exit)
        if type(cmd) == "table" and table.concat(cmd, " ") == "dms ipc call theme getMode" then
          local mode = dms_mode_from_session()
          if mode then
            local result = { code = 0, signal = 0, stdout = mode .. "\n", stderr = "" }
            if on_exit then on_exit(result) end
            return { wait = function() return result end, kill = function() end, is_closing = function() return true end }
          end
        end
        return real_system(cmd, opts, on_exit)
      end

      -- transparency：Normal 等背景置 NONE，透出 kitty 的 0.85 透明背景
      require("base46").setup({ transparency = true })
      vim.cmd.colorscheme("dms")
    end,
  },
}
