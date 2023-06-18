
if not Selection then
    ----- 选择器
    Selection = {
        msg = "GM_Selection",
    }
end

function Selection:init()

end

function Selection:NewSelection(nPlayerID, unitArgs)
    local entities = Selection:GetEntIndexListFromTable(unitArgs)
    local data = {
        nPlayerID = nPlayerID,
        type = 'new',
        entities = entities
    }
    self:SendToPlayer(data)
end

function Selection:AddToSelection(nPlayerID, unitArgs)
    local entities = Selection:GetEntIndexListFromTable(unitArgs)
    local data = {
        nPlayerID = nPlayerID,
        type = 'add',
        entities = entities
    }
    self:SendToPlayer(data)
end

function Selection:RemoveFromSelection(nPlayerID, unitArgs)
    local entities = Selection:GetEntIndexListFromTable(unitArgs)
    local data = {
        nPlayerID = nPlayerID,
        type = 'remove',
        entities = entities
    }
    self:SendToPlayer(data)
end

function Selection:ResetSelection(nPlayerID)
    local data = {
        nPlayerID = nPlayerID,
        type = 'reset',
        entities = {}
    }
    self:SendToPlayer(data)
end

function Selection:GetEntIndexListFromTable(unitArgs)
    local entities = {}
    if type(unitArgs)=="number" then
        table.insert(entities, unitArgs) ---- Entity Index
    ---- Check contents of the table
    elseif type(unitArgs)=="table" then
        if unitArgs.IsCreature then
            table.insert(entities, unitArgs:GetEntityIndex()) ---- NPC Handle
        else
            for _,arg in pairs(unitArgs) do
                ---- Table of entity index values
                if type(arg)=="number" then
                    table.insert(entities, arg)
                ---- Table of npc handles
                elseif type(arg)=="table" then
                    if arg.IsCreature then
                        table.insert(entities, arg:GetEntityIndex())
                    end
                end
            end
        end
    end
    return entities
end

function Selection:SendToPlayer(data)
    print('7>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
    DeepPrint(data)
    PlayerManager:sendMsg(Selection.msg, data, data.nPlayerID)
end