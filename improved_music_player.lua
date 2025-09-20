--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

--// TopbarPlus
local TopbarPlus = require(ReplicatedStorage:WaitForChild("Icon"))

-- Buat icon music di Topbar
local musicIcon = TopbarPlus.new()
musicIcon:setImage("rbxassetid://3926305904") -- icon music
musicIcon:setLabel("Music")
musicIcon:setOrder(1)

--// Referensi Part & Sound
local MusicPart = workspace:WaitForChild("Music")
local Sound = MusicPart:WaitForChild("Sound")

-- Setting supaya suara global (kedengaran semua player)
Sound.EmitterSize = 10000
Sound.MaxDistance = 10000
Sound.RollOffMode = Enum.RollOffMode.Linear
Sound.Volume = 1

--// Daftar Lagu
local musics = {
	{"Garam Madu", "rbxassetid://113882895076957"},
	{"Blackpink Jump", "rbxassetid://92084261300490"},
	{"Party ANTHEM X SHADOW BREAKBEAT", "rbxassetid://75923366503445"},
	{"Kasih Aba Aba", "rbxassetid://77029134655507"},
	{"GGS", "rbxassetid://109746033841363"},
	{"Lathi", "rbxassetid://131577308628551"},
	{"Mambo Jambo", "rbxassetid://122797530716934"},
	{"Bella Ciao Takutu", "rbxassetid://92398397394211"},
	{"Justin Bieber Baby", "rbxassetid://77004945761610"},
	{"Pica Pica", "rbxassetid://79998011940712"},
	{"Aku Yang Salah", "rbxassetid://138273008737782"},
	{"Rock That Body", "rbxassetid://112001349747253"},
	{"Adnan 1234", "rbxassetid://73723477743757"},
	{"Industry Baby", "rbxassetid://129237875771122"},
	{"Unholly Sam Smith", "rbxassetid://134093416515984"},
	{"Pon Di Gente", "rbxassetid://84501903837361"},
	{"Adnan Remix", "rbxassetid://125271685091415"},
	{"Cartel", "rbxassetid://108224687344753"},
	{"ARIA", "rbxassetid://119520238015043"},
	{"HBRP", "rbxassetid://77383266146059"},
	{"Tokyo Drift", "rbxassetid://102058235736906"},
	{"Opening Aloy", "rbxassetid://109299756196858"},
	{"TikTok Remix", "rbxassetid://114518964063234"},
}

local currentIndex = nil
local currentSong = nil
local isPlaying = false
local isShuffled = false
local shuffledList = {}

--// UI Generator
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MusicUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main Container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 450, 0, 600)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Main Frame Styling
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2
mainStroke.Color = Color3.fromRGB(100, 100, 120)
mainStroke.Parent = mainFrame

-- Gradient Background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Header
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 60)
headerFrame.Position = UDim2.new(0, 0, 0, 0)
headerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
headerFrame.BackgroundTransparency = 0.3
headerFrame.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = headerFrame

-- Only round top corners
local headerMask = Instance.new("Frame")
headerMask.Size = UDim2.new(1, 0, 1, 16)
headerMask.Position = UDim2.new(0, 0, 0, 0)
headerMask.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
headerMask.BackgroundTransparency = 0.3
headerMask.Parent = headerFrame

local headerMaskCorner = Instance.new("UICorner")
headerMaskCorner.CornerRadius = UDim.new(0, 16)
headerMaskCorner.Parent = headerMask

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 0, 30)
titleLabel.Position = UDim2.new(0, 20, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎵 Music Player"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

-- Now Playing
local nowPlaying = Instance.new("TextLabel")
nowPlaying.Size = UDim2.new(1, -20, 0, 20)
nowPlaying.Position = UDim2.new(0, 20, 0, 35)
nowPlaying.BackgroundTransparency = 1
nowPlaying.Text = "Now Playing: None"
nowPlaying.TextColor3 = Color3.fromRGB(100, 200, 255)
nowPlaying.Font = Enum.Font.Gotham
nowPlaying.TextSize = 14
nowPlaying.TextXAlignment = Enum.TextXAlignment.Left
nowPlaying.Parent = headerFrame

-- Progress Bar Container
local progressContainer = Instance.new("Frame")
progressContainer.Size = UDim2.new(1, -40, 0, 4)
progressContainer.Position = UDim2.new(0, 20, 1, -20)
progressContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
progressContainer.Parent = mainFrame

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 2)
progressCorner.Parent = progressContainer

-- Progress Bar
local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.Position = UDim2.new(0, 0, 0, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
progressBar.Parent = progressContainer

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(0, 2)
progressBarCorner.Parent = progressBar

-- Control Panel
local controlPanel = Instance.new("Frame")
controlPanel.Size = UDim2.new(1, -40, 0, 80)
controlPanel.Position = UDim2.new(0, 20, 1, -100)
controlPanel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
controlPanel.BackgroundTransparency = 0.2
controlPanel.Parent = mainFrame

local controlCorner = Instance.new("UICorner")
controlCorner.CornerRadius = UDim.new(0, 12)
controlCorner.Parent = controlPanel

-- Control Buttons
local prevButton = Instance.new("TextButton")
prevButton.Size = UDim2.new(0, 50, 0, 50)
prevButton.Position = UDim2.new(0, 20, 0, 15)
prevButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
prevButton.Text = "⏮️"
prevButton.TextColor3 = Color3.fromRGB(255, 255, 255)
prevButton.Font = Enum.Font.GothamBold
prevButton.TextSize = 20
prevButton.Parent = controlPanel

local prevCorner = Instance.new("UICorner")
prevCorner.CornerRadius = UDim.new(0, 8)
prevCorner.Parent = prevButton

local playButton = Instance.new("TextButton")
playButton.Size = UDim2.new(0, 60, 0, 60)
playButton.Position = UDim2.new(0.5, -30, 0, 10)
playButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
playButton.Text = "▶️"
playButton.TextColor3 = Color3.fromRGB(255, 255, 255)
playButton.Font = Enum.Font.GothamBold
playButton.TextSize = 24
playButton.Parent = controlPanel

local playCorner = Instance.new("UICorner")
playCorner.CornerRadius = UDim.new(0, 10)
playCorner.Parent = playButton

local nextButton = Instance.new("TextButton")
nextButton.Size = UDim2.new(0, 50, 0, 50)
nextButton.Position = UDim2.new(1, -70, 0, 15)
nextButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
nextButton.Text = "⏭️"
nextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
nextButton.Font = Enum.Font.GothamBold
nextButton.TextSize = 20
nextButton.Parent = controlPanel

local nextCorner = Instance.new("UICorner")
nextCorner.CornerRadius = UDim.new(0, 8)
nextCorner.Parent = nextButton

-- Volume Control
local volumeLabel = Instance.new("TextLabel")
volumeLabel.Size = UDim2.new(0, 60, 0, 20)
volumeLabel.Position = UDim2.new(0, 20, 1, -25)
volumeLabel.BackgroundTransparency = 1
volumeLabel.Text = "Volume:"
volumeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
volumeLabel.Font = Enum.Font.Gotham
volumeLabel.TextSize = 12
volumeLabel.TextXAlignment = Enum.TextXAlignment.Left
volumeLabel.Parent = controlPanel

local volumeSlider = Instance.new("Frame")
volumeSlider.Size = UDim2.new(0, 100, 0, 4)
volumeSlider.Position = UDim2.new(0, 80, 1, -20)
volumeSlider.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
volumeSlider.Parent = controlPanel

local volumeSliderCorner = Instance.new("UICorner")
volumeSliderCorner.CornerRadius = UDim.new(0, 2)
volumeSliderCorner.Parent = volumeSlider

local volumeBar = Instance.new("Frame")
volumeBar.Size = UDim2.new(1, 0, 1, 0)
volumeBar.Position = UDim2.new(0, 0, 0, 0)
volumeBar.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
volumeBar.Parent = volumeSlider

local volumeBarCorner = Instance.new("UICorner")
volumeBarCorner.CornerRadius = UDim.new(0, 2)
volumeBarCorner.Parent = volumeBar

-- Shuffle Button
local shuffleButton = Instance.new("TextButton")
shuffleButton.Size = UDim2.new(0, 30, 0, 30)
shuffleButton.Position = UDim2.new(1, -50, 1, -25)
shuffleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
shuffleButton.Text = "🔀"
shuffleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
shuffleButton.Font = Enum.Font.GothamBold
shuffleButton.TextSize = 16
shuffleButton.Parent = controlPanel

local shuffleCorner = Instance.new("UICorner")
shuffleCorner.CornerRadius = UDim.new(0, 6)
shuffleCorner.Parent = shuffleButton

-- Playlist Container
local playlistContainer = Instance.new("Frame")
playlistContainer.Size = UDim2.new(1, -40, 1, -200)
playlistContainer.Position = UDim2.new(0, 20, 0, 80)
playlistContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playlistContainer.BackgroundTransparency = 0.1
playlistContainer.Parent = mainFrame

local playlistCorner = Instance.new("UICorner")
playlistCorner.CornerRadius = UDim.new(0, 12)
playlistCorner.Parent = playlistContainer

-- Playlist Title
local playlistTitle = Instance.new("TextLabel")
playlistTitle.Size = UDim2.new(1, -20, 0, 30)
playlistTitle.Position = UDim2.new(0, 10, 0, 5)
playlistTitle.BackgroundTransparency = 1
playlistTitle.Text = "📋 Playlist"
playlistTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
playlistTitle.Font = Enum.Font.GothamBold
playlistTitle.TextSize = 16
playlistTitle.TextXAlignment = Enum.TextXAlignment.Left
playlistTitle.Parent = playlistContainer

-- Playlist (ScrollingFrame)
local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1, -20, 1, -40)
listFrame.Position = UDim2.new(0, 10, 0, 35)
listFrame.BackgroundTransparency = 1
listFrame.ScrollBarThickness = 6
listFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
listFrame.CanvasSize = UDim2.new(0, 0, 0, #musics * 50)
listFrame.Parent = playlistContainer

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -40, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

--// Functions
local function createShuffledList()
	shuffledList = {}
	for i = 1, #musics do
		table.insert(shuffledList, i)
	end
	
	-- Fisher-Yates shuffle
	for i = #shuffledList, 2, -1 do
		local j = math.random(i)
		shuffledList[i], shuffledList[j] = shuffledList[j], shuffledList[i]
	end
end

local function getCurrentList()
	return isShuffled and shuffledList or (function()
		local list = {}
		for i = 1, #musics do
			table.insert(list, i)
		end
		return list
	end)()
end

local function playSong(index)
	local data = musics[index]
	if not data then return end

	local name, id = data[1], data[2]
	Sound.SoundId = id
	Sound.Volume = 1
	Sound.Looped = false

	-- Coba Play
	local ok, err = pcall(function()
		Sound:Play()
	end)

	if ok then
		currentIndex = index
		currentSong = {Name = name, Id = id}
		isPlaying = true
		nowPlaying.Text = "Now Playing: " .. name
		playButton.Text = "⏸️"
		musicIcon:notify("🎶 Now Playing", name)
		
		-- Update progress bar
		progressBar.Size = UDim2.new(0, 0, 1, 0)
	else
		nowPlaying.Text = "Error playing: " .. name
		musicIcon:notify("⚠️ Error", "Audio tidak bisa diputar")
	end
end

local function stopSong()
	Sound:Stop()
	isPlaying = false
	nowPlaying.Text = "Stopped"
	playButton.Text = "▶️"
	musicIcon:notify("⏹️ Music Stopped")
	progressBar.Size = UDim2.new(0, 0, 1, 0)
end

local function pauseSong()
	if isPlaying then
		Sound:Pause()
		isPlaying = false
		playButton.Text = "▶️"
	else
		Sound:Resume()
		isPlaying = true
		playButton.Text = "⏸️"
	end
end

local function nextSong()
	if not currentIndex then return end
	
	local currentList = getCurrentList()
	local currentPos = 1
	for i, v in ipairs(currentList) do
		if v == currentIndex then
			currentPos = i
			break
		end
	end
	
	local nextPos = currentPos + 1
	if nextPos > #currentList then
		nextPos = 1
	end
	
	playSong(currentList[nextPos])
end

local function prevSong()
	if not currentIndex then return end
	
	local currentList = getCurrentList()
	local currentPos = 1
	for i, v in ipairs(currentList) do
		if v == currentIndex then
			currentPos = i
			break
		end
	end
	
	local prevPos = currentPos - 1
	if prevPos < 1 then
		prevPos = #currentList
	end
	
	playSong(currentList[prevPos])
end

-- Auto Next
Sound.Ended:Connect(function()
	if currentIndex then
		nextSong()
	end
end)

-- Progress Bar Update
local function updateProgress()
	if isPlaying and Sound.IsPlaying then
		local progress = Sound.TimePosition / Sound.TimeLength
		progressBar.Size = UDim2.new(progress, 0, 1, 0)
	end
end

-- Volume Control
local function updateVolume()
	local volume = volumeBar.Size.X.Scale
	Sound.Volume = volume
end

-- Generate Playlist Buttons
for i, data in ipairs(musics) do
	local name = data[1]

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 45)
	btn.Position = UDim2.new(0, 5, 0, (i-1) * 50)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = listFrame

	local btnPadding = Instance.new("UIPadding")
	btnPadding.PaddingLeft = UDim.new(0, 10)
	btnPadding.Parent = btn

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	-- Hover effects
	btn.MouseEnter:Connect(function()
		local tween = TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(60, 60, 70)
		})
		tween:Play()
	end)

	btn.MouseLeave:Connect(function()
		local tween = TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		})
		tween:Play()
	end)

	btn.MouseButton1Click:Connect(function()
		playSong(i)
	end)
end

-- Button Events
playButton.MouseButton1Click:Connect(function()
	if isPlaying then
		pauseSong()
	else
		if currentIndex then
			playSong(currentIndex)
		end
	end
end)

prevButton.MouseButton1Click:Connect(prevSong)
nextButton.MouseButton1Click:Connect(nextSong)

shuffleButton.MouseButton1Click:Connect(function()
	isShuffled = not isShuffled
	if isShuffled then
		createShuffledList()
		shuffleButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	else
		shuffleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	end
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- Volume slider interaction
local function onVolumeSliderInput(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local sliderPosition = input.Position.X - volumeSlider.AbsolutePosition.X
		local progress = math.clamp(sliderPosition / volumeSlider.AbsoluteSize.X, 0, 1)
		volumeBar.Size = UDim2.new(progress, 0, 1, 0)
		updateVolume()
	end
end

volumeSlider.InputBegan:Connect(onVolumeSliderInput)
volumeSlider.InputChanged:Connect(onVolumeSliderInput)

-- Toggle UI via Topbar Icon
musicIcon.selected:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Progress update loop
game:GetService("RunService").Heartbeat:Connect(updateProgress)

-- Initialize
createShuffledList()
volumeBar.Size = UDim2.new(1, 0, 1, 0) -- Set initial volume to 100%