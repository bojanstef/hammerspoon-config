local dotenv = require("dotenv")
local pomodoro = require("pomodoro")

local envFile = os.getenv("HOME") .. "/.hammerspoon/.env"
dotenv.loadEnvFile(envFile)

-- Function to copy password to clipboard
local function copyPassword()
    -- Function to execute a shell command and return its output
    local function runCommand(cmd)
        print("Executing command: " .. cmd)     -- Logging the command being executed
        local handle = io.popen(cmd .. " 2>&1") -- Capture stderr
        if handle then
            local result = handle:read("*a")
            handle:close()
            print("Command output: " .. tostring(result)) -- Logging the command output
            return result
        else
            print("Failed to open handle for command.") -- Logging failure to execute command
            return nil
        end
    end

    -- Retrieve the password ID from the environment variable
    local passwordID = os.PASSWORD_ID ---@diagnostic disable-line: undefined-field
    if not passwordID then
        hs.alert.show("Environment variable PASSWORD_ID not set!")
        return
    end

    -- Define your 1Password CLI command with full path to 'op'
    local opPath = "/opt/homebrew/bin/op" -- Replace with your actual path from 'which op'
    local opCommand = string.format('%s item get --fields label=password %s --reveal', opPath, passwordID)

    -- Execute the command
    local output = runCommand(opCommand)

    -- If output contains "ERROR"
    if output and output:find("ERROR") then
        -- Notify the user of the error
        hs.alert.show("Failed to retrieve password. Please check your 1Password app.")
    elseif output and output ~= "" then -- Check if the output is not empty
        -- Trim any trailing whitespace or newlines
        local password = output:gsub("%s+$", "")
        -- Type the password into the current focus
        hs.eventtap.keyStrokes(password)
    else
        -- Display an alert indicating failure
        hs.alert.show("Failed to retrieve password.")
    end
end

-- Function to resize the focused window to portrait aspect dimensions (e.g., TikTok)
local function resizeToPortraitAspect()
    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("No focused window")
        return
    end

    -- Define the desired width and height in points
    -- Adjust these values based on your screen resolution if needed
    local desiredWidth = 540  -- Example width (half of 1080 pixels if 1 point = 2 pixels)
    local desiredHeight = 960 -- Example height to maintain 9:16 aspect ratio

    -- Get the screen of the current window
    local screen = win:screen()
    local screenFrame = screen:frame()

    -- Calculate the new window frame centered on the screen
    local newFrame = {
        x = screenFrame.x + (screenFrame.w - desiredWidth) / 2,
        y = screenFrame.y + (screenFrame.h - desiredHeight) / 2,
        w = desiredWidth,
        h = desiredHeight
    }

    -- Apply the new frame to the window
    win:setFrame(newFrame)
end

-- Function to lock the screen
local function lockScreen()
    -- Use Hammerspoon's built-in function to lock the screen
    hs.caffeinate.lockScreen()
    print("Screen locked.") -- Logging screen lock
end

-- Bind functions to hotkeys
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "P", copyPassword)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "V", resizeToPortraitAspect)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "W", pomodoro.startWork)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "B", pomodoro.startBreak)
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "C", pomodoro.stopTimer)
hs.hotkey.bind({ "cmd", "shift" }, "space", lockScreen)

-- Optional: Alert when Hammerspoon configuration is loaded
hs.alert.show("Hammerspoon config loaded")
