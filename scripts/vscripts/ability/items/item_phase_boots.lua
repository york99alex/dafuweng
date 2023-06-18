function onItem_phase_boots(keys)
    local nAdd = math.floor(keys.Damage * 0.3)
    keys.caster:SetBaseMoveSpeed(keys.caster:GetBaseMoveSpeed() + nAdd)
    Timers:CreateTimer(3, function()
        if IsValid(keys.caster) then
            keys.caster:SetBaseMoveSpeed(keys.caster:GetBaseMoveSpeed() - nAdd)
        end
    end)
end