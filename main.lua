---@diagnostic disable: undefined-global, lowercase-global

local gameVersion = 1.4

local screenW
local screenH

local speed = 220
local gravity = 900
local jumpStrength = -330

local floppy = {
    x = 100,
    y = 0,
    width = 50,
    height = 50,
    vy = 0,
    angle = 0
}

local pillar_gap = 200
local lower_pillar_height
local upper_pillar_height

local lower_pillar
local upper_pillar

local titleScreen = true
local paused = false
local isGameOver = false

local score = 0
local highScore = 0
local hasSaved = false

local hardMode = false
local doomTimer = 0

local soundLock = false
local loseSoundLock = false
local winSoundLock = false

local pointSound
local winSound
local loseSound
local flapSound
local chillTheme
local doomTheme

local spriteSheet
local quads
local currentFrame = 1
local timer = 0

local path = "high_score.txt"


local function createPillars()
    local currentGap = math.max(100, pillar_gap)

    local minimumHeight = 50
    local maximumHeight = math.floor(screenH - currentGap - 50)

    if maximumHeight < minimumHeight then
        lower_pillar_height = math.floor((screenH - currentGap) / 2)
    else
        lower_pillar_height = math.random(minimumHeight, maximumHeight)
    end

    upper_pillar_height = screenH - lower_pillar_height - currentGap

    lower_pillar = {
        x = screenW,
        y = screenH - lower_pillar_height,
        width = 50,
        height = lower_pillar_height,
        passed = false
    }

    upper_pillar = {
        x = screenW,
        y = 0,
        width = 50,
        height = upper_pillar_height
    }
end


local function resetGame()
    floppy.x = 100
    floppy.y = screenH / 2
    floppy.vy = 0
    floppy.angle = 0

    score = 0
    speed = 220
    pillar_gap = 200
    hardMode = false
    doomTimer = 0

    hasSaved = false
    isGameOver = false

    soundLock = false
    winSoundLock = false
    loseSoundLock = false

    createPillars()

    if flapSound then flapSound:stop() end
    if winSound then winSound:stop() end
    if loseSound then loseSound:stop() end
    if pointSound then pointSound:stop() end
    if doomTheme then doomTheme:stop() end
    if chillTheme then chillTheme:play() end

    love.window.setTitle("Floppy Bird")
end


local function loadHighScore(filename)
    if love.filesystem.getInfo(filename) then
        local content = love.filesystem.read(filename)
        highScore = tonumber(content) or 0
    else
        highScore = 0
    end
end


local function writeHighScore(filename)
    if score > highScore then
        highScore = score
        love.filesystem.write(filename, tostring(highScore))
    end
end


local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2
        and x2 < x1 + w1
        and y1 < y2 + h2
        and y2 < y1 + h1
end


local function hasPassedPillar(bird, pillar)
    return bird.x > pillar.x + pillar.width
end


local function checkGameOver()
    if floppy.y <= 0 then
        return true
    end

    if floppy.y + floppy.height >= screenH then
        return true
    end

    if checkCollision(
        floppy.x,
        floppy.y,
        floppy.width,
        floppy.height,
        lower_pillar.x,
        lower_pillar.y,
        lower_pillar.width,
        lower_pillar.height
    ) then
        return true
    end

    if checkCollision(
        floppy.x,
        floppy.y,
        floppy.width,
        floppy.height,
        upper_pillar.x,
        upper_pillar.y,
        upper_pillar.width,
        upper_pillar.height
    ) then
        return true
    end

    return false
end


local function titleScreenDraw()
    local centerY = love.graphics.getHeight() / 2
    local lineHeight = love.graphics.getFont():getHeight()

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "Welcome to Floppy Bird " .. tostring(gameVersion),
        0,
        centerY - lineHeight,
        screenW,
        "center"
    )

    love.graphics.setColor(1, 1, 0)
    love.graphics.printf(
        "Press 'space' to start",
        0,
        centerY + lineHeight,
        screenW,
        "center"
    )
end


local function pauseScreenDraw()
    local centerY = love.graphics.getHeight() / 2
    local lineHeight = love.graphics.getFont():getHeight()
    local y = centerY - lineHeight / 2

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(
        "Game Paused. Press P to resume.",
        0,
        y,
        love.graphics.getWidth(),
        "center"
    )
end


function love.load()
    math.randomseed(os.time())

    love.filesystem.setIdentity("FloppyBird")

    screenW, screenH = love.graphics.getDimensions()

    floppy.y = screenH / 2

    love.window.setTitle("Floppy Bird")

    -- Load sounds after LÖVE has initialized.
    pointSound = love.audio.newSource("prrrt.mp3", "static")
    winSound = love.audio.newSource("drumroll.mp3", "static")
    loseSound = love.audio.newSource("gameOver.mp3", "static")
    flapSound = love.audio.newSource("flap.mp3", "static")

    chillTheme = love.audio.newSource("BGmusic.mp3", "stream")
    doomTheme = love.audio.newSource("DOOM.mp3", "stream")

    chillTheme:setLooping(true)
    chillTheme:setVolume(0.2)

    doomTheme:setLooping(true)
    doomTheme:setVolume(0.5)

    -- Load sprite sheet.
    spriteSheet = love.graphics.newImage("floppy_bird.png")

    local sw, sh = spriteSheet:getDimensions()

    quads = {
        love.graphics.newQuad(143, 102, 166, 123, sw, sh),
        love.graphics.newQuad(328, 102, 154, 123, sw, sh),
        love.graphics.newQuad(492, 102, 164, 123, sw, sh)
    }

    currentFrame = 1
    timer = 0

    loadHighScore(path)
    createPillars()

    chillTheme:play()
end


function love.update(dt)
    if titleScreen or paused then
        return
    end

    if not isGameOver and checkGameOver() then
        isGameOver = true
    end

    if not isGameOver then
        local activeDuration

        if floppy.vy < 0 then
            activeDuration = 0.08
        else
            activeDuration = 0.25
        end

        timer = timer + dt

        if timer >= activeDuration then
            timer = timer - activeDuration
            currentFrame = (currentFrame % #quads) + 1
        end

        floppy.vy = floppy.vy + gravity * dt
        floppy.y = floppy.y + floppy.vy * dt

        lower_pillar.x = lower_pillar.x - speed * dt
        upper_pillar.x = upper_pillar.x - speed * dt
    else
        -- Let the bird fall after game over.
        currentFrame = 2

        if floppy.y + floppy.height < screenH then
            floppy.vy = floppy.vy + gravity * dt
            floppy.y = math.min(
                screenH - floppy.height,
                floppy.y + floppy.vy * dt
            )
        end

        if not hasSaved then
            writeHighScore(path)
            hasSaved = true
        end
    end

    -- Rotate the bird based on vertical velocity.
    local targetAngle

    if floppy.vy < 0 then
        targetAngle = -0.4
    else
        targetAngle = math.min(1.2, (floppy.vy / 600) * 1.2)
    end

    floppy.angle = floppy.angle
        + (targetAngle - floppy.angle) * 8 * dt

    -- Create a new pair of pillars.
    if lower_pillar.x + lower_pillar.width < 0 then
        createPillars()
    end

    -- Add score after passing the lower pillar.
    if not lower_pillar.passed
        and hasPassedPillar(floppy, lower_pillar) then

        lower_pillar.passed = true
        score = score + 1
    end

    -- Enable hard mode after beating the high score.
    if score > highScore then
        hardMode = true
    end

    if hardMode and not isGameOver then
        if chillTheme:isPlaying() then
            chillTheme:stop()
        end

        if not doomTheme:isPlaying() then
            doomTheme:play()
        end

        speed = 250
        pillar_gap = 140
        doomTimer = doomTimer + dt

        love.window.setTitle("Floppy Death")

        if doomTimer >= 10 then
            speed = 350
            pillar_gap = 130
            love.window.setTitle("DOOOM")
        end
    elseif isGameOver then
        if chillTheme:isPlaying() then
            chillTheme:stop()
        end

        if doomTheme:isPlaying() then
            doomTheme:stop()
        end

        doomTimer = 0
    end

    -- Play a sound every five points.
    if score % 5 == 0 and score ~= 0 and not soundLock then
        pointSound:play()
        soundLock = true
    end

    if score % 5 ~= 0 then
        soundLock = false
    end

    -- Play the appropriate game-over sound.
    if isGameOver and score >= highScore and not winSoundLock then
        winSound:play()
        winSoundLock = true
    elseif isGameOver and score < highScore and not loseSoundLock then
        loseSound:play()
        loseSoundLock = true
    end
end


function love.draw()
    if titleScreen then
        titleScreenDraw()
    end

    if paused then
        pauseScreenDraw()
    end

    -- Safety check for the animation array.
    if quads and quads[currentFrame] then
        love.graphics.setColor(1, 1, 1)

        local _, _, quadWidth, quadHeight =
            quads[currentFrame]:getViewport()

        local scale = floppy.height / quadHeight

        local drawX = floppy.x + floppy.width / 2
        local drawY = floppy.y + floppy.height / 2

        love.graphics.draw(
            spriteSheet,
            quads[currentFrame],
            drawX,
            drawY,
            floppy.angle,
            scale,
            scale,
            quadWidth / 2,
            quadHeight / 2
        )
    end

    -- Draw pillars.
    if hardMode and doomTimer >= 10 then
        love.graphics.setColor(1, 0, 0)
    elseif hardMode then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(0, 1, 0)
    end

    love.graphics.rectangle(
        "fill",
        lower_pillar.x,
        lower_pillar.y,
        lower_pillar.width,
        lower_pillar.height
    )

    love.graphics.rectangle(
        "fill",
        upper_pillar.x,
        upper_pillar.y,
        upper_pillar.width,
        upper_pillar.height
    )

    -- Draw score.
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. tostring(score), 10, 10, 0, 2, 2)

    -- Draw game-over screen.
    if isGameOver then
        local centerY = screenH / 2
        local lineHeight = love.graphics.getFont():getHeight()
        local spacing = 30

        love.graphics.setColor(1, 0, 0)
        love.graphics.printf(
            "GAME OVER!",
            0,
            centerY - lineHeight - spacing,
            screenW,
            "center"
        )

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            "Score: " .. tostring(score),
            0,
            centerY,
            screenW,
            "center"
        )

        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(
            "High Score: " .. tostring(highScore),
            0,
            centerY + lineHeight + spacing,
            screenW,
            "center"
        )

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            "Press 'R' to restart",
            0,
            centerY + lineHeight * 5,
            screenW,
            "center"
        )
    end

    love.graphics.setColor(1, 1, 1)
end


function love.keypressed(key)
    if key == "space" and titleScreen and not isGameOver then
        titleScreen = false

        if not chillTheme:isPlaying() then
            chillTheme:play()
        end

    elseif key == "space" and not titleScreen
        and not paused and not isGameOver then

        floppy.vy = jumpStrength
        flapSound:play()

    elseif key == "p" and not paused
        and not titleScreen and not isGameOver then

        paused = true

        if chillTheme:isPlaying() then
            chillTheme:pause()
        end

        if doomTheme:isPlaying() then
            doomTheme:pause()
        end

    elseif key == "p" and paused
        and not titleScreen and not isGameOver then

        paused = false

        if hardMode then
            doomTheme:play()
        else
            chillTheme:play()
        end

    elseif key == "r" and isGameOver then
        resetGame()
    end
end


function love.touchpressed(_, _, _)
    if titleScreen and not isGameOver then
        titleScreen = false
    elseif not titleScreen and not paused and not isGameOver then
        floppy.vy = jumpStrength
        flapSound:play()
    end
end
