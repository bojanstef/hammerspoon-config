-- Function to load .env file into environment variables
local function loadEnvFile(filepath)
    local envFile = io.open(filepath, "r")
    if not envFile then
        hs.alert.show(".env file not found at " .. filepath)
        return
    end

    for line in envFile:lines() do
        -- Skip lines that are empty or comments
        if line:match("^[^#].*=") then
            local key, value = line:match("^(.-)=(.*)$")
            if key and value then
                -- Trim whitespace from key and value
                key = key:match("^%s*(.-)%s*$")
                value = value:match("^%s*(.-)%s*$")
                -- Set as an environment variable
                os[key] = value
            end
        end
    end

    envFile:close()
end

return {
    loadEnvFile = loadEnvFile,
}
