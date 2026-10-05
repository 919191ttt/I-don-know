-- ============================================================
-- 919191ttt 综合脚本 v5.0 - DELTA TACTICAL 完整整合版
-- 功能: 通用 / AI对话 / 浏览器 / 其他脚本(Doors) / 制作人
-- ============================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Tween = game:GetService("TweenService")
local Http = game:GetService("HttpService")
local MPS = game:GetService("MarketplaceService")
local LP = Players.LocalPlayer

local CFG = {
    WALLPAPER_ID = "",
    API_KEY = "",
    API_URL = "https://api.deepseek.com/chat/completions",
    MODEL = "deepseek-chat",
}

local CLR = {
    BG      = Color3.fromRGB(15, 18, 22),
    PANEL   = Color3.fromRGB(22, 26, 32),
    PANEL2  = Color3.fromRGB(28, 33, 40),
    ACCENT  = Color3.fromRGB(184, 255, 0),
    ACCENT2 = Color3.fromRGB(120, 180, 0),
    TEXT    = Color3.fromRGB(225, 230, 235),
    SUB     = Color3.fromRGB(130, 140, 150),
    LINE    = Color3.fromRGB(45, 52, 60),
    DANGER  = Color3.fromRGB(230, 70, 70),
}

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ============ 工具函数 ============
local function mk(c, p)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do o[k] = v end
    return o
end

local function rr(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = o
    return c
end

local function stroke(o, col, th, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or CLR.LINE
    s.Thickness = th or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = o
    return s
end

local function req(opts)
    local ok, res
    if syn and syn.request then ok, res = pcall(syn.request, opts)
    elseif http and http.request then ok, res = pcall(http.request, opts)
    elseif request then ok, res = pcall(request, opts)
    elseif http_request then ok, res = pcall(http_request, opts)
    else return false, "执行器不支持 HTTP 请求" end
    if not ok then return false, tostring(res) end
    return true, res
end

-- ============ ScreenGui ============
local gui = mk("ScreenGui", {
    Name = "TTT_Delta",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

-- ============ 壁纸层 ============
local wallpaper = mk("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = CLR.BG,
    BorderSizePixel = 0,
    ZIndex = 0,
    Parent = gui,
})
for i = -10, 20 do
    mk("Frame", {
        Size = UDim2.new(0, 2, 2, 0),
        Position = UDim2.new(0, i * 80, -0.5, 0),
        Rotation = 25,
        BackgroundColor3 = CLR.ACCENT,
        BackgroundTransparency = 0.94,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = wallpaper,
    })
end
for i = 0, 20 do
    mk("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, i * 60),
        BackgroundColor3 = CLR.ACCENT,
        BackgroundTransparency = 0.97,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = wallpaper,
    })
end
if CFG.WALLPAPER_ID ~= "" then
    mk("ImageLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = CFG.WALLPAPER_ID,
        ScaleType = Enum.ScaleType.Crop,
        ImageTransparency = 0.4,
        ZIndex = 2,
        Parent = wallpaper,
    })
end
mk("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = CLR.BG,
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = wallpaper,
})

-- ============ 主窗口 ============
local winSize = isMobile and UDim2.new(0.94, 0, 0.85, 0) or UDim2.new(0, 620, 0, 460)
local win = mk("Frame", {
    Name = "MainWindow",
    Size = winSize,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = CLR.PANEL,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Active = true,
    ZIndex = 10,
    Parent = gui,
})
rr(win, 10)
stroke(win, CLR.LINE, 1)
mk("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = CLR.ACCENT,
    BorderSizePixel = 0,
    ZIndex = 11,
    Parent = win,
})

-- ============ 标题栏 ============
local titleBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = CLR.PANEL,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 11,
    Parent = win,
})
local logo = mk("Frame", {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(0, 12, 0, 6),
    BackgroundColor3 = CLR.ACCENT,
    BorderSizePixel = 0,
    ZIndex = 12,
    Parent = titleBar,
})
rr(logo, 4)
mk("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "▲",
    TextColor3 = CLR.BG,
    TextSize = 18,
    Font = Enum.Font.GothamBlack,
    ZIndex = 13,
    Parent = logo,
})
mk("TextLabel", {
    Size = UDim2.new(1, -140, 0, 16),
    Position = UDim2.new(0, 52, 0, 6),
    BackgroundTransparency = 1,
    Text = "919191TTT // 综合脚本",
    TextColor3 = CLR.TEXT,
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
    Parent = titleBar,
})
mk("TextLabel", {
    Size = UDim2.new(1, -140, 0, 12),
    Position = UDim2.new(0, 52, 0, 22),
    BackgroundTransparency = 1,
    Text = "DELTA TACTICAL v5.0",
    TextColor3 = CLR.ACCENT,
    TextSize = 10,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 12,
    Parent = titleBar,
})
local minBtn = mk("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -76, 0, 7),
    BackgroundColor3 = CLR.PANEL2,
    Text = "—",
    TextColor3 = CLR.TEXT,
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 12,
    Parent = titleBar,
})
rr(minBtn, 4)
stroke(minBtn, CLR.LINE, 1)
local closeBtn = mk("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -40, 0, 7),
    BackgroundColor3 = CLR.PANEL2,
    Text = "✕",
    TextColor3 = CLR.DANGER,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    ZIndex = 12,
    Parent = titleBar,
})
rr(closeBtn, 4)
stroke(closeBtn, CLR.LINE, 1)
mk("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, 44),
    BackgroundColor3 = CLR.LINE,
    BorderSizePixel = 0,
    ZIndex = 11,
    Parent = win,
})

-- ============ 标签栏 ============
local tabBar = mk("Frame", {
    Size = UDim2.new(1, -24, 0, 34),
    Position = UDim2.new(0, 12, 0, 52),
    BackgroundTransparency = 1,
    ZIndex = 11,
    Parent = win,
})
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = tabBar,
})

local tabFrames = {}
local showApiModal
local apiModalOpen = false

local function switchTab(name)
    for n, f in pairs(tabFrames) do f.Visible = (n == name) end
    for _, c in pairs(tabBar:GetChildren()) do
        if c:IsA("TextButton") then
            local active = (c.Name == name)
            local ind = c:FindFirstChild("Indicator")
            if ind then ind.Visible = active end
            Tween:Create(c, TweenInfo.new(0.15), {
                TextColor3 = active and CLR.ACCENT or CLR.SUB,
                BackgroundColor3 = active and CLR.PANEL2 or CLR.PANEL,
            }):Play()
        end
    end
    if name == "AIChat" and CFG.API_KEY == "" then
        task.delay(0.25, function()
            if CFG.API_KEY == "" and not apiModalOpen and showApiModal then
                showApiModal()
            end
        end)
    end
end

local function mkTab(name, label)
    local tabW = isMobile and 54 or 78
    local btn = mk("TextButton", {
        Name = name,
        Size = UDim2.new(0, tabW, 1, 0),
        BackgroundColor3 = CLR.PANEL,
        Text = label,
        TextColor3 = CLR.SUB,
        TextSize = isMobile and 10 or 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 12,
        Parent = tabBar,
    })
    rr(btn, 4)
    local ind = mk("Frame", {
        Name = "Indicator",
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = CLR.ACCENT,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 13,
        Parent = btn,
    })
    rr(ind, 1)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.Activated:Connect(function() switchTab(name) end)
end

mkTab("General", "通用")
mkTab("AIChat", "AI 对话")
mkTab("Browser", "浏览器")
mkTab("OtherScripts", "其他脚本")
mkTab("Credits", "制作人")

-- ============ 内容区 ============
local content = mk("Frame", {
    Size = UDim2.new(1, -24, 1, -96),
    Position = UDim2.new(0, 12, 0, 92),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 11,
    Parent = win,
})

local function mkPage(name)
    local f = mk("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CLR.ACCENT,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 11,
        Parent = content,
    })
    mk("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = f,
    })
    mk("UIPadding", {
        PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 12),
        Parent = f,
    })
    tabFrames[name] = f
    return f
end

local pgGeneral = mkPage("General")
local pgAI = mkPage("AIChat")
local pgBrowser = mkPage("Browser")
local pgOther = mkPage("OtherScripts")
local pgCredits = mkPage("Credits")

-- ============ 组件工厂 ============
local function section(title, parent, order)
    local w = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = parent,
    })
    mk("Frame", {
        Size = UDim2.new(0, 3, 0, 12),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundColor3 = CLR.ACCENT,
        BorderSizePixel = 0,
        Parent = w,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title:upper(),
        TextColor3 = CLR.ACCENT,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = w,
    })
end

local function btn(text, cb, parent, order, activeColor)
    local b = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = CLR.PANEL2,
        Text = text,
        TextColor3 = CLR.TEXT,
        TextSize = isMobile and 13 or 12,
        Font = Enum.Font.GothamMedium,
        AutoButtonColor = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
        Parent = parent,
    })
    rr(b, 6)
    stroke(b, CLR.LINE, 1)
    mk("UIPadding", { PaddingLeft = UDim.new(0, 12), Parent = b })
    local toggled = false
    b.MouseEnter:Connect(function()
        if not toggled then
            Tween:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(36, 42, 50),
            }):Play()
        end
    end)
    b.MouseLeave:Connect(function()
        if not toggled then
            Tween:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = CLR.PANEL2,
            }):Play()
        end
    end)
    local function onClick()
        local ok, err = pcall(cb)
        if not ok then warn("[919191ttt] " .. tostring(err)) end
    end
    b.MouseButton1Click:Connect(onClick)
    b.Activated:Connect(onClick)
    return b, function(state)
        toggled = state
        Tween:Create(b, TweenInfo.new(0.2), {
            BackgroundColor3 = state and (activeColor or CLR.ACCENT2) or CLR.PANEL2,
            TextColor3 = state and Color3.fromRGB(255, 255, 255) or CLR.TEXT,
        }):Play()
    end
end

local function slider(text, min, max, default, cb, parent, order)
    local w = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = CLR.PANEL2,
        LayoutOrder = order,
        Parent = parent,
    })
    rr(w, 6)
    stroke(w, CLR.LINE, 1)
    local lbl = mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 16),
        Position = UDim2.new(0, 10, 0, 6),
        BackgroundTransparency = 1,
        Text = text .. "  " .. default,
        TextColor3 = CLR.SUB,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = w,
    })
    mk("TextLabel", {
        Size = UDim2.new(0, 60, 0, 16),
        Position = UDim2.new(1, -70, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = CLR.ACCENT,
        TextSize = 11,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Right,
        Name = "Value",
        Parent = w,
    })
    local track = mk("Frame", {
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 0, 32),
        BackgroundColor3 = CLR.LINE,
        BorderSizePixel = 0,
        Parent = w,
    })
    rr(track, 2)
    local fill = mk("Frame", {
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = CLR.ACCENT,
        BorderSizePixel = 0,
        Parent = track,
    })
    rr(fill, 2)
    local drag = false
    local function update(x)
        local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * pct)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        w.Value.Text = tostring(v)
        lbl.Text = text .. "  " .. v
        if cb then cb(v) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; update(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

-- ============ 通用页功能 ============
local flyOn, flySpeed = false, 50
local bv, bg, flyConn
local function startFly()
    if flyOn then return end
    local ch = LP.Character
    if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart")
    local hum = ch:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    flyOn = true
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = 3000; bv.Velocity = Vector3.new(0, 0, 0); bv.Parent = hrp
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9000; bg.D = 500; bg.CFrame = hrp.CFrame; bg.Parent = hrp
    hum.PlatformStand = true
    flyConn = RS.RenderStepped:Connect(function()
        if not flyOn then return end
        local cam = workspace.CurrentCamera
        local md = hum.MoveDirection
        local v = Vector3.new(0, 0, 0)
        if md.Magnitude > 0 then
            v = cam.CFrame:VectorToWorldSpace(Vector3.new(md.X, 0, md.Z)).Unit * flySpeed
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, flySpeed * 0.8, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v = v - Vector3.new(0, flySpeed * 0.8, 0) end
        bv.Velocity = v
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if not flyOn then return end
    flyOn = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    local ch = LP.Character
    if ch then
        local h = ch:FindFirstChild("Humanoid")
        if h then h.PlatformStand = false end
    end
end

local function setWS(s) local c = LP.Character; if c then local h = c:FindFirstChild("Humanoid"); if h then h.WalkSpeed = s end end end
local function setJP(p) local c = LP.Character; if c then local h = c:FindFirstChild("Humanoid"); if h then h.UseJumpPower = true; h.JumpPower = p end end end
local function resetChar() local c = LP.Character; if c then local h = c:FindFirstChild("Humanoid"); if h then h.Health = 0 end end end

local noclipOn = false
local noclipConn
local function toggleNoclip(s)
    noclipOn = s
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if s then
        noclipConn = RS.Stepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end

local function fling(target)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.Velocity = Vector3.new(math.random(-500, 500), math.random(700, 1200), math.random(-500, 500))
    hrp.RotVelocity = Vector3.new(math.random(-150, 150), math.random(-150, 150), math.random(-150, 150))
    local p = Instance.new("Part")
    p.Size = Vector3.new(2, 2, 2)
    p.Transparency = 1
    p.CanCollide = false
    p.CFrame = hrp.CFrame
    p.Parent = hrp
    local att = Instance.new("Attachment"); att.Parent = p
    local ap = Instance.new("AlignPosition")
    ap.Attachment0 = att
    ap.Mode = Enum.PositionAlignmentMode.OneAttachment
    ap.Position = hrp.Position
    ap.MaxForce = math.huge
    ap.Responsiveness = 200
    ap.Parent = p
    local conn
    conn = RS.Heartbeat:Connect(function()
        if p and p.Parent then
            p.CFrame = p.CFrame * CFrame.Angles(math.rad(60), math.rad(60), math.rad(60))
        else
            conn:Disconnect()
        end
    end)
    task.delay(5, function()
        if conn then conn:Disconnect() end
        if p then p:Destroy() end
    end)
end

local function teleport(target)
    if not target or not target.Character then return end
    local me = LP.Character
    if not me then return end
    local mh = me:FindFirstChild("HumanoidRootPart")
    local th = target.Character:FindFirstChild("HumanoidRootPart")
    if mh and th then mh.CFrame = th.CFrame * CFrame.new(0, 0, -3) end
end

-- ============ 通用页 UI ============
local order = 0
local function nOrder() order = order + 1; return order end

section("飞行系统", pgGeneral, nOrder())
local flyBtn, setFly = btn("加速度飞行   [ 关 ]", function()
    if flyOn then stopFly(); setFly(false); flyBtn.Text = "加速度飞行   [ 关 ]"
    else startFly(); setFly(true); flyBtn.Text = "加速度飞行   [ 开 ]" end
end, pgGeneral, nOrder())
slider("飞行速度", 10, 250, 50, function(v) flySpeed = v end, pgGeneral, nOrder())

section("角色属性", pgGeneral, nOrder())
btn("速度提升至 100", function() setWS(100) end, pgGeneral, nOrder())
btn("跳跃力提升至 120", function() setJP(120) end, pgGeneral, nOrder())
btn("重置速度 / 跳跃", function() setWS(16); setJP(50) end, pgGeneral, nOrder())

section("辅助功能", pgGeneral, nOrder())
local ncB, setNC = btn("穿墙模式   [ 关 ]", function()
    toggleNoclip(not noclipOn)
    setNC(noclipOn)
    ncB.Text = "穿墙模式   [" .. (noclipOn and "开" or "关") .. "]"
end, pgGeneral, nOrder())
btn("重置角色", function() resetChar() end, pgGeneral, nOrder())

section("玩家列表 · 甩飞 / 传送", pgGeneral, nOrder())
local pList = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 200),
    BackgroundColor3 = CLR.PANEL,
    LayoutOrder = nOrder(),
    Parent = pgGeneral,
})
rr(pList, 6)
stroke(pList, CLR.LINE, 1)
local pScroll = mk("ScrollingFrame", {
    Size = UDim2.new(1, -8, 1, -8),
    Position = UDim2.new(0, 4, 0, 4),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = CLR.ACCENT,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Parent = pList,
})
mk("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = pScroll })

local function refreshPlayers()
    for _, c in pairs(pScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    local i = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            i = i + 1
            local row = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = CLR.PANEL2,
                LayoutOrder = i,
                Parent = pScroll,
            })
            rr(row, 4)
            mk("TextLabel", {
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = plr.Name,
                TextColor3 = CLR.TEXT,
                TextSize = isMobile and 12 or 11,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = row,
            })
            local fb = mk("TextButton", {
                Size = UDim2.new(0, 52, 0, 24),
                Position = UDim2.new(1, -118, 0, 5),
                BackgroundColor3 = Color3.fromRGB(60, 30, 30),
                Text = "甩飞",
                TextColor3 = CLR.DANGER,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent = row,
            })
            rr(fb, 4)
            stroke(fb, CLR.DANGER, 1, 0.6)
            local tb = mk("TextButton", {
                Size = UDim2.new(0, 52, 0, 24),
                Position = UDim2.new(1, -60, 0, 5),
                BackgroundColor3 = Color3.fromRGB(25, 45, 35),
                Text = "传送",
                TextColor3 = CLR.ACCENT,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent = row,
            })
            rr(tb, 4)
            stroke(tb, CLR.ACCENT, 1, 0.6)
            fb.MouseButton1Click:Connect(function() fling(plr) end)
            fb.Activated:Connect(function() fling(plr) end)
            tb.MouseButton1Click:Connect(function() teleport(plr) end)
            tb.Activated:Connect(function() teleport(plr) end)
        end
    end
    local l = pScroll:FindFirstChildOfClass("UIListLayout")
    if l then pScroll.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 10) end
end
refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5); refreshPlayers() end)

-- ============ AI 页面 ============
local aiOrder = 0
local function nAI() aiOrder = aiOrder + 1; return aiOrder end

local aiTop = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    LayoutOrder = nAI(),
    Parent = pgAI,
})
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = aiTop,
})

local function topBtn(text, color, cb)
    local b = mk("TextButton", {
        Size = UDim2.new(0, isMobile and 72 or 88, 1, 0),
        BackgroundColor3 = CLR.PANEL2,
        Text = text,
        TextColor3 = color or CLR.TEXT,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = aiTop,
    })
    rr(b, 4)
    stroke(b, CLR.LINE, 1)
    b.MouseButton1Click:Connect(cb)
    b.Activated:Connect(cb)
    return b
end

local msgBox = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, isMobile and 280 or 260),
    BackgroundColor3 = CLR.BG,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = CLR.ACCENT,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    LayoutOrder = nAI(),
    Parent = pgAI,
})
rr(msgBox, 6)
stroke(msgBox, CLR.LINE, 1)
local msgLayout = mk("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, Parent = msgBox })
mk("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = msgBox })

local msgN = 0
local function addMsg(role, text)
    msgN = msgN + 1
    local isUser = role == "user"
    local isSys = role == "system"
    local wrapper = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder = msgN,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = msgBox,
    })
    local bubble = mk("Frame", {
        Size = UDim2.new(0.88, 0, 0, 20),
        BackgroundColor3 = isSys and CLR.PANEL
            or (isUser and Color3.fromRGB(35, 55, 25)
            or Color3.fromRGB(28, 40, 20)),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = isUser and UDim2.new(1, -1, 0, 0) or UDim2.new(0, 0, 0, 0),
        AnchorPoint = isUser and Vector2.new(1, 0) or Vector2.new(0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = wrapper,
    })
    rr(bubble, 6)
    stroke(bubble, isUser and CLR.ACCENT2 or CLR.LINE, 1, 0.5)
    local prefix = isUser and "▸ 你" or (isSys and "▸ 系统" or "▸ AI")
    local prefixCol = isUser and CLR.TEXT or (isSys and CLR.SUB or CLR.ACCENT)
    mk("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        Text = prefix,
        TextColor3 = prefixCol,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bubble,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 8, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = CLR.TEXT,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = bubble,
    })
    task.defer(function()
        msgBox.CanvasSize = UDim2.new(0, 0, 0, msgLayout.AbsoluteContentSize.Y + 20)
        msgBox.CanvasPosition = Vector2.new(0, math.huge)
    end)
    return wrapper
end

task.delay(0.3, function()
    addMsg("system", "919191TTT AI 就绪。\n• 直接输入问题对话\n• 点击 [图片] 附加图片URL\n• 点击 [分析] 让我看看你玩的游戏")
end)

local history = {}
local function pushH(r, c)
    table.insert(history, { role = r, content = c })
    if #history > 12 then table.remove(history, 1) end
end

local function callAI(text, cb)
    if CFG.API_KEY == "" then cb(false, "请先设置 API Key") return end
    pushH("user", text)
    local msgs = {
        { role = "system", content = [[你是"919191TTT AI"，一个 Roblox 游戏专家助手，说话简洁、直接、专业。
能力：识别用户所玩的游戏、提供攻略、解答脚本编程问题、闲聊。
使用中文，回答简洁明了。]] }
    }
    for _, m in ipairs(history) do table.insert(msgs, m) end
    local body = Http:JSONEncode({
        model = CFG.MODEL,
        messages = msgs,
        max_tokens = 1000,
        temperature = 0.7,
    })
    local opts = {
        Url = CFG.API_URL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. CFG.API_KEY,
        },
        Body = body,
    }
    task.spawn(function()
        local ok, res = req(opts)
        if not ok then cb(false, "请求失败: " .. tostring(res)) return end
        local code = res.StatusCode or res.Status
        if code ~= 200 then cb(false, "API " .. tostring(code) .. ": " .. tostring(res.Body)) return end
        local pok, data = pcall(Http.JSONDecode, Http, res.Body)
        if not pok or not data.choices or not data.choices[1] then
            cb(false, "解析失败") return
        end
        local reply = data.choices[1].message.content
        pushH("assistant", reply)
        cb(true, reply)
    end)
end

local function collectCtx()
    local c = {}
    pcall(function()
        local info = MPS:GetProductInfo(game.PlaceId)
        c.GameName = info.Name
        c.Creator = info.Creator and info.Creator.Name or "未知"
    end)
    c.PlaceId = tostring(game.PlaceId)
    local ch = LP.Character
    if ch then
        local h = ch:FindFirstChildOfClass("Humanoid")
        if h then
            c.HP = math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth)
            c.WS = math.floor(h.WalkSpeed)
        end
    end
    local texts = {}
    local function scan(p, d)
        if d > 4 or #texts >= 30 then return end
        for _, o in pairs(p:GetChildren()) do
            if o:IsA("TextLabel") or o:IsA("TextButton") then
                local t = o.Text
                if t and #t > 0 and #t < 50 and not t:match("^%s*$") then
                    table.insert(texts, t)
                end
            end
            pcall(scan, o, d + 1)
        end
    end
    pcall(scan, LP:FindFirstChild("PlayerGui"), 0)
    c.UITexts = texts
    c.Players = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(c.Players, p.Name) end
    return c
end

topBtn("分析", CLR.ACCENT, function()
    if CFG.API_KEY == "" then showApiModal() return end
    addMsg("system", "正在采集游戏信息...")
    local c = collectCtx()
    local prompt = string.format([[
分析以下 Roblox 游戏，给出：
1. 游戏名称与类型判断
2. 玩法特色
3. 新手/进阶攻略建议（分步骤）

游戏信息：
- 名称: %s
- PlaceId: %s
- 创作者: %s
- 血量: %s, 速度: %s
- 屏幕UI: %s
- 在线玩家: %s
]],
        c.GameName or "未知", c.PlaceId, c.Creator or "未知",
        c.HP or "?", c.WS or "?",
        table.concat(c.UITexts or {}, " | "),
        table.concat(c.Players or {}, ", "))
    addMsg("user", "【分析当前游戏】")
    local lb = addMsg("system", "AI 思考中...")
    callAI(prompt, function(ok, r)
        if lb and lb.Parent then lb:Destroy() end
        if ok then addMsg("assistant", r) else addMsg("system", "❌ " .. r) end
    end)
end)

topBtn("图片", Color3.fromRGB(150, 180, 255), function()
    if CFG.API_KEY == "" then showApiModal() return end
    local pGui = mk("ScreenGui", { Name = "TTT_ImgIn", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 110 })
    pcall(function() pGui.Parent = game:GetService("CoreGui") end)
    if not pGui.Parent then pGui.Parent = LP.PlayerGui end
    local ov = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        Parent = pGui,
    })
    local bw, bh = isMobile and 300 or 400, 200
    local box = mk("Frame", {
        Size = UDim2.new(0, bw, 0, bh),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CLR.PANEL,
        Parent = ov,
    })
    rr(box, 8)
    stroke(box, CLR.ACCENT, 1, 0.3)
    mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 24),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = "▸ 图片 URL",
        TextColor3 = CLR.ACCENT,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        Text = "粘贴图片URL (https://...) 并附上你想问的问题\n注意: deepseek-chat 不支持视觉",
        TextColor3 = CLR.SUB,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = box,
    })
    local urlIn = mk("TextBox", {
        Size = UDim2.new(1, -20, 0, 34),
        Position = UDim2.new(0, 10, 0, 76),
        BackgroundColor3 = CLR.PANEL2,
        Text = "",
        PlaceholderText = "https://...",
        PlaceholderColor3 = CLR.SUB,
        TextColor3 = CLR.TEXT,
        TextSize = 12,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })
    rr(urlIn, 4)
    stroke(urlIn, CLR.LINE, 1)
    mk("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = urlIn })
    local cancelBtn = mk("TextButton", {
        Size = UDim2.new(0.5, -15, 0, 32),
        Position = UDim2.new(0, 10, 1, -42),
        BackgroundColor3 = CLR.PANEL2,
        Text = "取消",
        TextColor3 = CLR.TEXT,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = box,
    })
    rr(cancelBtn, 4)
    local sendBtn = mk("TextButton", {
        Size = UDim2.new(0.5, -15, 0, 32),
        Position = UDim2.new(0.5, 5, 1, -42),
        BackgroundColor3 = CLR.ACCENT,
        Text = "发送给 AI",
        TextColor3 = CLR.BG,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = box,
    })
    rr(sendBtn, 4)
    local function doSend()
        local url = urlIn.Text:gsub("%s", "")
        if url == "" then return end
        pGui:Destroy()
        addMsg("user", "【图片】" .. url)
        local lb = addMsg("system", "AI 分析图片中...")
        callAI("用户发来图片：" .. url .. "\n请基于此URL给出有帮助的回应。", function(ok, r)
            if lb and lb.Parent then lb:Destroy() end
            if ok then addMsg("assistant", r) else addMsg("system", "❌ " .. r) end
        end)
    end
    cancelBtn.MouseButton1Click:Connect(function() pGui:Destroy() end)
    cancelBtn.Activated:Connect(function() pGui:Destroy() end)
    sendBtn.MouseButton1Click:Connect(doSend)
    sendBtn.Activated:Connect(doSend)
end)

topBtn("清空", CLR.DANGER, function()
    for _, c in pairs(msgBox:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    history = {}; msgN = 0
    addMsg("system", "对话已清空")
end)

topBtn("API Key", Color3.fromRGB(120, 200, 150), function()
    showApiModal()
end)

local aiInputBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, isMobile and 42 or 38),
    BackgroundTransparency = 1,
    LayoutOrder = nAI(),
    Parent = pgAI,
})
local chatIn = mk("TextBox", {
    Size = UDim2.new(1, -70, 1, 0),
    BackgroundColor3 = CLR.PANEL2,
    Text = "",
    PlaceholderText = "输入消息...",
    PlaceholderColor3 = CLR.SUB,
    TextColor3 = CLR.TEXT,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    Parent = aiInputBar,
})
rr(chatIn, 4)
stroke(chatIn, CLR.LINE, 1)
mk("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = chatIn })
local sendBtn = mk("TextButton", {
    Size = UDim2.new(0, 64, 1, 0),
    Position = UDim2.new(1, -64, 0, 0),
    BackgroundColor3 = CLR.ACCENT,
    Text = "发送",
    TextColor3 = CLR.BG,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false,
    Parent = aiInputBar,
})
rr(sendBtn, 4)
local sending = false
local function doSend()
    if sending then return end
    if CFG.API_KEY == "" then showApiModal() return end
    local t = chatIn.Text
    if not t or t == "" then return end
    sending = true
    chatIn.Text = ""
    addMsg("user", t)
    local lb = addMsg("system", "AI 思考中...")
    callAI(t, function(ok, r)
        sending = false
        if lb and lb.Parent then lb:Destroy() end
        if ok then addMsg("assistant", r) else addMsg("system", "❌ " .. r) end
    end)
end
sendBtn.MouseButton1Click:Connect(doSend)
sendBtn.Activated:Connect(doSend)
chatIn.FocusLost:Connect(function(e) if e then doSend() end end)

-- ============ API Key 弹窗 ============
showApiModal = function()
    if apiModalOpen then return end
    apiModalOpen = true
    local pGui = mk("ScreenGui", { Name = "TTT_ApiIn", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 110 })
    pcall(function() pGui.Parent = game:GetService("CoreGui") end)
    if not pGui.Parent then pGui.Parent = LP.PlayerGui end
    local ov = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = pGui,
    })
    local bw, bh = isMobile and 300 or 400, 190
    local box = mk("Frame", {
        Size = UDim2.new(0, bw, 0, bh),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = CLR.PANEL,
        Parent = ov,
    })
    rr(box, 8)
    stroke(box, CLR.ACCENT, 1, 0.2)
    mk("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = CLR.ACCENT,
        BorderSizePixel = 0,
        Parent = box,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = "▸ DEEPSEEK API KEY",
        TextColor3 = CLR.ACCENT,
        TextSize = 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 12, 0, 34),
        BackgroundTransparency = 1,
        Text = "在 platform.deepseek.com 免费申请，以 sk- 开头",
        TextColor3 = CLR.SUB,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = box,
    })
    local inp = mk("TextBox", {
        Size = UDim2.new(1, -20, 0, 36),
        Position = UDim2.new(0, 10, 0, 72),
        BackgroundColor3 = CLR.PANEL2,
        Text = CFG.API_KEY,
        PlaceholderText = "sk-xxxxxxxxxxxxxx",
        PlaceholderColor3 = CLR.SUB,
        TextColor3 = CLR.TEXT,
        TextSize = 12,
        Font = Enum.Font.Code,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = box,
    })
    rr(inp, 4)
    stroke(inp, CLR.LINE, 1)
    mk("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = inp })
    local cancelB = mk("TextButton", {
        Size = UDim2.new(0.5, -15, 0, 32),
        Position = UDim2.new(0, 10, 1, -42),
        BackgroundColor3 = CLR.PANEL2,
        Text = "取消",
        TextColor3 = CLR.TEXT,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = box,
    })
    rr(cancelB, 4)
    local saveB = mk("TextButton", {
        Size = UDim2.new(0.5, -15, 0, 32),
        Position = UDim2.new(0.5, 5, 1, -42),
        BackgroundColor3 = CLR.ACCENT,
        Text = "保存",
        TextColor3 = CLR.BG,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        Parent = box,
    })
    rr(saveB, 4)
    local function close() apiModalOpen = false; pGui:Destroy() end
    local function save()
        local k = (inp.Text or ""):gsub("%s", "")
        if k == "" then
            inp.PlaceholderText = "不能为空"
            return
        end
        CFG.API_KEY = k
        close()
        addMsg("system", "API Key 已保存")
    end
    cancelB.MouseButton1Click:Connect(close)
    cancelB.Activated:Connect(close)
    saveB.MouseButton1Click:Connect(save)
    saveB.Activated:Connect(save)
    inp.FocusLost:Connect(function(e) if e then save() end end)
    box.Size = UDim2.new(0, bw, 0, 0)
    Tween:Create(box, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, bw, 0, bh),
    }):Play()
end

-- ============ 浏览器页面 ============
local brOrder = 0
local function nBr() brOrder = brOrder + 1; return brOrder end

local brTop = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundTransparency = 1,
    LayoutOrder = nBr(),
    Parent = pgBrowser,
})
local backBtn = mk("TextButton", {
    Size = UDim2.new(0, 32, 1, 0),
    BackgroundColor3 = CLR.PANEL2,
    Text = "◀",
    TextColor3 = CLR.TEXT,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = brTop,
})
rr(backBtn, 4)
stroke(backBtn, CLR.LINE, 1)
local refreshBtn = mk("TextButton", {
    Size = UDim2.new(0, 32, 1, 0),
    Position = UDim2.new(0, 36, 0, 0),
    BackgroundColor3 = CLR.PANEL2,
    Text = "↻",
    TextColor3 = CLR.ACCENT,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    Parent = brTop,
})
rr(refreshBtn, 4)
stroke(refreshBtn, CLR.LINE, 1)
local urlBar = mk("TextBox", {
    Size = UDim2.new(1, -140, 1, 0),
    Position = UDim2.new(0, 72, 0, 0),
    BackgroundColor3 = CLR.PANEL2,
    Text = "",
    PlaceholderText = "输入网址或搜索内容...",
    PlaceholderColor3 = CLR.SUB,
    TextColor3 = CLR.TEXT,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = brTop,
})
rr(urlBar, 4)
stroke(urlBar, CLR.LINE, 1)
mk("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = urlBar })
local goBtn = mk("TextButton", {
    Size = UDim2.new(0, 64, 1, 0),
    Position = UDim2.new(1, -64, 0, 0),
    BackgroundColor3 = CLR.ACCENT,
    Text = "打开",
    TextColor3 = CLR.BG,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    Parent = brTop,
})
rr(goBtn, 4)

local brView = mk("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, isMobile and 320 or 300),
    BackgroundColor3 = CLR.BG,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = CLR.ACCENT,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    LayoutOrder = nBr(),
    Parent = pgBrowser,
})
rr(brView, 6)
stroke(brView, CLR.LINE, 1)
mk("UIPadding", {
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    Parent = brView,
})
local brLabel = mk("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "▸ 输入网址或关键词开始浏览\n▸ 支持: 网页文本、搜索、API查询",
    TextColor3 = CLR.SUB,
    TextSize = 12,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = true,
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = brView,
})

local brHistory = {}
local brHistIdx = 0

local function stripHTML(html)
    html = html:gsub("<script[^>]*>.-</script>", "")
    html = html:gsub("<style[^>]*>.-</style>", "")
    html = html:gsub("<[^>]+>", " ")
    html = html:gsub("&nbsp;", " ")
    html = html:gsub("&amp;", "&")
    html = html:gsub("&lt;", "<")
    html = html:gsub("&gt;", ">")
    html = html:gsub("&quot;", '"')
    html = html:gsub("&#(%d+);", function(n) return string.char(tonumber(n) % 256) end)
    html = html:gsub("%s+", " ")
    html = html:gsub("^%s+", ""):gsub("%s+$", "")
    return html
end

local function navigate(url, isSearch)
    if url == "" then return end
    local finalUrl = url
    if isSearch then
        finalUrl = "https://www.bing.com/search?q=" .. Http:UrlEncode(url)
    elseif not url:match("^https?://") then
        finalUrl = "https://" .. url
    end
    brLabel.Text = "▸ 加载中... " .. finalUrl
    brLabel.TextColor3 = CLR.ACCENT
    local opts = {
        Url = finalUrl,
        Method = "GET",
        Headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            ["Accept"] = "text/html,application/xhtml+xml,*/*",
        },
    }
    task.spawn(function()
        local ok, res = req(opts)
        if not ok then
            brLabel.Text = "❌ 请求失败: " .. tostring(res)
            brLabel.TextColor3 = CLR.DANGER
            return
        end
        local code = res.StatusCode or res.Status
        if code ~= 200 then
            brLabel.Text = "❌ HTTP " .. tostring(code) .. "\n\n" .. (res.Body or "")
            brLabel.TextColor3 = CLR.DANGER
            return
        end
        local body = res.Body or ""
        if body:match("^%s*[%{%[]") then
            local ok2, dec = pcall(Http.JSONDecode, Http, body)
            if ok2 then
                local ok3, pretty = pcall(Http.JSONEncode, Http, dec)
                body = ok3 and pretty or body
            end
        else
            body = stripHTML(body)
        end
        if #body > 8000 then body = body:sub(1, 8000) .. "\n\n... [内容过长已截断]" end
        brLabel.Text = "▸ " .. finalUrl .. "\n\n" .. body
        brLabel.TextColor3 = CLR.TEXT
        task.defer(function()
            brView.CanvasSize = UDim2.new(0, 0, 0, brLabel.AbsoluteSize.Y + 30)
            brView.CanvasPosition = Vector2.new(0, 0)
        end)
    end)
    table.insert(brHistory, finalUrl)
    brHistIdx = #brHistory
end

local function doNavigate()
    local t = urlBar.Text
    if not t or t == "" then return end
    local isSearch = not t:match("^https?://") and (t:match("%.") == nil or t:match("%s"))
    navigate(t, isSearch)
end

goBtn.MouseButton1Click:Connect(doNavigate)
goBtn.Activated:Connect(doNavigate)
urlBar.FocusLost:Connect(function(e) if e then doNavigate() end end)

refreshBtn.MouseButton1Click:Connect(function()
    if brHistIdx > 0 and brHistory[brHistIdx] then
        navigate(brHistory[brHistIdx], false)
    end
end)
refreshBtn.Activated:Connect(function()
    if brHistIdx > 0 and brHistory[brHistIdx] then
        navigate(brHistory[brHistIdx], false)
    end
end)

backBtn.MouseButton1Click:Connect(function()
    if brHistIdx > 1 then
        brHistIdx = brHistIdx - 1
        local u = brHistory[brHistIdx]
        brHistIdx = brHistIdx + 1
        table.remove(brHistory)
        brHistIdx = brHistIdx - 1
        navigate(u, false)
    end
end)
backBtn.Activated:Connect(function()
    if brHistIdx > 1 then
        brHistIdx = brHistIdx - 1
        local u = brHistory[brHistIdx]
        brHistIdx = brHistIdx + 1
        table.remove(brHistory)
        brHistIdx = brHistIdx - 1
        navigate(u, false)
    end
end)

local quickBar = mk("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    LayoutOrder = nBr(),
    Parent = pgBrowser,
})
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    Parent = quickBar,
})
for _, site in ipairs({
    { "百度", "https://www.baidu.com" },
    { "必应", "https://www.bing.com" },
    { "GitHub", "https://github.com" },
    { "Roblox", "https://www.roblox.com" },
}) do
    local q = mk("TextButton", {
        Size = UDim2.new(0, 62, 1, 0),
        BackgroundColor3 = CLR.PANEL2,
        Text = site[1],
        TextColor3 = CLR.TEXT,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = quickBar,
    })
    rr(q, 4)
    stroke(q, CLR.LINE, 1)
    q.MouseButton1Click:Connect(function()
        urlBar.Text = site[2]
        navigate(site[2], false)
    end)
    q.Activated:Connect(function()
        urlBar.Text = site[2]
        navigate(site[2], false)
    end)
end

-- ============ 其他脚本页面 ============
local otherOrder = 0
local function nOther() otherOrder = otherOrder + 1; return otherOrder end
section("脚本列表", pgOther, nOther())

-- ============ Doors 脚本核心 ============
local function loadDoorsScript()
    local RS2 = RS
    local UIS2 = UIS
    local Players2 = Players
    local LP2 = LP
    local active = true
    local conns = {}
    local function track(c) table.insert(conns, c); return c end
    local function cleanup()
        active = false
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        for _, g in pairs(gui:GetChildren()) do
            if g.Name == "DoorsPanel" then g:Destroy() end
        end
        pcall(function()
            local L = game:GetService("Lighting")
            L.Ambient = Color3.fromRGB(70, 70, 70)
            L.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
            L.Brightness = 1
            L.FogEnd = 1000
        end)
        local ch = LP2.Character
        if ch then
            local h = ch:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16; h.PlatformStand = false end
        end
    end

    local S = {
        ESP = false, ItemESP = false, FullBright = false,
        AutoHide = false, NoJumpScare = false, AutoUnlock = false,
        Fly = false, Noclip = false, Speed = 16,
    }

    local espMap = {}
    local function clearESP()
        for _, g in pairs(espMap) do pcall(function() g:Destroy() end) end
        espMap = {}
    end
    local function makeESP(part, color, label)
        if espMap[part] then return end
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 120, 0, 40)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.Parent = part
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 1, 0)
        t.BackgroundTransparency = 1
        t.Text = label
        t.TextColor3 = color
        t.TextStrokeTransparency = 0
        t.TextScaled = true
        t.Font = Enum.Font.GothamBold
        t.Parent = bb
        espMap[part] = bb
    end
    local entities = {"Rush","Ambush","Seek","Figure","Screech","Eyes","Halt","Glitch","Jack","Shadow"}
    local function updateESP()
        if not S.ESP then clearESP(); return end
        local ch = LP2.Character
        if not ch or not ch:FindFirstChild("HumanoidRootPart") then return end
        local myPos = ch.HumanoidRootPart.Position
        for _, o in pairs(workspace:GetChildren()) do
            if not active then return end
            for _, nm in ipairs(entities) do
                if o.Name:find(nm) then
                    local p = o:IsA("Model") and o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart")
                    if p and not espMap[p] then
                        local d = (p.Position - myPos).Magnitude
                        local col = d < 30 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 200, 0)
                        makeESP(p, col, "⚠ " .. o.Name .. " (" .. math.floor(d) .. "m)")
                    end
                    break
                end
            end
        end
        for part, g in pairs(espMap) do
            if not part or not part.Parent then
                pcall(function() g:Destroy() end)
                espMap[part] = nil
            end
   