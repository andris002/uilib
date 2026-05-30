local int = nil
local theme = nil
local progressv = false
local progactive = false

local notify = function(title, description, time, theme, icon)
    SendNUIMessage({type='notify', title = title, description = description, time = time, theme = theme, icon = icon})
end

local progress = function(title, message, time, icon, theme, anim)
    if progactive then 
        return false
    end

    if anim and anim.animDict then
        RequestAnimDict(anim.animDict)
        while not HasAnimDictLoaded(anim.animDict) do
            Wait(0)
        end
    end

    if anim and anim.name then
        TaskPlayAnim(PlayerPedId(), anim.animDict, anim.name, 8.0, 0, -1, anim.flag or 1, 0, 0, 0, 0)
    end

    SendNUIMessage({type='progress', title = title, message = message, time = time, theme = theme, icon = icon})
    progactive = true
    progressv = false

    while true do 
        Wait(500)
        if progressv then 
            progressv = false 
            ClearPedTasksImmediately(PlayerPedId()) 
            progactive = false 
            break 
        end
    end

    return true
end

local interaction = function(data, theme)
    SendNUIMessage({type='interaction', data = data, theme = theme})
    SetNuiFocus(true, false)
    while true do 
        Wait(500)
        if int then break end
    end

    return int
end

local settings = function()
    SendNUIMessage({type='settings'})
end

exports('getColor', function()
    return theme
end)

-- interaction({ {id = 'shop', title = 'Shop', button = 'a'}, {id = 'illegal', title = 'Illegal shop', button = 'r'} })

exports('interaction', interaction) 

-- progress(title, message, time, icon, theme)

exports('progress', progress) 

-- notify(title, description, time, theme, icon)

exports('notify', notify)

RegisterNetEvent('nn_uipack:notify')
AddEventHandler('nn_uipack:notify', function(title, description, time, theme, icon)
    notify(title, description, time, theme, icon)
end)

RegisterNUICallback('interaction', function(data, cb)
    int = data
    SetNuiFocus(false, false)
    int = nil
    cb('ok')
end)

RegisterNUICallback('newcolor', function(data, cb)
    theme = data
    TriggerEvent('nn_uipack:colorChanged', data)
    cb('ok')
end)

RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('progress', function(_, cb)
    progressv = true
    cb('ok')
end)

RegisterCommand('+settings', function()
    settings()
    SetNuiFocus(true, true)
end)

RegisterKeyMapping('+settings', 'Open Ui lib settings', 'keyboard', 'F6')

--[[
RegisterCommand('+prog', function()
    local success = exports['noname_uilib']:progress('DrugLab', 'Picking up the drug', 10000, "FlaskConical", nil, 
    {
        name = 'idle_a',
        animDict = 'missarmenian3_gardener',
        flag = 1
    })

    if success then 
        print('The progress has been ended')
    end
end)

RegisterCommand('+int', function()
    local int = exports['noname_uilib']:interaction({
        {id = 'shop', title = 'Shop', button = 'a'},
        {id = 'exit', title = 'Exit', button = 'x'}
    })

    if int then 
        print(int) -- the custom id ('shop' or 'exit')
    end
end)
--]]
