local timerMenu = hs.menubar.new()
local timerRunning = false
local remainingTime = 0
local timer
local activeMode = nil -- Track the current active TimerMode
local TimerMode = { ---@alias TimerMode 1|2
    Work = 1,
    Break = 2,
}

-- Helper function to get mode names
local function getModeName(mode)
    if mode == TimerMode.Work then
        return "Work"
    elseif mode == TimerMode.Break then
        return "Break"
    else
        return "Unknown"
    end
end

-- Helper function to get mode icons
local function getModeIcon(mode)
    if mode == TimerMode.Work then
        return "🤖"
    elseif mode == TimerMode.Break then
        return "☕"
    else
        return ""
    end
end

-- Function to convert numbers to fullwidth digits
local function toFullwidth(num)
    local fullwidthDigits = {"０", "１", "２", "３", "４", "５", "６", "７", "８", "９"}
    return (tostring(num):gsub("%d", function(digit)
        return fullwidthDigits[tonumber(digit) + 1]
    end))
end

-- Update the `formatTimerTitle` function to use fullwidth digits
local function formatTimerTitle(mode, minutes, seconds)
    local time = toFullwidth(string.format("%2d:%02d", minutes, seconds)) -- Fullwidth time
    return string.format("%s %s", time, getModeIcon(mode))
end

-- Function to update the timer
local function updateTimer()
    if remainingTime <= 0 then
        timer:stop()
        timerRunning = false
        local finishedModeName = getModeName(activeMode)
        local nextModeName = activeMode == TimerMode.Work and getModeName(TimerMode.Break) or getModeName(TimerMode.Work)
        hs.alert.show(finishedModeName .. " timer complete! Next: " .. nextModeName)
        timerMenu:setTitle("Done: " .. finishedModeName .. " ⏰")
        activeMode = nil
        return
    end
    local minutes = math.floor(remainingTime / 60)
    local seconds = remainingTime % 60
    timerMenu:setTitle(formatTimerTitle(activeMode, minutes, seconds))
    remainingTime = remainingTime - 1
end

-- Function to start the timer
---@param mode TimerMode
local function startTimer(mode)
    if timerRunning then
        hs.alert.show("Timer already running!")
        return
    end

    -- Set duration based on the mode
    local duration
    if mode == TimerMode.Work then
        duration = 25 * 60 -- 25 minutes for Work mode
    elseif mode == TimerMode.Break then
        duration = 5 * 60 -- 5 minutes for Break mode
    else
        hs.alert.show("Invalid Timer Mode!")
        return
    end

    timerRunning = true
    activeMode = mode
    remainingTime = duration
    timerMenu:setTitle("Starting " .. getModeName(mode) .. " " .. getModeIcon(mode))
    timer = hs.timer.doEvery(1, updateTimer)
end

-- Function to stop the timer
local function stopTimer()
    if timer then
        timer:stop()
    end
    timerRunning = false
    activeMode = nil
    remainingTime = 0
    timerMenu:setTitle("⏰")
end

-- Add options to the menubar
timerMenu:setTitle("⏰")
timerMenu:setMenu({
    { title = "Work\t🤖", fn = function() startTimer(TimerMode.Work) end },
    { title = "Break\t☕", fn = function() startTimer(TimerMode.Break) end },
    { title = "Cancel", fn = function() stopTimer() end },
})

-- Helper functions
local function startWork() startTimer(TimerMode.Work) end
local function startBreak() startTimer(TimerMode.Break) end

-- Expose only the start and stop timer functions
return {
    startWork = startWork,
    startBreak = startBreak,
    stopTimer = stopTimer,
}
