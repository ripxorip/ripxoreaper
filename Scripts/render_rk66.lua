-- ==========================
-- RK66 EP Automated Render
-- Wet & Dry stems, explicit track list, forced 0 to end, 48kHz 24bit mono
-- Uses Render: auto-close (42230) for headless, no-dialog exports
-- Uses RENDER_FILE as folder only, RENDER_PATTERN as filename to prevent folder bugs
-- Adjusts Phil Folder fader to +0 dB and pan to center before loop, restores after
-- ==========================

-- 🧙‍♂️ CONFIGURATION
local tracks_to_render = {
  "Philip Rythm Main",
  "Philip Rythm Dub",
  "Philip Rythm Extra",
  "Philip Rythm Extra Dub",
  "Philip Solo"
}

local export_dir = "C:\\export"  -- No trailing backslash

-- ==========================
-- 🗃️ Get project name (e.g. "1" from "1.rpp")
local _, project_path = reaper.EnumProjects(-1, "")
local project_name = project_path:match("([^\\/]+)%.rpp$") or "Project"
reaper.ShowConsoleMsg("Project name: " .. project_name .. "\n")

-- ==========================
-- 🔍 Find Phil Folder and store original fader/pan
local phil_folder_name = "Phil"  -- <<< UPDATE if your folder track is named differently!
local phil_folder = nil
local phil_folder_vol = nil
local phil_folder_pan = nil

local track_count = reaper.CountTracks(0)

local phil_fx_states = {}
for i = 0, track_count - 1 do
  local track = reaper.GetTrack(0, i)
  local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
  if track_name:lower() == phil_folder_name:lower() then
    phil_folder = track
    phil_folder_vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
    phil_folder_pan = reaper.GetMediaTrackInfo_Value(track, "D_PAN")

    -- Store FX bypass states
    local fx_count = reaper.TrackFX_GetCount(track)
    for fx = 0, fx_count - 1 do
      phil_fx_states[fx] = reaper.TrackFX_GetEnabled(track, fx)
      reaper.TrackFX_SetEnabled(track, fx, false) -- bypass FX
    end

    reaper.SetMediaTrackInfo_Value(track, "D_VOL", 1.0)
    reaper.SetMediaTrackInfo_Value(track, "D_PAN", 0.0)

    reaper.ShowConsoleMsg("Phil Folder fader set to 1.0 and pan set to 0.0, FX bypassed\n")
    break
  end
end

if phil_folder == nil then
  reaper.ShowConsoleMsg("⚠️ Phil Folder NOT FOUND! Check the name.\n")
end

-- ==========================
-- ⏱️ Force time selection to 0 -> project end
local proj_len = reaper.GetProjectLength(0)
reaper.GetSet_LoopTimeRange(true, false, 0, proj_len, false)
reaper.ShowConsoleMsg("Time selection forced: 0 to " .. proj_len .. "\n")

-- ==========================
-- 🔄 Loop through explicit tracks

for _, target_name in ipairs(tracks_to_render) do
  local found = false

  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    if track_name == target_name then
      found = true
      reaper.ShowConsoleMsg("\n=== Processing: " .. track_name .. " ===\n")

      -- ⚙️ Store original FX states and fader/pan
      local fx_count = reaper.TrackFX_GetCount(track)
      local fx_bypass = {}
      for fx = 0, fx_count - 1 do
        fx_bypass[fx] = reaper.TrackFX_GetEnabled(track, fx)
      end
      local orig_vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
      local orig_pan = reaper.GetMediaTrackInfo_Value(track, "D_PAN")

      -- Center fader and pan
      reaper.SetMediaTrackInfo_Value(track, "D_VOL", 1.0)
      reaper.SetMediaTrackInfo_Value(track, "D_PAN", 0.0)

      -- 🟢 Solo track
      reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 1)

      -- ==========================
      -- 🔊 WET render
      for fx = 0, fx_count - 1 do
        reaper.TrackFX_SetEnabled(track, fx, true)
      end

      local wet_pattern = string.format("%s_wet_%s",
        project_name,
        track_name:gsub(" ", "_")
      )
      reaper.GetSetProjectInfo_String(0, "RENDER_FILE", export_dir, true)
      reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", wet_pattern, true)
      reaper.GetSetProjectInfo(0, "RENDER_SRATE", 48000, true)
      reaper.GetSetProjectInfo(0, "RENDER_CHANNELS", 1, true)
      reaper.GetSetProjectInfo(0, "RENDER_BPS", 24, true)
      reaper.GetSetProjectInfo(0, "RENDER_SETTINGS", 0, true)
      reaper.GetSetProjectInfo(0, "RENDER_BOUNDSFLAG", 1, true)

      reaper.ShowConsoleMsg("Rendering WET: " .. export_dir .. "\\" .. wet_pattern .. ".wav\n")
      reaper.Main_OnCommand(42230, 0)

      -- ==========================
      -- 🟡 DRY render
      for fx = 0, fx_count - 1 do
        reaper.TrackFX_SetEnabled(track, fx, false)
      end

      local dry_pattern = string.format("%s_dry_%s",
        project_name,
        track_name:gsub(" ", "_")
      )
      reaper.GetSetProjectInfo_String(0, "RENDER_FILE", export_dir, true)
      reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", dry_pattern, true)

      reaper.ShowConsoleMsg("Rendering DRY: " .. export_dir .. "\\" .. dry_pattern .. ".wav\n")
      reaper.Main_OnCommand(42230, 0)

      -- ♻️ Restore FX states and fader/pan
      for fx = 0, fx_count - 1 do
        reaper.TrackFX_SetEnabled(track, fx, fx_bypass[fx])
      end
      reaper.SetMediaTrackInfo_Value(track, "D_VOL", orig_vol)
      reaper.SetMediaTrackInfo_Value(track, "D_PAN", orig_pan)

      -- 🔕 Unsolo
      reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 0)

      reaper.ShowConsoleMsg("Finished: " .. track_name .. "\n")
      break
    end
  end

  if not found then
    reaper.ShowConsoleMsg("⚠️ Track NOT FOUND: " .. target_name .. "\n")
  end
end

-- ✅ Restore Phil Folder fader & pan

if phil_folder ~= nil then
  -- Restore FX bypass states
  local fx_count = reaper.TrackFX_GetCount(phil_folder)
  for fx = 0, fx_count - 1 do
    if phil_fx_states[fx] ~= nil then
      reaper.TrackFX_SetEnabled(phil_folder, fx, phil_fx_states[fx])
    end
  end
  reaper.SetMediaTrackInfo_Value(phil_folder, "D_VOL", phil_folder_vol)
  reaper.SetMediaTrackInfo_Value(phil_folder, "D_PAN", phil_folder_pan)
  reaper.ShowConsoleMsg("Phil Folder fader, pan, and FX states restored.\n")
end

reaper.ShowConsoleMsg("\n✅ ALL TRACKS DONE! RK66 EP RENDER COMPLETE! ✅\n")
