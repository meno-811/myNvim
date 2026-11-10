local event = vim.json.decode(io.stdin:read("*a"))
if event.hook_event_name == "SessionStart" and type(event.transcript_path) == "string" then
  vim.fn.writefile({ event.transcript_path }, assert(arg[1]))
end
