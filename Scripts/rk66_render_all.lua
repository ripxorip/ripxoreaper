-- ==========================
-- RK66 Batch Invoker: Open each .rpp, run render script, clean, sort, zip, done
-- ==========================

-- 🗂️ Project paths — adjust to match your setup
local project_paths = {
  "C:\\Prod\\RK66\\1_patched\\1.rpp",
  "C:\\Prod\\RK66\\2_patched\\2.rpp",
  "C:\\Prod\\RK66\\3_patched\\3.rpp",
  "C:\\Prod\\RK66\\4_patched\\4.rpp"
}

-- 🔗 Your render script Command ID from Action List
local render_script_id = reaper.NamedCommandLookup("_RSdac58d86b3b7c9322b68a87aee0a4c369b7055d1")

if render_script_id == 0 then
  reaper.ShowConsoleMsg("❌ Could not find render script Command ID! Aborting.\n")
  return
end

local export_dir = "C:\\export"

-- ==========================
-- 1️⃣ Fully clean export folder: remove ALL files & subfolders
reaper.ShowConsoleMsg("✅ Cleaning export folder: " .. export_dir .. "\n")

-- Remove everything under export dir
os.execute('cmd /C "rmdir /S /Q ' .. export_dir .. '"')

-- Recreate export dir to be sure it exists
os.execute('cmd /C "mkdir ' .. export_dir .. '"')

-- ==========================
-- 2️⃣ Loop: open each .rpp, run render script, close
reaper.ShowConsoleMsg("✅ RK66 Batch Invoker started...\n")

for _, path in ipairs(project_paths) do
  reaper.ShowConsoleMsg("\n=== Opening project: " .. path .. " ===\n")

  reaper.Main_openProject(path)

  reaper.ShowConsoleMsg("Running render script on: " .. path .. "\n")
  reaper.Main_OnCommand(render_script_id, 0)

  -- ✅ Close project without save prompt
  reaper.ShowConsoleMsg("Closing project (no save): " .. path .. "\n")
  reaper.Main_OnCommand(40860, 0)
end

-- ==========================
-- 3️⃣ Sort rendered WAVs into per-project folders
reaper.ShowConsoleMsg("\n✅ Sorting rendered files...\n")

for _, path in ipairs(project_paths) do
  local proj_num = path:match("([0-9]+)_patched")
  if proj_num then
    local folder = export_dir .. "\\" .. proj_num
    os.execute('cmd /C "mkdir ' .. folder .. '"')

    local pattern = export_dir .. "\\" .. proj_num .. "_*.wav"
    os.execute('cmd /C "move ' .. pattern .. ' ' .. folder .. '"')

    reaper.ShowConsoleMsg("Moved files for project: " .. proj_num .. "\n")
  end
end

-- ==========================
-- 4️⃣ Create final ZIP archive of the entire export folder
reaper.ShowConsoleMsg("\n✅ Creating ZIP archive...\n")

local zip_cmd = 'powershell -Command "Compress-Archive -Path ' .. export_dir .. '\\* -DestinationPath ' .. export_dir .. '\\RK66_EP_Philip_Tracks.zip -Force"'
os.execute(zip_cmd)

reaper.ShowConsoleMsg("✅ Archive created: " .. export_dir .. "\\RK66_EP_Philip_Tracks.zip\n")

-- ==========================
-- ✅ All done!
reaper.ShowConsoleMsg("\n✅ RK66 Batch Invoker done — all projects rendered, sorted & zipped!\n")
