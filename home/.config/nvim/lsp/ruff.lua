return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
  on_attach = function(client)
    -- hover 交给 basedpyright，ruff 只负责 lint
    client.server_capabilities.hoverProvider = false
  end,
}
