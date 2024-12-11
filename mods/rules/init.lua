local players_privileges = {}
local accepted_rules = minetest.get_mod_storage()

-- Function to check if a player has accepted the rules
local function has_accepted_rules(player_name)
    return accepted_rules:get_string(player_name) == "true"
end

-- Function to show the rules form
local function show_rules_form(player_name, lang)
    local message = {
        es = {
            "Bienvenido a 'NOSTALGIA', es un servidor con reglas, y son estas:",
            "No Spamear, No malas palabras, No romper construcciones,",
            "No bloquear los caminos, ni romperlos.",
            "Si esto sucede serás baneado."
        },
        en = {
            "Welcome to 'NOSTALGIA', this is a server with rules, and they are:",
            "No Spamming, No bad words, No destroying buildings,",
            "Do not block or break paths.",
            "If this happens, you will be banned."
        }
    }
    
    local button_label = {
        es = "Aceptar",
        en = "Accept"
    }
    
    local selected_message = message[lang] or message.es
    minetest.show_formspec(player_name, "rules:welcome",
        "size[10,6]" ..
        "label[0.5,0.5;" .. minetest.formspec_escape(selected_message[1]) .. "]" ..
        "label[0.5,1;" .. minetest.formspec_escape(selected_message[2]) .. "]" ..
        "label[0.5,1.5;" .. minetest.formspec_escape(selected_message[3]) .. "]" ..
        "label[0.5,2;" .. minetest.formspec_escape(selected_message[4]) .. "]" ..
        "button_exit[2,5;2,1;accept;" .. minetest.formspec_escape(button_label[lang] or button_label.es) .. "]" ..
        "button_exit[6,5;2,1;english;English]"
    )
end

minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    
    -- Show rules only if the player hasn't accepted them yet
    if not has_accepted_rules(player_name) then
        local lang = minetest.get_player_information(player_name).lang_code or "es"
        minetest.after(2, function()
            show_rules_form(player_name, lang)
        end)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    
    if formname == "rules:welcome" then
        if fields.accept then
            players_privileges[player_name] = true
            accepted_rules:set_string(player_name, "true")
            minetest.chat_send_player(player_name, "¡Gracias por aceptar las reglas! Ahora puedes jugar.")
            minetest.set_player_privs(player_name, {shout=true, interact=true})
        elseif fields.english then
            show_rules_form(player_name, "en")
        end
    end
end)

minetest.register_chatcommand("rules", {
    description = "Muestra las reglas del servidor.",
    func = function(name)
        local lang = minetest.get_player_information(name).lang_code or "es"
        show_rules_form(name, lang)
    end
})
