# ⚡ Ripxorip REAPER Config ⚡

🎚️ **Welcome to my personal REAPER config vault** —  
this repo holds the *essence* of my workflow: custom scripts, macros, keybindings, and MIDI mappings that make me edit and record like a pro.

---

## 🚀 **What’s inside**

✅ **`Scripts/ripxorip/`** — my curated Lua scripts.  
   - Small tools to boost my editing speed.
   - Organized so I don’t drag Cockos junk or ReaPack randoms into my Git.

✅ **`reaper-kb.ini`** — my entire brain:  
   - Custom actions 🪄
   - Keybindings ⌨️
   - MIDI mappings 🎹  
   If I lose this, my muscle memory is toast — so it lives in Git.

✅ **Optional:** `reaper-menu.ini` if I’m feeling fancy with custom toolbars and context menus.

---

## 🔗 **How I keep it in sync**

I use **symlinks** to point my REAPER config to this repo:

| OS       | Live Path                                  | Repo Path                                |
|----------|--------------------------------------------|------------------------------------------|
| **Win**  | `%APPDATA%\REAPER\Scripts\ripxorip`        | `C:\dev\ripxoreaper\Scripts`             |
| **Win**  | `%APPDATA%\REAPER\reaper-kb.ini`           | `C:\dev\ripxoreaper\reaper-kb.ini`       |
| **Linux**| `~/.config/REAPER/Scripts/ripxorip`        | `~/dev/ripxorip/Scripts`                 |
| **Linux**| `~/.config/REAPER/reaper-kb.ini`           | `~/dev/ripxorip/reaper-kb.ini`           |

When I tweak my config:  
1️⃣ Change stuff in REAPER →  
2️⃣ Git sees it →  
3️⃣ Commit that sweet magic →  
4️⃣ Pull on any other machine →  
5️⃣ Jam out exactly like home.

---

## 🧹 **What’s NOT here**

🗑️ No bloated PNGs from theme folders.  
🗑️ No plugin scans or UndoHistory.  
🗑️ No zip file chaos.  
Just the *surgical* bits I care about.

---

## 🤘 **Setup**

1. Clone the repo wherever you want (`C:\dev\ripxoreaper` / `~/dev/ripxorip`).
2. Run `setup-symlinks.bat` (**Windows**, as Admin) or `setup-symlinks.sh` (**Linux**).
3. Fire up REAPER — everything works.
4. Be unstoppable.

---

## 💡 **Why?**

Because my creative flow deserves version control, reproducibility, and zero bullshit.

---

### ✨ *Hack the DAW. Own your config. Rock out.* 🎸