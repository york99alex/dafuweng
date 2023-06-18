local co_pool = {}

function co_create(f)
    local co = table.remove(co_pool)
    if co == nil then
        co = coroutine.create(
        function(...)
            local rt = f(...)
            while true do
                f = nil
                co_pool[#co_pool + 1] = co
                f = coroutine.yield(rt)
                rt = f(coroutine.yield())
            end
        end)
    else
        coroutine.resume(co, f)
    end
    return co
end

local create = co_create
local running = coroutine.running
local resume = coroutine.resume
local yield = coroutine.yield
local error = error
local unpack = unpack
local debug = debug
local FrameTimer = FrameTimer
local CoTimer = CoTimer

local comap = {}
setmetatable(comap, { __mode = "kv" })

function coroutine.start(f, ...)
    local co = create(f)

    if running() == nil then
        local flag, msg = resume(co, ...)

        if not flag then
            msg = debug.traceback(co, msg)
            error(msg)
        end
    else
        local args = { ... }
        local timer = nil

        local action = function()
            local flag, msg = resume(co, unpack(args))

            if not flag then
                timer:Stop()
                msg = debug.traceback(co, msg)
                error(msg)
            end
        end

        timer = FrameTimer.New(action, 0, 1)
        comap[co] = timer
        timer:Start()
    end

    return co
end

function coroutine.wait(t, co, ...)
    local args = { ... }
    co = co or running()
    local timer = nil

    local action = function()
        local flag, msg = resume(co, unpack(args))

        if not flag then
            timer:Stop()
            msg = debug.traceback(co, msg)
            error(msg)
            return
        end
    end

    timer = CoTimer.New(action, t, 1)
    comap[co] = timer
    timer:Start()
    return yield()
end

function coroutine.step(t, co, ...)
    local args = { ... }
    co = co or running()
    local timer = nil

    local action = function()
        local flag, msg = resume(co, unpack(args))

        if not flag then
            timer:Stop()
            msg = debug.traceback(co, msg)
            error(msg)
            return
        end
    end

    timer = FrameTimer.New(action, t or 1, 1)
    comap[co] = timer
    timer:Start()
    return yield()
end

function coroutine.www(www, co)
    co = co or running()
    local timer = nil

    local action = function()
        if not www.isDone then
            return
        end

        timer:Stop()
        local flag, msg = resume(co)

        if not flag then
            msg = debug.traceback(co, msg)
            error(msg)
            return
        end
    end

    timer = FrameTimer.New(action, 1, -1)
    comap[co] = timer
    timer:Start()
    return yield()
end

function coroutine.stop(co)
    local timer = comap[co]

    if timer ~= nil then
        comap[co] = nil
        timer:Stop()
    end
end