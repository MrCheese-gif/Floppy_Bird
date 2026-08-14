# READ ME

⚠️WARNING: This game is the local version of *Floppy bird* and hence does not work on the web using WebBuilder.

# Change log

### Version 1.4

- Added the ability to pause mid-game when pressing the <kbd>P</kbd> key.
- Added nil-checkers to the music and sound effects, so that if a sound asset is missing, the game won't crash.
- Added more bugs to fix later
- Added more fixes to bug later

#### Bug Fixes

- Fixed a bug where bird keeps spinning after death

### Version 1.3

- Used `love.filesystem` instead of `io.read` to let the game run on web using [Love WebBuilder](https://schellingb.github.io/LoveWebBuilder/package), however, **this version does not work on WebBuilder**. To get the version that works on WebBuilder, click [here](https://www.placeholder.com)

- Due to this, the location of `high_score.txt` has changed

#### Bug Fixes

- Fixed an error where if `high_score.txt` does not exist, the highscore doesn't persist.

- Fixed an error where game blue screens on death.

### Version 1.2

- Added a title screen to the game

- Horizontally centered all text that appears in the 'Game Over' state

#### Bug Fixes

- N/A: No bugs found

---

This project was coded in [Lua](www.lua.org). It uses [LÖVE2D](www.love2d.org) as the game engine. 

## Requirements

- Lua
- LÖVE2D

**To download the requirements, click [here for Lua](www.lua.org) and [here for LÖVE](www.love2d.org)**

## Instructions

To run the game, first download the code as a `.zip` file from my GitHub page (pres the green button that says `Code`, and then click `download as zip`), then [unzip](https://www.ezyzip.com/unzip-files-online.html) the folder. Then, download LÖVE2D from their website. After you have done that, drag the folder you just unzipped onto the LÖVE2D icon. Immediately, a game window will pop up, and you will be able to play 'floppy bird'. You must do this every time you want to play.

## How to Play

If you have never played flappy bird before, basically:
You are a bird, and you have to go between the green poles. You can do so by flapping to go up (you will fall automatically). The poles will keep going left.

### Controls

- Press <kbd>space</kbd> to jump

- Press the <kbd>R</kbd> key to restart after you have died

- Press the <kbd>P</kbd> key to pause mid-game

## ~~Cheating~~ Changing the high score

If you are playing against your friends and have a serious skill issue, open Terminal and type:

**MacOS:** 

```bash
nano ~/Library/Application\ Support/LOVE/FloppyBird/high_score.txt
```

**Windows:** 

```bash
cd C:\Users\YourUsername\AppData\Roaming\LOVE\FloppyBird
nano high_score.txt
```

**Linux:** 

```bash
nano ~/.local/share/love/FloppyBird/high_score.txt
```

You will see your high score there. Simply change it to your desired score, press `ctrl + O` to save and then `ctrl + X` to exit and flex on your friends.

> [!NOTE] You can also use this to reset the high score to 0.

## Doom Mode

 To prevent a huge, unbeatable score, after you beat the previous high score, doom mode will commence, where the pillars will change color to yellow and the music changes. At this point, it is advisable to panic and crash into either:

- The ground
- The ceiling
- A pillar

> Since the default high score is set to 0, doom mode will activate once you go through the first pillars on your first run.

# Bugs

> To report bugs or request features, email alrisdhanwani@protonmail.com
