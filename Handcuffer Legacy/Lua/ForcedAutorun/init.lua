if CLIENT then
    Handcuffer = {}
    Handcuffer.Path = table.pack(...)[1]

    dofile(Handcuffer.Path .. "/Lua/Scripts/cuff.lua")

    if not File.Exists(Handcuffer.Path .. "/config.json") then
        File.Write(Handcuffer.Path .. "/config.json", json.serialize(dofile(Handcuffer.Path .. "/Lua/defaultconfig.lua")))
    end

    Handcuffer.Config = json.parse(File.Read(Handcuffer.Path .. "/config.json"))

    -- "Resets" settings
    Game.AddCommand("hcreset", "Restores the config", function()
        File.Write(Handcuffer.Path .. "/config.json", json.serialize(dofile(Handcuffer.Path .. "/Lua/defaultconfig.lua")))
        Handcuffer.Key = Keys.F
    end)


    -- All keys list: https://docs.monogame.net/api/Microsoft.Xna.Framework.Input.Keys.html
    -- I'M NOT PSYCHO. I'M NOT PSYCHO.
    Handcuffer.Keybinds = {
        ["A"] = Keys.A,
        ["B"] = Keys.B,
        ["C"] = Keys.C,
        ["D"] = Keys.D,
        ["E"] = Keys.E,
        ["F"] = Keys.F,
        ["G"] = Keys.G,
        ["H"] = Keys.H,
        ["I"] = Keys.I,
        ["J"] = Keys.J,
        ["K"] = Keys.K,
        ["L"] = Keys.L,
        ["M"] = Keys.M,
        ["N"] = Keys.N,
        ["O"] = Keys.O,
        ["P"] = Keys.P,
        ["Q"] = Keys.Q,
        ["R"] = Keys.R,
        ["S"] = Keys.S,
        ["T"] = Keys.T,
        ["U"] = Keys.U,
        ["V"] = Keys.V,
        ["W"] = Keys.W,
        ["X"] = Keys.X,
        ["Y"] = Keys.Y,
        ["Z"] = Keys.Z,
        ["F1"] = Keys.F1,
        ["F2"] = Keys.F2,
        ["F3"] = Keys.F3,
        ["F4"] = Keys.F4,
        ["F5"] = Keys.F5,
        ["F6"] = Keys.F6,
        ["LEFTALT"] = Keys.LeftAlt,
        ["TILDE"] = Keys.OemTilde,
        ["`"] = Keys.OemTilde,
        ["SPACE"] = Keys.Space,
        ["LEFTSHIFT"] = Keys.LeftShift,
        ["TAB"] = Keys.Tab,
        ["CAPSLOCK"] = Keys.CapsLock,
    }

    -- Current key as userdata type
    print(Handcuffer.Config.USERKEY)
    Handcuffer.Key = Handcuffer.Keybinds[Handcuffer.Config.USERKEY]

    Game.AddCommand("hcrebind", "Rebinds handcuff key", function(keyargs)
        if not keyargs[1] then
            print("Send a key as an argument")
            return nil
        end
        -- Makes comparison easier
        local userKey = keyargs[1]:upper()
        if not Handcuffer.Keybinds[userKey] then
            return print("Key does not exist.\nAll possibles keys are: tinyurl.com/examplekeybinds")
        end
        Handcuffer.Key = Handcuffer.Keybinds[userKey]
        Handcuffer.Config.USERKEY = userKey
        File.Write(Handcuffer.Path .. "/config.json", json.serialize(Handcuffer.Config))

        print("Rebinded to " .. userKey .. " key")
    end)

    Timer.Wait(function()
        local runstring = "\n/// Running Handcuffer version: " .. Handcuffer.Config.VERSION .. " ///\n"

        -- add dashes
        local linelength = string.len(runstring) + 2
        local i = 0
        while i < linelength do
            runstring = runstring .. "-"
            i = i + 1
        end

        print(runstring ..
            "\n- Default handcuff keybind is: F" ..
            "\n- Current handcuff keybind is: " .. Handcuffer.Config.USERKEY
        )
    end, 1000)
end
