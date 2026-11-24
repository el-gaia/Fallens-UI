--==============================================================================
-- FALLENS UI Library · v2.0 · 2026-11-24
-- Modern remake of the Mario Hub UI standalone build (original by xDTaraZz).
-- Rebranded FALLENS: new logo, lucide.dev icons via rbxassetid, all 8-bit Mario
-- visuals removed (sprite engine, intro runner, WORLD 1-1 pill, brick floor,
-- clouds, pipes, coin spin, block-bump).
-- Every theme now carries exactly ONE accent color; the window title and all
-- accent-colored elements use the active theme's Accent.
-- Icon set: lucide.dev (ISC) mapped to Roblox assets via frappedevs/lucideblox.
--==============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Version = "2.0",
    Options = {},
    Toggles = {},
    Unloaded = false,
    Window = nil,
}

local Config = {
    Name = "FALLENS",
    GuiAttribute = "FallensUI",
    Root = "fallens",
    ConfigRoot = "fallens/configs",
    -- Re-upload this PNG to a permanent host when the signed URL expires;
    -- you can also override it at runtime: FALLENS:SetAssets({ logo = "rbxassetid://..." })
    DefaultAssets = {
        logo = "https://cdn.discordapp.com/attachments/1557688744147034162/1574424970082394112/rn_image_picker_lib_temp_48f24650-a5a9-45d2-90b5-0a54859c29a3.png?ex=6b059904&is=6b044784&hm=0807d117c227b3d76645a13af3c015a4a83e1c5f1fa416381068d2283587416b&",
    },
    SeasonTheme = "Dark",
    HttpTimeout = 8,
    Text = { Title = 26, Header = 22, Group = 16, Label = 15, Desc = 13, Small = 12, Button = 15, Watermark = 13, Section = 13 },
    Window = {
        Width = 820, Height = 560, MinWidth = 520, MinHeight = 360,
        TouchMinWidth = 320, TouchMinHeight = 260,
        Topbar = 56, Sidebar = 196, SidebarCompact = 64, Header = 62, UserCard = 58,
        CompactBreakpoint = 640, TwoColumnMin = 540, Margin = 24, TouchMargin = 10,
        Radius = 12, Stroke = 3, Shadow = 6,
    },
    Metrics = {
        Desktop = { Row = 32, Box = 32, Item = 30, Track = 10, Knob = 18, Switch = Vector2.new(42, 22), SwitchKnob = 16, Tab = 38, Check = 22, Icon = 18, Depth = 4, Radius = 8 },
        Touch = { Row = 38, Box = 36, Item = 36, Track = 12, Knob = 24, Switch = Vector2.new(50, 26), SwitchKnob = 20, Tab = 44, Check = 26, Icon = 20, Depth = 4, Radius = 8 },
    },
    Button = { PadX = 14, IconGap = 6, Depth = 4, HoverLighten = 0.14 },
    Group = { Header = 36, PadX = 12, PadY = 10, Shadow = 4, Radius = 12, Stroke = 2 },
    Gap = { X = 8, Y = 6, Column = 12 },
    Page = { Pad = 14, ScrollBar = 6 },
    Dropdown = { MaxVisible = 7, SearchThreshold = 8, MinWidth = 170 },
    ColorPicker = { Field = 150, Hue = 14 },
    Notify = { Width = 300, TouchWidth = 260, Duration = 4, Gap = 8 },
    Tween = { Fast = 0.15, Normal = 0.2, Slide = 0.28, Pop = 0.32, Collapse = 0.24, Notify = 0.42 },
    Ease = {
        Out = { Enum.EasingStyle.Quint, Enum.EasingDirection.Out },
        Back = { Enum.EasingStyle.Back, Enum.EasingDirection.Out },
        In = { Enum.EasingStyle.Quad, Enum.EasingDirection.In },
        Sine = { Enum.EasingStyle.Sine, Enum.EasingDirection.InOut },
        Linear = { Enum.EasingStyle.Linear, Enum.EasingDirection.InOut },
        Bounce = { Enum.EasingStyle.Bounce, Enum.EasingDirection.Out },
    },
    Layer = { Window = 10, Watermark = 30, Float = 40, Overlay = 50, Modal = 52, Tooltip = 55, Notify = 60 },
    DragThreshold = 6,
    ConfirmWindow = 2,
    TooltipDelay = 0.45,
    ScaleRange = { Min = 0.7, Max = 1.4 },
    MouseNames = {
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
    },
}

local function rgb(hex)
    return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end

-- Each theme defines ONE accent color. The window title and every
-- accent-colored element (toggles, sliders, tabs, buttons, notifications,
-- progress, ...) reads it from the active theme's Accent token.
local function Palette(spec)
    local palette = {}
    for token, value in pairs(spec) do
        if type(value) == "string" then
            palette[token] = rgb(value)
        else
            palette[token] = value
        end
    end
    return palette
end

local Themes = {
    Order = { "Overworld", "Halloween", "Light", "Dark", "Underground", "Castle", "Ghost House", "Star Road", "Desert", "Ice Land", "Jungle", "Sky World" },
    Overworld = Palette({
        Backdrop = "C4D6EC", BackdropAlt = "E2E9F2", Topbar = "7092CC", Sidebar = "96563E", SidebarAlt = "804834",
        SidebarText = "FCF2E6", SidebarMuted = "E2C4B0", Panel = "FAF6EE", PanelHeader = "F1E7D4", Element = "FFFCF6", Hover = "EEE2CA",
        Outline = "3E384A", Shadow = "7880A0", Text = "3A3028", SubText = "76685A", Muted = "A09484", Track = "DED4C4",
        Accent = "D64C40", OnAccent = "FFFFFF",
    }),
    Halloween = Palette({
        Backdrop = "1A1226", BackdropAlt = "2A1838", Topbar = "2B1A3E", Sidebar = "3A2150", SidebarAlt = "2C1840",
        SidebarText = "FFF1E2", SidebarMuted = "C9A9D8", Panel = "241830", PanelHeader = "301F40", Element = "2E2140", Hover = "3C2A52",
        Outline = "0B0610", Shadow = "0B0610", Text = "FFF1E2", SubText = "D7BFD9", Muted = "9C85A8", Track = "4A3460",
        Accent = "F28A2E", OnAccent = "1E1024",
    }),
    Light = Palette({
        Backdrop = "F2EEE6", BackdropAlt = "FAF8F3", Topbar = "EDE4D4", Sidebar = "EAE2D4", SidebarAlt = "DDD3C2",
        SidebarText = "4A3F35", SidebarMuted = "9B8E7E", Panel = "FFFFFF", PanelHeader = "F6F1E8", Element = "FBF9F5", Hover = "F0E8DA",
        Outline = "4A4458", Shadow = "CFC7BA", Text = "3A3028", SubText = "7C6E60", Muted = "ABA092", Track = "E6DED2",
        Accent = "D64C40", OnAccent = "FFFFFF",
    }),
    Dark = Palette({
        Backdrop = "1E1F26", BackdropAlt = "25262F", Topbar = "17181E", Sidebar = "22232B", SidebarAlt = "1B1C22",
        SidebarText = "E8E6F0", SidebarMuted = "8D8A9C", Panel = "2A2B34", PanelHeader = "31323C", Element = "353743", Hover = "3E404D",
        Outline = "0E0E12", Shadow = "0E0E12", Text = "ECEAF4", SubText = "A9A6B8", Muted = "7B788C", Track = "454756",
        Accent = "E0584C", OnAccent = "FFFFFF",
    }),
    Underground = Palette({
        Backdrop = "141A36", BackdropAlt = "1E2750", Topbar = "0E1330", Sidebar = "22327A", SidebarAlt = "1A2762",
        SidebarText = "ECF0FF", SidebarMuted = "98A8E0", Panel = "1F2749", PanelHeader = "27305A", Element = "2C3666", Hover = "36417A",
        Outline = "05060F", Shadow = "05060F", Text = "F2F4FF", SubText = "AEB6E2", Muted = "7C86B8", Track = "3C4780",
        Accent = "5B8CF0", OnAccent = "1E1B2E",
    }),
    Castle = Palette({
        Backdrop = "1E1818", BackdropAlt = "33201C", Topbar = "150F0F", Sidebar = "4A4040", SidebarAlt = "3A3232",
        SidebarText = "FFF1E6", SidebarMuted = "C8B0A4", Panel = "2B2323", PanelHeader = "352B2B", Element = "3D3232", Hover = "4A3D3D",
        Outline = "0A0707", Shadow = "0A0707", Text = "FFF1E6", SubText = "D9BFB0", Muted = "9F8579", Track = "524242",
        Accent = "E8703A", OnAccent = "FFFFFF",
    }),
    ["Ghost House"] = Palette({
        Backdrop = "1C2226", BackdropAlt = "232B30", Topbar = "151A1E", Sidebar = "2C3A3A", SidebarAlt = "223030",
        SidebarText = "E6F2EE", SidebarMuted = "8FB0A8", Panel = "242C31", PanelHeader = "2B353B", Element = "303B42", Hover = "39454D",
        Outline = "0B0E10", Shadow = "0B0E10", Text = "EAF4F1", SubText = "A3BDB6", Muted = "71898A", Track = "3E4B52",
        Accent = "4FB89C", OnAccent = "1C2126",
    }),
    ["Star Road"] = Palette({
        Backdrop = "1C1236", BackdropAlt = "2D1C54", Topbar = "130B28", Sidebar = "3B2475", SidebarAlt = "2D1A5C",
        SidebarText = "FFF7FF", SidebarMuted = "CDB9F2", Panel = "251749", PanelHeader = "2E1D5A", Element = "34225F", Hover = "412A72",
        Outline = "07030F", Shadow = "07030F", Text = "FFF7FF", SubText = "CDB9F2", Muted = "9580C4", Track = "4A3480",
        Accent = "E85CA8", OnAccent = "26144A",
    }),
    Desert = Palette({
        Backdrop = "E8DABD", BackdropAlt = "F4EBD8", Topbar = "C99A62", Sidebar = "B07E4E", SidebarAlt = "966A40",
        SidebarText = "FFF6E8", SidebarMuted = "EED4B2", Panel = "FFF9EE", PanelHeader = "F4E6CC", Element = "FFFCF6", Hover = "F0DFC0",
        Outline = "5A4632", Shadow = "C2A07A", Text = "4A3828", SubText = "86705A", Muted = "B09A80", Track = "E6D6BC",
        Accent = "C8643A", OnAccent = "FFFFFF",
    }),
    ["Ice Land"] = Palette({
        Backdrop = "D8E8F4", BackdropAlt = "EDF4FA", Topbar = "86B0D2", Sidebar = "6A96BA", SidebarAlt = "5A82A4",
        SidebarText = "F4FAFF", SidebarMuted = "CFE3F2", Panel = "F8FCFF", PanelHeader = "E6F0F8", Element = "FFFFFF", Hover = "DCEAF5",
        Outline = "3E4F63", Shadow = "A6BACE", Text = "2E3D4D", SubText = "62788E", Muted = "95A8BA", Track = "D4E1EC",
        Accent = "3A8AC8", OnAccent = "FFFFFF",
    }),
    Jungle = Palette({
        Backdrop = "1F2E23", BackdropAlt = "293C2D", Topbar = "17231A", Sidebar = "2F4A33", SidebarAlt = "253B29",
        SidebarText = "EEF7EA", SidebarMuted = "A3C29C", Panel = "26382A", PanelHeader = "2E4332", Element = "334A37", Hover = "3D5641",
        Outline = "0C120D", Shadow = "0C120D", Text = "EEF6EA", SubText = "AFC6A8", Muted = "7E957A", Track = "445C47",
        Accent = "E08A3A", OnAccent = "1F2A1F",
    }),
    ["Sky World"] = Palette({
        Backdrop = "E6EEFC", BackdropAlt = "F6F9FF", Topbar = "A4BEEA", Sidebar = "8AA4D6", SidebarAlt = "7A92C4",
        SidebarText = "FFFFFF", SidebarMuted = "E3EBFA", Panel = "FFFFFF", PanelHeader = "EEF3FC", Element = "FFFFFF", Hover = "E4ECFA",
        Outline = "46506A", Shadow = "B6C2DA", Text = "333C52", SubText = "6A7590", Muted = "9AA4BC", Track = "DCE3F0",
        Accent = "4A6FB5", OnAccent = "FFFFFF",
    }),
    -- Neutral tokens shared by every theme (not accent colors).
    Shared = Palette({
        White = "FFFFFF", Black = "000000", Ink = "2E2838", Knob = "FFFFFF", Danger = "E0584C", DangerDark = "A83A30",
    }),
}

local State = {
    Gui = nil,
    Overlay = nil,
    Window = nil,
    Drag = nil,
    Binding = nil,
    MenuKey = "LeftControl",
    ThemeName = "Dark",
    UserScale = 1,
    Touch = false,
    KeyPickers = {},
    Connections = {},
    Tasks = {},
    UnloadHooks = {},
    Fps = 60,
    StartTime = os.clock(),
}

local Util = {}
local Anim = {}
local Draw = {}
local Assets = { Overrides = {}, Cache = {} }
local Theme = { Colors = {}, Bound = {}, Renderers = setmetatable({}, { __mode = "k" }), InstanceRenderers = {} }
local Icons = {}
local Gui = { Stack = {} }
local Tooltip = {}
local Notify = {}
local Watermark = {}
local Float = {}
local Keybinds = {}
local Configs = { Folder = Config.ConfigRoot .. "/default" }
local Widget = {}
local Container = {}
Container.__index = Container

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Groupbox = {}
Groupbox.__index = Groupbox
local Visuals = {}

--==============================================================================
-- Util
--==============================================================================

function Util.Try(handler, ...)
    local args = table.pack(...)
    local ok, err = pcall(handler, table.unpack(args, 1, args.n))
    if not ok and type(err) == "string" and not err:find("attempt to call a nil value") then
        warn("[FALLENS] " .. err)
    end
    return ok, err
end

function Util.Connect(signal, handler)
    local connection = signal:Connect(handler)
    table.insert(State.Connections, connection)
    return connection
end

function Util.Every(interval, callback)
    local job = { Interval = math.max(0.05, interval or 1), Run = callback, Elapsed = 0, Busy = false }
    table.insert(State.Tasks, job)
    return job
end

function Util.Await(timeout, handler)
    local result
    local thread = coroutine.create(function(...)
        result = table.pack(handler(...))
    end)
    local ok = coroutine.resume(thread, ...)
    if not ok or coroutine.status(thread) == "dead" then
        return coroutine.status(thread) == "dead", result and table.unpack(result, 1, result.n)
    end
    local deadline = os.clock() + (timeout or 5)
    while coroutine.status(thread) ~= "dead" and os.clock() < deadline do
        task.wait(0.05)
    end
    return coroutine.status(thread) == "dead", result and table.unpack(result, 1, result.n)
end

function Util.GuiParent()
    local ok, hidden = pcall(function()
        return gethui()
    end)
    if ok and typeof(hidden) == "Instance" then
        return hidden
    end
    local okCore = pcall(function()
        CoreGui:FindFirstChild(Config.Name)
        return CoreGui
    end)
    if okCore then
        return CoreGui
    end
    return LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
end

function Util.FileApi()
    return type(writefile) == "function" and type(readfile) == "function"
end

function Util.EnsureFolder(path)
    if type(makefolder) == "function" then
        pcall(makefolder, path)
    end
end

function Util.Exists(path)
    if type(isfile) == "function" then
        local ok, found = pcall(isfile, path)
        return ok and found == true
    end
    if type(readfile) == "function" then
        local ok = pcall(readfile, path)
        return ok
    end
    return false
end

function Util.Sanitize(name)
    return tostring(name):gsub("[^%w%-_]+", "_"):gsub("^_+", ""):gsub("_+$", "")
end

function Util.Hash(text)
    local hash = 5381
    for _ = 1, #text do
        hash = (hash * 33 + text:byte(_, _)) % 2147483647
    end
    return string.format("%08x", hash)
end

function Util.InputName(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.Keyboard then
        return input.KeyCode.Name
    end
    return Config.MouseNames[inputType]
end

function Util.KeyName(key)
    if key == nil then
        return nil
    end
    if type(key) == "string" then
        return key
    end
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.KeyCode then
            return key.Name
        end
        return Config.MouseNames[key] and Config.MouseNames[key] or key.Name
    end
    return tostring(key)
end

function Util.IsPointer(input)
    local kind = input.UserInputType
    return kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.MouseButton2
        or kind == Enum.UserInputType.MouseButton3 or kind == Enum.UserInputType.Touch
end

function Util.IsMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

function Util.Inside(inst, position)
    local abs = inst.AbsolutePosition
    local size = inst.AbsoluteSize
    return position.X >= abs.X and position.X <= abs.X + size.X
        and position.Y >= abs.Y and position.Y <= abs.Y + size.Y
end

function Util.TextSize(token)
    return Config.Text[token] or 15
end

function Util.Http(url)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and #body > 0 then
        return body
    end
    return nil
end

function Util.Metrics()
    return State.Touch and Config.Metrics.Touch or Config.Metrics.Desktop
end

--==============================================================================
-- Anim (tween helpers on top of TweenService)
--==============================================================================

function Anim.Tween(inst, goal, duration, ease, delay, reverse)
    local style = Config.Ease[ease or "Out"] or Config.Ease.Out
    local info = TweenInfo.new(duration or 0.2, style[1], style[2], -1, reverse == true, delay or 0)
    local tween = TweenService:Create(inst, info, goal)
    tween:Play()
    return tween
end

function Anim.Fade(inst, transparency, duration)
    return Anim.Tween(inst, { BackgroundTransparency = transparency }, duration or 0.18, "Out")
end

function Anim.Bump(inst, rise)
    local base = inst.Position
    local up = Anim.Tween(inst, { Position = base + UDim2.fromOffset(0, -(rise or 8)) }, 0.12, "Back")
    up.Completed:Once(function()
        Anim.Tween(inst, { Position = base }, 0.22, "Bounce")
    end)
    return up
end

Anim.Loops = {}
Anim.GroupState = {}

function Anim.Loop(group, inst, goal, duration, ease)
    local style = Config.Ease[ease or "Sine"] or Config.Ease.Sine
    local info = TweenInfo.new(duration or 1, style[1], style[2], -1, true)
    local tween = TweenService:Create(inst, info, goal)
    Anim.Loops[group] = Anim.Loops[group] or {}
    Anim.Loops[group][inst] = { Tween = tween, Goal = goal }
    if Anim.GroupState[group] ~= false then
        tween:Play()
    end
    return tween
end

function Anim.SetGroupActive(group, active)
    Anim.GroupState[group] = active == true
    local list = Anim.Loops[group]
    if not list then
        return
    end
    for inst, entry in pairs(list) do
        if not inst.Parent then
            list[inst] = nil
        elseif active then
            entry.Tween:Play()
        else
            entry.Tween:Cancel()
        end
    end
end

function Anim.StopAll()
    for _, list in pairs(Anim.Loops) do
        for _, entry in pairs(list) do
            pcall(function()
                entry.Tween:Cancel()
            end)
        end
    end
    for key in pairs(Anim.Loops) do
        Anim.Loops[key] = nil
    end
    for key in pairs(Anim.GroupState) do
        Anim.GroupState[key] = nil
    end
end

--==============================================================================
-- Fonts
--==============================================================================

local Fonts = {
    Faces = {
        Display = Enum.Font.BuilderSansBold,
        Body = Enum.Font.BuilderSansMedium,
        Desc = Enum.Font.BuilderSans,
        Strong = Enum.Font.BuilderSansBold,
        Logo = Enum.Font.BuilderSansExtraBold,
    },
}

function Fonts.Face(kind)
    return Fonts.Faces[kind] or Fonts.Faces.Body
end

--==============================================================================
-- Theme engine: one accent per theme, re-rendered live on switch
--==============================================================================

function Theme.Apply(name)
    if name == "Order" or name == "Shared" or not Themes[name] then
        name = "Dark"
    end
    local palette = Themes[name]
    State.ThemeName = name
    for token, color in pairs(Themes.Shared) do
        Theme.Colors[token] = color
    end
    for token, color in pairs(palette) do
        Theme.Colors[token] = color
    end
    for inst, map in pairs(Theme.Bound) do
        if inst.Parent then
            Theme.Paint(inst, map)
        else
            Theme.Bound[inst] = nil
        end
    end
    for owner, render in pairs(Theme.Renderers) do
        Util.Try(render)
    end
    for inst, render in pairs(Theme.InstanceRenderers) do
        if inst.Parent then
            Util.Try(render)
        else
            Theme.InstanceRenderers[inst] = nil
        end
    end
end

function Theme.Prune()
    for _, registry in ipairs({ Theme.Bound, Theme.InstanceRenderers }) do
        for inst in pairs(registry) do
            if not inst.Parent then
                registry[inst] = nil
            end
        end
    end
end

function Theme.UnbindTree(root)
    if not root then
        return
    end
    local list = root:GetDescendants()
    table.insert(list, root)
    for _, inst in ipairs(list) do
        Theme.Bound[inst] = nil
        Theme.InstanceRenderers[inst] = nil
    end
end

function Theme.Paint(inst, map)
    for property, token in pairs(map) do
        local color = Theme.Colors[token]
        if color ~= nil and inst[property] ~= color then
            inst[property] = color
        end
    end
end

function Theme.Bind(inst, map)
    local existing = Theme.Bound[inst]
    if existing then
        for property, token in pairs(map) do
            existing[property] = token
        end
    else
        Theme.Bound[inst] = map
    end
    Theme.Paint(inst, map)
    return inst
end

function Theme.OnRender(owner, render)
    local registry = typeof(owner) == "Instance" and Theme.InstanceRenderers or Theme.Renderers
    registry[owner] = render
    Util.Try(render)
end

--==============================================================================
-- Draw helpers
--==============================================================================

function Draw.New(className, props)
    local inst = Instance.new(className)
    local parent = props.Parent
    props.Parent = nil
    for property, value in pairs(props) do
        inst[property] = value
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

function Draw.Corner(inst, radius)
    if radius == nil or radius == 0 then
        return nil
    end
    return Draw.New("UICorner", {
        CornerRadius = typeof(radius) == "number" and UDim.new(0, radius) or radius,
        Parent = inst,
    })
end

function Draw.Stroke(inst, token, thickness, inside)
    local stroke = Draw.New("UIStroke", {
        Thickness = thickness or 1,
        ApplyStrokeMode = inside == true and Enum.ApplyStrokeMode.Contextual or Enum.ApplyStrokeMode.Border,
        Parent = inst,
    })
    if token then
        Theme.Bind(stroke, { Color = token })
    end
    return stroke
end

-- Frame-like box with optional themed face / stroke / corner radius.
function Draw.Box(className, props, face, stroke, radius, thickness)
    local inst = Draw.New(className, props)
    if face then
        Theme.Bind(inst, { BackgroundColor3 = face })
    end
    if stroke then
        Draw.Stroke(inst, stroke, thickness)
    end
    Draw.Corner(inst, radius)
    return inst
end

function Draw.Text(props, face, size, token, text)
    local label = Draw.New("TextLabel", props)
    label.Font = Fonts.Face(face or "Body")
    label.TextSize = size or 15
    label.Text = text ~= nil and tostring(text) or ""
    if token then
        Theme.Bind(label, { TextColor3 = token })
    end
    return label
end

function Draw.List(parent, gap, padded, alignX, alignY)
    return Draw.New("UIListLayout", {
        Padding = UDim.new(0, gap or 6),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = alignX or Enum.HorizontalAlignment.Left,
        VerticalAlignment = alignY or Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = parent,
    })
end

function Draw.Padding(inst, top, right, bottom, left)
    return Draw.New("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        Parent = inst,
    })
end

function Draw.Scroll(props, gap)
    local scroll = Draw.New("ScrollingFrame", props)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = Config.Page.ScrollBar
    scroll.ScrollBarImageTransparency = 0.6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Draw.List(scroll, gap or Config.Gap.Y, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    return scroll
end

-- Logo emblem: plain ImageLabel with the FALLENS logo (no shadow, no sprite).
function Draw.Emblem(parent, size, order)
    local holder = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        LayoutOrder = order or 0,
        Parent = parent,
    })
    local image = Draw.New("ImageLabel", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    Assets.Listen(image)
    task.spawn(function()
        image.Image = Assets.Logo()
    end)
    return holder
end
--============================================================================--
-- lucide.dev icon set mapped to Roblox assets (rbxassetid).
-- Source: frappedevs/lucideblox (MIT) community port of Lucide Icons.
-- Icons are white strokes on transparency: tint them with ImageColor3.
--============================================================================--
local LucideIcons = {
    ["CD"] = "7734110220", ["activity"] = "7733655755", ["airplay"] = "7733655834",
    ["alarm-check"] = "7733655912", ["alarm-clock"] = "7733656100", ["alarm-clock-off"] = "7733656003",
    ["alarm-minus"] = "7733656164", ["alarm-plus"] = "7733658066", ["album"] = "7733658133",
    ["alert-circle"] = "7733658271", ["alert-octagon"] = "7733658335", ["alert-triangle"] = "7733658504",
    ["align-center"] = "7733909776", ["align-center-horizontal"] = "8997380477", ["align-center-vertical"] = "8997380737",
    ["align-end-horizontal"] = "8997380820", ["align-end-vertical"] = "8997380907", ["align-horizonal-distribute-center"] = "8997381028",
    ["align-horizonal-distribute-end"] = "8997381144", ["align-horizonal-distribute-start"] = "8997381290", ["align-horizontal-justify-center"] = "8997381461",
    ["align-horizontal-justify-end"] = "8997381549", ["align-horizontal-justify-start"] = "8997381652", ["align-horizontal-space-around"] = "8997381738",
    ["align-horizontal-space-between"] = "8997381854", ["align-justify"] = "7733661326", ["align-left"] = "7733911357",
    ["align-right"] = "7733663582", ["align-start-horizontal"] = "8997381965", ["align-start-vertical"] = "8997382085",
    ["align-vertical-distribute-center"] = "8997382212", ["align-vertical-distribute-end"] = "8997382326", ["align-vertical-distribute-start"] = "8997382428",
    ["align-vertical-justify-center"] = "8997382502", ["align-vertical-justify-end"] = "8997382584", ["align-vertical-justify-start"] = "8997382639",
    ["align-vertical-space-around"] = "8997382708", ["align-vertical-space-between"] = "8997382793", ["anchor"] = "7733911490",
    ["aperture"] = "7733666258", ["archive"] = "7733911621", ["arrow-big-down"] = "7733668653",
    ["arrow-big-left"] = "7733911731", ["arrow-big-right"] = "7733671493", ["arrow-big-up"] = "7733671663",
    ["arrow-down"] = "7733672933", ["arrow-down-circle"] = "7733671763", ["arrow-down-left"] = "7733672282",
    ["arrow-down-right"] = "7733672831", ["arrow-left"] = "7733673136", ["arrow-left-circle"] = "7733673056",
    ["arrow-left-right"] = "8997382869", ["arrow-right"] = "7733673345", ["arrow-right-circle"] = "7733673229",
    ["arrow-up"] = "7733673717", ["arrow-up-circle"] = "7733673466", ["arrow-up-left"] = "7733673539",
    ["arrow-up-right"] = "7733673646", ["asterisk"] = "7733673800", ["at-sign"] = "7733673907",
    ["award"] = "7733673987", ["axe"] = "7733674079", ["banknote"] = "7733674153",
    ["bar-chart"] = "7733674319", ["bar-chart-2"] = "7733674239", ["battery"] = "7733674820",
    ["battery-charging"] = "7733674402", ["battery-full"] = "7733674503", ["battery-low"] = "7733674589",
    ["battery-medium"] = "7733674731", ["beaker"] = "7733674922", ["bell"] = "7733911828",
    ["bell-minus"] = "7733675028", ["bell-off"] = "7733675107", ["bell-plus"] = "7733675181",
    ["bell-ring"] = "7733675275", ["bike"] = "7733678330", ["binary"] = "7733678388",
    ["bluetooth"] = "7733687147", ["bluetooth-connected"] = "7734110952", ["bluetooth-off"] = "7733914252",
    ["bluetooth-searching"] = "7733914320", ["bold"] = "7733687211", ["book"] = "7733914390",
    ["book-open"] = "7733687281", ["bookmark"] = "7733692043", ["bookmark-minus"] = "7733689754",
    ["bookmark-plus"] = "7734111084", ["bot"] = "7733916988", ["box"] = "7733917120",
    ["box-select"] = "7733696665", ["briefcase"] = "7733919017", ["brush"] = "7733701455",
    ["bug"] = "7733701545", ["building"] = "7733701625", ["bus"] = "7733701715",
    ["calculator"] = "7733919105", ["calendar"] = "7733919198", ["camera"] = "7733708692",
    ["camera-off"] = "7733919260", ["car"] = "7733708835", ["carrot"] = "8997382987",
    ["cast"] = "7733919326", ["charge"] = "8997383136", ["check"] = "7733715400",
    ["check-circle"] = "7733919427", ["check-circle-2"] = "7733710700", ["check-square"] = "7733919526",
    ["chevron-down"] = "7733717447", ["chevron-first"] = "8997383275", ["chevron-last"] = "8997383390",
    ["chevron-left"] = "7733717651", ["chevron-right"] = "7733717755", ["chevron-up"] = "7733919605",
    ["chevrons-down"] = "7733720604", ["chevrons-down-up"] = "7733720483", ["chevrons-left"] = "7733720701",
    ["chevrons-right"] = "7733919682", ["chevrons-up"] = "7733723433", ["chevrons-up-down"] = "7733723321",
    ["chrome"] = "7733919783", ["circle"] = "7733919881", ["circle-slashed"] = "8997383530",
    ["clipboard"] = "7733734762", ["clipboard-check"] = "7733919947", ["clipboard-copy"] = "7733920037",
    ["clipboard-list"] = "7733920117", ["clipboard-x"] = "7733734668", ["clock"] = "7733734848",
    ["clock-1"] = "8997383694", ["clock-10"] = "8997383876", ["clock-11"] = "8997384034",
    ["clock-12"] = "8997384150", ["clock-2"] = "8997384295", ["clock-3"] = "8997384456",
    ["clock-4"] = "8997384603", ["clock-5"] = "8997384798", ["clock-6"] = "8997384977",
    ["clock-7"] = "8997385147", ["clock-8"] = "8997385352", ["clock-9"] = "8997385485",
    ["cloud"] = "7733746980", ["cloud-drizzle"] = "7733920226", ["cloud-fog"] = "7733920317",
    ["cloud-hail"] = "7733920444", ["cloud-lightning"] = "7733741741", ["cloud-moon"] = "7733920519",
    ["cloud-off"] = "7733745572", ["cloud-rain"] = "7733746651", ["cloud-rain-wind"] = "7733746456",
    ["cloud-snow"] = "7733746798", ["cloud-sun"] = "7733746880", ["cloudy"] = "7733747106",
    ["clover"] = "7733747233", ["code"] = "7733749837", ["code-2"] = "7733920644",
    ["codepen"] = "7733920768", ["codesandbox"] = "7733752575", ["coffee"] = "7733752630",
    ["coins"] = "7743866529", ["columns"] = "7733757178", ["command"] = "7733924046",
    ["compass"] = "7733924216", ["contact"] = "7743866666", ["contrast"] = "7733764005",
    ["cookie"] = "8997385628", ["copy"] = "7733764083", ["copyleft"] = "7733764196",
    ["copyright"] = "7733764275", ["corner-down-left"] = "7733764327", ["corner-down-right"] = "7733764385",
    ["corner-left-down"] = "7733764448", ["corner-left-up"] = "7733764536", ["corner-right-down"] = "7733764605",
    ["corner-right-up"] = "7733764680", ["corner-up-left"] = "7733764800", ["corner-up-right"] = "7733764915",
    ["cpu"] = "7733765045", ["crop"] = "7733765140", ["cross"] = "7733765224",
    ["crosshair"] = "7733765307", ["crown"] = "7733765398", ["currency"] = "7733765592",
    ["database"] = "7743866778", ["delete"] = "7733768142", ["divide"] = "7733769365",
    ["divide-circle"] = "7733769152", ["divide-square"] = "7733769261", ["dollar-sign"] = "7733770599",
    ["download"] = "7733770755", ["download-cloud"] = "7733770689", ["dribbble"] = "7733770843",
    ["droplet"] = "7733770982", ["droplets"] = "7733771078", ["drumstick"] = "8997385789",
    ["edit"] = "7733771472", ["edit-2"] = "7733771217", ["edit-3"] = "7733771361",
    ["egg"] = "8997385940", ["electricity"] = "7733771628", ["electricity-off"] = "7733771563",
    ["equal"] = "7733771811", ["equal-not"] = "7733771726", ["euro"] = "7733771891",
    ["expand"] = "7733771982", ["external-link"] = "7743866903", ["eye"] = "7733774602",
    ["eye-off"] = "7733774495", ["fast-forward"] = "7743867090", ["feather"] = "7733777166",
    ["figma"] = "7743867310", ["file"] = "7733793319", ["file-check"] = "7733779668",
    ["file-check-2"] = "7733779610", ["file-code"] = "7733779730", ["file-digit"] = "7733935829",
    ["file-input"] = "7733935917", ["file-minus"] = "7733936115", ["file-minus-2"] = "7733936010",
    ["file-output"] = "7733788742", ["file-plus"] = "7733788885", ["file-plus-2"] = "7733788816",
    ["file-search"] = "7733788966", ["file-text"] = "7733789088", ["file-x"] = "7733938136",
    ["file-x-2"] = "7743867554", ["files"] = "7743867811", ["film"] = "7733942579",
    ["filter"] = "7733798407", ["flag"] = "7733798691", ["flag-triangle-left"] = "7733798509",
    ["flag-triangle-right"] = "7733798634", ["flame"] = "7733798747", ["flashlight"] = "7733798851",
    ["flashlight-off"] = "7733798799", ["flask-conical"] = "7733798901", ["flask-round"] = "7733798957",
    ["folder"] = "7733799185", ["folder-minus"] = "7733799022", ["folder-open"] = "8997386062",
    ["folder-plus"] = "7733799092", ["form-input"] = "7733799275", ["forward"] = "7733799371",
    ["framer"] = "7733799486", ["frown"] = "7733799591", ["function-square"] = "7733799682",
    ["gamepad"] = "7733799901", ["gamepad-2"] = "7733799795", ["gauge"] = "7733799969",
    ["gavel"] = "7733800044", ["gem"] = "7733942651", ["ghost"] = "7743868000",
    ["gift"] = "7733946818", ["gift-card"] = "7733945018", ["git-branch"] = "7733949149",
    ["git-branch-plus"] = "7743868200", ["git-commit"] = "7743868360", ["git-merge"] = "7733952195",
    ["git-pull-request"] = "7733952287", ["github"] = "7733954058", ["gitlab"] = "7733954246",
    ["glasses"] = "7733954403", ["globe"] = "7733954760", ["globe-2"] = "7733954611",
    ["grab"] = "7733954884", ["graduation-cap"] = "7733955058", ["grid"] = "7733955179",
    ["grip-horizontal"] = "7733955302", ["grip-vertical"] = "7733955410", ["hammer"] = "7733955511",
    ["hand"] = "7733955740", ["hand-metal"] = "7733955664", ["hard-drive"] = "7733955793",
    ["hard-hat"] = "7733955850", ["hash"] = "7733955906", ["haze"] = "7733955969",
    ["headphones"] = "7733956063", ["heart"] = "7733956134", ["help-circle"] = "7733956210",
    ["hexagon"] = "7743868527", ["highlighter"] = "7743868648", ["history"] = "7733960880",
    ["home"] = "7733960981", ["image"] = "7733964126", ["image-minus"] = "7733963797",
    ["image-off"] = "7733963907", ["image-plus"] = "7733964016", ["import"] = "7733964240",
    ["inbox"] = "7733964370", ["indent"] = "7733964452", ["indian-rupee"] = "7733964536",
    ["infinity"] = "7733964640", ["info"] = "7733964719", ["inspect"] = "7733964808",
    ["italic"] = "7733964917", ["jersey-pound"] = "7733965029", ["key"] = "7733965118",
    ["landmark"] = "7733965184", ["languages"] = "7733965249", ["laptop"] = "7733965386",
    ["laptop-2"] = "7733965313", ["lasso"] = "7733967892", ["lasso-select"] = "7743868832",
    ["layers"] = "7743868936", ["layout"] = "7733970543", ["layout-dashboard"] = "7733970318",
    ["layout-grid"] = "7733970390", ["layout-list"] = "7733970442", ["layout-template"] = "7733970494",
    ["library"] = "7743869054", ["life-buoy"] = "7733973479", ["lightbulb"] = "7733975185",
    ["lightbulb-off"] = "7733975123", ["link"] = "7733978098", ["link-2"] = "7743869163",
    ["link-2-off"] = "7733975283", ["list"] = "7743869612", ["list-checks"] = "7743869317",
    ["list-minus"] = "7733980795", ["list-ordered"] = "7743869411", ["list-plus"] = "7733984995",
    ["list-x"] = "7743869517", ["loader"] = "7733992358", ["loader-2"] = "7733989869",
    ["locate"] = "7733992469", ["locate-fixed"] = "7733992424", ["lock"] = "7733992528",
    ["log-in"] = "7733992604", ["log-out"] = "7733992677", ["mail"] = "7733992732",
    ["map"] = "7733992829", ["map-pin"] = "7733992789", ["maximize"] = "7733992982",
    ["maximize-2"] = "7733992901", ["megaphone"] = "7733993049", ["meh"] = "7733993147",
    ["menu"] = "7733993211", ["message-circle"] = "7733993311", ["message-square"] = "7733993369",
    ["mic"] = "7743869805", ["mic-off"] = "7743869714", ["minimize"] = "7733997941",
    ["minimize-2"] = "7733997870", ["minus"] = "7734000129", ["minus-circle"] = "7733998053",
    ["minus-square"] = "7743869899", ["monitor"] = "7734002839", ["monitor-off"] = "7734000184",
    ["monitor-speaker"] = "7743869988", ["moon"] = "7743870134", ["more-horizontal"] = "7734006080",
    ["more-vertical"] = "7734006187", ["mountain"] = "7734008868", ["mountain-snow"] = "7743870286",
    ["mouse-pointer"] = "7743870392", ["mouse-pointer-2"] = "7734010405", ["mouse-pointer-click"] = "7734010488",
    ["move"] = "7743870731", ["move-diagonal"] = "7743870505", ["move-diagonal-2"] = "7734013178",
    ["move-horizontal"] = "7734016210", ["move-vertical"] = "7743870608", ["music"] = "7734020554",
    ["navigation"] = "7734020989", ["navigation-2"] = "7734020942", ["network"] = "7734021047",
    ["no_entry"] = "7734021118", ["octagon"] = "7734021165", ["on-charge"] = "7734021231",
    ["option"] = "7734021300", ["outdent"] = "7734021384", ["package"] = "7734021469",
    ["package-check"] = "8997386143", ["package-minus"] = "8997386266", ["package-plus"] = "8997386355",
    ["package-search"] = "8997386448", ["package-x"] = "8997386545", ["palette"] = "7734021595",
    ["paperclip"] = "7734021680", ["pause"] = "7734021897", ["pause-circle"] = "7734021767",
    ["pause-octagon"] = "7734021827", ["pen-tool"] = "7734022041", ["pencil"] = "7734022107",
    ["percent"] = "7743870852", ["person-standing"] = "7743871002", ["phone"] = "7734032056",
    ["phone-call"] = "7734027264", ["phone-forwarded"] = "7734027345", ["phone-incoming"] = "7743871120",
    ["phone-missed"] = "7734029465", ["phone-off"] = "7734029534", ["phone-outgoing"] = "7743871253",
    ["pie-chart"] = "7734034378", ["piggy-bank"] = "7734034513", ["pin"] = "8997386648",
    ["pipette"] = "7743871384", ["plane"] = "7734037723", ["play"] = "7743871480",
    ["play-circle"] = "7734037784", ["plus"] = "7734042071", ["plus-circle"] = "7734040271",
    ["plus-square"] = "7734040369", ["pocket"] = "7734042139", ["podcast"] = "7734042234",
    ["pointer"] = "7734042307", ["pound-sterling"] = "7734042354", ["power"] = "7734042493",
    ["power-off"] = "7734042423", ["printer"] = "7734042580", ["qr-code"] = "7743871575",
    ["quote"] = "7734045100", ["radio"] = "7743871662", ["radio-receiver"] = "7734045155",
    ["redo"] = "7743871739", ["refresh-ccw"] = "7734050715", ["refresh-cw"] = "7734051052",
    ["regex"] = "7734051188", ["repeat"] = "7734051454", ["repeat-1"] = "7734051342",
    ["reply"] = "7734051594", ["reply-all"] = "7734051524", ["rewind"] = "7734051670",
    ["rocking-chair"] = "7734051769", ["rotate-ccw"] = "7734051861", ["rotate-cw"] = "7734051957",
    ["rss"] = "7734052075", ["ruler"] = "7734052157", ["russian-ruble"] = "7734052248",
    ["save"] = "7734052335", ["scale"] = "7734052454", ["scan"] = "8997386861",
    ["scan-line"] = "8997386772", ["scissors"] = "7734052570", ["screen-share"] = "7734052814",
    ["screen-share-off"] = "7734052653", ["search"] = "7734052925", ["send"] = "7734053039",
    ["separator-horizontal"] = "7734053146", ["separator-vertical"] = "7734053213", ["server"] = "7734053426",
    ["server-crash"] = "7734053281", ["server-off"] = "7734053361", ["settings"] = "7734053495",
    ["settings-2"] = "8997386997", ["share"] = "7734053697", ["share-2"] = "7734053595",
    ["sheet"] = "7743871876", ["shield"] = "7734056608", ["shield-alert"] = "7734056326",
    ["shield-check"] = "7734056411", ["shield-close"] = "7734056470", ["shield-off"] = "7734056540",
    ["shirt"] = "7734056672", ["shopping-bag"] = "7734056747", ["shopping-cart"] = "7734056813",
    ["shovel"] = "7734056878", ["shrink"] = "7734056971", ["shuffle"] = "7734057059",
    ["sidebar"] = "7734058260", ["sidebar-close"] = "7734058092", ["sidebar-open"] = "7734058165",
    ["sigma"] = "7734058345", ["signal"] = "8997387546", ["signal-high"] = "8997387110",
    ["signal-low"] = "8997387189", ["signal-medium"] = "8997387319", ["signal-zero"] = "8997387434",
    ["skip-back"] = "7734058404", ["skip-forward"] = "7734058495", ["skull"] = "7734058599",
    ["slash"] = "8997387644", ["sliders"] = "7734058803", ["smartphone"] = "7734058979",
    ["smartphone-charging"] = "7734058894", ["smile"] = "7734059095", ["snowflake"] = "7734059180",
    ["sort-asc"] = "7734060715", ["sort-desc"] = "7743871973", ["speaker"] = "7734063416",
    ["sprout"] = "7743872071", ["square"] = "7743872181", ["star"] = "7734068321",
    ["star-half"] = "7734068258", ["stop-circle"] = "7734068379", ["stretch-horizontal"] = "8997387754",
    ["stretch-vertical"] = "8997387862", ["strikethrough"] = "7734068425", ["subscript"] = "8997387937",
    ["sun"] = "7734068495", ["sunrise"] = "7743872365", ["sunset"] = "7734070982",
    ["superscript"] = "8997388036", ["swiss-franc"] = "7734071038", ["switch-camera"] = "7743872492",
    ["table"] = "7734073253", ["tablet"] = "7743872620", ["tag"] = "7734075797",
    ["target"] = "7743872758", ["tent"] = "7734078943", ["terminal"] = "7743872929",
    ["terminal-square"] = "7734079055", ["text-cursor"] = "8997388195", ["text-cursor-input"] = "8997388094",
    ["thermometer"] = "7734084149", ["thermometer-snowflake"] = "7743873074", ["thermometer-sun"] = "7734084018",
    ["thumbs-down"] = "7734084236", ["thumbs-up"] = "7743873212", ["ticket"] = "7734086558",
    ["timer"] = "7743873443", ["timer-off"] = "8997388325", ["timer-reset"] = "7743873336",
    ["toggle-left"] = "7734091286", ["toggle-right"] = "7743873539", ["tornado"] = "7743873633",
    ["trash"] = "7743873871", ["trash-2"] = "7743873772", ["trello"] = "7743873996",
    ["trending-down"] = "7743874143", ["trending-up"] = "7743874262", ["triangle"] = "7743874367",
    ["truck"] = "7743874482", ["tv"] = "7743874674", ["tv-2"] = "7743874599",
    ["type"] = "7743874740", ["umbrella"] = "7743874820", ["underline"] = "7743874904",
    ["undo"] = "7743874974", ["unlink"] = "7743875149", ["unlink-2"] = "7743875069",
    ["unlock"] = "7743875263", ["upload"] = "7743875428", ["upload-cloud"] = "7743875358",
    ["user"] = "7743875962", ["user-check"] = "7743875503", ["user-minus"] = "7743875629",
    ["user-plus"] = "7743875759", ["user-x"] = "7743875879", ["users"] = "7743876054",
    ["verified"] = "7743876142", ["vibrate"] = "7743876302", ["video"] = "7743876610",
    ["video-off"] = "7743876466", ["view"] = "7743876754", ["voicemail"] = "7743876916",
    ["volume"] = "7743877487", ["volume-1"] = "7743877081", ["volume-2"] = "7743877250",
    ["volume-x"] = "7743877381", ["wallet"] = "7743877573", ["wand"] = "8997388430",
    ["watch"] = "7743877668", ["webcam"] = "7743877896", ["wifi"] = "7743878148",
    ["wifi-off"] = "7743878056", ["wind"] = "7743878264", ["wrap-text"] = "8997388548",
    ["wrench"] = "7743878358", ["x"] = "7743878857", ["x-circle"] = "7743878496",
    ["x-octagon"] = "7743878618", ["x-square"] = "7743878737", ["zoom-in"] = "7743878977",
    ["zoom-out"] = "7743879082",
}
Icons.Lucide = LucideIcons

-- Alias map: newer lucide names and legacy Mario sprite names both resolve.
Icons.Aliases = {
    -- newer lucide names shipped by lucideblox under older names
    house = "home", ["sliders-horizontal"] = "sliders", zap = "electricity",
    ["triangle-alert"] = "alert-triangle", ["circle-alert"] = "alert-circle",
    ["circle-check"] = "check-circle-2", ["circle-x"] = "x-circle",
    sparkles = "star", ["arrow-up-left"] = "arrow-left-up", ["arrow-up-right"] = "arrow-right-up",
    ["arrow-down-left"] = "arrow-left-down", ["arrow-down-right"] = "arrow-right-down",
    -- legacy Mario-era sprite names kept for old scripts
    mushroom = "electricity", qblock = "box", coin = "coins", pipe = "globe",
    boo = "ghost", sword = "axe", swords = "axe", gear = "settings", bomb = "alert-octagon",
    used = "square", brick = "layout-grid", castle = "home", oneup = "user",
    shell = "shield", flower = "crosshair", pumpkin = "ghost", bat = "moon",
    spider = "bug", candy = "gift",
    -- legacy source alias names
    player = "user", teleport = "globe", visuals = "eye", combat = "axe",
    shop = "coins", quest = "flag", misc = "box", troll = "shield",
}

function Icons.NormalizeKey(rawName)
    local key = tostring(rawName or ""):lower():gsub("%s+", ""):gsub("_", "-")
    local alias = Icons.Aliases[key]
    if alias then
        key = alias
    end
    return key
end

function Icons.Resolve(rawName)
    local key = Icons.NormalizeKey(rawName)
    local id = Icons.Lucide[key]
    if id then
        return "rbxassetid://" .. id, key
    end
    return nil, key
end

-- Create a tinted lucide icon ImageLabel. Color token defaults to "Text".
function Icons.Create(parent, iconSpec, size, colorToken)
    local image = Icons.Resolve(iconSpec)
    local label = Draw.New("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size or Util.Metrics().Icon, size or Util.Metrics().Icon),
        ScaleType = Enum.ScaleType.Fit,
        ImageColor3 = Color3.new(1, 1, 1),
        Parent = parent,
    })
    if image then
        label.Image = image
    else
        label.Image = Icons.Resolve("star")
    end
    Theme.Bind(label, { ImageColor3 = colorToken or "Text" })
    return label
end

-- Icon inside a small rounded badge (element face, accent icon).
function Icons.Badge(parent, iconSpec, size, colorToken)
    local badge = Draw.Box("Frame", {
        BackgroundTransparency = 0,
        Size = UDim2.fromOffset(size or 26, size or 26),
        Parent = parent,
    }, "Element", "Track", (size or 26) / 4, 1)
    local icon = Icons.Create(badge, iconSpec, math.floor((size or 26) * 0.62), colorToken)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)
    return badge
end
--==============================================================================
-- Assets: logo pipeline (override -> executor customasset -> raw URL)
--==============================================================================

Assets.Listeners = setmetatable({}, { __mode = "k" })

function Assets.Listen(image)
    Assets.Listeners[image] = true
end

function Assets.Refresh()
    for image in pairs(Assets.Listeners) do
        if image.Parent then
            task.spawn(function()
                image.Image = Assets.Logo()
            end)
        else
            Assets.Listeners[image] = nil
        end
    end
end

function Assets.Configure(map)
    local changed = false
    if type(map) == "table" then
        for key, value in pairs(map) do
            if Assets.Overrides[key] ~= value then
                Assets.Overrides[key] = value
                changed = true
            end
        end
    end
    if changed then
        Assets.Cache.Logo = nil
        Assets.Refresh()
    end
    return changed
end

local function CustomAsset(url)
    if type(getcustomasset) ~= "function" or type(writefile) ~= "function" then
        return nil
    end
    pcall(function()
        makefolder(Config.Root)
    end)
    local file = Config.Root .. "/logo_" .. Util.Hash(url) .. ".png"
    if not Util.Exists(file) then
        local data = Util.Http(url)
        if type(data) ~= "string" or #data == 0 then
            return nil
        end
        pcall(writefile, file, data)
    end
    if not Util.Exists(file) then
        return nil
    end
    local ok, asset = pcall(getcustomasset, file)
    if ok and type(asset) == "string" and #asset > 0 then
        return asset
    end
    return nil
end

-- Resolves the FALLENS logo image. Executor-friendly: downloads the PNG once
-- and maps it through getcustomasset; falls back to the raw URL; a rbxassetid
-- override is passed straight through.
function Assets.Logo()
    if Assets.Cache.Logo then
        return Assets.Cache.Logo
    end
    local source = Assets.Overrides.logo or Config.DefaultAssets.logo
    local resolved = ""
    if type(source) == "string" and #source > 0 then
        if source:sub(1, 13) == "rbxassetid://" or source:sub(1, 10) == "rbxasset://" then
            resolved = source
        else
            resolved = CustomAsset(source) or source
        end
    end
    Assets.Cache.Logo = resolved
    return resolved
end

--==============================================================================
-- Gui core: ScreenGui, input routing, dragging, fps, recurring tasks
--==============================================================================

function Gui.ClearPrevious(parent)
    local env = type(getgenv) == "function" and getgenv() or nil
    if env and type(env.FALLENS) == "table" and env.FALLENS ~= Library and not env.FALLENS.Unloaded then
        Util.Try(env.FALLENS.Unload, env.FALLENS)
    end
    if env then
        env.FALLENS = Library
    end
    for _, child in ipairs(parent:GetChildren()) do
        if child:GetAttribute(Config.GuiAttribute) then
            child:Destroy()
        end
    end
end

function Gui.Setup()
    if State.Gui then
        return
    end
    local parent = Util.GuiParent()
    Gui.ClearPrevious(parent)
    State.Gui = Draw.New("ScreenGui", {
        Name = Config.Name,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        Parent = parent,
    })
    State.Gui:SetAttribute(Config.GuiAttribute, Library.Version)
    Notify.Build()
    Tooltip.Build()
    Util.Connect(UserInputService.InputBegan, Gui.OnInputBegan)
    Util.Connect(UserInputService.InputChanged, Gui.OnInputChanged)
    Util.Connect(UserInputService.InputEnded, Gui.OnInputEnded)
    Util.Connect(RunService.Heartbeat, Gui.OnHeartbeat)
    Util.Every(20, Theme.Prune)
end

function Gui.OnInputBegan(input, processed)
    if State.Binding then
        Keybinds.Capture(input)
        return
    end
    if UserInputService:GetFocusedTextBox() then
        return
    end
    local name = Util.InputName(input)
    if not name then
        return
    end
    if name == State.MenuKey and State.Window and not processed then
        State.Window:Toggle()
    end
    -- Allow feature keybinds even when the game binds the same key.
    if input.UserInputType == Enum.UserInputType.Keyboard or not processed then
        Keybinds.Dispatch(name, true)
    end
end

function Gui.OnInputChanged(input)
    if State.Drag and Util.IsMove(input) then
        State.Drag.Move(input)
    end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        Tooltip.Follow(UserInputService:GetMouseLocation())
    end
end

function Gui.OnInputEnded(input)
    if Util.IsPointer(input) and State.Drag then
        local drag = State.Drag
        State.Drag = nil
        Util.Try(drag.Stop)
    end
    local name = Util.InputName(input)
    if name then
        Keybinds.Dispatch(name, false)
    end
end

function Gui.OnHeartbeat(deltaTime)
    if deltaTime > 0 then
        State.Fps = State.Fps * 0.92 + (1 / deltaTime) * 0.08
    end
    for _, job in ipairs(State.Tasks) do
        job.Elapsed = job.Elapsed + deltaTime
        if job.Elapsed >= job.Interval and not job.Busy then
            job.Elapsed = 0
            job.Busy = true
            task.spawn(function()
                Util.Try(job.Run)
                job.Busy = false
            end)
        end
    end
end

--@param handle Drag target, move(delta) drag callback, exclude ignored child zones
function Gui.Draggable(handle, move, exclude)
    handle.InputBegan:Connect(function(input)
        if not Util.IsPointer(input) then
            return
        end
        for _, zone in ipairs(exclude or {}) do
            if zone.Visible and Util.Inside(zone, input.Position) then
                return
            end
        end
        local start = input.Position
        local begin = move(nil)
        State.Drag = {
            Move = function(moved)
                move(begin, moved.Position - start)
            end,
        }
    end)
end

--==============================================================================
-- Watermark: logo + FALLENS (accent) + FPS / PING / session stats
--==============================================================================

function Watermark.Build(title)
    local frame = Draw.Box("Frame", {
        Name = "Watermark",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        AutomaticSize = Enum.AutomaticSize.X,
        Active = true,
        Size = UDim2.fromOffset(0, 30),
        ZIndex = Config.Layer.Watermark,
        Parent = State.Gui,
    }, "Panel", "Outline", 10, 2)
    frame.BackgroundTransparency = 0.25
    Draw.Padding(frame, 0, 12, 0, 8)
    Draw.List(frame, 10, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    Draw.Emblem(frame, 18, 1)
    -- One title color: the active theme accent.
    Draw.Text({
        Text = tostring(title or Config.Name):upper(),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 20),
        LayoutOrder = 2,
        Parent = frame,
    }, "Logo", Config.Text.Watermark + 1, "Accent")
    Watermark.Stats = {}
    for index, key in ipairs({ "Fps", "Ping", "Time" }) do
        Watermark.Stats[key] = Draw.Text({
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 20),
            LayoutOrder = 2 + index,
            Parent = frame,
        }, "Body", Config.Text.Watermark, "SubText")
    end
    Watermark.Frame = frame
    Gui.Draggable(frame, function(begin, delta)
        if not delta then
            return frame.Position
        end
        frame.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
        return begin
    end)
    Watermark.Update()
    Util.Every(0.5, Watermark.Update)
end

function Watermark.Update()
    if not Watermark.Frame or not Watermark.Frame.Visible then
        return
    end
    local ok, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    local elapsed = math.floor(os.clock() - State.StartTime)
    Watermark.Stats.Fps.Text = string.format("FPS %d", math.floor(State.Fps + 0.5))
    Watermark.Stats.Ping.Text = ok and string.format("PING %dms", math.floor(ping + 0.5)) or "PING --"
    Watermark.Stats.Time.Text = string.format("SESSION %02d:%02d", math.floor(elapsed / 60) % 100, elapsed % 60)
end

function Watermark.SetVisible(visible)
    if Watermark.Frame then
        Watermark.Frame.Visible = visible
        Watermark.Update()
    end
end

--==============================================================================
-- Float (show mobile): logo inside a window-style themed frame, no shadow
--==============================================================================

function Float.Clamp()
    local button = Float.Button
    if not button or not State.Gui then
        return
    end
    local viewport = State.Gui.AbsoluteSize
    if viewport.X <= 0 or viewport.Y <= 0 then
        return
    end
    local pos = button.Position
    local absX = viewport.X * pos.X.Scale + pos.X.Offset
    local absY = viewport.Y * pos.Y.Scale + pos.Y.Offset
    local size = Float.Size or 48
    local clampedX = math.clamp(absX, 6, math.max(6, viewport.X - size - 6))
    local clampedY = math.clamp(absY, 6, math.max(6, viewport.Y - size - 6))
    button.Position = UDim2.fromOffset(math.floor(clampedX + 0.5), math.floor(clampedY + 0.5))
end

function Float.Build()
    local size = State.Touch and 56 or 48
    local button = Draw.New("TextButton", {
        Name = "Float",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 18, 0.45, 0),
        Size = UDim2.fromOffset(size, size),
        ZIndex = Config.Layer.Float,
        Visible = State.Touch,
        Parent = State.Gui,
    })
    -- Window-style frame: same backdrop + outline stroke + corner radius as
    -- the main window, repainted live when the theme changes. No icon shadow.
    local face = Draw.Box("Frame", {
        Name = "Face",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.05,
        ClipsDescendants = true,
        Parent = button,
    }, "Backdrop", "Outline", Config.Window.Radius, 2)
    local logo = Draw.New("ImageLabel", {
        Name = "Logo",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.64, 0.64),
        ScaleType = Enum.ScaleType.Fit,
        Parent = face,
    })
    Assets.Listen(logo)
    task.spawn(function()
        logo.Image = Assets.Logo()
    end)
    Float.Button, Float.Face, Float.Logo, Float.Size = button, face, logo, size
    Anim.Loop("Float", logo, { Position = UDim2.fromScale(0.5, 0.44) }, 0.9, "Sine")
    local moved = false
    Gui.Draggable(button, function(begin, delta)
        if not delta then
            moved = false
            return button.Position
        end
        moved = moved or delta.Magnitude > Config.DragThreshold
        if moved then
            button.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
            Float.Clamp()
        end
        return begin
    end)
    button.Activated:Connect(function()
        if moved or not State.Window then
            return
        end
        Anim.Bump(face, 10)
        State.Window:Toggle()
    end)
end

function Float.SetVisible(visible)
    if Float.Button then
        Float.Button.Visible = visible
        Anim.SetGroupActive("Float", visible)
        if visible then
            Float.Clamp()
        end
    end
end

--==============================================================================
-- Notify: accent-tinted lucide icons, accent timer bar
--==============================================================================

Notify.Icons = {
    Info = "info",
    Success = "check-circle-2",
    Warning = "alert-triangle",
    Error = "x-circle",
    Coin = "coins",
    Power = "power",
}

function Notify.Build()
    local width = State.Touch and Config.Notify.TouchWidth or Config.Notify.Width
    State.NotifyHost = Draw.New("Frame", {
        Name = "Notifications",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.new(0, width + 8, 1, -28),
        ZIndex = Config.Layer.Notify,
        Parent = State.Gui,
    })
    Draw.List(State.NotifyHost, Config.Notify.Gap, false, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom)
end

function Notify.Push(title, content, duration, kind)
    if not State.NotifyHost then
        return
    end
    local width = State.NotifyHost.Size.X.Offset - 8
    local text = content ~= nil and tostring(content) or ""
    local bounds = TextService:GetTextSize(text, Util.TextSize("Desc") + 1, Fonts.Face("Desc"), Vector2.new(width - 68, math.huge))
    local height = math.max(58, bounds.Y + 44)
    local holder = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(width + 8, height + 4),
        ClipsDescendants = false,
        Parent = State.NotifyHost,
    })
    local card = Draw.New("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(width + 60, 0),
        Size = UDim2.fromOffset(width, height),
        Parent = holder,
    })
    Draw.Box("Frame", {
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0.45,
        Parent = card,
    }, "Shadow", nil, 12)
    local face = Draw.Box("Frame", {
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,
        Parent = card,
    }, "Panel", "Outline", 12, 2)
    local icon = Icons.Create(face, Notify.Icons[kind or "Coin"] or "coins", 36, "Accent")
    icon.Position = UDim2.fromOffset(12, 11)
    Draw.Text({
        Position = UDim2.fromOffset(58, 9),
        Size = UDim2.new(1, -68, 0, 18),
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = face,
    }, "Body", Util.TextSize("Group"), "Text", title or Config.Name)
    Draw.Text({
        Text = text,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(58, 29),
        Size = UDim2.new(1, -68, 0, bounds.Y),
        Parent = face,
    }, "Desc", Util.TextSize("Desc") + 1, "SubText")
    local timer = Draw.Box("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 4),
        Parent = face,
    }, "Accent")
    duration = duration or Config.Notify.Duration
    Anim.Tween(card, { Position = UDim2.fromOffset(0, 0) }, Config.Tween.Notify, "Back")
    Anim.Tween(timer, { Size = UDim2.new(0, 0, 0, 4) }, duration, "Linear")
    local closed = false
    local function Dismiss()
        if closed then
            return
        end
        closed = true
        local slide = Anim.Tween(card, { Position = UDim2.fromOffset(width + 60, 0) }, 0.22, "In")
        slide.Completed:Once(function()
            local collapse = Anim.Tween(holder, { Size = UDim2.fromOffset(width + 8, 0) }, 0.16)
            collapse.Completed:Once(function()
                holder:Destroy()
            end)
        end)
    end
    card.Activated:Connect(Dismiss)
    task.delay(duration + 0.4, Dismiss)
end

--==============================================================================
-- Tooltip
--==============================================================================

function Tooltip.Build()
    local tip = Draw.Box("Frame", {
        Name = "Tooltip",
        BackgroundTransparency = 0.05,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 24),
        Visible = false,
        ZIndex = Config.Layer.Tooltip,
        Parent = State.Gui,
    }, "Panel", "Outline", 8, 2)
    Draw.Padding(tip, 2, 8, 2, 8)
    Tooltip.Label = Draw.Text({
        Size = UDim2.fromOffset(0, 20),
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tip,
    }, "Desc", Util.TextSize("Desc"), "SubText")
    Tooltip.Frame = tip
end

function Tooltip.Show(text)
    if not Tooltip.Frame or not text or text == "" then
        return
    end
    Tooltip.Label.Text = tostring(text)
    Tooltip.Frame.Visible = true
end

function Tooltip.Follow(position)
    if not Tooltip.Frame or not Tooltip.Frame.Visible then
        return
    end
    local viewport = State.Gui.AbsoluteSize
    local size = Tooltip.Frame.AbsoluteSize
    local x = math.clamp(position.X + 14, 8, math.max(8, viewport.X - size.X - 8))
    local y = math.clamp(position.Y + 18, 8, math.max(8, viewport.Y - size.Y - 8))
    Tooltip.Frame.Position = UDim2.fromOffset(x, y)
end

function Tooltip.Hide()
    if Tooltip.Frame then
        Tooltip.Frame.Visible = false
    end
end

--==============================================================================
-- Keybinds
--==============================================================================

Keybinds.ShortNames = {
    LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift",
    LeftAlt = "LAlt", RightAlt = "RAlt", Backquote = "`", Return = "Enter", Escape = "Esc",
    CapsLock = "Caps", PageUp = "PgUp", PageDown = "PgDn", Insert = "Ins",
}

Keybinds.List = {}

function Keybinds.Short(name)
    return Keybinds.ShortNames[name] or name
end

function Keybinds.Register(name, mode, callback, active)
    Keybinds.List[name] = Keybinds.List[name] or {}
    local bind = { Mode = mode or "Always", Callback = callback, Active = active or false }
    table.insert(Keybinds.List[name], bind)
    return bind
end

function Keybinds.Dispatch(name, down)
    local binds = Keybinds.List[name]
    if not binds then
        return
    end
    local visible = State.Window ~= nil and State.Window.Visible == true
    for _, bind in ipairs(binds) do
        if bind.Mode == "Always" or visible then
            if bind.Mode == "Toggle" then
                if down then
                    bind.Active = not bind.Active
                    if bind.Callback then
                        Util.Try(bind.Callback, bind.Active)
                    end
                end
            elseif bind.Callback then
                Util.Try(bind.Callback, down)
            end
        end
    end
end

function Keybinds.Capture(input)
    local picker = State.Binding
    State.Binding = nil
    if not picker or typeof(picker) ~= "table" then
        return
    end
    local name = nil
    if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
        name = "None"
    else
        name = Util.InputName(input)
    end
    if picker.Capture then
        Util.Try(picker.Capture, picker, name)
    end
end
--==============================================================================
-- Window
--==============================================================================

function Window.DetectTouch(forced)
    if forced == "Mobile" or forced == "Desktop" then
        State.Touch = forced == "Mobile"
        return
    end
    State.Touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Window.New(options)
    Window.DetectTouch(options.Layout)
    local size = options.Size or Vector2.new(Config.Window.Width, Config.Window.Height)
    if typeof(size) == "UDim2" then
        size = Vector2.new(size.X.Offset, size.Y.Offset)
    end
    local self = setmetatable({
        Title = options.Title or Config.Name,
        SubTitle = options.SubTitle or "",
        Desired = size,
        Size = size,
        Tabs = {},
        TabOrder = 0,
        ActiveTab = nil,
        Visible = false,
        Minimized = false,
        Compact = false,
    }, Window)
    State.Window = self
    State.MenuKey = Util.KeyName(options.MenuKey or options.ToggleKey or options.MinimizeKey) or "LeftControl"
    self:BuildFrame()
    self:BuildTopbar()
    self:BuildSidebar()
    self:BuildMain()
    self:FitViewport()
    Util.Connect(State.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
        self:FitViewport()
    end)
    return self
end

function Window:BuildFrame()
    local shadow = Config.Window.Shadow
    local radius = Config.Window.Radius
    self.Root = Draw.New("Frame", {
        Name = "Window",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Visible = false,
        ZIndex = Config.Layer.Window,
        Parent = State.Gui,
    })
    self.UserScale = Draw.New("UIScale", { Parent = self.Root })
    self.Pop = Draw.New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        Parent = self.Root,
    })
    self.PopScale = Draw.New("UIScale", { Parent = self.Pop })
    Draw.Box("Frame", {
        Position = UDim2.fromOffset(shadow, shadow),
        Size = UDim2.new(1, -shadow, 1, -shadow),
        BackgroundTransparency = 0.45,
        Parent = self.Pop,
    }, "Shadow", nil, radius)
    self.Body = Draw.Box("Frame", {
        Size = UDim2.new(1, -shadow, 1, -shadow),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        Parent = self.Pop,
    }, nil, "Outline", radius, Config.Window.Stroke)
    local gradient = Draw.New("UIGradient", {
        Rotation = 90,
        Parent = self.Body,
    })
    Theme.OnRender(gradient, function()
        gradient.Color = ColorSequence.new(Theme.Colors.Backdrop, Theme.Colors.BackdropAlt)
    end)
end

function Window:BuildTopbar()
    local height, radius = Config.Window.Topbar, Config.Window.Radius
    local topbar = Draw.Box("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, height),
        ClipsDescendants = true,
        Active = true,
        ZIndex = 5,
        Parent = self.Body,
    }, "Topbar", nil, radius)
    Draw.Box("Frame", {
        Position = UDim2.new(0, 0, 1, -radius),
        Size = UDim2.new(1, 0, 0, radius),
        Parent = topbar,
    }, "Topbar")
    self.TopbarLine = Draw.Box("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 3),
        ZIndex = 3,
        Parent = topbar,
    }, "Outline")
    self.Topbar = topbar
    local left = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -200, 1, -3),
        ZIndex = 4,
        Parent = topbar,
    })
    Draw.List(left, 10, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    Draw.Emblem(left, 40, 1)
    self:BuildTitle(left)
    self:BuildPill(left, self.SubTitle)
    local right = Draw.New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 0),
        Size = UDim2.new(0, 180, 1, -3),
        ZIndex = 4,
        Parent = topbar,
    })
    Draw.List(right, 8, true, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)
    self:BuildTopButton(right, "Minimize", function()
        self:SetMinimized(not self.Minimized)
    end)
    self:BuildTopButton(right, "Close", function()
        self:SetVisible(false)
        if not State.Touch then
            Library:Notify(self.Title, "Hidden - " .. Keybinds.Short(State.MenuKey), 3, "Info")
        end
    end)
    Gui.Draggable(topbar, function(begin, delta)
        if not delta then
            return self.Root.Position
        end
        self.Root.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
        self:ClampPosition()
        return begin
    end, { right })
end

-- Window title: exactly one color, the active theme accent.
function Window:BuildTitle(parent)
    self.TitleLabel = Draw.Text({
        Text = self.Title:upper(),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 34),
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 2,
        Parent = parent,
    }, "Logo", Config.Text.Title, "Accent")
end

function Window:BuildPill(parent, text)
    local pill = Draw.Box("Frame", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 22),
        LayoutOrder = 3,
        Parent = parent,
    }, "Shadow", "Outline", UDim.new(1, 0), 2)
    pill.BackgroundTransparency = 0.45
    Draw.Padding(pill, 0, 10, 0, 10)
    Draw.Text({
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromScale(0, 1),
        Parent = pill,
    }, "Body", Util.TextSize("Small"), "Text", text)
    pill.Visible = text ~= nil and text ~= ""
    return pill
end

function Window:BuildTopButton(parent, kind, callback)
    local size = State.Touch and 36 or 30
    local holder = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size + 1),
        LayoutOrder = 2 + #parent:GetChildren(),
        Parent = parent,
    })
    local top = Draw.Box("Frame", {
        Size = UDim2.fromScale(1, 1),
        Parent = holder,
    }, "Element", "Track", 8, 1)
    local icon = Icons.Create(top, kind == "Close" and "x" or "minus", math.floor(size * 0.44), "Text")
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Position = UDim2.fromScale(0.5, 0.5)
    local hit = Draw.New("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = holder,
    })
    hit.MouseButton1Down:Connect(function()
        Anim.Tween(top, { Position = UDim2.fromOffset(0, 2) }, 0.06, "Linear")
    end)
    hit.MouseButton1Up:Connect(function()
        Anim.Tween(top, { Position = UDim2.new() }, Config.Tween.Normal, "Back")
    end)
    hit.MouseLeave:Connect(function()
        Anim.Tween(top, { Position = UDim2.new() }, Config.Tween.Fast)
    end)
    hit.Activated:Connect(callback)
    return holder, top
end

function Window:BuildSidebar()
    self.Sidebar = Draw.Box("Frame", {
        Name = "Sidebar",
        Position = UDim2.new(0, 0, 0, Config.Window.Topbar),
        Size = UDim2.new(0, Config.Window.Sidebar, 1, -Config.Window.Topbar),
        ClipsDescendants = true,
        ZIndex = 4,
        Parent = self.Body,
    }, "Sidebar", nil, nil)
    Draw.Box("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 2, 1, 0),
        Parent = self.Sidebar,
    }, "Outline")
    local card = Draw.Box("Frame", {
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, Config.Window.UserCard),
        Parent = self.Sidebar,
    }, "SidebarAlt", nil, 10)
    Draw.Padding(card, 0, 10, 0, 10)
    Draw.List(card, 8, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    Draw.Emblem(card, 38, 1)
    Draw.Text({
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 20),
        TextTruncate = Enum.TextTruncate.AtEnd,
        LayoutOrder = 2,
        Parent = card,
    }, "Strong", Util.TextSize("Label"), "SidebarText", LocalPlayer and LocalPlayer.DisplayName or "Player")
    local scroll = Draw.Scroll({
        Position = UDim2.new(0, 0, 0, Config.Window.UserCard + 20),
        Size = UDim2.new(1, 0, 1, -(Config.Window.UserCard + 20)),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.Sidebar,
    }, Config.Gap.Y)
    Draw.Padding(scroll, 6, 6, 6, 6)
    self.TabList = scroll
end

function Window:BuildMain()
    self.Main = Draw.New("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, Config.Window.Topbar),
        Size = UDim2.new(1, -Config.Window.Sidebar, 1, -Config.Window.Topbar),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 4,
        Parent = self.Body,
    })
end

function Window:ClampPosition()
    local viewport = State.Gui.AbsoluteSize
    local size = self.Root.AbsoluteSize
    local pos = self.Root.Position
    local absX = viewport.X * pos.X.Scale + pos.X.Offset
    local absY = viewport.Y * pos.Y.Scale + pos.Y.Offset
    local minX = size.X / 2 + 40
    local maxX = viewport.X - size.X / 2 - 40
    local minY = size.Y / 2 + 10
    local maxY = viewport.Y - size.Y / 2 - 10
    if maxX < minX then
        minX, maxX = viewport.X / 2, viewport.X / 2
    end
    if maxY < minY then
        minY, maxY = viewport.Y / 2, viewport.Y / 2
    end
    absX = math.clamp(absX, minX, maxX)
    absY = math.clamp(absY, minY, maxY)
    self.Root.Position = UDim2.fromOffset(math.floor(absX + 0.5), math.floor(absY + 0.5))
end

function Window:FitViewport()
    local viewport = State.Gui.AbsoluteSize
    local margin = State.Touch and Config.Window.TouchMargin or Config.Window.Margin
    local minSize = Vector2.new(
        State.Touch and Config.Window.TouchMinWidth or Config.Window.MinWidth,
        State.Touch and Config.Window.TouchMinHeight or Config.Window.MinHeight
    )
    local size = self.Desired
    size = Vector2.new(
        math.min(math.max(size.X, minSize.X), math.max(minSize.X, viewport.X - margin * 2)),
        math.min(math.max(size.Y, minSize.Y), math.max(minSize.Y, viewport.Y - margin * 2))
    )
    self.Size = size
    self.Root.Size = UDim2.fromOffset(math.floor(size.X + 0.5), math.floor(size.Y + 0.5))
    self.Compact = size.X < Config.Window.CompactBreakpoint
    local sidebarWidth = self.Compact and Config.Window.SidebarCompact or Config.Window.Sidebar
    self.Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -Config.Window.Topbar)
    self.Main.Size = UDim2.new(1, -sidebarWidth, 1, -Config.Window.Topbar)
    for _, tab in ipairs(self.Tabs) do
        tab:RenderCompact(self.Compact)
    end
    self:ClampPosition()
end

function Window:SetScale(scale)
    State.UserScale = math.clamp(scale, Config.ScaleRange.Min, Config.ScaleRange.Max)
    Anim.Tween(self.UserScale, { Scale = State.UserScale }, Config.Tween.Normal, "Back")
end

function Window:SetMinimized(minimized)
    minimized = minimized == true
    if self.Minimized == minimized then
        return
    end
    self.Minimized = minimized
    local height = minimized and Config.Window.Topbar or self.Size.Y
    Anim.Tween(self.Body, { Size = UDim2.new(1, -Config.Window.Shadow, 0, height) }, Config.Tween.Slide, "Out")
end

function Window:Toggle()
    self:SetVisible(not self.Visible)
end

function Window:SetVisible(visible)
    if self.Visible == visible then
        return
    end
    self.Visible = visible
    if visible then
        self.Root.Visible = true
        self:FitViewport()
        self.PopScale.Scale = 0.86
        Anim.Tween(self.PopScale, { Scale = 1 }, Config.Tween.Pop, "Back")
    else
        local fade = Anim.Tween(self.PopScale, { Scale = 0.86 }, 0.14, "In")
        fade.Completed:Once(function()
            self.Root.Visible = false
            self.PopScale.Scale = 1
        end)
    end
end

function Window:AddTab(name, icon, description)
    local tab = setmetatable({
        Window = self,
        Name = name or "Tab",
        Icon = icon or "star",
        Description = description or "",
        Groupboxes = {},
        Order = #self.Tabs + 1,
        NextOrder = 0,
    }, Tab)
    table.insert(self.Tabs, tab)
    self.TabOrder = self.TabOrder + 1
    tab:BuildButton()
    tab:BuildPage()
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    return tab
end

Window.Tab = Window.AddTab
Window.Section = Window.AddTabSection

function Window:SelectTab(tab)
    if self.ActiveTab == tab then
        return
    end
    if self.ActiveTab then
        self.ActiveTab:SetActive(false)
    end
    self.ActiveTab = tab
    tab:SetActive(true)
end

--==============================================================================
-- Tab
--==============================================================================

setmetatable(Groupbox, { __index = Container })

function Tab:BuildButton()
    local metrics = Util.Metrics()
    local button = Draw.New("TextButton", {
        Name = "Tab",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, metrics.Tab),
        LayoutOrder = self.Order,
        Parent = self.Window.TabList,
    })
    self.Button = button
    local pill = Draw.Box("Frame", {
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(1, 0, 0, metrics.Tab - 6),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = button,
    }, "Accent", nil, 8)
    Draw.Corner(pill, 8)
    self.Pill = pill
    local icon = Icons.Create(pill, self.Icon, math.floor(metrics.Icon * 1.1), "SidebarMuted")
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Position = UDim2.new(0, 10, 0.5, 0)
    self.TabIcon = icon
    local label = Draw.Text({
        Position = UDim2.fromOffset(10 + metrics.Icon * 1.1 + 8, 0),
        Size = UDim2.new(1, -(28 + metrics.Icon * 1.1), 1, 0),
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = button,
    }, "Body", Util.TextSize("Label"), "SidebarText", self.Name)
    self.Label = label
    button.Activated:Connect(function()
        self.Window:SelectTab(self)
    end)
    self:RenderCompact(self.Window.Compact)
end

function Tab:RenderCompact(compact)
    if self.Label then
        self.Label.Visible = not compact
    end
    if compact and self.TabIcon then
        self.TabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        self.TabIcon.Position = UDim2.fromScale(0.5, 0.5)
    elseif self.TabIcon then
        local metrics = Util.Metrics()
        self.TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        self.TabIcon.Position = UDim2.new(0, 10, 0.5, 0)
    end
end

function Tab:SetActive(active)
    if active then
        self.Page.Visible = true
        Anim.Tween(self.Pill, { BackgroundTransparency = 0 }, Config.Tween.Fast, "Out")
        Theme.Bind(self.Label, { TextColor3 = "OnAccent" })
        Theme.Bind(self.TabIcon, { ImageColor3 = "OnAccent" })
    else
        self.Page.Visible = false
        Anim.Tween(self.Pill, { BackgroundTransparency = 1 }, Config.Tween.Fast, "Out")
        Theme.Bind(self.Label, { TextColor3 = "SidebarText" })
        Theme.Bind(self.TabIcon, { ImageColor3 = "SidebarMuted" })
    end
end

function Tab:BuildPage()
    self.Page = Draw.Scroll({
        Name = "Page",
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 4,
        Parent = self.Window.Main,
    }, Config.Gap.Column)
    Draw.Padding(self.Page, Config.Page.Pad, Config.Page.Pad, Config.Page.Pad, Config.Page.Pad)
    local row = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.Page,
    })
    Draw.List(row, Config.Gap.Column, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    self.Columns = {}
    for index, side in ipairs({ "Left", "Right" }) do
        local column = Draw.New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = index,
            Parent = row,
        })
        Draw.List(column, Config.Gap.Y, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
        self.Columns[side] = column
    end
end

function Tab:AddGroupbox(name, icon, side)
    local group = setmetatable({
        Tab = self,
        Name = name or "Group",
        Icon = icon,
        Side = side or "Left",
        NextOrder = 0,
        Rows = {},
    }, Groupbox)
    group:Build()
    table.insert(self.Groupboxes, group)
    self:RefreshColumns()
    return group
end

function Tab:AddLeftGroupbox(name, icon)
    return self:AddGroupbox(name, icon, "Left")
end

function Tab:AddRightGroupbox(name, icon)
    return self:AddGroupbox(name, icon, "Right")
end

function Tab:AddTabSection(text)
    local section = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = self.NextOrder + 1,
        Parent = self.Columns.Left,
    })
    self.NextOrder = self.NextOrder + 1
    Draw.Text({
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
    }, "Strong", Util.TextSize("Section"), "Accent", tostring(text):upper())
    Draw.Box("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundTransparency = 0.35,
        Parent = section,
    }, "Track")
    return section
end

function Tab:RefreshColumns()
    local left = self.Columns.Left
    local right = self.Columns.Right
    local rightUsed = false
    for _, group in ipairs(self.Groupboxes) do
        if group.Side == "Right" then
            rightUsed = true
        end
    end
    if rightUsed then
        left.Size = UDim2.new(0.5, -Config.Gap.Column / 2, 0, 0)
        left.AutomaticSize = Enum.AutomaticSize.Y
        right.Size = UDim2.new(0.5, -Config.Gap.Column / 2, 0, 0)
        right.AutomaticSize = Enum.AutomaticSize.Y
        right.Visible = true
    else
        left.Size = UDim2.new(1, 0, 0, 0)
        left.AutomaticSize = Enum.AutomaticSize.Y
        right.Size = UDim2.new(0, 0, 0, 0)
        right.Visible = false
    end
end

Tab.Section = Tab.AddTabSection

--==============================================================================
-- Groupbox
--==============================================================================

function Groupbox:Build()
    local box = Draw.Box("Frame", {
        Name = "Groupbox",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
        Parent = self.Tab.Columns[self.Side],
    }, "Panel", "Outline", Config.Group.Radius, Config.Group.Stroke)
    Draw.Padding(box, Config.Group.PadY, Config.Group.PadX, Config.Group.PadY, Config.Group.PadX)
    Draw.List(box, Config.Gap.Y, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    self.Root = box
    local header = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Active = true,
        Size = UDim2.new(1, 0, 0, Config.Group.Header - 14),
        Parent = box,
    })
    Draw.List(header, 8, true, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
    if self.Icon then
        local icon = Icons.Create(header, self.Icon, 18, "Accent")
        icon.LayoutOrder = 1
    end
    Draw.Text({
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 22),
        LayoutOrder = 2,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    }, "Strong", Util.TextSize("Group"), "Text", self.Name)
    local chevron = Icons.Create(header, "chevron-down", 18, "SubText")
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, 0, 0.5, 0)
    self.Chevron = chevron
    self.Body = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = box,
    })
    Draw.List(self.Body, Config.Gap.Y, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    header.InputBegan:Connect(function(input)
        if Util.IsPointer(input) then
            self:SetCollapsed(not self.Collapsed)
        end
    end)
    self.Collapsed = false
end

function Groupbox:SetCollapsed(collapsed)
    collapsed = collapsed == true
    if self.Collapsed == collapsed then
        return
    end
    self.Collapsed = collapsed
    self.Body.Visible = not collapsed
    Anim.Tween(self.Chevron, { Rotation = collapsed and -90 or 0 }, Config.Tween.Collapse)
end

function Groupbox:AddChild()
    local child = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self.NextOrder + 1,
        Parent = self.Body,
    })
    self.NextOrder = self.NextOrder + 1
    return child
end

--==============================================================================
-- Widget base + Row helpers
--==============================================================================

function Widget.Register(idx, option)
    if idx and type(idx) == "string" and #idx > 0 then
        option.Idx = idx
        Library.Options[idx] = option
    end
    return option
end

function Widget.SetVisible(self, visible)
    if self.Root then
        self.Root.Visible = visible == true
    end
end

function Widget.AddGuard(self, guard)
    self.Guards = self.Guards or {}
    table.insert(self.Guards, guard)
    return self
end

function Widget.RunGuards(self, value)
    for _, guard in ipairs(self.Guards or {}) do
        local ok, allowed = pcall(guard, value)
        if ok and allowed == false then
            return false
        end
    end
    return true
end

-- Shared row layout: text + optional description + right-side control zone.
function Widget.BuildRow(container, info)
    info = info or {}
    local metrics = Util.Metrics()
    local hasDesc = info.Description ~= nil and info.Description ~= ""
    local row = container:AddChild()
    row.AutomaticSize = Enum.AutomaticSize.None
    row.Size = UDim2.new(1, 0, 0, hasDesc and metrics.Row + 16 or metrics.Row)
    local text = Draw.Text({
        Position = UDim2.fromOffset(0, hasDesc and 4 or 0),
        Size = UDim2.new(1, -(metrics.Box + 12), 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextWrapped = hasDesc == true,
        Parent = row,
    }, "Body", Util.TextSize("Label"), "Text", info.Text or info.Name or "")
    local desc
    if hasDesc then
        desc = Draw.Text({
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(1, -(metrics.Box + 12), 0, 14),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = row,
        }, "Desc", Util.TextSize("Desc"), "SubText", info.Description)
        if Tooltip.Show then
            text.MouseEnter:Connect(function()
                Tooltip.Show(info.Description)
            end)
            text.MouseLeave:Connect(Tooltip.Hide)
        end
    end
    return row, text, desc
end

function Widget.TextBounds(text, sizeToken, face, width)
    return TextService:GetTextSize(tostring(text), Util.TextSize(sizeToken), Fonts.Face(face or "Desc"), Vector2.new(width or 10000, math.huge))
end

--==============================================================================
-- Container: simple, chainable content
--==============================================================================

function Container:AddDivider()
    local divider = Draw.Box("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundTransparency = 0.2,
        LayoutOrder = self.NextOrder + 1,
        Parent = self.Body,
    }, "Track")
    self.NextOrder = self.NextOrder + 1
    return divider
end

function Container:AddSeparatorText(text)
    local section = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        LayoutOrder = self.NextOrder + 1,
        Parent = self.Body,
    })
    self.NextOrder = self.NextOrder + 1
    Draw.Text({
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section,
    }, "Strong", Util.TextSize("Section"), "Accent", tostring(text):upper())
    return section
end

function Container:AddLabel(text)
    local row = self:AddChild()
    local label = Draw.Text({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = row,
    }, "Body", Util.TextSize("Label"), "Text", text)
    function label.SetText(_, value)
        label.Text = tostring(value)
    end
    function label.AddColorPicker(_, idx, info)
        local picker = Container.AddColorPicker(self, idx, info)
        picker.Root.LayoutOrder = row.LayoutOrder + 1
        return picker
    end
    function label.AddKeyPicker(_, idx, info)
        local picker = Container.AddKeybind(self, idx, info)
        return picker
    end
    return label
end

function Container:AddParagraph(info)
    info = type(info) == "table" and info or { Text = tostring(info) }
    local row = self:AddChild()
    if info.Title and info.Title ~= "" then
        Draw.Text({
            Size = UDim2.new(1, 0, 0, 18),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        }, "Strong", Util.TextSize("Label"), "Text", info.Title)
    end
    local body = Draw.Text({
        Position = UDim2.fromOffset(0, info.Title and info.Title ~= "" and 20 or 0),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = row,
    }, "Desc", Util.TextSize("Desc"), "SubText", info.Text or "")
    function body.SetText(_, value)
        body.Text = tostring(value)
    end
    return body
end

Container.BeginChild = Container.AddChild
Container.Divider = Container.AddDivider
Container.Section = Container.AddSeparatorText
Container.Paragraph = Container.AddParagraph
--==============================================================================
-- Widgets
--==============================================================================

local function Norm(idx, info)
    if type(idx) == "table" then
        return nil, idx
    end
    return idx, info or {}
end

local Dropdown = {}

local function Fire(option, ...)
    if option.Callback then
        Util.Try(option.Callback, ...)
    end
end

--==============================================================================
-- Button (all styles use the single theme accent)
--==============================================================================

local function UpdateButtonWidths(row)
    local buttons = {}
    for _, child in ipairs(row:GetChildren()) do
        if child:IsA("GuiObject") and child.Name == "ButtonHolder" then
            table.insert(buttons, child)
        elseif child:IsA("GuiObject") and child.ClassName == "UIListLayout" then
            -- layout element
        end
    end
    local count = math.max(1, #buttons)
    for _, holder in ipairs(buttons) do
        holder.Size = UDim2.new(1 / count, -(Config.Gap.X * (count - 1)) / count, 1, 0)
    end
end

local function CreateButtonVisual(row, info)
    local metrics = Util.Metrics()
    local style = info.Style or "Default"
    -- Single-accent policy: every emphasized style is the theme accent.
    local primary = style ~= "Default" and style ~= "Secondary" and style ~= "Ghost"
    local holder = Draw.New("Frame", {
        Name = "ButtonHolder",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = row,
    })
    local face = Draw.Box("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 0,
        Parent = holder,
    }, primary and "Accent" or "Element", primary and nil or "Track", metrics.Radius, primary and 0 or 1)
    local content = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = face,
    })
    Draw.List(content, Config.Button.IconGap, true, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
    if info.Icon then
        local icon = Icons.Create(content, info.Icon, metrics.Icon, primary and "OnAccent" or "Accent")
    end
    local label = Draw.Text({
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 18),
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = content,
    }, "Strong", Util.TextSize("Button"), primary and "OnAccent" or "Text", info.Text or "Button")
    local hit = Draw.New("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 3,
        Parent = holder,
    })
    hit.MouseEnter:Connect(function()
        Anim.Tween(face, { BackgroundTransparency = primary and 0.18 or 0.4 }, 0.12, "Out")
    end)
    hit.MouseLeave:Connect(function()
        Anim.Tween(face, { BackgroundTransparency = 0 }, 0.12, "Out")
    end)
    hit.MouseButton1Down:Connect(function()
        Anim.Tween(face, { Position = UDim2.fromOffset(0, 2) }, 0.06, "Linear")
    end)
    hit.MouseButton1Up:Connect(function()
        Anim.Tween(face, { Position = UDim2.new() }, Config.Tween.Fast, "Back")
    end)
    local button = {
        Type = "Button",
        NoSave = true,
        Root = holder,
        Info = info,
        Label = label,
    }
    local armed = false
    local function Reset()
        armed = false
        label.Text = info.Text or "Button"
    end
    hit.Activated:Connect(function()
        if info.DoubleClick then
            if not armed then
                armed = true
                label.Text = "Click again to confirm"
                task.delay(Config.ConfirmWindow, function()
                    if armed and label.Parent then
                        Reset()
                    end
                end)
                return
            end
            Reset()
        end
        Anim.Tween(face, { Position = UDim2.new() }, 0.05, "Linear")
        if info.Func then
            Util.Try(info.Func)
        end
    end)
    function button.AddButton(_, info2, callback2)
        info2 = type(info2) == "table" and info2 or { Text = tostring(info2) }
        if callback2 and info2.Func == nil then
            info2.Func = callback2
        end
        local chained = CreateButtonVisual(row, info2)
        UpdateButtonWidths(row)
        return chained
    end
    return button
end

function Container:AddButton(info, callback)
    info = type(info) == "table" and info or { Text = tostring(info) }
    if callback and info.Func == nil then
        info.Func = callback
    end
    local metrics = Util.Metrics()
    local row = self:AddChild()
    row.AutomaticSize = Enum.AutomaticSize.None
    row.Size = UDim2.new(1, 0, 0, metrics.Row + 2)
    local layout = Draw.List(row, Config.Gap.X, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    layout.FillDirection = Enum.FillDirection.Horizontal
    local button = CreateButtonVisual(row, info)
    UpdateButtonWidths(row)
    return button
end

--==============================================================================
-- Toggle / Checkbox
--==============================================================================

local function BuildSwitchControl(row, info, isCheckbox)
    local metrics = Util.Metrics()
    local control
    if isCheckbox then
        control = Draw.Box("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(metrics.Check, metrics.Check),
            Parent = row,
        }, "Track", "Outline", 6, 1)
        local check = Icons.Create(control, "check", metrics.Check - 10, "OnAccent")
        check.AnchorPoint = Vector2.new(0.5, 0.5)
        check.Position = UDim2.fromScale(0.5, 0.5)
        control.Icon = check
    else
        control = Draw.Box("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(metrics.Switch.X, metrics.Switch.Y),
            Parent = row,
        }, "Track", nil, metrics.Switch.Y / 2)
        local knob = Draw.Box("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, metrics.SwitchKnob / 2 + 2, 0.5, 0),
            Size = UDim2.fromOffset(metrics.SwitchKnob, metrics.SwitchKnob),
            Parent = control,
        }, "Knob", nil, metrics.SwitchKnob / 2)
        control.Knob = knob
    end
    return control
end

local function CreateBoolWidget(container, idx, info, isCheckbox)
    local metrics = Util.Metrics()
    local row, text = Widget.BuildRow(container, info)
    local control = BuildSwitchControl(row, info, isCheckbox)
    local hit = Draw.New("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -metrics.Box - 14, 0, 0),
        Size = UDim2.new(0, metrics.Box + 16, 1, 0),
        ZIndex = 3,
        Parent = row,
    })
    local option = {
        Type = isCheckbox and "Checkbox" or "Toggle",
        Value = info.Default == true,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
        AddGuard = Widget.AddGuard,
        RunGuards = Widget.RunGuards,
    }
    local function Render()
        local on = option.Value
        if isCheckbox then
            Theme.Bind(control, { BackgroundColor3 = on and "Accent" or "Track" })
            control.Icon.ImageTransparency = on and 0 or 1
        else
            Theme.Bind(control, { BackgroundColor3 = on and "Accent" or "Track" })
            local metrics2 = Util.Metrics()
            local x = on and metrics2.Switch.X - metrics2.SwitchKnob / 2 - 2 or metrics2.SwitchKnob / 2 + 2
            Anim.Tween(control.Knob, { Position = UDim2.new(0, x, 0.5, 0) }, Config.Tween.Fast, "Out")
        end
    end
    option.Render = Render
    function option.SetValue(value, silent)
        value = value == true
        if value == option.Value then
            return
        end
        if value and not option:RunGuards(true) then
            return
        end
        option.Value = value
        Render()
        if not silent then
            Fire(option, value)
        end
    end
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        option.SetValue(value == true, true)
    end
    hit.Activated:Connect(function()
        option:SetValue(not option.Value)
    end)
    Widget.Register(idx, option)
    if idx then
        Library.Toggles[idx] = option
    end
    Render()
    return option
end

function Container:AddToggle(idx, info)
    idx, info = Norm(idx, info)
    return CreateBoolWidget(self, idx, info, false)
end

function Container:AddCheckbox(idx, info)
    idx, info = Norm(idx, info)
    return CreateBoolWidget(self, idx, info, true)
end

--==============================================================================
-- Slider
--==============================================================================

function Container:AddSlider(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local min = tonumber(info.Min) or 0
    local max = tonumber(info.Max) or 100
    if max <= min then
        max = min + 1
    end
    local step = math.abs(tonumber(info.Increment) or 1)
    local row, text = Widget.BuildRow(self, info)
    row.Size = UDim2.new(1, 0, 0, metrics.Row + 18)
    local valueLabel = Draw.Text({
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(80, 16),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    }, "Strong", Util.TextSize("Small"), "Accent", "0")
    local track = Draw.Box("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 0, metrics.Track),
        Active = true,
        Parent = row,
    }, "Track", nil, metrics.Track / 2)
    local fill = Draw.Box("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 0,
        Parent = track,
    }, "Accent", nil, metrics.Track / 2)
    local knob = Draw.Box("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(metrics.Knob, metrics.Knob),
        Active = true,
        ZIndex = 2,
        Parent = track,
    }, "Knob", "Accent", metrics.Knob / 2, 2)
    local option = {
        Type = "Slider",
        Value = tonumber(info.Default) or min,
        Min = min,
        Max = max,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
        AddGuard = Widget.AddGuard,
        RunGuards = Widget.RunGuards,
    }
    local function Snap(value)
        value = math.clamp(tonumber(value) or min, min, max)
        if step > 0 then
            value = math.floor((value - min) / step + 0.5) * step + min
        end
        return math.clamp(value, min, max)
    end
    local function Render()
        local ratio = (option.Value - min) / (max - min)
        ratio = math.clamp(ratio, 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        local display = string.format("%g", math.floor(option.Value * 100 + 0.5) / 100)
        if info.Suffix then
            display = display .. tostring(info.Suffix)
        end
        valueLabel.Text = display
    end
    option.Render = Render
    function option.SetValue(value, silent)
        value = Snap(value)
        if value == option.Value then
            return
        end
        option.Value = value
        Render()
        if not silent and not info.Finished then
            Fire(option, value)
        elseif not silent and info.Finished then
            Fire(option, value)
        end
    end
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        option.SetValue(tonumber(value) or option.Value, true)
    end
    local dragging = false
    local function FromPosition(x)
        local abs = track.AbsolutePosition
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return option.Value
        end
        return Snap(min + (max - min) * math.clamp((x - abs.X) / width, 0, 1))
    end
    track.InputBegan:Connect(function(input)
        if Util.IsPointer(input) then
            dragging = true
            option:SetValue(FromPosition(input.Position.X))
        end
    end)
    knob.InputBegan:Connect(function(input)
        if Util.IsPointer(input) then
            dragging = true
        end
    end)
    Util.Connect(UserInputService.InputChanged, function(input)
        if dragging and Util.IsMove(input) then
            option:SetValue(FromPosition(input.Position.X))
        end
    end)
    Util.Connect(UserInputService.InputEnded, function(input)
        if dragging and Util.IsPointer(input) then
            dragging = false
            if info.Finished then
                Fire(option, option.Value)
            end
        end
    end)
    Widget.Register(idx, option)
    Render()
    return option
end

--==============================================================================
-- Dropdown
--==============================================================================

Dropdown.Active = nil

function Container:AddDropdown(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local values = type(info.Values) == "table" and info.Values or {}
    local row, text = Widget.BuildRow(self, info)
    local button = Draw.Box("TextButton", {
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -metrics.Box - 14, 0, -3),
        Size = UDim2.new(0, math.max(Config.Dropdown.MinWidth, metrics.Box + 100), 0, metrics.Box + 6),
        Parent = row,
    }, "Element", "Track", metrics.Radius, 1)
    local label = Draw.Text({
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -34, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = button,
    }, "Body", Util.TextSize("Small"), "Text", "")
    local chevron = Icons.Create(button, "chevron-down", 16, "SubText")
    chevron.AnchorPoint = Vector2.new(1, 0.5)
    chevron.Position = UDim2.new(1, -8, 0.5, 0)
    local holder = self:AddChild()
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.Visible = false
    local option = {
        Type = "Dropdown",
        Value = nil,
        Values = values,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
        AddGuard = Widget.AddGuard,
        RunGuards = Widget.RunGuards,
    }
    local search
    local listFrame
    local closeConnection
    local function Close()
        if Dropdown.Active == option then
            Dropdown.Active = nil
        end
        if closeConnection then
            closeConnection:Disconnect()
            closeConnection = nil
        end
        holder.Visible = false
        Anim.Tween(chevron, { Rotation = 0 }, Config.Tween.Fast)
    end
    local function RenderList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child.Name == "Item" then
                child:Destroy()
            end
        end
        local query = search and string.lower(search.Text or "") or ""
        local shown = 0
        for _, value in ipairs(option.Values) do
            if query == "" or string.find(string.lower(tostring(value)), query, 1, true) then
                shown = shown + 1
                local item = Draw.Box("TextButton", {
                    Name = "Item",
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2.new(1, 0, 0, metrics.Item),
                    LayoutOrder = shown,
                    Parent = listFrame,
                }, "Element", nil, 6)
                local itemLabel = Draw.Text({
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = item,
                }, "Body", Util.TextSize("Small"), option.Value == value and "Accent" or "Text", tostring(value))
                if option.Value == value then
                    local mark = Icons.Create(item, "check", 14, "Accent")
                    mark.AnchorPoint = Vector2.new(1, 0.5)
                    mark.Position = UDim2.new(1, -6, 0.5, 0)
                end
                item.MouseEnter:Connect(function()
                    if option.Value ~= value then
                        item.BackgroundColor3 = Theme.Colors.Hover
                    end
                end)
                item.MouseLeave:Connect(function()
                    item.BackgroundColor3 = Theme.Colors.Element
                end)
                item.Activated:Connect(function()
                    option:SetValue(value)
                    Close()
                end)
            end
        end
        local visible = math.min(shown, Config.Dropdown.MaxVisible)
        listFrame.Size = UDim2.new(1, 0, 0, visible * metrics.Item)
        holder.Size = UDim2.new(1, 0, 0, (search and 30 or 0) + visible * metrics.Item + 8)
        holder.Visible = true
        if shown == 0 then
            Draw.Text({
                Size = UDim2.new(1, 0, 0, 20),
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = listFrame,
            }, "Desc", Util.TextSize("Small"), "Muted", "No matches")
        end
    end
    local function Open()
        if Dropdown.Active and Dropdown.Active ~= option and type(Dropdown.Active.CloseExternal) == "function" then
            Dropdown.Active.CloseExternal()
        end
        Dropdown.Active = option
        holder.Visible = true
        if #option.Values >= Config.Dropdown.SearchThreshold then
            if not search then
                search = Draw.New("TextBox", {
                    PlaceholderText = "Search...",
                    Text = "",
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.Colors.Element,
                    TextColor3 = Theme.Colors.Text,
                    PlaceholderColor3 = Theme.Colors.Muted,
                    Font = Fonts.Face("Desc"),
                    TextSize = Util.TextSize("Small"),
                    ClearTextOnFocus = false,
                    Parent = holder,
                })
                Draw.Stroke(search, "Track", 1)
                Draw.Corner(search, 6)
                search:GetPropertyChangedSignal("Text"):Connect(RenderList)
            end
            search.Visible = true
        end
        if not listFrame then
            listFrame = Draw.Scroll({
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                ClipsDescendants = true,
                Parent = holder,
            }, 2)
        end
        listFrame.Position = UDim2.new(0, 0, 0, search and 30 or 0)
        RenderList()
        Anim.Tween(chevron, { Rotation = 180 }, Config.Tween.Fast)
        closeConnection = Util.Connect(UserInputService.InputBegan, function(input, processed)
            if Util.IsPointer(input) then
                local inside = Util.Inside(holder, input.Position) or Util.Inside(button, input.Position)
                if not inside then
                    Close()
                end
            end
        end)
    end
    option.CloseExternal = Close
    local function Render()
        label.Text = option.Value ~= nil and tostring(option.Value) or "..."
    end
    option.Render = Render
    function option.SetValue(value, silent)
        if option.Value == value then
            return
        end
        option.Value = value
        Render()
        if holder.Visible then
            RenderList()
        end
        if not silent then
            Fire(option, value)
        end
    end
    function option.SetValues(_, values2)
        option.Values = type(values2) == "table" and values2 or {}
        if not table.find(option.Values, option.Value) then
            option.Value = nil
            Render()
        end
        if holder.Visible then
            RenderList()
        end
    end
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        if table.find(option.Values, value) then
            option.SetValue(value, true)
        end
    end
    button.Activated:Connect(function()
        if holder.Visible then
            Close()
        else
            Open()
        end
    end)
    Widget.Register(idx, option)
    if info.Default ~= nil and table.find(values, info.Default) then
        option.Value = info.Default
    elseif #values > 0 then
        option.Value = values[1]
    end
    Render()
    return option
end

--==============================================================================
-- ListBox (multi select)
--==============================================================================

function Container:AddListBox(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local values = type(info.Values) == "table" and info.Values or {}
    local row, text = Widget.BuildRow(self, info)
    local holder = self:AddChild()
    local visibleRows = math.max(1, tonumber(info.Height) or 4)
    holder.Size = UDim2.new(1, 0, 0, 28 + visibleRows * metrics.Item + 4)
    local search = Draw.New("TextBox", {
        PlaceholderText = "Search...",
        Text = "",
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Theme.Colors.Element,
        TextColor3 = Theme.Colors.Text,
        PlaceholderColor3 = Theme.Colors.Muted,
        Font = Fonts.Face("Desc"),
        TextSize = Util.TextSize("Small"),
        ClearTextOnFocus = false,
        Parent = holder,
    })
    Theme.Bind(search, { BackgroundColor3 = "Element", TextColor3 = "Text", PlaceholderColor3 = "Muted" })
    Draw.Stroke(search, "Track", 1)
    Draw.Corner(search, 6)
    local listFrame = Draw.Scroll({
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, visibleRows * metrics.Item),
        Parent = holder,
    }, 2)
    local option = {
        Type = "ListBox",
        Value = {},
        Values = values,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
    }
    local function RenderList()
        for _, child in ipairs(listFrame:GetChildren()) do
            if child.Name == "Item" then
                child:Destroy()
            end
        end
        local query = string.lower(search.Text or "")
        for _, value in ipairs(option.Values) do
            if query == "" or string.find(string.lower(tostring(value)), query, 1, true) then
                local selected = table.find(option.Value, value) ~= nil
                local item = Draw.Box("TextButton", {
                    Name = "Item",
                    Text = "",
                    AutoButtonColor = false,
                    Size = UDim2.new(1, 0, 0, metrics.Item),
                    Parent = listFrame,
                }, selected and "Accent" or "Element", selected and nil or "Track", 6, selected and 0 or 1)
                Draw.Text({
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -16, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = item,
                }, "Body", Util.TextSize("Small"), selected and "OnAccent" or "Text", tostring(value))
                item.Activated:Connect(function()
                    local at = table.find(option.Value, value)
                    if at then
                        table.remove(option.Value, at)
                    else
                        table.insert(option.Value, value)
                    end
                    RenderList()
                    Fire(option, option.Value)
                end)
            end
        end
    end
    search:GetPropertyChangedSignal("Text"):Connect(RenderList)
    function option.SetValues(_, values2)
        option.Values = type(values2) == "table" and values2 or {}
        option.Value = {}
        RenderList()
    end
    function option.GetActiveValues()
        return option.Value
    end
    function option.IsSelected(_, value)
        return table.find(option.Value, value) ~= nil
    end
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        if type(value) ~= "table" then
            return
        end
        option.Value = {}
        for _, entry in ipairs(value) do
            if table.find(option.Values, entry) then
                table.insert(option.Value, entry)
            end
        end
        RenderList()
    end
    if type(info.Default) == "table" then
        for _, entry in ipairs(info.Default) do
            if table.find(values, entry) then
                table.insert(option.Value, entry)
            end
        end
    elseif info.Default ~= nil and table.find(values, info.Default) then
        table.insert(option.Value, info.Default)
    end
    Widget.Register(idx, option)
    RenderList()
    return option
end

--==============================================================================
-- Input
--==============================================================================

function Container:AddInput(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local row, text = Widget.BuildRow(self, info)
    local box = Draw.New("TextBox", {
        PlaceholderText = info.Placeholder or "",
        Text = info.Default or "",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -metrics.Box - 14, 0, -3),
        Size = UDim2.new(0, math.max(170, metrics.Box + 100), 0, metrics.Box + 6),
        BackgroundColor3 = Theme.Colors.Element,
        TextColor3 = Theme.Colors.Text,
        PlaceholderColor3 = Theme.Colors.Muted,
        Font = Fonts.Face("Desc"),
        TextSize = Util.TextSize("Small"),
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ClipsDescendants = true,
        Parent = row,
    })
    Theme.Bind(box, { BackgroundColor3 = "Element", TextColor3 = "Text", PlaceholderColor3 = "Muted" })
    Draw.Padding(box, 0, 8, 0, 8)
    Draw.Stroke(box, "Track", 1)
    Draw.Corner(box, metrics.Radius)
    local option = {
        Type = "Input",
        Value = info.Default or "",
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
    }
    function option.SetValue(_, value, silent)
        box.Text = tostring(value or "")
        option.Value = box.Text
        if not silent then
            Fire(option, option.Value)
        end
    end
    function option.Serialize()
        return box.Text
    end
    function option.Deserialize(value)
        option.SetValue(value, true)
    end
    box:GetPropertyChangedSignal("Text"):Connect(function()
        option.Value = box.Text
    end)
    box.FocusLost:Connect(function(enterPressed)
        option.Value = box.Text
        if info.Finished ~= false or enterPressed then
            Fire(option, box.Text)
        end
    end)
    Widget.Register(idx, option)
    return option
end

--==============================================================================
-- Keybind
--==============================================================================

function Container:AddKeybind(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local row, text = Widget.BuildRow(self, info)
    local button = Draw.Box("TextButton", {
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -metrics.Box - 14, 0, -3),
        Size = UDim2.new(0, metrics.Box + 50, 0, metrics.Box + 6),
        Parent = row,
    }, "Element", "Track", metrics.Radius, 1)
    local label = Draw.Text({
        Size = UDim2.fromScale(1, 1),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = button,
    }, "Strong", Util.TextSize("Small"), "Accent", "None")
    local option = {
        Type = "Keybind",
        Value = Util.KeyName(info.Default) or "None",
        Mode = info.Mode or "Toggle",
        Active = false,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        ChangedCallback = info.ChangedCallback,
        SetVisible = Widget.SetVisible,
    }
    option.Bind = nil
    local function Render()
        label.Text = Keybinds.Short(option.Value or "None")
    end
    option.Render = Render
    function option.SetValue(name, silent)
        name = Util.KeyName(name) or "None"
        if option.Bind and option.OldName and option.OldName ~= "None" and Keybinds.List[option.OldName] then
            for index, bind in ipairs(Keybinds.List[option.OldName]) do
                if bind == option.Bind then
                    table.remove(Keybinds.List[option.OldName], index)
                    break
                end
            end
        end
        option.OldName = option.Value
        option.Value = name
        if name ~= "None" then
            option.Bind = Keybinds.Register(name, option.Mode, function(...)
                Fire(option, ...)
            end, option.Active)
        end
        Render()
        if not silent and option.ChangedCallback then
            Util.Try(option.ChangedCallback, name)
        end
    end
    function option.Capture(_, name)
        option:SetValue(name or "None")
    end
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        option.SetValue(value, true)
    end
    button.Activated:Connect(function()
        State.Binding = option
        label.Text = "..."
    end)
    Widget.Register(idx, option)
    option.SetValue(option.Value, true)
    return option
end

--==============================================================================
-- ColorPicker
--==============================================================================

function Container:AddColorPicker(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local row, text = Widget.BuildRow(self, info)
    local swatch = Draw.Box("TextButton", {
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -metrics.Box - 14, 0, -3),
        Size = UDim2.fromOffset(metrics.Box + 6, metrics.Box + 6),
        Parent = row,
    }, nil, "Track", metrics.Radius, 1)
    local holder = self:AddChild()
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.Visible = false
    local field = Draw.Box("Frame", {
        Size = UDim2.new(1, -90, 0, Config.ColorPicker.Field),
        BackgroundColor3 = Color3.new(1, 0, 0),
        Active = true,
        Parent = holder,
    }, nil, "Outline", 8, 1)
    local whiteOverlay = Draw.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = field,
    })
    local whiteGradient = Draw.New("UIGradient", {
        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
        Transparency = NumberSequence.new(0, 1),
        Parent = whiteOverlay,
    })
    local blackOverlay = Draw.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Parent = field,
    })
    local blackGradient = Draw.New("UIGradient", {
        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
        Transparency = NumberSequence.new(1, 0),
        Rotation = 90,
        Parent = blackOverlay,
    })
    Draw.Corner(whiteOverlay, 8)
    Draw.Corner(blackOverlay, 8)
    local cursor = Draw.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = field,
    })
    Draw.Corner(cursor, 5)
    local hueBar = Draw.Box("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 78, 0, Config.ColorPicker.Field),
        Active = true,
        Parent = holder,
    }, nil, "Outline", 8, 1)
    local hueGradient = Draw.New("UIGradient", {
        Color = ColorSequence.new({
            Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(255, 0, 0),
        }),
        Parent = hueBar,
    })
    local hueCursor = Draw.Box("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Size = UDim2.new(1, 4, 0, 4),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 3,
        Parent = hueBar,
    }, nil, "Outline", 2, 1)
    local default = info.Default
    if typeof(default) ~= "Color3" then
        default = Color3.fromRGB(224, 88, 76)
    end
    local hue, sat, val = default:ToHSV()
    if hue < 0 then
        hue = 0
    end
    local option = {
        Type = "ColorPicker",
        Value = default,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
    }
    local function Render()
        field.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        cursor.Position = UDim2.new(sat, 0, 1 - val, 0)
        hueCursor.Position = UDim2.new(0.5, 0, hue, 0)
        swatch.BackgroundColor3 = option.Value
        option.Value = Color3.fromHSV(hue, sat, val)
    end
    option.Render = Render
    local function FromHSVPosition(x, y)
        local abs = field.AbsolutePosition
        local size = field.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then
            return
        end
        sat = math.clamp((x - abs.X) / size.X, 0, 1)
        val = 1 - math.clamp((y - abs.Y) / size.Y, 0, 1)
        Render()
        Fire(option, option.Value)
    end
    local function FromHuePosition(x)
        local abs = hueBar.AbsolutePosition
        local size = hueBar.AbsoluteSize
        if size.X <= 0 then
            return
        end
        hue = math.clamp((x - abs.X) / size.X, 0, 1)
        Render()
        Fire(option, option.Value)
    end
    local fieldDragging, hueDragging = false, false
    field.InputBegan:Connect(function(input)
        if Util.IsPointer(input) then
            fieldDragging = true
            FromHSVPosition(input.Position.X, input.Position.Y)
        end
    end)
    hueBar.InputBegan:Connect(function(input)
        if Util.IsPointer(input) then
            hueDragging = true
            FromHuePosition(input.Position.X)
        end
    end)
    Util.Connect(UserInputService.InputChanged, function(input)
        if Util.IsMove(input) then
            if fieldDragging then
                FromHSVPosition(input.Position.X, input.Position.Y)
            elseif hueDragging then
                FromHuePosition(input.Position.X)
            end
        end
    end)
    Util.Connect(UserInputService.InputEnded, function(input)
        if Util.IsPointer(input) then
            fieldDragging = false
            hueDragging = false
        end
    end)
    function option.SetValue(color, silent)
        if typeof(color) == "Color3" then
            hue, sat, val = color:ToHSV()
            Render()
            if not silent then
                Fire(option, option.Value)
            end
        end
    end
    function option.Serialize()
        local r = math.floor(option.Value.R * 255 + 0.5)
        local g = math.floor(option.Value.G * 255 + 0.5)
        local b = math.floor(option.Value.B * 255 + 0.5)
        return { r, g, b }
    end
    function option.Deserialize(value)
        if type(value) == "table" and #value == 3 then
            option.SetValue(Color3.fromRGB(value[1], value[2], value[3]), true)
        end
    end
    swatch.Activated:Connect(function()
        holder.Visible = not holder.Visible
        if holder.Visible then
            holder.Size = UDim2.new(1, 0, 0, Config.ColorPicker.Field + 8)
        else
            holder.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    Widget.Register(idx, option)
    Render()
    return option
end

--==============================================================================
-- Stepper
--==============================================================================

function Container:AddStepper(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local row, text = Widget.BuildRow(self, info)
    local cluster = Draw.New("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -metrics.Box - 14, 0, -3),
        Size = UDim2.fromOffset(120, metrics.Box + 6),
        Parent = row,
    })
    local stepperLayout = Draw.List(cluster, 6, false, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center)
    stepperLayout.FillDirection = Enum.FillDirection.Horizontal
    local function MakeSide(iconName, dir)
        local side = Draw.Box("TextButton", {
            Text = "",
            AutoButtonColor = false,
            Size = UDim2.fromOffset(28, metrics.Box + 6),
            Parent = cluster,
        }, "Element", "Track", metrics.Radius, 1)
        local icon = Icons.Create(side, iconName, 14, "Accent")
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        return side, dir
    end
    local option = {
        Type = "Stepper",
        Value = tonumber(info.Default) or (type(info.Values) == "table" and info.Values[1]) or 0,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
    }
    local valueLabel = Draw.Text({
        Size = UDim2.fromOffset(48, 18),
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = cluster,
    }, "Strong", Util.TextSize("Small"), "Accent", tostring(option.Value))
    local function Step(delta)
        local value = option.Value
        if type(info.Values) == "table" and #info.Values > 0 then
            local at = table.find(info.Values, value) or 1
            at = math.clamp(at + delta, 1, #info.Values)
            option.Value = info.Values[at]
        else
            local min = tonumber(info.Min)
            local max = tonumber(info.Max)
            local stepBy = tonumber(info.Step) or 1
            value = value + delta * stepBy
            if min then
                value = math.max(min, value)
            end
            if max then
                value = math.min(max, value)
            end
            option.Value = value
        end
        valueLabel.Text = tostring(option.Value)
        Fire(option, option.Value)
    end
    local minus = MakeSide("minus", -1)
    local plus = MakeSide("plus", 1)
    minus[1].Activated:Connect(function()
        Step(-1)
    end)
    plus[1].Activated:Connect(function()
        Step(1)
    end)
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        if value ~= nil then
            option.Value = value
            valueLabel.Text = tostring(value)
        end
    end
    Widget.Register(idx, option)
    valueLabel.Text = tostring(option.Value)
    return option
end

--==============================================================================
-- Segmented
--==============================================================================

function Container:AddSegmented(idx, info)
    idx, info = Norm(idx, info)
    local metrics = Util.Metrics()
    local values = type(info.Values) == "table" and info.Values or { "A", "B" }
    local row = self:AddChild()
    row.AutomaticSize = Enum.AutomaticSize.None
    row.Size = UDim2.new(1, 0, 0, metrics.Row)
    if info.Text and info.Text ~= "" then
        Draw.Text({
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, 0, 0, 16),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        }, "Body", Util.TextSize("Label"), "Text", info.Text)
    end
    local cluster = Draw.New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, info.Text and info.Text ~= "" and 18 or 0),
        Size = UDim2.new(1, 0, 0, metrics.Box + 8),
        Parent = row,
    })
    local segmentedLayout = Draw.List(cluster, 4, false, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    segmentedLayout.FillDirection = Enum.FillDirection.Horizontal
    local option = {
        Type = "Segmented",
        Value = info.Default or values[1],
        Values = values,
        Info = info,
        Root = row,
        NoSave = info.NoSave,
        Callback = info.Callback,
        SetVisible = Widget.SetVisible,
    }
    local segments = {}
    local function Render()
        for value, segment in pairs(segments) do
            local active = option.Value == value
            Theme.Bind(segment.Face, { BackgroundColor3 = active and "Accent" or "Element" })
            Theme.Bind(segment.Label, { TextColor3 = active and "OnAccent" or "SubText" })
        end
    end
    option.Render = Render
    function option.SetValue(value, silent)
        if not table.find(option.Values, value) then
            return
        end
        option.Value = value
        Render()
        if not silent then
            Fire(option, value)
        end
    end
    function option.Serialize()
        return option.Value
    end
    function option.Deserialize(value)
        option.SetValue(value, true)
    end
    for _, value in ipairs(values) do
        local segment = Draw.Box("TextButton", {
            Text = "",
            AutoButtonColor = false,
            Size = UDim2.new(1 / #values, -4, 0, metrics.Box + 8),
            Parent = cluster,
        }, nil, "Track", metrics.Radius, 1)
        local label = Draw.Text({
            Size = UDim2.fromScale(1, 1),
            TextXAlignment = Enum.TextXAlignment.Center,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = segment,
        }, "Strong", Util.TextSize("Small"), "SubText", tostring(value))
        segments[value] = { Face = segment, Label = label }
        segment.Activated:Connect(function()
            option:SetValue(value)
        end)
    end
    Widget.Register(idx, option)
    Render()
    return option
end

--==============================================================================
-- Container aliases (compatibility with the original hub API)
--==============================================================================

Container.Toggle = Container.AddToggle
Container.Checkbox = Container.AddCheckbox
Container.Slider = Container.AddSlider
Container.Dropdown = Container.AddDropdown
Container.Input = Container.AddInput
Container.Button = Container.AddButton
Container.Keybind = Container.AddKeybind
Container.Colorpicker = Container.AddColorPicker
Container.Label = Container.AddLabel
Container.Paragraph = Container.AddParagraph
Container.Divider = Container.AddDivider
Container.Section = Container.AddSeparatorText
Container.Stepper = Container.AddStepper
Container.Segmented = Container.AddSegmented
--==============================================================================
-- Configs (executor file system, JSON snapshots)
--==============================================================================

function Configs.SetFolder(name)
    Configs.Folder = Config.ConfigRoot .. "/" .. Util.Sanitize(name)
    if Util.FileApi() then
        Util.EnsureFolder(Config.ConfigRoot)
        Util.EnsureFolder(Configs.Folder)
    end
end

function Configs.Path(name)
    return Configs.Folder .. "/" .. Util.Sanitize(name) .. ".json"
end

function Configs.Save(name)
    if not Util.FileApi() then
        return false, "No file API on this executor"
    end
    local snapshot = {}
    for idx, option in pairs(Library.Options) do
        if not option.NoSave and option.Serialize then
            local ok, value = pcall(option.Serialize, option)
            if ok then
                snapshot[idx] = { Type = option.Type, Value = value }
            end
        end
    end
    return (pcall(writefile, Configs.Path(name), HttpService:JSONEncode(snapshot)))
end

function Configs.Load(name)
    local path = Configs.Path(name)
    if not Util.FileApi() or not Util.Exists(path) then
        return false, "Config not found"
    end
    local read, raw = pcall(readfile, path)
    local ok, snapshot = pcall(HttpService.JSONDecode, HttpService, read and raw or "")
    if not ok or type(snapshot) ~= "table" then
        return false, "Config file is broken"
    end
    for idx, saved in pairs(snapshot) do
        local option = Library.Options[idx]
        if option and not option.NoSave and option.Type == saved.Type then
            Util.Try(option.Deserialize, option, saved.Value)
        end
    end
    return true
end

function Configs.Delete(name)
    local path = Configs.Path(name)
    if type(delfile) ~= "function" or not Util.FileApi() or not Util.Exists(path) then
        return false, "Config not found"
    end
    return (pcall(delfile, path))
end

function Configs.List()
    if type(listfiles) ~= "function" or not Util.FileApi() then
        return {}
    end
    local ok, files = pcall(listfiles, Configs.Folder)
    local names = {}
    for _, path in ipairs(ok and files or {}) do
        local found = path:match("([^/\\]+)%.json$")
        if found then
            table.insert(names, found)
        end
    end
    table.sort(names)
    return names
end

function Configs.SetAutoload(name)
    if not Util.FileApi() then
        return false, "No file API on this executor"
    end
    return (pcall(writefile, Configs.Folder .. "/autoload.txt", name))
end

function Configs.GetAutoload()
    local path = Configs.Folder .. "/autoload.txt"
    if not Util.FileApi() or not Util.Exists(path) then
        return nil
    end
    local ok, name = pcall(readfile, path)
    return ok and type(name) == "string" and name ~= "" and name or nil
end

function Configs.BuildSection(group)
    local nameInput = group:AddInput("FallensConfigName", { Text = "Config name", Placeholder = "default", NoSave = true })
    local list = group:AddListBox("FallensConfigList", { Text = "Saved configs", Values = Configs.List(), Height = 4, NoSave = true })
    local autoload = group:AddLabel("Autoload: " .. (Configs.GetAutoload() or "None"))
    local function Selected()
        local typed = tostring(nameInput.Value or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if typed ~= "" then
            return typed
        end
        local picked = type(list.Value) == "table" and list.Value[1] or nil
        return picked
    end
    local function Run(actionName, handler)
        local name = Selected()
        if not name or name == "" then
            Library:Notify("Configs", "Pick or type a config name first", 3, "Warning")
            return
        end
        local ok, reason = handler(name)
        Library:Notify("Configs", ok and (actionName .. ": " .. name) or (actionName .. " failed: " .. tostring(reason)), 3, ok and "Success" or "Error")
        list:SetValues(Configs.List())
    end
    group:AddButton({ Text = "Save", Style = "Primary", Func = function()
        Run("Save", Configs.Save)
    end }):AddButton({ Text = "Load", Style = "Primary", Func = function()
        Run("Load", Configs.Load)
    end })
    group:AddButton({ Text = "Delete", Style = "Danger", DoubleClick = true, Func = function()
        Run("Delete", Configs.Delete)
    end }):AddButton({ Text = "Refresh", Func = function()
        list:SetValues(Configs.List())
    end })
    group:AddButton({ Text = "Set autoload", Style = "Primary", Func = function()
        Run("Set autoload", function(name)
            local ok = Configs.SetAutoload(name)
            if ok then
                autoload:SetText("Autoload: " .. name)
            end
            return ok
        end)
    end })
end

--==============================================================================
-- Settings tab
--==============================================================================

function Window:AddSettingsTab()
    local tab = self:AddTab("Settings", "settings", "Interface and configs")
    local interface = tab:AddLeftGroupbox("Interface", "sliders")
    interface:AddDropdown("FallensTheme", {
        Text = "Theme",
        Values = Themes.Order,
        Default = State.ThemeName,
        Callback = function(name)
            Library:SetTheme(name)
        end,
    })
    interface:AddSlider("FallensScale", {
        Text = "UI scale",
        Min = Config.ScaleRange.Min * 100,
        Max = Config.ScaleRange.Max * 100,
        Default = State.UserScale * 100,
        Suffix = "%",
        Finished = true,
        Callback = function(value)
            self:SetScale(value / 100)
        end,
    })
    interface:AddKeybind("FallensMenuKey", {
        Text = "Menu key",
        Default = State.MenuKey,
        Mode = "Always",
        ChangedCallback = function(name)
            State.MenuKey = name
        end,
    })
    interface:AddToggle("FallensWatermark", {
        Text = "Watermark",
        Description = "Hub name, FPS, ping and session time",
        Default = Watermark.Frame ~= nil and Watermark.Frame.Visible,
        Callback = Watermark.SetVisible,
    })
    interface:AddToggle("FallensFloat", {
        Text = "Mobile button",
        Description = "Floating logo button that opens the menu",
        Default = Float.Button ~= nil and Float.Button.Visible,
        Callback = Float.SetVisible,
    })
    local about = tab:AddLeftGroupbox("About", "star")
    about:AddLabel(string.format("%s v%s", self.Title, Library.Version))
    about:AddLabel("Device: " .. (State.Touch and "Mobile" or "PC"))
    about:AddButton({ Text = "Rejoin", Func = function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end }):AddButton({ Text = "Unload", Style = "Danger", DoubleClick = true, Func = function()
        Library:Unload()
    end })
    Configs.BuildSection(tab:AddRightGroupbox("Configs", "save"))
    return tab
end

--==============================================================================
-- Visuals: pure GuiObject ESP engine (no Drawing API dependency)
--==============================================================================

Visuals.Settings = {
    Enabled = false,
    Box = true,
    BoxStyle = "Full",
    BoxFill = false,
    Name = true,
    Health = true,
    HealthText = false,
    Distance = true,
    Tracer = false,
    TracerOrigin = "Bottom",
    HeadDot = false,
    Chams = false,
    TeamCheck = true,
    MaxDistance = 2000,
    TextSize = 13,
    Radar = false,
    RadarRange = 250,
    RadarSize = 180,
    EnemyColor = Color3.fromRGB(224, 88, 76),
    FriendColor = Color3.fromRGB(96, 196, 120),
}
Visuals.Entries = {}
Visuals.Targets = {}
Visuals.Provider = nil
Visuals.LastScan = 0
Visuals.ScanInterval = 0.2
Visuals.Started = false

function Visuals.DefaultProvider()
    local targets = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                targets[#targets + 1] = {
                    Model = char,
                    Name = player.DisplayName,
                    Health = hum.Health,
                    MaxHealth = hum.MaxHealth,
                    Friendly = player.Team ~= nil and player.Team == LocalPlayer.Team,
                }
            end
        end
    end
    return targets
end

function Visuals.EnsureGui()
    if Visuals.Gui and Visuals.Gui.Parent then
        return Visuals.Gui
    end
    Visuals.Gui = Draw.New("ScreenGui", {
        Name = "FALLENSVisuals",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 5,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = Util.GuiParent(),
    })
    return Visuals.Gui
end

function Visuals.BuildEntry()
    local entry = {}
    local holder = Draw.New("Frame", {
        Name = "Entry",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = Visuals.EnsureGui(),
    })
    entry.Holder = holder
    local box = Draw.New("Frame", {
        Name = "Box",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = holder,
    })
    entry.Box = box
    entry.BoxStroke = Draw.New("UIStroke", { Thickness = 1, Parent = box })
    entry.Corners = {}
    for _ = 1, 8 do
        local piece = Draw.New("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Visible = false,
            Parent = holder,
        })
        table.insert(entry.Corners, piece)
    end
    entry.Name = Draw.New("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.Face("Strong"),
        TextSize = 13,
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeTransparency = 0.4,
        AnchorPoint = Vector2.new(0.5, 1),
        Parent = holder,
    })
    entry.Distance = Draw.New("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.Face("Desc"),
        TextSize = 12,
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeTransparency = 0.5,
        AnchorPoint = Vector2.new(0.5, 0),
        Parent = holder,
    })
    entry.HealthText = Draw.New("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.Face("Desc"),
        TextSize = 11,
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeTransparency = 0.5,
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = holder,
    })
    entry.HealthBg = Draw.New("Frame", {
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = holder,
    })
    entry.HealthFill = Draw.New("Frame", {
        BackgroundColor3 = Color3.new(0, 1, 0),
        BorderSizePixel = 0,
        Parent = entry.HealthBg,
    })
    entry.Tracer = Draw.New("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(0, 1),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = holder,
    })
    entry.Dot = Draw.New("Frame", {
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(5, 5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = false,
        Parent = holder,
    })
    Draw.Corner(entry.Dot, 3)
    entry.Highlight = nil
    entry.Used = false
    return entry
end

function Visuals.HideEntry(entry)
    for _, inst in ipairs({
        entry.Box, entry.Name, entry.Distance, entry.HealthText,
        entry.HealthBg, entry.Tracer, entry.Dot,
    }) do
        if inst then
            inst.Visible = false
        end
    end
    for _, piece in ipairs(entry.Corners or {}) do
        piece.Visible = false
    end
end

function Visuals.DestroyEntry(entry)
    Visuals.Chams(entry, nil, nil)
    if entry.Holder then
        entry.Holder:Destroy()
    end
end

function Visuals.Chams(entry, model, color)
    if not model then
        if entry.Highlight then
            entry.Highlight:Destroy()
            entry.Highlight = nil
        end
        return
    end
    if not entry.Highlight then
        entry.Highlight = Instance.new("Highlight")
        entry.Highlight.FillTransparency = 0.55
        entry.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        entry.Highlight.Adornee = model
        entry.Highlight.Parent = Visuals.EnsureGui()
    end
    entry.Highlight.FillColor = color
    entry.Highlight.OutlineColor = color
end

function Visuals.TracerOrigin(viewport)
    local origin = Visuals.Settings.TracerOrigin
    if origin == "Center" then
        return Vector2.new(viewport.X / 2, viewport.Y / 2)
    elseif origin == "Mouse" then
        local mouse = UserInputService:GetMouseLocation()
        return Vector2.new(mouse.X, mouse.Y)
    end
    return Vector2.new(viewport.X / 2, viewport.Y)
end

local function SetLine(line, from, to)
    local delta = to - from
    local distance = delta.Magnitude
    if distance < 1 then
        line.Visible = false
        return
    end
    line.Visible = true
    line.Size = UDim2.fromOffset(distance, 1)
    line.Position = UDim2.fromOffset(from.X, from.Y)
    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
end

function Visuals.Layout(entry, root, target, distance, camera, viewport, settings)
    local topPos = (root.CFrame * CFrame.new(0, root.Size.Y / 2 + 0.5, 0)).Position
    local bottomPos = (root.CFrame * CFrame.new(0, -root.Size.Y / 2 - 0.5, 0)).Position
    local top = camera:WorldToViewportPoint(topPos)
    local bottom = camera:WorldToViewportPoint(bottomPos)
    if top.Z <= 0 or bottom.Z <= 0 then
        Visuals.HideEntry(entry)
        return
    end
    local height = math.abs(top.Y - bottom.Y)
    local width = math.max(12, height * 0.55)
    local x = (top.X + bottom.X) / 2
    local y = math.min(top.Y, bottom.Y)
    local color = target.Friendly and settings.FriendColor or settings.EnemyColor
    entry.Box.Visible = settings.Box and settings.BoxStyle == "Full"
    if entry.Box.Visible then
        entry.Box.Position = UDim2.fromOffset(x - width / 2, y)
        entry.Box.Size = UDim2.fromOffset(width, height)
        entry.Box.BackgroundTransparency = settings.BoxFill and 0.75 or 1
        entry.Box.BackgroundColor3 = color
        entry.BoxStroke.Color = color
    end
    local cornerMode = settings.Box and settings.BoxStyle == "Corner"
    local cl = math.max(6, math.min(width, height) * 0.28)
    local t = 2
    local cornerSpecs = {
        { x - width / 2, y, cl, t },
        { x - width / 2, y, t, cl },
        { x + width / 2 - cl, y, cl, t },
        { x + width / 2 - t, y, t, cl },
        { x - width / 2, y + height - t, cl, t },
        { x - width / 2, y + height - cl, t, cl },
        { x + width / 2 - cl, y + height - t, cl, t },
        { x + width / 2 - t, y + height - cl, t, cl },
    }
    for index, piece in ipairs(entry.Corners) do
        piece.Visible = cornerMode
        if cornerMode then
            local spec = cornerSpecs[index]
            piece.Position = UDim2.fromOffset(spec[1], spec[2])
            piece.Size = UDim2.fromOffset(spec[3], spec[4])
            piece.BackgroundColor3 = color
        end
    end
    if settings.Name then
        entry.Name.Visible = true
        entry.Name.Text = target.Name or ""
        entry.Name.TextSize = settings.TextSize
        entry.Name.TextColor3 = color
        entry.Name.Position = UDim2.fromOffset(x, y - 2)
    else
        entry.Name.Visible = false
    end
    if settings.Distance then
        entry.Distance.Visible = true
        entry.Distance.Text = string.format("%dm", math.floor(distance + 0.5))
        entry.Distance.TextSize = settings.TextSize - 1
        entry.Distance.Position = UDim2.fromOffset(x, y + height + 2)
    else
        entry.Distance.Visible = false
    end
    local pct = target.MaxHealth and target.MaxHealth > 0 and math.clamp(target.Health / target.MaxHealth, 0, 1) or 1
    if settings.Health then
        entry.HealthBg.Visible = true
        entry.HealthBg.Position = UDim2.fromOffset(x - width / 2 - 7, y)
        entry.HealthBg.Size = UDim2.fromOffset(3, height)
        entry.HealthFill.Visible = true
        entry.HealthFill.AnchorPoint = Vector2.new(0, 1)
        entry.HealthFill.Position = UDim2.new(0, 0, 1, 0)
        entry.HealthFill.Size = UDim2.new(1, 0, pct, 0)
        entry.HealthFill.BackgroundColor3 = Color3.new(1 - pct, pct, 0.25)
    else
        entry.HealthBg.Visible = false
    end
    if settings.HealthText then
        entry.HealthText.Visible = true
        entry.HealthText.Text = string.format("%d%%", math.floor(pct * 100 + 0.5))
        entry.HealthText.Position = UDim2.fromOffset(x - width / 2 - 10, y + height / 2)
    else
        entry.HealthText.Visible = false
    end
    if settings.Tracer then
        SetLine(entry.Tracer, Visuals.TracerOrigin(viewport), Vector2.new(x, y + height))
        entry.Tracer.BackgroundColor3 = color
    else
        entry.Tracer.Visible = false
    end
    if settings.HeadDot then
        entry.Dot.Visible = true
        entry.Dot.Position = UDim2.fromOffset(top.X, top.Y)
        entry.Dot.BackgroundColor3 = color
    else
        entry.Dot.Visible = false
    end
    if settings.Chams then
        Visuals.Chams(entry, target.Model, color)
    else
        Visuals.Chams(entry, nil, nil)
    end
end

function Visuals.Scan()
    local provider = Visuals.Provider or Visuals.DefaultProvider
    local ok, targets = pcall(provider)
    Visuals.Targets = ok and type(targets) == "table" and targets or {}
end

function Visuals.ClearAll()
    for model, entry in pairs(Visuals.Entries) do
        Visuals.DestroyEntry(entry)
        Visuals.Entries[model] = nil
    end
    if Visuals.Radar and Visuals.Radar.Frame then
        for _, dot in ipairs(Visuals.Radar.Dots) do
            dot.Visible = false
        end
        Visuals.Radar.Frame.Visible = Visuals.Settings.Radar and Visuals.Settings.Enabled
    end
end

function Visuals.Render()
    local settings = Visuals.Settings
    local gui = Visuals.Gui
    if not gui or not gui.Parent then
        return
    end
    if not settings.Enabled then
        if next(Visuals.Entries) ~= nil then
            Visuals.ClearAll()
        end
        return
    end
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end
    local now = os.clock()
    if now - Visuals.LastScan >= Visuals.ScanInterval then
        Visuals.LastScan = now
        Visuals.Scan()
    end
    local viewport = gui.AbsoluteSize
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    for _, target in ipairs(Visuals.Targets) do
        local model = target.Model
        if model and model.Parent and (not settings.TeamCheck or not target.Friendly) then
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = localRoot and (root.Position - localRoot.Position).Magnitude or 0
                if dist <= settings.MaxDistance then
                    local entry = Visuals.Entries[model]
                    if not entry then
                        entry = Visuals.BuildEntry()
                        Visuals.Entries[model] = entry
                    end
                    Visuals.Layout(entry, root, target, dist, camera, viewport, settings)
                    entry.Used = true
                end
            end
        end
    end
    for model, entry in pairs(Visuals.Entries) do
        if entry.Used then
            entry.Used = false
        else
            Visuals.DestroyEntry(entry)
            Visuals.Entries[model] = nil
        end
    end
end

function Visuals.RadarBuild()
    Visuals.RadarTearDown()
    local settings = Visuals.Settings
    if not settings.Radar then
        return
    end
    local size = settings.RadarSize
    local radar = Draw.Box("Frame", {
        Name = "Radar",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -20, 0, 20),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 0.15,
        Active = true,
        ZIndex = 5,
        Parent = Visuals.EnsureGui(),
    }, "Backdrop", "Outline", 12, 2)
    local cross = Draw.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size - 16, 1),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = radar,
    })
    Theme.Bind(cross, { BackgroundColor3 = "Track" })
    local cross2 = Draw.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1, size - 16),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = radar,
    })
    Theme.Bind(cross2, { BackgroundColor3 = "Track" })
    local center = Draw.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(5, 5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = radar,
    })
    Draw.Corner(center, 3)
    local dots = {}
    for _ = 1, 24 do
        local dot = Draw.New("Frame", {
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(4, 4),
            Visible = false,
            Parent = radar,
        })
        Draw.Corner(dot, 2)
        table.insert(dots, dot)
    end
    Gui.Draggable(radar, function(begin, delta)
        if not delta then
            return radar.Position
        end
        radar.Position = begin + UDim2.fromOffset(delta.X, delta.Y)
        return begin
    end)
    Visuals.Radar = { Frame = radar, Dots = dots }
end

function Visuals.RadarTearDown()
    if Visuals.Radar and Visuals.Radar.Frame then
        Visuals.Radar.Frame:Destroy()
    end
    Visuals.Radar = nil
end

function Visuals.RadarRender()
    local settings = Visuals.Settings
    local radar = Visuals.Radar
    if not settings.Radar or not settings.Enabled then
        if radar and radar.Frame then
            radar.Frame.Visible = false
        end
        return
    end
    if not radar then
        Visuals.RadarBuild()
        radar = Visuals.Radar
        if not radar then
            return
        end
    end
    radar.Frame.Visible = true
    local camera = Workspace.CurrentCamera
    local localChar = LocalPlayer.Character
    local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
    if not camera or not localRoot then
        for _, dot in ipairs(radar.Dots) do
            dot.Visible = false
        end
        return
    end
    local size = settings.RadarSize
    local half = size / 2
    local range = math.max(1, settings.RadarRange)
    local rightVector = camera.CFrame.RightVector
    local lookVector = camera.CFrame.LookVector
    local dotIndex = 0
    for _, target in ipairs(Visuals.Targets) do
        local model = target.Model
        local root = model and model.Parent and (model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart)
        if root and (not settings.TeamCheck or not target.Friendly) then
            local rel = root.Position - localRoot.Position
            if rel.Magnitude <= range then
                local px = half + (rel:Dot(rightVector) / range) * half
                local py = half - (rel:Dot(lookVector) / range) * half
                dotIndex = dotIndex + 1
                local dot = radar.Dots[dotIndex]
                if dot then
                    dot.Visible = true
                    dot.Position = UDim2.fromOffset(px - 2, py - 2)
                    dot.BackgroundColor3 = target.Friendly and settings.FriendColor or settings.EnemyColor
                end
            end
        end
    end
    for index = dotIndex + 1, #radar.Dots do
        radar.Dots[index].Visible = false
    end
end

function Visuals.Start()
    if Visuals.Started then
        return
    end
    Visuals.Started = true
    Util.Connect(RunService.RenderStepped, function()
        Visuals.Render()
        Visuals.RadarRender()
    end)
    table.insert(State.UnloadHooks, function()
        Visuals.ClearAll()
        Visuals.RadarTearDown()
        if Visuals.Gui then
            Visuals.Gui:Destroy()
            Visuals.Gui = nil
        end
    end)
end

-- Build the complete Visuals tab in one call; returns the tab.
function Window:AddVisualsTab(options)
    options = options or {}
    Visuals.Start()
    if options.Provider then
        Visuals:SetProvider(options.Provider)
    end
    local function Bind(key)
        return function(value)
            Visuals:Set(key, value)
        end
    end
    local tab = self:AddTab(options.Name or "Visuals", options.Icon or "eye", options.Description or "Player ESP")
    local main = tab:AddLeftGroupbox("ESP", "eye")
    main:AddToggle("FallensEsp", { Text = "Enable ESP", Callback = Bind("Enabled") })
    main:AddToggle("FallensEspTeam", { Text = "Team check", Default = true, Callback = Bind("TeamCheck") })
    main:AddSlider("FallensEspRange", { Text = "Max distance", Min = 50, Max = 5000, Default = 2000, Suffix = "m", Callback = Bind("MaxDistance") })
    main:AddSlider("FallensEspText", { Text = "Text size", Min = 9, Max = 20, Default = 13, Callback = Bind("TextSize") })
    local look = tab:AddRightGroupbox("Elements", "list")
    look:AddToggle("FallensEspBox", { Text = "Box", Default = true, Callback = Bind("Box") })
    look:AddDropdown("FallensEspBoxStyle", { Text = "Box style", Values = { "Full", "Corner" }, Default = "Full", Callback = Bind("BoxStyle") })
    look:AddToggle("FallensEspFill", { Text = "Box fill", Callback = Bind("BoxFill") })
    look:AddToggle("FallensEspName", { Text = "Name", Default = true, Callback = Bind("Name") })
    look:AddToggle("FallensEspHealth", { Text = "Health bar", Default = true, Callback = Bind("Health") })
    look:AddToggle("FallensEspHealthText", { Text = "Health number", Callback = Bind("HealthText") })
    look:AddToggle("FallensEspDistance", { Text = "Distance", Default = true, Callback = Bind("Distance") })
    look:AddToggle("FallensEspDot", { Text = "Head dot", Callback = Bind("HeadDot") })
    look:AddToggle("FallensEspTracer", { Text = "Tracers", Callback = Bind("Tracer") })
    look:AddDropdown("FallensEspTracerFrom", { Text = "Tracer from", Values = { "Bottom", "Center", "Mouse" }, Default = "Bottom", Callback = Bind("TracerOrigin") })
    look:AddToggle("FallensEspChams", { Text = "Chams", Callback = Bind("Chams") })
    local colors = tab:AddLeftGroupbox("Colors", "palette")
    colors:AddLabel("Enemy"):AddColorPicker("FallensEspEnemyColor", { Default = Visuals.Settings.EnemyColor, Callback = Bind("EnemyColor") })
    colors:AddLabel("Friendly"):AddColorPicker("FallensEspFriendColor", { Default = Visuals.Settings.FriendColor, Callback = Bind("FriendColor") })
    local radar = tab:AddLeftGroupbox("Radar", "target")
    radar:AddToggle("FallensRadar", {
        Text = "Radar",
        Description = "Minimap of nearby players, drag to move",
        Callback = function(value)
            Visuals:Set("Radar", value)
            Visuals.RadarBuild()
        end,
    })
    radar:AddSlider("FallensRadarRange", { Text = "Radar range", Min = 50, Max = 1000, Default = 250, Suffix = "m", Callback = Bind("RadarRange") })
    radar:AddSlider("FallensRadarSize", { Text = "Radar size", Min = 100, Max = 320, Default = 180, Suffix = "px", Callback = Bind("RadarSize") })
    return tab
end

function Visuals:SetProvider(provider)
    if type(provider) == "function" then
        Visuals.Provider = provider
        Visuals.LastScan = 0
    end
end

function Visuals:Set(key, value)
    if Visuals.Settings[key] == nil then
        return
    end
    Visuals.Settings[key] = value
    if key == "Radar" then
        if value then
            Visuals.RadarBuild()
        else
            Visuals.RadarTearDown()
        end
    elseif key == "RadarSize" then
        Visuals.RadarBuild()
    elseif key == "TextSize" then
        -- text labels resize on next render frame
    end
end

function Visuals:Get(key)
    return Visuals.Settings[key]
end

function Visuals:SetEnabled(on)
    Visuals.Settings.Enabled = on == true
    if not on then
        Visuals.ClearAll()
    end
end

--==============================================================================
-- Library public API
--==============================================================================

function Library:CreateWindow(options)
    options = options or {}
    State.UserScale = math.clamp(options.Scale or 1, Config.ScaleRange.Min, Config.ScaleRange.Max)
    Theme.Apply(options.Theme or Config.SeasonTheme)
    Assets.Configure(Config.DefaultAssets)
    Assets.Configure(options.Assets)
    Window.DetectTouch(options.Layout)
    Gui.Setup()
    local window = Window.New(options)
    self.Window = window
    Float.Build()
    Watermark.Build(options.WatermarkTitle or window.Title)
    Watermark.SetVisible(options.Watermark ~= false)
    Configs.SetFolder(options.ConfigFolder or options.Folder or window.Title)
    Util.Try(options.OnUnlocked)
    window:SetVisible(true)
    Library:Notify(window.Title, State.Touch and "Ready" or ("Ready - " .. Keybinds.Short(State.MenuKey)), 5, "Power")
    return window
end

function Library:SetTheme(name)
    Theme.Apply(name)
    local option = self.Options.FallensTheme
    if option and option.Value ~= State.ThemeName then
        option.Value = State.ThemeName
        option:Render()
    end
end

function Library:Notify(info, content, duration, kind)
    if type(info) == "table" and not info.EN then
        info, content, duration, kind = info.Title, info.Content or info.Description, info.Duration, info.Type or info.Icon
    end
    if self.Unloaded or not State.NotifyHost then
        return
    end
    Notify.Push(info, content, duration, kind)
end

function Library:Toggle()
    if self.Window then
        self.Window:Toggle()
    end
end

function Library:Every(interval, callback)
    return Util.Every(interval, callback)
end

function Library:SaveConfig(name)
    return Configs.Save(name)
end

function Library:LoadConfig(name)
    return Configs.Load(name)
end

function Library:LoadAutoloadConfig()
    local name = Configs.GetAutoload()
    if not name then
        return
    end
    local ok, reason = Configs.Load(name)
    self:Notify("Configs", ok and ("Autoloaded: " .. name) or ("Autoload failed: " .. tostring(reason)), 3, ok and "Success" or "Error")
end

function Library:OnUnload(callback)
    table.insert(State.UnloadHooks, callback)
end

function Library:Unload()
    if self.Unloaded then
        return
    end
    self.Unloaded = true
    for _, callback in ipairs(State.UnloadHooks) do
        Util.Try(callback)
    end
    Anim.StopAll()
    for _, connection in ipairs(State.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    for index = #State.Connections, 1, -1 do
        State.Connections[index] = nil
    end
    for key in pairs(State.KeyPickers) do
        State.KeyPickers[key] = nil
    end
    for index = #State.Tasks, 1, -1 do
        State.Tasks[index] = nil
    end
    for key in pairs(Theme.Bound) do
        Theme.Bound[key] = nil
    end
    for key in pairs(Theme.Renderers) do
        Theme.Renderers[key] = nil
    end
    for key in pairs(Theme.InstanceRenderers) do
        Theme.InstanceRenderers[key] = nil
    end
    for key in pairs(Assets.Listeners) do
        Assets.Listeners[key] = nil
    end
    State.Drag, State.Binding, State.Window, State.NotifyHost = nil, nil, nil, nil
    if State.Gui then
        State.Gui:Destroy()
        State.Gui = nil
    end
end

function Library:SetAssets(map)
    Assets.Configure(map)
end

function Library:T(english)
    return english
end

function Library:SetLanguage(code)
    -- The FALLENS remake ships an English interface only.
    State.Language = "EN"
    if code == "TH" then
        warn("[FALLENS] Thai interface is not included in this build")
    end
end

function Library:GetLanguage()
    return State.Language or "EN"
end

function Library:GetTheme()
    return State.ThemeName
end

function Library:Icon(parent, name, size, color)
    return Icons.Create(parent, name, size, color)
end

Library.Themes = Themes.Order
Library.Icons = Icons
Library.Visuals = Visuals
Library.Window = Library.CreateWindow

return Library
