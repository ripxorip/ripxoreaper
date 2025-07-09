-- toggle_tuner_track.lua
-- Phil's stateless tuner toggle: big & proud or ghost mode

function toggle_tuner_track()
  local tuner_name = "tuner"
  local track_count = reaper.CountTracks(0)

  for i = 0, track_count - 1 do
    local track = reaper.GetTrack(0, i)
    local _, name = reaper.GetTrackName(track, "")

    if name:lower() == tuner_name then
      local height = reaper.GetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE")

      if height >= 100 then
        -- Ghost mode
        reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 0)
        reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 0)
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
      else
        -- Big and proud
        reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 500)
        reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 1)
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
      end

      reaper.TrackList_AdjustWindows(false)
      break
    end
  end
end

reaper.Undo_BeginBlock()
toggle_tuner_track()
reaper.Undo_EndBlock("Stateless toggle tuner visibility", -1)
