return {
  cmd = { 'pylsp' },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
  telemetry = { enabled = false },
  formatters = { ignoreComments = false, },
  settings = {
    jedi_completion = { fuzzy = true },
  },
}
