-- Smart click track toggler for Reaper
-- Updated: Toggles solo if already soloed while others are soloed

local CLICK_TRACK_NAME = "Click"

local function findClickTrack()
  for i = 0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    local retval, name = reaper.GetSetMediaTrackInfo_String(tr, "P_NAME", "", false)
    if name:lower():find(CLICK_TRACK_NAME:lower()) then
      return tr
    end
  end
  return nil
end

local function isOtherTrackSoloed(clickTrack)
  for i = 0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    if tr ~= clickTrack then
      local solo = reaper.GetMediaTrackInfo_Value(tr, "I_SOLO")
      if solo > 0 then return true end
    end
  end
  return false
end

-- Main
reaper.Undo_BeginBlock()
local clickTrack = findClickTrack()

if clickTrack then
  local isMuted = reaper.GetMediaTrackInfo_Value(clickTrack, "B_MUTE") == 1
  local isSoloed = reaper.GetMediaTrackInfo_Value(clickTrack, "I_SOLO") > 0
  local othersSoloed = isOtherTrackSoloed(clickTrack)

  if isMuted then
    -- Always unmute when muted
    reaper.SetMediaTrackInfo_Value(clickTrack, "B_MUTE", 0)
    if othersSoloed then
      reaper.SetMediaTrackInfo_Value(clickTrack, "I_SOLO", 1)
    end
  else
    if othersSoloed then
      -- Toggle solo status if others are soloed
      reaper.SetMediaTrackInfo_Value(clickTrack, "I_SOLO", isSoloed and 0 or 1)
    else
      -- No other solo: mute and clear solo
      reaper.SetMediaTrackInfo_Value(clickTrack, "B_MUTE", 1)
      reaper.SetMediaTrackInfo_Value(clickTrack, "I_SOLO", 0)
    end
  end
end

reaper.Undo_EndBlock("Smart toggle click track (with solo logic)", -1)
