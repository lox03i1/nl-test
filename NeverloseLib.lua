--[[
    NeverLose UI Library
    Executor : loadstring(game:HttpGet("RAW_URL"))()
    Language : Luau  |  single-file, CoreGui, protect_gui aware
]]

local NeverLoseLib = {}
NeverLoseLib.__index = NeverLoseLib

-- ── Services ──────────────────────────────────────────────────────────────────
local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")

-- ── Palette ───────────────────────────────────────────────────────────────────
local C = {
    BG         = Color3.fromRGB(20,  20,  26),
    SIDEBAR    = Color3.fromRGB(13,  13,  17),
    SECTION_BG = Color3.fromRGB(24,  24,  31),
    BORDER     = Color3.fromRGB(38,  38,  50),
    ACCENT     = Color3.fromRGB(0,   175, 225),
    ACCENT_DIM = Color3.fromRGB(0,   100, 140),
    ACCENTGLOW = Color3.fromRGB(0,   210, 255),
    TEXT       = Color3.fromRGB(215, 215, 222),
    SUBTEXT    = Color3.fromRGB(95,  95,  112),
    GROUP_TEXT = Color3.fromRGB(60,  60,  75),
    TOGGLE_OFF = Color3.fromRGB(50,  50,  64),
    TRACK      = Color3.fromRGB(35,  35,  46),
    TAB_HOVER  = Color3.fromRGB(26,  26,  33),
    INPUT_BG   = Color3.fromRGB(28,  28,  36),
    WHITE      = Color3.fromRGB(255, 255, 255),
}

local FBOLD = Enum.Font.GothamBold
local FMED  = Enum.Font.GothamMedium
local FREG  = Enum.Font.Gotham
local TI    = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(r, p)
    return mk("UICorner", {CornerRadius = UDim.new(0, r)}, p)
end

local function stroke(col, thick, p)
    return mk("UIStroke", {
        Color = col, Thickness = thick,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, p)
end

local function pad(t, r, b, l, p)
    return mk("UIPadding", {
        PaddingTop    = UDim.new(0, t),
        PaddingRight  = UDim.new(0, r),
        PaddingBottom = UDim.new(0, b),
        PaddingLeft   = UDim.new(0, l),
    }, p)
end

local function lst(spacing, dir, p)
    return mk("UIListLayout", {
        SortOrder     = Enum.SortOrder.LayoutOrder,
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding       = UDim.new(0, spacing or 0),
    }, p)
end

local function tw(obj, props)
    TweenService:Create(obj, TI, props):Play()
end

local function ripple(btn)
    local r = mk("Frame", {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.7,
        ZIndex = btn.ZIndex + 1,
    }, btn)
    corner(99, r)
    tw(r, {Size = UDim2.new(0,120,0,120), BackgroundTransparency = 1})
    task.delay(0.3, function() r:Destroy() end)
end

local function protect(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    elseif protect_gui then
        protect_gui(gui)
    end
end

-- ── Window ────────────────────────────────────────────────────────────────────
function NeverLoseLib.new(title, opts)
    opts = opts or {}
    local self = setmetatable({}, NeverLoseLib)
    local W = opts.Width  or 820
    local H = opts.Height or 530

    -- destroy existing instance
    local existing = CoreGui:FindFirstChild("NeverLoseLib")
    if existing then existing:Destroy() end

    local gui = mk("ScreenGui", {
        Name           = "NeverLoseLib",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        DisplayOrder   = 999,
    }, CoreGui)
    protect(gui)

    -- shadow
    mk("ImageLabel", {
        Size              = UDim2.new(1, 47, 1, 47),
        Position          = UDim2.new(0, -23, 0, -23),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://6015897843",
        ImageColor3       = Color3.new(0,0,0),
        ImageTransparency = 0.55,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49,49,450,450),
        ZIndex            = 0,
    }, gui)

    local win = mk("Frame", {
        Name             = "Win",
        Size             = UDim2.new(0, W, 0, H),
        Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, gui)
    corner(7, win)
    stroke(C.BORDER, 1, win)

    -- ── Topbar ────────────────────────────────────────────────────────────────
    local topbar = mk("Frame", {
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, win)
    stroke(C.BORDER, 1, topbar)

    mk("TextLabel", {
        Size             = UDim2.new(0, 185, 1, 0),
        BackgroundTransparency = 1,
        Text             = title or "NEVERLOSE",
        TextColor3       = C.WHITE,
        Font             = FBOLD,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 3,
    }, topbar)

    -- close btn
    local closeBtn = mk("TextButton", {
        Size             = UDim2.new(0, 26, 0, 26),
        Position         = UDim2.new(1, -34, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(170, 35, 35),
        Text             = "✕",
        TextColor3       = C.WHITE,
        Font             = FBOLD,
        TextSize         = 11,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, topbar)
    corner(5, closeBtn)
    closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

    -- minimize btn
    local minBtn = mk("TextButton", {
        Size             = UDim2.new(0, 26, 0, 26),
        Position         = UDim2.new(1, -64, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(50, 50, 64),
        Text             = "─",
        TextColor3       = C.SUBTEXT,
        Font             = FBOLD,
        TextSize         = 11,
        BorderSizePixel  = 0,
        ZIndex           = 4,
    }, topbar)
    corner(5, minBtn)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tw(win, {Size = minimized
            and UDim2.new(0, W, 0, 46)
            or  UDim2.new(0, W, 0, H)
        })
    end)

    -- ── Drag ──────────────────────────────────────────────────────────────────
    local dragging, dStart, wStart
    topbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dStart   = i.Position
            wStart   = win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - dStart
            win.Position = UDim2.new(
                wStart.X.Scale, wStart.X.Offset + d.X,
                wStart.Y.Scale, wStart.Y.Offset + d.Y
            )
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local sidebar = mk("Frame", {
        Size             = UDim2.new(0, 185, 1, -46),
        Position         = UDim2.new(0, 0, 0, 46),
        BackgroundColor3 = C.SIDEBAR,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, win)
    stroke(C.BORDER, 1, sidebar)

    local sideScroll = mk("ScrollingFrame", {
        Size                 = UDim2.new(1, 0, 1, -54),
        Position             = UDim2.new(0, 0, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = 2,
        ScrollBarImageColor3 = C.ACCENT,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
    }, sidebar)
    lst(0, nil, sideScroll)
    pad(4, 0, 4, 0, sideScroll)

    -- user bar
    local ubar = mk("Frame", {
        Size             = UDim2.new(1, 0, 0, 54),
        Position         = UDim2.new(0, 0, 1, -54),
        BackgroundColor3 = Color3.fromRGB(10, 10, 14),
        BorderSizePixel  = 0,
    }, sidebar)
    stroke(C.BORDER, 1, ubar)

    local avFrame = mk("Frame", {
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 10, 0.5, -16),
        BackgroundColor3 = C.ACCENT_DIM,
    }, ubar)
    corner(5, avFrame)
    mk("TextLabel", {
        Size             = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Text             = "👤",
        TextSize         = 14,
        Font             = FMED,
    }, avFrame)

    local plr = Players.LocalPlayer
    mk("TextLabel", {
        Size             = UDim2.new(1,-52,0,16),
        Position         = UDim2.new(0,48,0,8),
        BackgroundTransparency = 1,
        Text             = plr.Name,
        TextColor3       = C.TEXT,
        Font             = FBOLD,
        TextSize         = 12,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, ubar)
    mk("TextLabel", {
        Size             = UDim2.new(1,-52,0,14),
        Position         = UDim2.new(0,48,0,27),
        BackgroundTransparency = 1,
        Text             = "Till: ∞",
        TextColor3       = C.ACCENT,
        Font             = FREG,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
    }, ubar)

    -- ── Content ───────────────────────────────────────────────────────────────
    local content = mk("Frame", {
        Size             = UDim2.new(1, -185, 1, -46),
        Position         = UDim2.new(0, 185, 0, 46),
        BackgroundColor3 = C.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, win)

    self._gui       = gui
    self._win       = win
    self._sidescroll = sideScroll
    self._content   = content
    self._tabs      = {}
    self._active    = nil
    self._W         = W
    self._H         = H

    return self
end

-- ── AddCategory ───────────────────────────────────────────────────────────────
function NeverLoseLib:AddCategory(name)
    local cat = {_lib = self}

    local groupLabel = mk("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text             = string.upper(name),
        TextColor3       = C.GROUP_TEXT,
        Font             = FBOLD,
        TextSize         = 9,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = #self._tabs * 10,
    }, self._sidescroll)
    pad(0, 0, 0, 14, groupLabel)

    function cat:AddTab(tabName)
        local lib = self._lib

        -- content frame for this tab
        local tabFrame = mk("ScrollingFrame", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            Visible              = false,
            ScrollBarThickness   = 3,
            ScrollBarImageColor3 = C.ACCENT,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        }, lib._content)
        lst(10, nil, tabFrame)
        pad(12, 14, 14, 14, tabFrame)

        -- sidebar row
        local row = mk("Frame", {
            Size        = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            LayoutOrder = #lib._tabs * 10 + 5,
        }, lib._sidescroll)

        local bar = mk("Frame", {
            Size             = UDim2.new(0, 3, 0, 0),
            Position         = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint      = Vector2.new(0, 0.5),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel  = 0,
        }, row)
        corner(2, bar)

        local btn = mk("TextButton", {
            Size             = UDim2.new(1, -4, 1, 0),
            Position         = UDim2.new(0, 4, 0, 0),
            BackgroundColor3 = C.SIDEBAR,
            BackgroundTransparency = 1,
            Text             = "",
            BorderSizePixel  = 0,
            ClipsDescendants = true,
        }, row)
        corner(5, btn)

        local dot = mk("Frame", {
            Size             = UDim2.new(0, 6, 0, 6),
            Position         = UDim2.new(0, 14, 0.5, -3),
            BackgroundColor3 = C.SUBTEXT,
        }, btn)
        corner(99, dot)

        local lbl = mk("TextLabel", {
            Size             = UDim2.new(1, -30, 1, 0),
            Position         = UDim2.new(0, 28, 0, 0),
            BackgroundTransparency = 1,
            Text             = tabName,
            TextColor3       = C.SUBTEXT,
            Font             = FMED,
            TextSize         = 13,
            TextXAlignment   = Enum.TextXAlignment.Left,
        }, btn)

        local entry = {btn=btn, bar=bar, dot=dot, lbl=lbl, frame=tabFrame}
        table.insert(lib._tabs, entry)

        local function activate()
            for _, e in ipairs(lib._tabs) do
                e.frame.Visible = false
                tw(e.bar, {Size = UDim2.new(0,3,0,0)})
                tw(e.btn, {BackgroundTransparency = 1})
                tw(e.dot, {BackgroundColor3 = C.SUBTEXT})
                tw(e.lbl, {TextColor3 = C.SUBTEXT})
            end
            tabFrame.Visible = true
            tw(bar, {Size = UDim2.new(0,3,0.6,0)})
            tw(btn, {BackgroundTransparency = 0.86})
            tw(dot, {BackgroundColor3 = C.ACCENT})
            tw(lbl, {TextColor3 = C.ACCENT})
            lib._active = entry
        end

        btn.MouseButton1Click:Connect(function() ripple(btn); activate() end)
        btn.MouseEnter:Connect(function()
            if lib._active ~= entry then tw(btn, {BackgroundTransparency = 0.92}) end
        end)
        btn.MouseLeave:Connect(function()
            if lib._active ~= entry then tw(btn, {BackgroundTransparency = 1}) end
        end)

        if #lib._tabs == 1 then activate() end

        -- ── Tab object ────────────────────────────────────────────────────────
        local tab = {_frame = tabFrame}

        function tab:AddSection(secName)
            local sec = {}
            local secFrame = mk("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = C.SECTION_BG,
                BorderSizePixel  = 0,
            }, self._frame)
            corner(6, secFrame)
            stroke(C.BORDER, 1, secFrame)

            local inner = mk("Frame", {
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
            }, secFrame)
            pad(10, 12, 10, 12, inner)
            lst(7, nil, inner)

            -- header
            mk("TextLabel", {
                Size          = UDim2.new(1,0,0,18),
                BackgroundTransparency = 1,
                Text          = secName,
                TextColor3    = C.TEXT,
                Font          = FBOLD,
                TextSize      = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder   = 0,
            }, inner)

            mk("Frame", {
                Size          = UDim2.new(1,0,0,1),
                BackgroundColor3 = C.BORDER,
                BorderSizePixel = 0,
                LayoutOrder   = 1,
            }, inner)

            local order = 1

            local function row(h)
                order = order + 1
                return mk("Frame", {
                    Size          = UDim2.new(1,0,0,h or 30),
                    BackgroundTransparency = 1,
                    LayoutOrder   = order,
                }, inner)
            end

            -- ── Toggle ────────────────────────────────────────────────────────
            function sec:AddToggle(name, default, callback)
                local val = default or false
                local r   = row(30)

                mk("TextLabel", {
                    Size          = UDim2.new(1,-46,1,0),
                    BackgroundTransparency = 1,
                    Text          = name,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, r)

                local track = mk("TextButton", {
                    Size          = UDim2.new(0,38,0,20),
                    Position      = UDim2.new(1,-38,0.5,-10),
                    BackgroundColor3 = val and C.ACCENT or C.TOGGLE_OFF,
                    Text          = "",
                    BorderSizePixel = 0,
                }, r)
                corner(99, track)

                local thumb = mk("Frame", {
                    Size          = UDim2.new(0,14,0,14),
                    Position      = val and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7),
                    BackgroundColor3 = C.WHITE,
                    BorderSizePixel  = 0,
                }, track)
                corner(99, thumb)

                local function set(v)
                    val = v
                    tw(track, {BackgroundColor3 = v and C.ACCENT or C.TOGGLE_OFF})
                    tw(thumb, {Position = v
                        and UDim2.new(1,-17,0.5,-7)
                        or  UDim2.new(0,3,0.5,-7)
                    })
                    if callback then callback(v) end
                end

                track.MouseButton1Click:Connect(function() set(not val) end)

                local ctrl = {}
                function ctrl:Set(v) set(v) end
                function ctrl:Get() return val end
                return ctrl
            end

            -- ── Slider ────────────────────────────────────────────────────────
            function sec:AddSlider(name, min, max, default, callback)
                local val = math.clamp(default or min, min, max)
                local r   = row(40)

                local topRow = mk("Frame", {
                    Size = UDim2.new(1,0,0,16),
                    BackgroundTransparency = 1,
                }, r)

                mk("TextLabel", {
                    Size          = UDim2.new(0.75,0,1,0),
                    BackgroundTransparency = 1,
                    Text          = name,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, topRow)

                local valLbl = mk("TextLabel", {
                    Size          = UDim2.new(0.25,0,1,0),
                    Position      = UDim2.new(0.75,0,0,0),
                    BackgroundTransparency = 1,
                    Text          = tostring(val),
                    TextColor3    = C.SUBTEXT,
                    Font          = FREG,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                }, topRow)

                local trkFrame = mk("Frame", {
                    Size          = UDim2.new(1,0,0,4),
                    Position      = UDim2.new(0,0,0,24),
                    BackgroundColor3 = C.TRACK,
                    BorderSizePixel  = 0,
                }, r)
                corner(99, trkFrame)

                local fill = mk("Frame", {
                    Size          = UDim2.new((val-min)/(max-min),0,1,0),
                    BackgroundColor3 = C.ACCENT,
                    BorderSizePixel  = 0,
                }, trkFrame)
                corner(99, fill)

                local knob = mk("TextButton", {
                    Size          = UDim2.new(0,14,0,14),
                    Position      = UDim2.new((val-min)/(max-min),-7,0.5,-7),
                    BackgroundColor3 = C.ACCENTGLOW,
                    Text          = "",
                    BorderSizePixel  = 0,
                    ZIndex        = 4,
                }, trkFrame)
                corner(99, knob)
                stroke(Color3.fromRGB(0,220,255), 1.5, knob)

                local sliding = false

                local function applyRel(rel)
                    rel = math.clamp(rel, 0, 1)
                    val = math.floor(min + rel*(max-min))
                    fill.Size      = UDim2.new(rel, 0, 1, 0)
                    knob.Position  = UDim2.new(rel, -7, 0.5, -7)
                    valLbl.Text    = tostring(val)
                    if callback then callback(val) end
                end

                knob.MouseButton1Down:Connect(function() sliding = true end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliding = false
                    end
                end)
                UIS.InputChanged:Connect(function(i)
                    if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local abs = trkFrame.AbsolutePosition
                        local sz  = trkFrame.AbsoluteSize
                        applyRel((i.Position.X - abs.X) / sz.X)
                    end
                end)
                trkFrame.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        local abs = trkFrame.AbsolutePosition
                        local sz  = trkFrame.AbsoluteSize
                        applyRel((i.Position.X - abs.X) / sz.X)
                    end
                end)

                local ctrl = {}
                function ctrl:Set(v)
                    local rel = math.clamp((v-min)/(max-min),0,1)
                    val = math.floor(min + rel*(max-min))
                    tw(fill, {Size = UDim2.new(rel,0,1,0)})
                    tw(knob, {Position = UDim2.new(rel,-7,0.5,-7)})
                    valLbl.Text = tostring(val)
                    if callback then callback(val) end
                end
                function ctrl:Get() return val end
                return ctrl
            end

            -- ── Button ────────────────────────────────────────────────────────
            function sec:AddButton(name, callback)
                local r   = row(30)
                local btn = mk("TextButton", {
                    Size          = UDim2.new(1,0,1,0),
                    BackgroundColor3 = C.INPUT_BG,
                    Text          = name,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 12,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                }, r)
                corner(5, btn)
                stroke(C.BORDER, 1, btn)

                btn.MouseEnter:Connect(function()
                    tw(btn, {BackgroundColor3 = Color3.fromRGB(34,34,45), TextColor3 = C.ACCENT})
                end)
                btn.MouseLeave:Connect(function()
                    tw(btn, {BackgroundColor3 = C.INPUT_BG, TextColor3 = C.TEXT})
                end)
                btn.MouseButton1Click:Connect(function()
                    ripple(btn)
                    if callback then callback() end
                end)
                return self
            end

            -- ── Dropdown ──────────────────────────────────────────────────────
            function sec:AddDropdown(name, options, default, callback)
                local val  = default or options[1]
                local open = false
                local r    = row(30)

                mk("TextLabel", {
                    Size          = UDim2.new(1,-136,1,0),
                    BackgroundTransparency = 1,
                    Text          = name,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, r)

                local dBtn = mk("TextButton", {
                    Size          = UDim2.new(0,124,0,24),
                    Position      = UDim2.new(1,-124,0.5,-12),
                    BackgroundColor3 = C.INPUT_BG,
                    Text          = val .. "  ▾",
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 11,
                    BorderSizePixel  = 0,
                    ClipsDescendants = false,
                }, r)
                corner(5, dBtn)
                stroke(C.BORDER, 1, dBtn)

                local dList = mk("Frame", {
                    Size          = UDim2.new(0,124,0,0),
                    Position      = UDim2.new(0,0,1,4),
                    BackgroundColor3 = C.INPUT_BG,
                    BorderSizePixel  = 0,
                    Visible       = false,
                    ZIndex        = 20,
                    ClipsDescendants = true,
                }, dBtn)
                corner(5, dList)
                stroke(C.BORDER, 1, dList)
                lst(0, nil, dList)

                local function rebuild()
                    for _, ch in ipairs(dList:GetChildren()) do
                        if ch:IsA("TextButton") then ch:Destroy() end
                    end
                    for _, opt in ipairs(options) do
                        local item = mk("TextButton", {
                            Size          = UDim2.new(1,0,0,26),
                            BackgroundColor3 = C.INPUT_BG,
                            Text          = opt,
                            TextColor3    = opt == val and C.ACCENT or C.TEXT,
                            Font          = FMED,
                            TextSize      = 11,
                            BorderSizePixel  = 0,
                            ZIndex        = 21,
                        }, dList)
                        pad(0,6,0,8, item)
                        item.MouseEnter:Connect(function()
                            tw(item, {BackgroundColor3 = C.TAB_HOVER})
                        end)
                        item.MouseLeave:Connect(function()
                            tw(item, {BackgroundColor3 = C.INPUT_BG})
                        end)
                        item.MouseButton1Click:Connect(function()
                            val = opt
                            dBtn.Text = val .. "  ▾"
                            open = false
                            tw(dList, {Size = UDim2.new(0,124,0,0)})
                            task.delay(0.2, function() dList.Visible = false end)
                            rebuild()
                            if callback then callback(val) end
                        end)
                    end
                end
                rebuild()

                dBtn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        dList.Visible = true
                        tw(dList, {Size = UDim2.new(0,124,0,#options*26)})
                    else
                        tw(dList, {Size = UDim2.new(0,124,0,0)})
                        task.delay(0.2, function() dList.Visible = false end)
                    end
                end)

                local ctrl = {}
                function ctrl:Get() return val end
                function ctrl:Set(v) val=v; dBtn.Text=v.."  ▾"; rebuild() end
                function ctrl:SetOptions(o) options=o; rebuild() end
                return ctrl
            end

            -- ── Textbox ───────────────────────────────────────────────────────
            function sec:AddTextbox(name, placeholder, callback)
                local r = row(30)
                mk("TextLabel", {
                    Size          = UDim2.new(1,-136,1,0),
                    BackgroundTransparency = 1,
                    Text          = name,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, r)

                local box = mk("TextBox", {
                    Size          = UDim2.new(0,124,0,24),
                    Position      = UDim2.new(1,-124,0.5,-12),
                    BackgroundColor3 = C.INPUT_BG,
                    Text          = "",
                    PlaceholderText  = placeholder or "",
                    PlaceholderColor3 = C.SUBTEXT,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 11,
                    BorderSizePixel  = 0,
                    ClearTextOnFocus = false,
                }, r)
                corner(5, box)
                stroke(C.BORDER, 1, box)
                pad(0,6,0,6, box)

                box.Focused:Connect(function()
                    tw(box, {BackgroundColor3 = Color3.fromRGB(32,32,42)})
                end)
                box.FocusLost:Connect(function()
                    tw(box, {BackgroundColor3 = C.INPUT_BG})
                    if callback then callback(box.Text) end
                end)

                local ctrl = {}
                function ctrl:Get() return box.Text end
                function ctrl:Set(v) box.Text = v end
                return ctrl
            end

            -- ── Keybind ───────────────────────────────────────────────────────
            function sec:AddKeybind(name, default, callback)
                local key     = default or Enum.KeyCode.Unknown
                local binding = false
                local r       = row(30)

                mk("TextLabel", {
                    Size          = UDim2.new(1,-90,1,0),
                    BackgroundTransparency = 1,
                    Text          = name,
                    TextColor3    = C.TEXT,
                    Font          = FMED,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }, r)

                local kbBtn = mk("TextButton", {
                    Size          = UDim2.new(0,78,0,24),
                    Position      = UDim2.new(1,-78,0.5,-12),
                    BackgroundColor3 = C.INPUT_BG,
                    Text          = key.Name,
                    TextColor3    = C.SUBTEXT,
                    Font          = FMED,
                    TextSize      = 11,
                    BorderSizePixel  = 0,
                }, r)
                corner(5, kbBtn)
                stroke(C.BORDER, 1, kbBtn)

                kbBtn.MouseButton1Click:Connect(function()
                    binding       = true
                    kbBtn.Text    = "..."
                    kbBtn.TextColor3 = C.ACCENT
                end)
                UIS.InputBegan:Connect(function(i, proc)
                    if binding and not proc
                    and i.UserInputType == Enum.UserInputType.Keyboard then
                        key              = i.KeyCode
                        binding          = false
                        kbBtn.Text       = key.Name
                        kbBtn.TextColor3 = C.SUBTEXT
                        if callback then callback(key) end
                    end
                end)

                local ctrl = {}
                function ctrl:Get() return key end
                return ctrl
            end

            -- ── Label ─────────────────────────────────────────────────────────
            function sec:AddLabel(text)
                local r = row(20)
                mk("TextLabel", {
                    Size          = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text          = text,
                    TextColor3    = C.SUBTEXT,
                    Font          = FREG,
                    TextSize      = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped   = true,
                }, r)
                return self
            end

            -- ── Separator ─────────────────────────────────────────────────────
            function sec:AddSeparator()
                order = order + 1
                mk("Frame", {
                    Size          = UDim2.new(1,0,0,1),
                    BackgroundColor3 = C.BORDER,
                    BorderSizePixel  = 0,
                    LayoutOrder   = order,
                }, inner)
                return self
            end

            return sec
        end

        return tab
    end

    return cat
end

-- ── Notify ────────────────────────────────────────────────────────────────────
function NeverLoseLib:Notify(title, body, duration)
    duration = duration or 3.5

    local existing = CoreGui:FindFirstChild("NLNotifs")
    local nGui = existing or mk("ScreenGui", {
        Name           = "NLNotifs",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn   = false,
        DisplayOrder   = 1000,
    }, CoreGui)
    if not existing then protect(nGui) end

    local holder = nGui:FindFirstChild("H") or (function()
        local h = mk("Frame", {
            Name = "H",
            Size = UDim2.new(0,290,1,0),
            Position = UDim2.new(1,-305,0,0),
            BackgroundTransparency = 1,
        }, nGui)
        lst(8, nil, h)
        pad(16,0,16,0, h)
        return h
    end)()

    local card = mk("Frame", {
        Size          = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.SECTION_BG,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
    }, holder)
    corner(6, card)
    stroke(C.BORDER, 1, card)

    local accentBar = mk("Frame", {
        Size          = UDim2.new(0,3,1,0),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
        ZIndex        = 2,
    }, card)
    corner(2, accentBar)

    local inner = mk("Frame", {
        Size          = UDim2.new(1,-10,0,0),
        Position      = UDim2.new(0,10,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, card)
    pad(8,8,8,6, inner)
    lst(3, nil, inner)

    mk("TextLabel", {
        Size          = UDim2.new(1,0,0,15),
        BackgroundTransparency = 1,
        Text          = title,
        TextColor3    = C.ACCENT,
        Font          = FBOLD,
        TextSize      = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, inner)

    mk("TextLabel", {
        Size          = UDim2.new(1,0,0,0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text          = body,
        TextColor3    = C.TEXT,
        Font          = FREG,
        TextSize      = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped   = true,
    }, inner)

    local prog = mk("Frame", {
        Size          = UDim2.new(1,0,0,2),
        Position      = UDim2.new(0,0,1,-2),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel  = 0,
    }, card)

    TweenService:Create(prog,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0,0,0,2)}
    ):Play()

    task.delay(duration, function()
        tw(card, {BackgroundTransparency = 1})
        task.delay(0.25, function() card:Destroy() end)
    end)
end

-- ── Toggle visibility ─────────────────────────────────────────────────────────
function NeverLoseLib:SetKeybind(key)
    UIS.InputBegan:Connect(function(i, proc)
        if not proc and i.KeyCode == key then
            self._win.Visible = not self._win.Visible
        end
    end)
end

-- ── Destroy ───────────────────────────────────────────────────────────────────
function NeverLoseLib:Destroy()
    self._gui:Destroy()
end

-- ── expose globally + return ──────────────────────────────────────────────────
getgenv().NeverLoseLib = NeverLoseLib
return NeverLoseLib
