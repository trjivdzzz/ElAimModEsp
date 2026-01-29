-- Mod Menu Premium para Delta Executor (Móvil)
-- Diseño minimalista, funcionalidades completas
-- Optimizado para pantallas táctiles

-- Configuración inicial
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables de estado
local ESPEnabled = false
local AimbotEnabled = false
local InfiniteJumpEnabled = false
local MenuVisible = false
local EspCache = {}
local TargetEnemy = nil

-- Configuración de colores premium
local ColorPalette = {
    Background = Color3.fromRGB(15, 15, 22),
    Panel = Color3.fromRGB(25, 25, 35),
    Primary = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(255, 70, 100),
    Accent = Color3.fromRGB(120, 220, 255),
    Text = Color3.fromRGB(245, 245, 250),
    Subtext = Color3.fromRGB(170, 170, 190),
    Success = Color3.fromRGB(0, 200, 120),
    Warning = Color3.fromRGB(255, 160, 50),
    Error = Color3.fromRGB(255, 80, 80)
}

local EspColors = {
    Enemy = Color3.fromRGB(255, 60, 80),
    Ally = Color3.fromRGB(80, 180, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Outline = Color3.fromRGB(0, 0, 0)
}

-- Función para crear elementos de UI con estilo premium
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        if pcall(function() element[prop] = value end) then
            element[prop] = value
        end
    end
    return element
end

-- Detectar si es móvil
local isMobile = UserInputService.TouchEnabled

-- Dimensiones para móvil
local screenSize = workspace.CurrentCamera.ViewportSize
local menuWidth = math.min(300, screenSize.X * 0.85)
local menuHeight = math.min(500, screenSize.Y * 0.85)

-- Crear interfaz principal
local ScreenGui = CreateElement("ScreenGui", {
    Name = "PremiumModMenu",
    DisplayOrder = 999,
    ResetOnSpawn = false
})

-- Botón de toggle para mostrar/ocultar menú (solo en móvil)
local ToggleButton = CreateElement("TextButton", {
    Name = "ToggleButton",
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(0, 20, 0.5, -30),
    BackgroundColor3 = ColorPalette.Primary,
    Text = "≡",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 28,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    AutoButtonColor = true,
    Visible = isMobile
})

-- Efecto de sombra
local ToggleShadow = CreateElement("Frame", {
    Name = "ToggleShadow",
    Size = UDim2.new(1, 6, 1, 6),
    Position = UDim2.new(0, -3, 0, -3),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.8,
    BorderSizePixel = 0
})

-- Frame principal del menú
local MainFrame = CreateElement("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, menuWidth, 0, menuHeight),
    Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2),
    BackgroundColor3 = ColorPalette.Background,
    BorderSizePixel = 0,
    Visible = false,
    ClipsDescendants = true
})

-- Efecto de gradiente premium
local Gradient = CreateElement("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 22))
    }),
    Rotation = 90
})

-- Barra superior premium
local TopBar = CreateElement("Frame", {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundColor3 = ColorPalette.Panel,
    BorderSizePixel = 0
})

local TopBarGradient = CreateElement("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ColorPalette.Primary),
        ColorSequenceKeypoint.new(1, ColorPalette.Accent)
    }),
    Rotation = 90
})

-- Título con estilo premium
local TitleContainer = CreateElement("Frame", {
    Name = "TitleContainer",
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1
})

local Title = CreateElement("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, 0, 0.6, 0),
    BackgroundTransparency = 1,
    Text = "NEON CONTROL",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 22,
    Font = Enum.Font.GothamBlack,
    TextXAlignment = Enum.TextXAlignment.Left
})

local Subtitle = CreateElement("TextLabel", {
    Name = "Subtitle",
    Size = UDim2.new(1, 0, 0.4, 0),
    Position = UDim2.new(0, 0, 0.6, 0),
    BackgroundTransparency = 1,
    Text = "PREMIUM EDITION",
    TextColor3 = ColorPalette.Accent,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Botón de cerrar (X)
local CloseButton = CreateElement("TextButton", {
    Name = "CloseButton",
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -50, 0.5, -20),
    BackgroundTransparency = 1,
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 32,
    Font = Enum.Font.GothamBold,
    TextStrokeTransparency = 0.5,
    AutoButtonColor = false
})

-- Contenedor de opciones con scroll
local OptionsContainer = CreateElement("ScrollingFrame", {
    Name = "OptionsContainer",
    Size = UDim2.new(1, -40, 1, -130),
    Position = UDim2.new(0, 20, 0, 85),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = ColorPalette.Primary,
    CanvasSize = UDim2.new(0, 0, 0, 320),
    ClipsDescendants = true
})

-- Separador decorativo
local Separator = CreateElement("Frame", {
    Name = "Separator",
    Size = UDim2.new(1, -40, 0, 1),
    Position = UDim2.new(0, 20, 0, 80),
    BackgroundColor3 = ColorPalette.Primary,
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0
})

-- Estado del sistema
local StatusBar = CreateElement("Frame", {
    Name = "StatusBar",
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 1, -40),
    BackgroundColor3 = ColorPalette.Panel,
    BorderSizePixel = 0
})

local StatusText = CreateElement("TextLabel", {
    Name = "StatusText",
    Size = UDim2.new(1, -40, 1, 0),
    Position = UDim2.new(0, 20, 0, 0),
    BackgroundTransparency = 1,
    Text = "⚡ SISTEMA ACTIVO",
    TextColor3 = ColorPalette.Success,
    TextSize = 14,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Función para crear toggles premium
local function CreatePremiumToggle(name, description, startState, callback)
    local optionHeight = 70
    
    local OptionFrame = CreateElement("Frame", {
        Name = name .. "Option",
        Size = UDim2.new(1, 0, 0, optionHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    
    -- Fondo con efecto hover
    local Background = CreateElement("Frame", {
        Name = "Background",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = ColorPalette.Panel,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, 8)
    })
    
    -- Icono
    local Icon = CreateElement("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 10, 0.5, -18),
        BackgroundTransparency = 1,
        Text = "●",
        TextColor3 = ColorPalette.Primary,
        TextSize = 20,
        Font = Enum.Font.GothamBold
    })
    
    -- Textos
    local TextContainer = CreateElement("Frame", {
        Name = "TextContainer",
        Size = UDim2.new(0.6, -50, 1, 0),
        Position = UDim2.new(0, 56, 0, 0),
        BackgroundTransparency = 1
    })
    
    local OptionName = CreateElement("TextLabel", {
        Name = "OptionName",
        Size = UDim2.new(1, 0, 0.6, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = ColorPalette.Text,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local OptionDesc = CreateElement("TextLabel", {
        Name = "OptionDesc",
        Size = UDim2.new(1, 0, 0.4, 0),
        Position = UDim2.new(0, 0, 0.6, 0),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = ColorPalette.Subtext,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Toggle premium
    local ToggleContainer = CreateElement("Frame", {
        Name = "ToggleContainer",
        Size = UDim2.new(0, 56, 0, 28),
        Position = UDim2.new(1, -66, 0.5, -14),
        BackgroundColor3 = startState and ColorPalette.Success or Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        CornerRadius = UDim.new(1, 0)
    })
    
    local ToggleKnob = CreateElement("Frame", {
        Name = "ToggleKnob",
        Size = UDim2.new(0, 24, 0, 24),
        Position = startState and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        CornerRadius = UDim.new(1, 0)
    })
    
    -- Estado
    local state = startState
    
    -- Función para animar toggle
    local function AnimateToggle(newState)
        local goalPosition = newState and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        local goalColor = newState and ColorPalette.Success or Color3.fromRGB(60, 60, 70)
        
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        local tween1 = TweenService:Create(ToggleContainer, tweenInfo, {BackgroundColor3 = goalColor})
        local tween2 = TweenService:Create(ToggleKnob, tweenInfo, {Position = goalPosition})
        
        tween1:Play()
        tween2:Play()
    end
    
    -- Función para cambiar estado
    local function ToggleState()
        state = not state
        AnimateToggle(state)
        
        -- Sonido de toggle (simulado)
        if state then
            Icon.TextColor3 = ColorPalette.Success
        else
            Icon.TextColor3 = ColorPalette.Primary
        end
        
        if callback then
            callback(state)
        end
    end
    
    -- Conectar eventos táctiles
    local function ConnectTouchEvents(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Efecto de presión
                local tween = TweenService:Create(Background, TweenInfo.new(0.1), {
                    BackgroundTransparency = 0.8
                })
                tween:Play()
            end
        end)
        
        frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                -- Restaurar transparencia
                local tween = TweenService:Create(Background, TweenInfo.new(0.2), {
                    BackgroundTransparency = 0.9
                })
                tween:Play()
                
                -- Activar toggle
                ToggleState()
            end
        end)
    end
    
    -- Conectar eventos a todo el frame
    ConnectTouchEvents(OptionFrame)
    ConnectTouchEvents(ToggleContainer)
    
    -- Ensamblar elementos
    Background.Parent = OptionFrame
    Icon.Parent = OptionFrame
    TextContainer.Parent = OptionFrame
    OptionName.Parent = TextContainer
    OptionDesc.Parent = TextContainer
    ToggleContainer.Parent = OptionFrame
    ToggleKnob.Parent = ToggleContainer
    
    -- Estado inicial
    if startState then
        Icon.TextColor3 = ColorPalette.Success
    end
    
    return OptionFrame, function() return state end, ToggleState
end

-- Crear opciones del menú
local ESPOption, getESPState, setESPState = CreatePremiumToggle("ENEMY ESP", "Visualización de enemigos con distancia", false, function(state)
    ESPEnabled = state
    if state then
        ActivateESP()
    else
        DeactivateESP()
    end
end)

local AimbotOption, getAimbotState, setAimbotState = CreatePremiumToggle("AIM ASSIST", "Auto-apuntado a enemigos cercanos", false, function(state)
    AimbotEnabled = state
    if state then
        ActivateAimbot()
    else
        DeactivateAimbot()
    end
end)

local InfiniteJumpOption, getJumpState, setJumpState = CreatePremiumToggle("INFINITE JUMP", "Salto infinito manteniendo espacio", false, function(state)
    InfiniteJumpEnabled = state
    if state then
        ActivateInfiniteJump()
    else
        DeactivateInfiniteJump()
    end
end)

-- Añadir opciones al contenedor
ESPOption.Parent = OptionsContainer
AimbotOption.Parent = OptionsContainer
InfiniteJumpOption.Parent = OptionsContainer

-- Ajustar tamaño del canvas
OptionsContainer.CanvasSize = UDim2.new(0, 0, 0, 230)

-- Función para mostrar/ocultar menú con animación
local function ToggleMenu()
    MenuVisible = not MenuVisible
    
    if MenuVisible then
        MainFrame.Visible = true
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, menuWidth, 0, menuHeight),
            Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
        })
        tween:Play()
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
            Size = UDim2.new(0, menuWidth, 0, 0),
            Position = UDim2.new(0.5, -menuWidth/2, 0.5, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            MainFrame.Visible = false
        end)
    end
end

-- Conectar eventos de botones
ToggleButton.MouseButton1Click:Connect(ToggleMenu)
CloseButton.MouseButton1Click:Connect(ToggleMenu)

-- Añadir efectos de hover a botones
local function AddButtonEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.2
        }):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 1
        }):Play()
    end)
end

AddButtonEffect(CloseButton)

-- Ensamblar interfaz
ToggleShadow.Parent = ToggleButton
Gradient.Parent = MainFrame
TopBarGradient.Parent = TopBar

TitleContainer.Parent = TopBar
Title.Parent = TitleContainer
Subtitle.Parent = TitleContainer
CloseButton.Parent = TopBar
Separator.Parent = MainFrame
OptionsContainer.Parent = MainFrame
TopBar.Parent = MainFrame
StatusBar.Parent = MainFrame
StatusText.Parent = StatusBar
MainFrame.Parent = ScreenGui
ToggleButton.Parent = ScreenGui

-- ============================================
-- SISTEMA ESP COMPLETAMENTE FUNCIONAL
-- ============================================

local EspConnections = {}

function IsEnemy(player)
    if player == LocalPlayer then return false end
    if not player.Character then return false end
    
    -- Detección básica de enemigos (puedes personalizar según el juego)
    local localTeam = LocalPlayer.Team
    local playerTeam = player.Team
    
    if localTeam and playerTeam then
        return localTeam ~= playerTeam
    end
    
    -- Si no hay sistema de equipos, todos son enemigos
    return true
end

function CreateEsp(player)
    if EspCache[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Crear ESP Box
    local espBox = CreateElement("BoxHandleAdornment", {
        Name = player.Name .. "_ESP",
        Adornee = humanoidRootPart,
        Size = humanoidRootPart.Size + Vector3.new(0.2, 0.2, 0.2),
        Color3 = IsEnemy(player) and EspColors.Enemy or EspColors.Ally,
        Transparency = 0.3,
        ZIndex = 1,
        AlwaysOnTop = true
    })
    
    -- Crear etiqueta con nombre y distancia
    local billboard = CreateElement("BillboardGui", {
        Name = player.Name .. "_Label",
        Adornee = humanoidRootPart,
        Size = UDim2.new(0, 200, 0, 60),
        ExtentsOffset = Vector3.new(0, 3, 0),
        AlwaysOnTop = true
    })
    
    local nameLabel = CreateElement("TextLabel", {
        Name = "NameLabel",
        Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Text = player.Name,
        TextColor3 = IsEnemy(player) and EspColors.Enemy or EspColors.Ally,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextStrokeColor3 = EspColors.Outline,
        TextStrokeTransparency = 0
    })
    
    local distanceText = CreateElement("TextLabel", {
        Name = "DistanceLabel",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "0m",
        TextColor3 = EspColors.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextStrokeColor3 = EspColors.Outline,
        TextStrokeTransparency = 0
    })
    
    -- Añadir a la caché
    EspCache[player] = {
        Box = espBox,
        Billboard = billboard,
        NameLabel = nameLabel,
        DistanceLabel = distanceText,
        Player = player
    }
    
    -- Añadir al juego
    espBox.Parent = Workspace
    billboard.Parent = humanoidRootPart
    nameLabel.Parent = billboard
    distanceText.Parent = billboard
end

function RemoveEsp(player)
    if EspCache[player] then
        if EspCache[player].Box then
            EspCache[player].Box:Destroy()
        end
        if EspCache[player].Billboard then
            EspCache[player].Billboard:Destroy()
        end
        EspCache[player] = nil
    end
end

function UpdateEsp()
    if not LocalPlayer.Character then return end
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    
    for player, espData in pairs(EspCache) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local distance = (localRoot.Position - rootPart.Position).Magnitude
            
            if espData.DistanceLabel then
                espData.DistanceLabel.Text = string.format("%.1fm", distance)
            end
            
            -- Actualizar color según si es enemigo
            local isEnemy = IsEnemy(player)
            if espData.Box then
                espData.Box.Color3 = isEnemy and EspColors.Enemy or EspColors.Ally
                espData.Box.Transparency = isEnemy and 0.3 or 0.1
            end
            if espData.NameLabel then
                espData.NameLabel.TextColor3 = isEnemy and EspColors.Enemy or EspColors.Ally
            end
            
            -- Mostrar solo enemigos (como solicitaste)
            espData.Box.Visible = isEnemy and ESPEnabled
            espData.Billboard.Enabled = isEnemy and ESPEnabled
        else
            RemoveEsp(player)
        end
    end
end

function ActivateESP()
    -- Limpiar conexiones previas
    for _, conn in pairs(EspConnections) do
        conn:Disconnect()
    end
    EspConnections = {}
    
    -- Inicializar ESP para jugadores existentes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            player.CharacterAdded:Connect(function(character)
                wait(0.5)
                if ESPEnabled then
                    CreateEsp(player)
                end
            end)
            
            if player.Character then
                CreateEsp(player)
            end
        end
    end
    
    -- Conectar eventos de jugadores
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            wait(0.5)
            if ESPEnabled then
                CreateEsp(player)
            end
        end)
    end)
    
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        RemoveEsp(player)
    end)
    
    -- Loop de actualización
    local updateLoop = RunService.RenderStepped:Connect(function()
        if ESPEnabled then
            UpdateEsp()
        else
            -- Limpiar ESP si está desactivado
            for player, _ in pairs(EspCache) do
                RemoveEsp(player)
            end
            EspCache = {}
        end
    end)
    
    -- Guardar conexiones
    table.insert(EspConnections, playerAddedConn)
    table.insert(EspConnections, playerRemovingConn)
    table.insert(EspConnections, updateLoop)
    
    StatusText.Text = "⚡ ESP ACTIVADO"
    StatusText.TextColor3 = ColorPalette.Success
end

function DeactivateESP()
    for _, conn in pairs(EspConnections) do
        conn:Disconnect()
    end
    EspConnections = {}
    
    for player, _ in pairs(EspCache) do
        RemoveEsp(player)
    end
    EspCache = {}
    
    StatusText.Text = "⚡ SISTEMA ACTIVO"
    StatusText.TextColor3 = ColorPalette.Success
end

-- ============================================
-- SISTEMA AIMBOT COMPLETAMENTE FUNCIONAL
-- ============================================

local AimbotLoop = nil

function GetClosestEnemy()
    if not LocalPlayer.Character then return nil end
    
    local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character then
            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                local distance = (localRoot.Position - enemyRoot.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer, closestDistance
end

function ActivateAimbot()
    if AimbotLoop then
        AimbotLoop:Disconnect()
    end
    
    AimbotLoop = RunService.RenderStepped:Connect(function()
        if not AimbotEnabled or not LocalPlayer.Character then return end
        
        local closestPlayer, distance = GetClosestEnemy()
        if closestPlayer and closestPlayer.Character and distance < 100 then
            local enemyRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                -- Suavizar el aimbot
                local currentCFrame = Camera.CFrame
                local targetPosition = enemyRoot.Position + Vector3.new(0, 2, 0)
                local newCFrame = CFrame.new(currentCFrame.Position, targetPosition)
                
                -- Interpolación suave
                Camera.CFrame = currentCFrame:Lerp(newCFrame, 0.3)
                
                TargetEnemy = closestPlayer
            end
        else
            TargetEnemy = nil
        end
    end)
    
    StatusText.Text = "🎯 AIMBOT ACTIVADO"
    StatusText.TextColor3 = ColorPalette.Warning
end

function DeactivateAimbot()
    if AimbotLoop then
        AimbotLoop:Disconnect()
        AimbotLoop = nil
    end
    TargetEnemy = nil
    
    StatusText.Text = "⚡ SISTEMA ACTIVO"
    StatusText.TextColor3 = ColorPalette.Success
end

-- ============================================
-- SISTEMA INFINITE JUMP COMPLETAMENTE FUNCIONAL
-- ============================================

local JumpConnection = nil
local IsJumping = false

function ActivateInfiniteJump()
    if JumpConnection then
        JumpConnection:Disconnect()
    end
    
    local function HandleJump(input)
        if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
            IsJumping = true
        end
    end
    
    local function HandleJumpEnd(input)
        if input.KeyCode == Enum.KeyCode.Space or input.UserInputType == Enum.UserInputType.Touch then
            IsJumping = false
        end
    end
    
    JumpConnection = RunService.Heartbeat:Connect(function()
        if InfiniteJumpEnabled and IsJumping and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    -- Conectar eventos de entrada
    UserInputService.InputBegan:Connect(HandleJump)
    UserInputService.InputEnded:Connect(HandleJumpEnd)
    
    StatusText.Text = "↑ SALTO INFINITO ACTIVADO"
    StatusText.TextColor3 = ColorPalette.Accent
end

function DeactivateInfiniteJump()
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
    IsJumping = false
    
    StatusText.Text = "⚡ SISTEMA ACTIVO"
    StatusText.TextColor3 = ColorPalette.Success
end

-- ============================================
-- SISTEMA DE ACTUALIZACIÓN DE ESTADO
-- ============================================

local function UpdateStatus()
    local activeFeatures = {}
    
    if ESPEnabled then
        table.insert(activeFeatures, "ESP")
    end
    
    if AimbotEnabled then
        table.insert(activeFeatures, "AIM")
    end
    
    if InfiniteJumpEnabled then
        table.insert(activeFeatures, "JUMP")
    end
    
    if #activeFeatures > 0 then
        StatusText.Text = "⚡ " .. table.concat(activeFeatures, " • ")
    else
        StatusText.Text = "⚡ SISTEMA ACTIVO"
    end
end

-- Loop de actualización de estado
RunService.Heartbeat:Connect(function()
    UpdateStatus()
end)

-- ============================================
-- INICIALIZACIÓN
-- ============================================

-- Asegurar que el menú se cierre al iniciar
MenuVisible = false
MainFrame.Visible = false
MainFrame.Size = UDim2.new(0, menuWidth, 0, 0)
MainFrame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, 0)

-- Inyectar GUI
ScreenGui.Parent = game:GetService("CoreGui")

-- Configurar para móvil
if isMobile then
    -- Ajustar posición del botón toggle
    TweenService:Create(ToggleButton, TweenInfo.new(0.5), {
        Position = UDim2.new(0, 20, 0.5, -30)
    }):Play()
    
    -- Instrucciones
    print("[Premium Mod Menu] Cargado exitosamente para MÓVIL")
    print("[Premium Mod Menu] Presiona el botón azul para abrir/cerrar el menú")
else
    -- Para PC
    ToggleButton.Visible = false
    MainFrame.Visible = true
    MenuVisible = true
    
    print("[Premium Mod Menu] Cargado exitosamente para PC")
    print("[Premium Mod Menu] Presiona RightShift para abrir/cerrar el menú")
    
    -- Atajo de teclado para PC
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
            ToggleMenu()
        end
    end)
end

-- Mensaje de confirmación
print("==========================================")
print("NEON CONTROL - PREMIUM EDITION")
print("ESP: Visualización de enemigos con distancia")
print("AIMBOT: Auto-apuntado a enemigos cercanos")
print("INFINITE JUMP: Salto infinito manteniendo espacio")
print("==========================================")
```
