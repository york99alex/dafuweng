--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------
local setmetatable = setmetatable
local CoUpdateBeat = CoUpdateBeat

local function GetGameTime()
    return GameRules:GetGameTime()
end

--给协同使用的帧计数timer
FrameTimer = {
    count = 1,
    duration = 1,
    loop = 1,
    func = nil,
    running = false
}

local FrameTimer = FrameTimer
local mt2 = {}
mt2.__index = FrameTimer

function FrameTimer.New(func, count, loop)
    local timer = {}
    setmetatable(timer, mt2)
    timer.frameCount = 0
    timer.count = timer.frameCount + count
    timer.duration = count
    timer.loop = loop
    timer.func = func
    return timer
end

function FrameTimer:Start()
    self.running = true
    CoUpdateBeat:Add(self.Update, self)
end

function FrameTimer:Stop()
    self.running = false
    CoUpdateBeat:Remove(self.Update, self)
end

function FrameTimer:Update()
    self.frameCount = self.frameCount + 1
    if not self.running then
        return
    end

    if self.frameCount >= self.count then
        self.func()

        if self.loop > 0 then
            self.loop = self.loop - 1
        end

        if self.loop == 0 then
            self:Stop()
        else
            self.count = self.frameCount + self.duration
        end
    end
end

CoTimer = {
    time = 0,
    duration = 1,
    loop = 1,
    running = false,
    func = nil
}

local CoTimer = CoTimer
local mt3 = {}
mt3.__index = CoTimer

function CoTimer.New(func, duration, loop)
    local timer = {}
    setmetatable(timer, mt3)
    timer.frameCount = 0
    timer:Reset(func, duration, loop)
    return timer
end

function CoTimer:Start()
    self.running = true
    self.count = self.frameCount + 1
    CoUpdateBeat:Add(self.Update, self)
end

function CoTimer:Reset(func, duration, loop)
    self.duration = duration
    self.loop = loop or 1
    self.func = func
    self.time = duration + GetGameTime()
    self.running = false
    self.count = self.frameCount + 1
end

function CoTimer:Stop()
    self.running = false
    CoUpdateBeat:Remove(self.Update, self)
end

function CoTimer:Update()
    self.frameCount = self.frameCount + 1
    if not self.running then
        return
    end

    if self.time <= GetGameTime() and self.frameCount > self.count then
        self.func()

        if self.loop > 0 then
            self.loop = self.loop - 1
            self.time = GetGameTime() + self.duration
        end

        if self.loop == 0 then
            self:Stop()
        elseif self.loop < 0 then
            self.time = GetGameTime() + self.duration
        end
    end
end