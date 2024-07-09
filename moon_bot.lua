local sampev = require "lib.samp.events"
local inicfg = require 'inicfg'
local ffi = require 'ffi'
local mb = require('MoonBot')

local bot

local alogin = false
local alogin_level = 0

local repeat_ = false
local prolet = false
local prolet_type = -1
local prolet_timer = 0

local first_spawn = false

local mapmarker_timer = 0

local teleport_timer = 0
local teleport_type = -1

local spectate = false
local spectate_player = -1
local spectate_timer = 0

local last_dialog_id = 0

local timer_for_send_click = 0

local Fractions = {
    [0] = 12,
    [1] = 13,
    [2] = 15,
    [3] = 17,
    [4] = 18,
    [5] = 5,
    [6] = 14,
    [7] = 6,
    [8] = 24,
    [9] = 26,
    [10] = 29,
    [11] = 11,
    [12] = 0
}

local bot_x, bot_y, bot_z = 0
local interior = 0

local last_rank = 0
local last_fraction_id = 0
local id_dialog_prolet = 65301

local iniFile = thisScript().name:gsub('.lua', '')..'.ini'
local ini = inicfg.load({
	cfg = {
		bot_nickname = "Scandalque_Empty",
		bot_password = "",
		bot_admin_password = "",
        bot_auto_reconnect = true,
        bot_log_chat = true,
        bot_debug = false,
        bot_mapmarker_tp = true
	}
}, iniFile)

ffi.cdef [[
    unsigned long GetTickCount();
]]

if not doesDirectoryExist(getWorkingDirectory().."\\config") then createDirectory(getWorkingDirectory().."\\config") end
inicfg.save(ini, iniFile)

function main() 
    if not isSampfuncsLoaded() or not isSampLoaded() then return end 
    while not isSampAvailable() do wait(100) end

    chat_message('Скрипт готов к работе. Команда: {FFDEAD}/a.info{ffffff}')

    bot = mb.add(ini.cfg.bot_nickname)
    if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s{ffffff}: Бот автоматически добавлен', bot.name)) end

	sampRegisterChatCommand('a.join', function()
        if bot.connected then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Бот уже подключен. Используйте {FFDEAD}/a.leave', bot.name, bot.playerID))
            return
        end
        bot:connect()
        chat_message(string.format('{FFDEAD}%s{ffffff}: Пытается присоединиться к серверу', bot.name))
    end)

	sampRegisterChatCommand('a.info', function()
        sampShowDialog(0, "{FFDEAD}A-BOT {ffffff}| Информация",string.format('\
        {ffffff}Все команды админ бота:\
        \
        {FFDEAD}/a.info\t\t{ffffff}Список команд и информация\
        {FFDEAD}/a.join\t\t{ffffff}Подключить бота к серверу\
        {FFDEAD}/a.autorec\t\t{ffffff}Включить/выключить авто-переподключение\
        {FFDEAD}/a.mapmarker\t{ffffff}Включить/выключить телепорт игрока по метке\
        {FFDEAD}/a.log\t\t{ffffff}Включить/выключить логирование чата\
        {FFDEAD}/a.debug\t\t{ffffff}Включить/выключить Debug мод\
        {FFDEAD}/a.leave\t\t{ffffff}Отключить бота с сервера\
        {FFDEAD}/a.send\t\t{ffffff}Отправить команду от имени бота\
        {FFDEAD}/a.repeat\t\t{ffffff}Включить/выключить повторение за игроком\
        {FFDEAD}/a.follow\t\t{ffffff}Включить/выключить следование за игроком\
        {FFDEAD}/a.prolet\t\t{ffffff}Принять себя в банду\
        {FFDEAD}/a.gotome\t\t{ffffff}Телепортировать бота к себе\
        {FFDEAD}/a.gethereme\t{ffffff}Телепортировать себя к боту\
        {FFDEAD}/a.reme\t\t{ffffff}Начать слежку за собой\
        {FFDEAD}/a.reoff\t\t{ffffff}Выключить слежку\
        {FFDEAD}/a.gun\t\t{ffffff}Выдать себе оружие\
        {FFDEAD}/a.spme\t\t{ffffff}Заспавнить себя (3+лвл админки)\
        {FFDEAD}/a.spawn\t\t{ffffff}Заспавнить бота (-2 и 5 лвл админки)\
        {FFDEAD}/a.tp\t\t{ffffff}Телепортация по /tp\
        {FFDEAD}/a.admins\t\t{ffffff}Список админов\
        \
        Конфиг:\
        \
        {FFDEAD}Авто-переподключение к серверу\t%s\
        {FFDEAD}Логирование чата в консоль\t\t%s\
        {FFDEAD}Телепорт по метке\t\t\t%s\
        {FFDEAD}Debug мод\t\t\t\t%s\
        {FFDEAD}Никнейм\t\t\t\t\t{ffffff}%s\
        \
        {FFDEAD}author: scq (идея - kichiro)',
        ini.cfg.bot_auto_reconnect and '{84e66a}включено' or '{ea9a8c}выключено',
        ini.cfg.bot_log_chat and '{84e66a}включено' or '{ea9a8c}выключено',
        ini.cfg.mapmarker and '{84e66a}включено' or '{ea9a8c}выключено',
        ini.cfg.bot_debug and '{84e66a}включено' or '{ea9a8c}выключено',
        ini.cfg.bot_nickname),
        "Закрыть",
        "",
        DIALOG_STYLE_MSGBOX)
    end)

	sampRegisterChatCommand('a.autorec', function()
        ini.cfg.bot_auto_reconnect = not ini.cfg.bot_auto_reconnect
        inicfg.save(ini, iniFile)
        chat_message(string.format('{FFDEAD}%s{ffffff}: Авто-переподключение к серверу %s', bot.name, ini.cfg.bot_auto_reconnect and '{84e66a}включено' or '{ea9a8c}выключено'))
    end)

    sampRegisterChatCommand('a.log', function()
        ini.cfg.bot_log_chat = not ini.cfg.bot_log_chat
        inicfg.save(ini, iniFile)
        chat_message(string.format('{FFDEAD}%s{ffffff}: Логирование чата в {afafaf}SAMPFUNCS консоль %s', bot.name, ini.cfg.bot_log_chat and '{84e66a}включено' or '{ea9a8c}выключено'))
    end)

    sampRegisterChatCommand('a.mapmarker', function()
        ini.cfg.mapmarker = not ini.cfg.mapmarker
        inicfg.save(ini, iniFile)
        chat_message(string.format('{FFDEAD}%s{ffffff}: Телепорт по метке %s', bot.name, ini.cfg.mapmarker and '{84e66a}включен' or '{ea9a8c}выключен'))
    end)

    sampRegisterChatCommand('a.debug', function()
        ini.cfg.bot_debug = not ini.cfg.bot_debug
        inicfg.save(ini, iniFile)
        chat_message(string.format('{FFDEAD}%s{ffffff}: Debug мод %s', bot.name, ini.cfg.bot_debug and '{84e66a}включен' or '{ea9a8c}выключен'))
    end)

	sampRegisterChatCommand('a.leave', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        bot:disconnect()

        chat_message(string.format('{FFDEAD}%s{ffffff}: Бот отключен от сервера', bot.name))
    end)

	sampRegisterChatCommand('a.send', function(arg)
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        if arg == nil or not arg or #arg == 0 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Используйте: /a.send [команда (без /)]', bot.name, bot.playerID))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Отправляю команду /%s', bot.name, bot.playerID, arg))
        bot:sendCommand('/'..arg)
    end)

	sampRegisterChatCommand('a.repeat', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        repeat_ = not repeat_

        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Повтор сообщений %s', bot.name, bot.playerID, repeat_ and '{84e66a}включен' or '{ea9a8c}выключен'))
    end)

	sampRegisterChatCommand('a.follow', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        follow = not follow
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Следование за игроком %s', bot.name, bot.playerID, follow and '{84e66a}включено' or '{ea9a8c}выключено'))
    end)

	sampRegisterChatCommand('a.prolet', function(arg)
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        local rank = arg:match("(%d+)")

        if rank == nil or not tonumber(rank) or tonumber(rank) < 1 or tonumber(rank) > 9 then
            chat_message(string.format('Подсказка: Вы можете использовать /a.prolet [ранг] для выбора нужного ранга'))
            rank = 1
        end
        
        last_rank = tonumber(rank)

        sampShowDialog(id_dialog_prolet, "{FFDEAD}A-BOT {FFFFFF}| Выбор фракции", "{ffffff}Фракция\t\t{ffffff}ID\n{B313E7}Ballas\t\t12\n{DBD604}Vagos\t\t13\n{009F00}Grove\t\t15\n{01FCFF}Aztecas\t\t17\n{2A9170}Rifa\t\t18\n{FFA701}LCN\t\t5\n{B4B5B7}Russian Mafia\t\t14\n{FF0000}Yakuza\t\t6\n{333333}Mongols MC\t\t24\n{F45000}Warlocks MC\t\t26\n{2C9197}Pagans MC\t\t29\n{139BEC}Инструкторы\t\t11\n{ffffff}Уволиться", "Выбрать", "Отмена", DIALOG_STYLE_TABLIST_HEADERS)
    end)

	sampRegisterChatCommand('a.setnick', function(arg)
        local nick = arg:match("(%S+)")

        if nick == nil or #nick == 0 then
            chat_message(string.format('Используйте: {ffDEAD}/a.setnick [ник]'))
            return
        end
        chat_message(string.format('Новый ник: {ffdead}'..nick))
        ini.cfg.bot_nickname = nick
        inicfg.save(ini, iniFile)
        thisScript():reload()
    end)

	sampRegisterChatCommand('a.gotome', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Отправляю команду на телепорт', bot.name, bot.playerID))
        bot:sendCommand('/goto '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    end)

	sampRegisterChatCommand('a.gethereme', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Отправляю команду на телепорт к себе', bot.name, bot.playerID))
        bot:sendCommand('/gethere '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    end)

	sampRegisterChatCommand('a.reme', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Отправляю команду на слежку', bot.name, bot.playerID))
        bot:sendCommand('/re '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    end)

	sampRegisterChatCommand('a.reoff', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Выхожу из слежки', bot.name, bot.playerID))
        bot:sendCommand('/re off')
        
    end)

	sampRegisterChatCommand('a.gun', function(arg)
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end

        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        local gun, ammo = arg:match("(%d+) (%d+)")

        if gun == nil or ammo == nil or not tonumber(gun) or not tonumber(ammo) or tonumber(ammo) < 1 or tonumber(ammo) > 500 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Используйте: /a.gun [оружие] [патроны (1-500)]', bot.name, bot.playerID))
            return
        end
        bot:sendCommand('/ygivegun '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))..' '..tonumber(gun)..' '..tonumber(ammo))
    end)

	sampRegisterChatCommand('a.admins', function(arg)
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        bot:sendCommand('/admins')
    end)

	sampRegisterChatCommand('a.spme', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end

        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        bot:sendCommand('/pspawn '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
    end)

	sampRegisterChatCommand('a.spawn', function()
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end

        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Отправляю команду спавна', bot.name, bot.playerID))
        bot:sendCommand('/spawn')
    end)
	sampRegisterChatCommand('a.tp', function(arg)
        if not bot.connected then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не подключен. Используйте {FFDEAD}/a.join', bot.name))
            return
        end

        if not alogin then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Бот не залогинен в админку', bot.name))
            return
        end
        if not first_spawn then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Пожалуйста, подождите!', bot.name))
            return
        end
        local id = arg:match("(%d+)")

        if (id == nil or not #arg) and alogin_level ~= -2 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Отправляю команду телепорта', bot.name, bot.playerID))
            bot:sendCommand('/tp '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff} Вы также можете использовать {FFDEAD}/a.tp [id] {FFFFFF}для телепорта игроков', bot.name, bot.playerID))
        elseif alogin_level ~= -2 then
            bot:sendCommand('/tp '..id)
        else
            bot:sendCommand('/tp')
        end
    end)

    while true do
        if teleport_timer ~= 0 and ffi.C.GetTickCount() > teleport_timer and alogin_level == -2 then
            if teleport_type == 1 then bot:sendCommand('/gethere '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
            elseif teleport_type == 2 then bot:sendCommand('/spawn '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) end
            teleport_timer = ffi.C.GetTickCount() + 1000
        end

        if mapmarker_timer ~= 0 and ffi.C.GetTickCount() > mapmarker_timer and ini.cfg.mapmarker then
            bot:sendCommand('/gethere '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
            mapmarker_timer = ffi.C.GetTickCount() + 1000
        end

        if spectate and ffi.C.GetTickCount() > spectate_timer and spectate_player ~= -1 and not prolet then
            bot:sendCommand('/re '..spectate_player)
            bot:sendClickTextdraw(2176)
            spectate_timer = ffi.C.GetTickCount() + 5000
        end

        if prolet_timer ~= 0 and prolet_timer < ffi.C.GetTickCount() then
            if prolet_type == -1 then
                prolet_timer = 0
                prolet_type = -1
                prolet = false
            end
            if prolet_type == 0 then
                bot:sendCommand('/re '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                bot:sendClickTextdraw(2176)
            elseif prolet_type == 1 then
                bot:sendCommand('/ainvite '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))..' '..last_fraction_id..' '..last_rank)
            elseif prolet_type == 2 then
                bot:sendCommand('/re off')
            end
            prolet_timer = ffi.C.GetTickCount() + 1500
        end

        if timer_for_send_click ~= 0 and timer_for_send_click < ffi.C.GetTickCount() then
            if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Пытаюсь кликнуть на спавн ДНК', bot.name, bot.playerID)) end
            bot:sendClickTextdraw(216)
            timer_for_send_click = ffi.C.GetTickCount() + 1000
        end

        if alogin and not follow then
            local sync = mb.getPlayerData()
            sync.position.x = bot_x
            sync.position.y = bot_y
            sync.position.z = bot_z
            bot:sendPlayerData(sync)
        end
        if alogin and spectate and spectate_player == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) and not follow then
            local sx, sy, sz = getCharCoordinates(PLAYER_PED)

            local sync = mb.getSpectatorData()
            sync.position.x = sx
            sync.position.y = sy
            sync.position.z = sz
            bot:sendSpectatorData(sync)
        end
        local result, button, list, input = sampHasDialogRespond(id_dialog_prolet)
		if result then
			if button == 1 then
				if Fractions[list] == 0 then
                    bot:sendCommand('/auninvite '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))..' sj')
                end
                prolet = true
                if not spectate then prolet_type = 0
                else prolet_type = 1 end
                prolet_timer = ffi.C.GetTickCount() + 1000
                last_fraction_id = Fractions[list]
                bot:sendCommand('/re '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
                
            end
        end
        result, button, list, input = sampHasDialogRespond(65513)
		if result then
            if teleport_type == 0 then
                if button == 1 then
                    teleport_type = 1
                    teleport_timer = ffi.C.GetTickCount() + 1000
                else
                    teleport_type = -1
                    teleport_timer = 0
                end
            end
			bot:sendDialogResponse(last_dialog_id, button, list, input)
        end
        wait(0)
    end
    wait(-1)
end
function chat_message(text)
    sampAddChatMessage('[A-BOT] {ffffff}'..text, 0xFFDEAD)
end

function sampev.onSendChat(message)
    if repeat_ then
        bot:sendChat(message)
    end
end

function sampev.onSendMapMarker(position)
    if ini.cfg.mapmarker then bot_send_click_map(position.x, position.y, getGroundZFor3dCoord(position.x, position.y, position.z)) end
end

function onBotPacket(bot, packetId, bs) 
    if packetId == 31 then
        chat_message(string.format('{FFDEAD}%s{ffffff}: Не смог подключиться к серверу: нет свободных слотов', bot.name))
        obnal()
        if ini.cfg.bot_auto_reconnect then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Произвожу переподключение', bot.name))
            bot:connect()
        end
    end
    if packetId == 32 then
        chat_message(string.format('{FFDEAD}%s{ffffff}: Соединение с сервером было разорвано', bot.name))
        obnal()
        if ini.cfg.bot_auto_reconnect then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Произвожу переподключение', bot.name))
            bot:connect()
        end
    end
    if packetId == 33 then
        chat_message(string.format('{FFDEAD}%s{ffffff}: Соединение с сервером было утеряно', bot.name))
        obnal()
        if ini.cfg.bot_auto_reconnect then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Произвожу переподключение', bot.name))
            bot:connect()
        end
    end
    if packetId == 36 then
        chat_message(string.format('{FFDEAD}%s{ffffff}: Не смог подключиться к серверу: меня заблокировало', bot.name))
        obnal()
        if ini.cfg.bot_auto_reconnect then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Произвожу переподключение', bot.name))
            bot:connect()
        end
    end
    if packetId == 37 then
        chat_message(string.format('{FFDEAD}%s{ffffff}: Не смог подключиться к серверу: пароль неверный', bot.name))
        obnal()
        if ini.cfg.bot_auto_reconnect then
            chat_message(string.format('{FFDEAD}%s{ffffff}: Произвожу переподключение', bot.name))
            bot:connect()
        end
    end
    if packetId == 34 then
        if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s{ffffff}: Сервер подключил меня', bot.name)) end
        obnal()
    end
end

function onBotRPC(bot, rpcId, bs)
    if rpcId == 12 then
        bs:resetReadPointer()
        local spp_x = bs:readFloat()
        local spp_y = bs:readFloat()
        local spp_z = bs:readFloat()
        bot_x = spp_x
        bot_y = spp_y
        bot_z = spp_z
    end
    if rpcId == 52 then
        if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: SendSpawn', bot.name, bot.playerID)) end
    end
    if rpcId == 61 then
        bs:resetReadPointer()
        local dialog_id = bs:readInt16()
        local dialog_style = bs:readInt8()
        local title = bs:readString8()
        local button1 = bs:readString8()
        local button2 = bs:readString8()
        local text = bs:decodeString(4096)

        print(dialog_id)
        print(dialog_style)
        print(#title)

        print(#text)

        if alogin_level == -2 then
            if title:find('TP%-Menu') then
                teleport_type = 0
            else
                teleport_type = -1
                teleport_timer = 0
            end
        end

        if title:find('Авторизация') then
            if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Бот проходит авторизацию', bot.name, bot.playerID)) end
            bot:sendDialogResponse(dialog_id, 1, 0, ini.cfg.bot_password)
        elseif title:find('Админ%-авторизация') then
            bot:sendDialogResponse(dialog_id, 1, 0, ini.cfg.bot_admin_password)
        else
            if dialog_id < 0 then bot:sendDialogResponse(dialog_id, 0, 0, '') end
            last_dialog_id = dialog_id
            sampShowDialog(65513, '{FFDEAD}A-BOT: '..title, text, button1, button2, dialog_style)
        end
    end
    if rpcId == 93 then
        bs:resetReadPointer()
        local color = bs:readInt32()
        local message = bs:readString32()
        if ini.cfg.bot_log_chat then
            print(message)
        end
        if message:find('Вы авторизировались как администратор') and color == -189267798 then
            alogin_level = tonumber(message:match("Вы авторизировались как администратор (%S+) уровня"))
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: авторизовался в админку', bot.name, bot.playerID))
            alogin = true
            bot:sendRequestClass(0)
        end

        if message:find('Не флуди!') and color == -2770006 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Не флуди!', bot.name, bot.playerID))
            if prolet then prolet_timer = ffi.C.GetTickCount() + 1000 end
        end


        if message:find('Админы Online:') or message:find('%w+_%w+ %| ID%: %d+ %| Level%: %d') then
            sampAddChatMessage(message, tonumber(color,16))
        end

        if message:find('Вы были телепортированы') and color == -1 then
            if teleport_type == 0 then
                teleport_type = 1
                teleport_timer = ffi.C.GetTickCount() + 1200
            end
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Я телепортировался через /tp', bot.name, bot.playerID))
        end

        if message:find('Вы были телепортированы') and color == -86 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Я телепортировался', bot.name, bot.playerID))
        end

        if message:find('Ответ от') and color == -646512470 then
            showGameText("~w~~h~Check ~r~~h~PM", 1000, 1)
            if not ini.cfg.bot_log_chat then
                print(message)
            end
        end

        if message:find('выдано игроку (%S+)') and color == -86 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Выдал оружие', bot.name, bot.playerID))
        end

        if message:find('SMS') and color == -65366 then
            showGameText("~w~~h~Check ~y~~h~SMS", 1000, 1)
            if not ini.cfg.bot_log_chat then
                print(message)
            end
        end
        if message:find('Игрок слишком далеко!') and color == -1263159297 then
            if prolet then
                prolet_type = 0
                prolet_timer = ffi.C.GetTickCount() + 1000
            end
        end
        if message:find('Игрок состоит в организации!') and color == -1347440726 then
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Игрок состоит в организации', bot.name, bot.playerID))
            if prolet then
                chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Увольтесь через /prolet или /uval', bot.name, bot.playerID))
                prolet_timer = 0
                prolet_type = -1
                prolet = false
            end
        end

        if message:find('Вы предложили (%S+)[(%d+)] вступить в') and color == 1182971050 then
            if prolet then
                prolet_type = 2
                prolet_timer = ffi.C.GetTickCount() + 7000
            end
        end

    end
    if rpcId == 139 then
        if ini.cfg.bot_debug then  chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Бот подключился к серверу (InitGame)', bot.name, bot.playerID)) end
        bot:sendRequestClass(0)
    end

    if rpcId == 68 then
        last_dialog_id = 0
        bot:sendRequestSpawn()
        bot:sendSpawn()
        if teleport_type == 2 then
            teleport_type = -1
            teleport_timer = 0
        end
        if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Спавн', bot.name, bot.playerID)) end
     end
    if rpcId == 126 then
        bs:resetReadPointer()
        local player_id = bs:readInt16()
        local spec_cam_type = bs:readInt8()
        if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Начинаю слежку за игроком %s[%d] (%d)', bot.name, bot.playerID, sampGetPlayerNickname(player_id), player_id, spec_cam_type)) end
        spectate = true
        spectate_player = player_id
        spectate_timer = ffi.C.GetTickCount() + 5000
        if prolet and prolet_type == 0 then
            prolet_type = 1
        end
    end
    if rpcId == 127 then
        bs:resetReadPointer()
        local veh_id = bs:readInt16()
        local spec_cam_type = bs:readInt8()
        if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Начинаю слежку за транспортом %d (%d)', bot.name, bot.playerID, veh_id, spec_cam_type)) end
    end

    if rpcId == 124 then
        bs:resetReadPointer()
        local spectating = bs:readInt32()

        spectate = toboolean(spectating)
        if not spectate then
            spectate = false
            spectate_player = -1
            spectate_timer = 0

            if prolet_type == 2 then
                prolet_timer = 0
                prolet_type = -1
                prolet = false
            end
        end

        if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Слежка %s', bot.name, bot.playerID, toboolean(spectating) and '{84e66a}включена' or '{ea9a8c}выключена')) end
    end


    if rpcId == 134 then
        bs:resetReadPointer()
        local textdraw_id = bs:readInt16()
        local flags = bs:readInt8()
        local width = bs:readFloat()
        local height = bs:readFloat()
        local lcolor = bs:readInt32()
        local lwidth = bs:readFloat()
        local lheight = bs:readFloat()
        local box_color = bs:readInt32()
        local shadow = bs:readInt8()
        local outline = bs:readInt8()
        local back_color = bs:readInt32()
        local style = bs:readInt8()
        local selectable = bs:readInt8()
        local x = bs:readFloat()
        local y = bs:readFloat()
        local model_id = bs:readInt16()
        local rotx = bs:readFloat()
        local roty = bs:readFloat()
        local rotz = bs:readFloat()
        local fzoom = bs:readFloat()
        local c1 = bs:readInt16()
        local c2 = bs:readInt16()
        local text = bs:readString16()
        if text:find('~w~Welcome') then
            timer_for_send_click = 0
            chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Я заспавнился', bot.name, bot.playerID))
            first_spawn = true
        end
        if text:find('SPAWN_SELECTION_') then
           if ini.cfg.bot_debug then chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Появился выбор спавна', bot.name, bot.playerID)) end
           timer_for_send_click = ffi.C.GetTickCount() + 500 
           bot:sendCommand('/alogin')
        end
    end
end

function sampev.onSendPlayerSync(data)
    if alogin and follow then
        local offset = 0
        offset = offset + 1
        local angle = getCharHeading(PLAYER_PED) - 90
        local sync = mb.getPlayerData()
        sync.leftRightKeys = data.leftRightKeys
        sync.upDownKeys = data.upDownKeys
        sync.keysData = data.keysData
        sync.position.x, sync.position.y, sync.position.z = data.position.x + (math.sin(-math.rad(angle)) * offset), data.position.y + (math.cos(-math.rad(angle)) * offset), data.position.z
        sync.moveSpeed.x, sync.moveSpeed.y, sync.moveSpeed.z = data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z
        sync.quaternion.w, sync.quaternion.x, sync.quaternion.y, sync.quaternion.z = data.quaternion[0], data.quaternion[1], data.quaternion[2], data.quaternion[3]
        sync.health = data.health
        sync.armor = data.armor
        sync.weapon = data.weapon
        sync.specialAction = data.specialAction
        sync.surfingOffsets.x, sync.surfingOffsets.y, sync.surfingOffsets.z = data.surfingOffsets.x, data.surfingOffsets.y, data.surfingOffsets.z
        sync.surfingVehicleId = data.surfingVehicleId
        sync.animationId = data.animationId
        sync.animationFlags = data.animationFlags
        bot:sendPlayerData(sync)
    end
end

function showGameText(text, time, style)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt32(bs, style)
    raknetBitStreamWriteInt32(bs, time)
    raknetBitStreamWriteInt32(bs, #text)
    raknetBitStreamWriteString(bs, text)
    raknetEmulRpcReceiveBitStream(73, bs)
end

function sampev.onServerMessage(color, text)
    if text:find('Вас телепортировал к себе администратор Evolve%-Rp') and color == -86 then
        if mapmarker_timer ~= 0 then
            mapmarker_timer = 0
        end
        if teleport_type == 1 then
            teleport_timer = ffi.C.GetTickCount() + 1000
            teleport_type = 2
        end
    end
end

function onScriptTerminate(s, quitGame)
    if s == thisScript() then inicfg.save(ini, iniFile) end
end

function toboolean(s)
    if s == true then return(true) elseif s == false then return(false) end
    if s == 1 then s = tostring(s) end -- true
    if s == 0 then s = tostring(s) end -- false
    if s:lower():find("true") then return(true) elseif s:lower():find("false") then return(false) elseif tonumber(s) == 1 then return(true) elseif tonumber(s) == 0 then return(false) else error("couldnt find boolean") return("Could not find bool.") end
end

function bot_send_click_map(x, y, z)
    if ini.cfg.bot_mapmarker_tp and bot.connected and first_spawn and alogin then
        local bot_bs = mb.getBitStream()
        bot_bs:resetWritePointer()
        bot_bs:writeFloat(x)
        bot_bs:writeFloat(y)
        bot_bs:writeFloat(z)
        bot:sendRPC(119, bot_bs)
        bot_bs:remove()
        chat_message(string.format('{FFDEAD}%s[%d]{ffffff}: Телепортируюсь по метке (%f %f %f)', bot.name, bot.playerID, x, y, z))
        mapmarker_timer = ffi.C.GetTickCount() + 1000
    end
end

function obnal()
    alogin = false
    alogin_level = 0
    first_spawn = false
    
    repeat_ = false
    prolet = false
    prolet_type = -1
    prolet_timer = 0
    
    mapmarker_timer = 0
    
    teleport_timer = 0
    teleport_type = -1
    
    spectate = false
    spectate_player = -1
    spectate_timer = 0
    
    last_dialog_id = 0
    
    timer_for_send_click = 0
    
    bot_x, bot_y, bot_z = 0
    interior = 0
    
    last_rank = 0
    last_fraction_id = 0
end