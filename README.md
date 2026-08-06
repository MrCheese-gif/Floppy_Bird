# READ ME

> ⚠️WARNING: This game is the Web Edition of *floppy bird* .

Original game: [Floppy Bird](https://github.com/MrCheese-gif/Floppy_Bird)

# Change log

### Version 1 WE

- Added the ability to pause mid-game when pressing the <kbd>P</kbd> key.
  
- Added nil-checkers to the music and sound effects, so that if a sound asset is missing, the game won't crash.
  
- Added more bugs to fix later
  
- Added more fixes to bug later

#### Bug Fixes

- Fixed a bug where bird keeps spinning after death

### Version 1.3

- Used `love.filesystem` instead of `io.read` to let the game run on web using [Love WebBuilder](https://schellingb.github.io/LoveWebBuilder/package), however, **this version does not work on WebBuilder**. To get the version that works on WebBuilder, click [here](This project was coded in [Lua](www.lua.org). It uses [LÖVE2D](https://www.love2d.org) as the game engine. )

- Due to this, the location of `high_score.txt` has changed

#### Bug Fixes

- Fixed an error where if `high_score.txt` does not exist, the highscore doesn't persist.

- Fixed an error where game blue screens on death.

### Version 1.2

- Added a title screen to the game

- Horizontally centered all text that appears in the 'Game Over' state

#### Bug Fixes

- N/A: No bugs found

**This project was coded in [Lua](https://www.lua.org). It uses [LÖVE2D](https://www.love2d.org) as the game engine and [Love WebBuilder](https://schellingb.github.io/LoveWebBuilder/package) to package the game.**

## Note

To make it run on the web, I have had to strip down a lot of things. This means that there is no background music in the game, only sound effects, and everything is going to be very compressed. For the best experience, it is recommended that you just play the original version. The web version is still not mature so you should expect bugs. This version works on both web and with the LÖVE2D app, however, it is recommended you use the [original version](https://github.com/MrCheese-gif/Floppy_Bird) for the latter

## Instructions

To run the game, first download the code as a `.zip` file from my GitHub page, then [unzip](https://www.ezyzip.com/unzip-files-online.html) the folder. Then, select the files inside the folder, go to the LOVE WebBuilder website, click 'run' to run once or 'build' to download as HTML, and drop in the files. Alternatively, you can also just download the ready HTML file and double click it in the File Explorer/ Finder to run it in your default browser.

## How to Play

If you have never played flappy bird before, basically:
You are a bird, and you have to go between the green poles. You can do so by flapping to go up (you will fall automatically). The poles will keep going left.

### Controls

- Press <kbd>space</kbd> to jump

- Press the <kbd>R</kbd> key to restart after you have died

- Press the <kbd>P</kbd> key to pause mid-game

## ~~Cheating~~ Changing the high score

Unlike the local version, this version does not support changing the high score. The high score will also not persist if you reload the page.

## Doom Mode

To prevent a huge, unbeatable score, after you beat the previous high score, doom mode will commence, where the pillars will change color to yellow. At this point, it is advisable to panic and crash into either:

- The ground
- The ceiling
- A pillar

> Since the default high score is set to 0, doom mode will activate once you go through the first pillars on your first run.

# Bugs

There is a very specific bug where if the high score is 0 and you immediately crash without going past the first pillar, the game will blue screen and crash. We are unaware of what is causing this bug, but you can be sure that we are trying to fix it.



> To report bugs or request features, email alrisdhanwani@protonmail.com
