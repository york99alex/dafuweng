-----@class CameraManage
if not CameraManage then
    CameraManage = {
        m_tCameraFollow = {}
    }
end
local this = CameraManage

function CameraManage:LookAt(nPlayerID, Pos, Lerp)
    local data = {}
    data.pos = Pos
    data.lerp = Lerp
    print("nPlayerID:", nPlayerID)
    if nPlayerID == -1 then
        this:SendToAllPlayer(data)
    else
        data.nPlayerID = nPlayerID
        this:SendToPlayer(data)
    end
end
function CameraManage:SendToPlayer(data)
    PlayerManager:sendMsg("GM_CameraCtrl", data, data.nPlayerID)
end

function CameraManage:SendToAllPlayer(data)
    PlayerManager:broadcastMsg("GM_CameraCtrl", data)
end