-- floppy bird
---@diagnostic disable: undefined-global, lowercase-global
-- HS: 35

-- variable definition
local screenW, screenH = love.graphics.getDimensions()
local speed = 220
local gravity = 900
local jumpStrength = -330
local floppy = { x = 100, y = screenH / 2, width = 50, height = 50, vy = 0, angle = 0 }
local lower_pillar_height = math.random(50, 450)
local pillar_gap = 200
local upper_pllar_height = screenH - lower_pillar_height - pillar_gap
local titleScreen = true
local paused = false

local score = 0
local lower_pillar = { x = screenW, y = screenH - lower_pillar_height, width = 50, height = lower_pillar_height, passed = false }
local upper_pillar = { x = screenW, y = 0, width = 50, height = upper_pllar_height }
local hardMode = false
local doomTimer = 0

-- SOUNDS --
local soundLock = false
local loseSoundLock = false
local winSoundLock = false
local pointSound = love.audio.newSource("prrrt.mp3", "static")
local winSound = love.audio.newSource("drumroll.mp3", "static")
local loseSound = love.audio.newSource("gameOver.mp3", "static")
local flapSound = love.audio.newSource("flap.mp3", "static")
local chillTheme = love.audio.newSource("BGmusic.mp3", "stream")
local doomTheme = love.audio.newSource("DOOM.mp3", "stream")
chillTheme:setLooping(true)
doomTheme:setLooping(true)
chillTheme:setVolume(0.2)
doomTheme:setVolume(0.5)


-- FUNCY FUNCTIONS

local path = "high_score.txt"
local highScore = 0
local hasSaved = false
local isGameOver = false

function loadHighScore(path)
    if love.filesystem.getInfo(path) then
        local content = love.filesystem.read(path)
        highScore = tonumber(content) or 0
    end
end

function writeHighScore(path)
    if score > highScore then
        highScore = score
        love.filesystem.write(path, tostring(highScore))

    end
end

function love.load()
    -- save dir for persistent storage
    love.filesystem.setIdentity("FloppyBird")
    -- make high_score.txt
    path = "high_score.txt"
    loadHighScore(path)
    love.window.setTitle("Floppy Bird")
    -- Load sprite sheet
    spriteSheet = love.graphics.newImage("floppy_bird.png")

    -- Define custom quads to isolate each bird perfectly without connecting lines
    local sw, sh = spriteSheet:getDimensions()
    quads = {
        love.graphics.newQuad(143, 102, 166, 123, sw, sh),
        love.graphics.newQuad(328, 102, 154, 123, sw, sh),
        love.graphics.newQuad(492, 102, 164, 123, sw, sh)
    }

    -- Animation state
    currentFrame = 1
    timer = 0

    -- sound
    chillTheme:play()
end

function love.update(dt)
    if not titleScreen and not paused then
        -- Trigger game over if collision occurs
        if not isGameOver and CheckGameOver() then
            isGameOver = true
        end

        if not isGameOver then
            -- Flapping speed matches bird's motion
            local activeDuration = 0.15
            if floppy.vy < 0 then
                activeDuration = 0.08 -- flap fast when rising
            else
                activeDuration = 0.25 -- flap slow when falling
            end

            timer = timer + dt
            if timer >= activeDuration then
                timer = timer - activeDuration
                currentFrame = (currentFrame % #quads) + 1
            end

            -- complicated angle of bird stuff
            -- Physics updates
            floppy.vy = floppy.vy + gravity * dt
            floppy.y = floppy.y + floppy.vy * dt
            lower_pillar.x = lower_pillar.x - speed * dt
            upper_pillar.x = upper_pillar.x - speed * dt
            hasSaved = false
        else
            -- Game over state: stop flapping (glide frame) but let bird fall down
            currentFrame = 2
            if floppy.y + floppy.height < screenH then
                floppy.vy = floppy.vy + gravity * dt
                floppy.y = math.min(screenH - floppy.height, floppy.y + floppy.vy * dt)
            end
            if not hasSaved then
                writeHighScore(path)
                hasSaved = true
            end
        end

    elseif paused then
        doomTheme:pause()
        chillTheme:pause()
    end



    -- Smoothly interpolate rotation angle based on vertical velocity
    local targetAngle = 0
    if floppy.vy < 0 then
        targetAngle = -0.4 -- Point slightly up when jumping
    else
        -- Map falling speed to a downward angle (max 1.2 radians ~ 70 degrees)
        targetAngle = math.min(1.2, (floppy.vy / 600) * 1.2)
    end
    floppy.angle = floppy.angle + (targetAngle - floppy.angle) * 8 * dt
    -- End of complicated stuff

    -- score stuff
    if lower_pillar.x + lower_pillar.width < 0 then
        lower_pillar.x = screenW
        upper_pillar.x = screenW
        lower_pillar_height = math.random(50, 400)
        upper_pllar_height = screenH - lower_pillar_height - pillar_gap
        lower_pillar.height = lower_pillar_height
        lower_pillar.y = screenH - lower_pillar_height
        upper_pillar.height = upper_pllar_height
        lower_pillar.passed = false
    end

    if not lower_pillar.passed and HasPassedPillars(floppy, lower_pillar) then
        lower_pillar.passed = true
        score = score + 1
    end
    -- hard mode
    if score > highScore then
        hardMode = true
    end

    if hardMode == true and not CheckGameOver() then
        chillTheme:stop()
        doomTheme:play()
        speed = 250
        pillar_gap = 175
        doomTimer = doomTimer + dt
        love.window.setTitle("Floppy death")
        if doomTimer >= 10 then
            speed = 350
            pillar_gap = 160
            speed = speed + dt
            love.window.setTitle("DOOOM")
        end
    elseif CheckGameOver() then
        chillTheme:stop()
        doomTheme:stop()
        doomTimer = 0
    end
    -- play sound if score is a multiple of 5
    if score % 5 == 0 and score ~= 0 and soundLock == false then
        pointSound:play()
        soundLock = true
    end

    if score % 5 ~= 0 then
        soundLock = false
    end

    -- win sound
    if score >= highScore and isGameOver == true and winSoundLock == false then
        winSound:play()
        winSoundLock = true
    elseif score < highScore and isGameOver == true and loseSoundLock == false then
        loseSound:play()
        loseSoundLock = true
    end
end

function love.draw()
    if titleScreen == true then
        TitleSootyScreen()
    end
    -- Draw floppy bird sprite centered on its collision box and rotated
    love.graphics.setColor(1, 1, 1) -- white color for clean image draw
    local qx, qy, qw, qh = quads[currentFrame]:getViewport()
    local s = floppy.height / qh
    local drawX = floppy.x + floppy.width / 2
    local drawY = floppy.y + floppy.height / 2
    -- Rotate around the center of the bird quad (qw/2, qh/2)
    love.graphics.draw(spriteSheet, quads[currentFrame], drawX, drawY, floppy.angle, s, s, qw / 2, qh / 2)

    if hardMode and doomTimer >= 10 then
        love.graphics.setColor(1, 0, 0) -- red
    elseif hardMode then
        love.graphics.setColor(1, 1, 0) -- yellow
    else
        love.graphics.setColor(0, 1, 0) -- green
    end
    love.graphics.rectangle('fill', lower_pillar.x, lower_pillar.y, lower_pillar.width, lower_pillar.height)
    love.graphics.rectangle('fill', upper_pillar.x, upper_pillar.y, upper_pillar.width, upper_pillar.height)

    -- Draw Score
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. tostring(score), 10, 10, 0, 2, 2)

    -- Game over screen
    if isGameOver then
        local centerY = screenH / 2
        local lineHeight = love.graphics.getFont():getHeight()
        local spacing = 30  -- space between lines

        -- "GAME OVER!" text
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER!", 0, centerY - lineHeight - spacing, screenW, "center")

        -- Score text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Score: " .. score, 0, centerY, screenW, "center")

        -- High Score text
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("High Score: " .. highScore, 0, centerY + lineHeight + spacing, screenW, "center")

        -- Restart instruction
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Press 'R' to restart", 0, centerY + (lineHeight * 5), screenW, "center")
    end
end

function love.keypressed(key)
    if key == 'space' and not isGameOver and titleScreen then
        titleScreen = false
        chillTheme:play()
    elseif key == 'space' and not isGameOver and not paused then
        floppy.vy = jumpStrength
        flapSound:play()
    elseif key == 'p' and not paused and not titleScreen then
        paused = true
    elseif key == 'p' and paused and not titleScreen and not hardMode then
        paused = false
        chillTheme:play()
    elseif key == 'p' and paused and not titleScreen and hardMode then
            paused = false
            doomTheme:play()
    elseif key == 'r' and isGameOver then
        floppy.y = screenH / 2
        floppy.x = 100
        -- physics reload
        floppy.vy = 0
        floppy.angle = 0
        lower_pillar.x = screenW
        upper_pillar.x = screenW
        lower_pillar.y = screenH - lower_pillar_height
        upper_pillar.y = 0
        lower_pillar.height = lower_pillar_height
        upper_pillar.height = upper_pllar_height
        lower_pillar.passed = false
        score = 0
        hasSaved = false
        isGameOver = false
        winSoundLock = false
        loseSoundLock = false
        soundLock = false
        flapSound:stop()
        winSound:stop()
        loseSound:stop()
        pointSound:stop()
        hardMode = false
        speed = 220
        pillar_gap = 200
        chillTheme:play()
        love.window.setTitle("Floppy Bird")
    end
end


function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
        x2 < x1 + w1 and
        y1 < y2 + h2 and
        y2 < y1 + h1
end

function HasPassedPillars(floppy, pillar)
    return floppy.x > pillar.x + pillar.width
end

function CheckGameOver()
    if floppy.y <= 0 or floppy.y + floppy.height >= screenH or
        CheckCollision(floppy.x, floppy.y, floppy.width, floppy.height, lower_pillar.x, lower_pillar.y, lower_pillar.width, lower_pillar.height) or
        CheckCollision(floppy.x, floppy.y, floppy.width, floppy.height, upper_pillar.x, upper_pillar.y, upper_pillar.width, upper_pillar.height) then
        return true
    end
    return false
end

function TitleSootyScreen()
    local centerY = love.graphics.getHeight() / 2
    local lineHeight = love.graphics.getFont():getHeight()

    -- Title text
    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.printf("Welcome to Floppy Bird V1.3", 0, centerY - lineHeight, screenW, "center")

    -- Start instruction
    love.graphics.setColor(1, 1, 0) -- yellow
    love.graphics.printf("Press 'space' to start", 0, centerY + lineHeight, screenW, "center")
end
