-- Mod Menu Minimalista para Delta Executor
-- Diseñado con estética no genérica y funcionalidades específicas

-- Configuración inicial
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Variables de estado
local ESPEnabled = false
local AimbotEnabled = false
local InfiniteJumpEnabled = false
local MenuVisible = true
local EspCache = {}

-- Configuración de colores y estilos
local ColorPalette = {
    Background = Color3.fromRGB(20, 20, 30),
    Panel = Color3.fromRGB(30, 30, 45),
    Primary = Color3.fromRGB(100, 150, 255),
    Secondary = Color3.fromRGB(255, 80, 100),
    Text = Color3.fromRGB(240, 240, 245),
    Subtext = Color3.fromRGB(180, 180, 200),
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 60)
}

local EspColors = {
    Enemy = Color3.fromRGB(255, 60, 80),
    Ally = Color3.fromRGB(60, 180, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Outline = Color3.fromRGB(0, 0, 0)
}

-- Función para crear elementos de UI
local function CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        if pcall(function() element[prop] = value end) then
            element[prop] = value
        end
    end
    return element
end

-- Crear interfaz principal
local ScreenGui = CreateElement("ScreenGui", {
    Name = "ModMenuGui",
    DisplayOrder = 10,
    ResetOnSpawn = false
})

local MainFrame = CreateElement("Frame", {
    Name = "MainFrame",
    Size = UDim2.new(0, 320, 0, 400),
    Position = UDim2.new(0.5, -160, 0.5, -200),
    BackgroundColor3 = ColorPalette.Background,
    BorderColor3 = ColorPalette.Primary,
    BorderSizePixel = 1,
    Active = true,
    Draggable = true
})

-- Título con estilo minimalista
local TitleContainer = CreateElement("Frame", {
    Name = "TitleContainer",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = ColorPalette.Panel,
    BorderSizePixel = 0
})

local Title = CreateElement("TextLabel", {
    Name = "Title",
    Size = UDim2.new(1, -20, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "SYSTEM MENU",
    TextColor3 = ColorPalette.Primary,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
})

local Subtitle = CreateElement("TextLabel", {
    Name = "Subtitle",
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 30),
    BackgroundTransparency = 1,
    Text = "minimalist design v1.0",
    TextColor3 = ColorPalette.Subtext,
    TextSize = 12,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Contenedor de opciones
local OptionsContainer = CreateElement("ScrollingFrame", {
    Name = "OptionsContainer",
    Size = UDim2.new(1, -20, 1, -80),
    Position = UDim2.new(0, 10, 0, 60),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 320)
})

-- Función para crear opciones con toggle
local function CreateOption(name, description, startState, callback)
    local optionHeight = 60
    
    local OptionFrame = CreateElement("Frame", {
        Name = name .. "Option",
        Size = UDim2.new(1, 0, 0, optionHeight),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    
    local OptionName = CreateElement("TextLabel", {
        Name = "OptionName",
        Size = UDim2.new(0.7, -10, 0, 24),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = ColorPalette.Text,
        TextSize = 16,
        Font = Enum.Font.GothamSemibold,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local OptionDesc = CreateElement("TextLabel", {
        Name = "OptionDesc",
        Size = UDim2.new(0.7, -10, 0, 18),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = description,
        TextColor3 = ColorPalette.Subtext,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local ToggleBackground = CreateElement("Frame", {
        Name = "ToggleBackground",
        Size = UDim2.new(0, 50, 0, 24),
        Position = UDim2.new(1, -50, 0, 18),
        BackgroundColor3 = Color3.fromRGB(50, 50, 60),
        BorderColor3 = Color3.fromRGB(70, 70, 80),
        BorderSizePixel = 1,
        CornerRadius = UDim.new(0, 12)
    })
    
    local ToggleButton = CreateElement("Frame", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 20, 0, 20),
        Position = startState and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
        BackgroundColor3 = startState and ColorPalette.Success or ColorPalette.Warning,
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, 10)
    })
    
    -- Estado inicial
    local state = startState
    
    -- Función para cambiar estado
    local function ToggleState()
        state = not state
        
        -- Animación del toggle
        local goalPosition = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local goalColor = state and ColorPalette.Success or ColorPalette.Warning
        
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = game:GetService("TweenService"):Create(ToggleButton, tweenInfo, {
            Position = goalPosition,
            BackgroundColor3 = goalColor
        })
        tween:Play()
        
        -- Llamar al callback
        if callback then
            callback(state)
        end
    end
    
    -- Conectar eventos de clic
    OptionFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleState()
        end
    end)
    
    ToggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ToggleState()
        end
    end)
    
    -- Añadir elementos
    ToggleBackground.Parent = OptionFrame
    ToggleButton.Parent = ToggleBackground
    OptionDesc.Parent = OptionFrame
    OptionName.Parent = OptionFrame
    
    return OptionFrame, function() return state end
end

-- Crear opciones del menú
local ESPOption, getESPState = CreateOption("ENEMY ESP", "Muestra posición y distancia de enemigos", false, function(state)
    ESPEnabled = state
    if state then
        ActivateESP()
    else
        DeactivateESP()
    end
end)

local AimbotOption, getAimbotState = CreateOption("AIM ASSIST", "Auto-apuntado a enemigos cercanos", false, function(state)
    AimbotEnabled = state
end)

local InfiniteJumpOption, getJumpState = CreateOption("INFINITE JUMP", "Salto infinito al mantener espacio", false, function(state)
    InfiniteJumpEnabled = state
end)

-- Añadir opciones al contenedor
ESPOption.Parent = OptionsContainer
AimbotOption.Parent = OptionsContainer
InfiniteJumpOption.Parent = OptionsContainer

-- Separador
local Separator = CreateElement("Frame", {
    Name = "Separator",
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 0, 190),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    BorderSizePixel = 0
})
Separator.Parent = OptionsContainer

-- Información de estado
local StatusLabel = CreateElement("TextLabel", {
    Name = "StatusLabel",
    Size = UDim2.new(1, -20, 0, 40),
    Position = UDim2.new(0, 10, 1, -50),
    BackgroundColor3 = ColorPalette.Panel,
    BorderSizePixel = 0,
    Text = "Estado: Listo",
    TextColor3 = ColorPalette.Text,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- Añadir elementos a la GUI
TitleContainer.Parent = MainFrame
Title.Parent = TitleContainer
Subtitle.Parent = TitleContainer
OptionsContainer.Parent = MainFrame
StatusLabel.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Función para mostrar/ocultar el menú
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightShift then
            MenuVisible = not MenuVisible
            MainFrame.Visible = MenuVisible
        end
    end
end)

-- Sistema ESP para enemigos
function ActivateESP()
    -- Función para determinar si un jugador es enemigo
    local function IsEnemy(player)
        if player == LocalPlayer then return false end
        if not player.Character then return false end
        
        -- Aquí puedes agregar lógica para determinar equipos
        -- Por ahora, consideramos enemigos a todos excepto al jugador local
        return true
    end
    
    -- Crear elementos ESP para un jugador
    local function CreateEsp(player)
        if EspCache[player] then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Crear cuadro ESP
        local espBox = CreateElement("BoxHandleAdornment", {
            Name = player.Name .. "_ESP",
            Adornee = humanoidRootPart,
            Size = humanoidRootPart.Size + Vector3.new(0.1, 0.1, 0.1),
            Color3 = IsEnemy(player) and EspColors.Enemy or EspColors.Ally,
            Transparency = 0.7,
            ZIndex = 1,
            AlwaysOnTop = true
        })
        
        -- Crear etiqueta con nombre y distancia
        local distanceLabel = CreateElement("BillboardGui", {
            Name = player.Name .. "_Label",
            Adornee = humanoidRootPart,
            Size = UDim2.new(0, 200, 0, 50),
            ExtentsOffset = Vector3.new(0, 3, 0),
            AlwaysOnTop = true
        })
        
        local nameLabel = CreateElement("TextLabel", {
            Name = "NameLabel",
            Size = UDim2.new(1, 0, 0, 20),
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
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = "0m",
            TextColor3 = EspColors.Text,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextStrokeColor3 = EspColors.Outline,
            TextStrokeTransparency = 0
        })
        
        -- Añadir a la caché
        EspCache[player] = {
            Box = espBox,
            Label = distanceLabel,
            NameLabel = nameLabel,
            DistanceLabel = distanceText,
            Player = player
        }
        
        -- Añadir a la pantalla
        espBox.Parent = Workspace
        distanceLabel.Parent = humanoidRootPart
        nameLabel.Parent = distanceLabel
        distanceText.Parent = distanceLabel
    end
    
    -- Eliminar ESP de un jugador
    local function RemoveEsp(player)
        if EspCache[player] then
            if EspCache[player].Box then
                EspCache[player].Box:Destroy()
            end
            if EspCache[player].Label then
                EspCache[player].Label:Destroy()
            end
            EspCache[player] = nil
        end
    end
    
    -- Actualizar distancia en ESP
    local function UpdateEsp()
        for player, espData in pairs(EspCache) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                
                if espData.DistanceLabel then
                    espData.DistanceLabel.Text = string.format("%.1fm", distance)
                end
                
                -- Actualizar color según si es enemigo
                local isEnemy = IsEnemy(player)
                if espData.Box then
                    espData.Box.Color3 = isEnemy and EspColors.Enemy or EspColors.Ally
                end
                if espData.NameLabel then
                    espData.NameLabel.TextColor3 = isEnemy and EspColors.Enemy or EspColors.Ally
                end
            else
                RemoveEsp(player)
            end
        end
    end
    
    -- Conectar eventos de jugadores
    local function PlayerAdded(player)
        player.CharacterAdded:Connect(function(character)
            wait(1) -- Esperar a que el personaje cargue completamente
            if ESPEnabled then
                CreateEsp(player)
            end
        end)
        
        if player.Character and ESPEnabled then
            CreateEsp(player)
        end
    end
    
    local function PlayerRemoving(player)
        RemoveEsp(player)
    end
    
    -- Inicializar ESP para jugadores existentes
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            PlayerAdded(player)
        end
    end
    
    -- Conectar eventos
    Players.PlayerAdded:Connect(PlayerAdded)
    Players.PlayerRemoving:Connect(PlayerRemoving)
    
    -- Loop de actualización de ESP
    local espLoop
    espLoop = RunService.RenderStepped:Connect(function()
        if not ESPEnabled then
            espLoop:Disconnect()
            DeactivateESP()
            return
        end
        
        UpdateEsp()
    end)
end

function DeactivateESP()
    for player, espData in pairs(EspCache) do
        if espData.Box then
            espData.Box:Destroy()
        end
        if espData.Label then
            espData.Label:Destroy()
        end
    end
    EspCache = {}
end

-- Sistema de Aimbot
local AimbotLoop
local function ActivateAimbot()
    if AimbotLoop then
        AimbotLoop:Disconnect()
    end
    
    AimbotLoop = RunService.RenderStepped:Connect(function()
        if not AimbotEnabled or not LocalPlayer.Character then return end
        
        local closestPlayer = nil
        local closestDistance = math.huge
        local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end
        
        -- Buscar el enemigo más cercano
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
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
        
        -- Apuntar al enemigo más cercano
        if closestPlayer and closestPlayer.Character then
            local enemyRoot = closestPlayer.Character:FindFirstChild("HumanoidRootPart")
            if enemyRoot then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, enemyRoot.Position)
            end
        end
    end)
end

-- Sistema de Salto Infinito
local InfiniteJumpConnection
local function ActivateInfiniteJump()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
    end
    
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if InfiniteJumpEnabled and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- Conectar eventos de toggle a funciones
getAimbotState = getAimbotState or function() return AimbotEnabled end
getJumpState = getJumpState or function() return InfiniteJumpEnabled end

-- Actualizar estado del menú
local function UpdateStatus()
    local status = {}
    
    if ESPEnabled then
        table.insert(status, "ESP ON")
    end
    
    if AimbotEnabled then
        table.insert(status, "AIM ON")
    end
    
    if InfiniteJumpEnabled then
        table.insert(status, "JUMP ON")
    end
    
    if #status == 0 then
        StatusLabel.Text = "Estado: Inactivo"
    else
        StatusLabel.Text = "Estado: " .. table.concat(status, " • ")
    end
end

-- Loop de actualización de estado
RunService.RenderStepped:Connect(function()
    UpdateStatus()
    
    -- Activar/desactivar funciones según estado
    if AimbotEnabled and not AimbotLoop then
        ActivateAimbot()
    elseif not AimbotEnabled and AimbotLoop then
        AimbotLoop:Disconnect()
        AimbotLoop = nil
    end
    
    if InfiniteJumpEnabled and not InfiniteJumpConnection then
        ActivateInfiniteJump()
    elseif not InfiniteJumpEnabled and InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
end)

-- Inyectar GUI al juego
ScreenGui.Parent = game:GetService("CoreGui")

-- Mensaje de confirmación
print("[Mod Menu] Cargado exitosamente")
print("[Mod Menu] Presiona RightShift para mostrar/ocultar el menú")
