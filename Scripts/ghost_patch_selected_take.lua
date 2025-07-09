-- Get last item in project
local count = reaper.CountMediaItems(0)
if count == 0 then
  reaper.ShowConsoleMsg("[ghost] No media items found in project.\n")
  return
end

local item = reaper.GetMediaItem(0, count - 1)
local take = reaper.GetActiveTake(item)
if not take then
  reaper.ShowConsoleMsg("[ghost] Last item has no active take.\n")
  return
end

local src = reaper.GetMediaItemTake_Source(take)
local path = reaper.GetMediaSourceFileName(src, "")

if path and path ~= "" then
  -- reaper.ShowConsoleMsg("[ghost] Last recorded WAV:\n" .. path .. "\n")

  local python = "C:/dev/pw-ghost-rec/.venv/Scripts/python.exe"
  local script = "C:/dev/pw-ghost-rec/take_patcher.py"

  -- Escape and quote path for Windows
  local function quote_path(p)
    -- Double quotes for Windows, escape any existing quotes
    return '"' .. p:gsub('"', '\\"') .. '"'
  end

  local quoted_path = quote_path(path)
  local cmd = python .. ' ' .. quote_path(script) .. ' ' .. quoted_path

  -- reaper.ShowConsoleMsg("[ghost] Running: " .. cmd .. "\n")
  local ok, exit_type, code = os.execute(cmd)
  if ok and code == 0 then
    -- reaper.ShowConsoleMsg("✅ Done patching take: " .. path .. "\n")
    -- Set take source to the new _buffered.wav file
    local new_path = path:gsub('%.wav$', '_buffered.wav')
    reaper.BR_SetTakeSourceFromFile(take, new_path, false)
  else
    reaper.ShowMessageBox("Patch failed! See console for details.", "Ghost Patch", 0)
  end

  -- Confirm finished
  -- reaper.ShowConsoleMsg("[ghost] ✅ Done converting.\n")

else
  reaper.ShowConsoleMsg("[ghost] Could not resolve source path.\n")
end
