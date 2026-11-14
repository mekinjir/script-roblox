local Players           = game:GetService("Players")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")

local player = Players.LocalPlayer
if not player then return end
local pg = player:WaitForChild("PlayerGui", 10)
if not pg then return end

for _, child in ipairs(pg:GetChildren()) do
	if child:IsA("ScreenGui") and child.Name == "MekiServerside_UI" then
		child:Destroy()
	end
end

-- ============ THEME ============
local T = {
	Bg      = Color3.fromRGB(18, 18, 24),
	Panel   = Color3.fromRGB(28, 28, 38),
	PanelLi = Color3.fromRGB(36, 36, 50),
	Stroke  = Color3.fromRGB(55, 55, 75),
	Accent  = Color3.fromRGB(0, 210, 255),
	Text    = Color3.fromRGB(235, 235, 245),
	SubText = Color3.fromRGB(150, 155, 175),
	Event   = Color3.fromRGB(70, 220, 140),
	Func    = Color3.fromRGB(100, 170, 255),
	Unrl    = Color3.fromRGB(255, 180, 90),
	Danger  = Color3.fromRGB(255, 90, 100),
}
local FONT, FONTB = Enum.Font.GothamMedium, Enum.Font.GothamBold

local function round(o, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = o; return c end
local function outline(o, color, thick, trans)
	local s = Instance.new("UIStroke")
	s.Color = color or T.Stroke; s.Thickness = thick or 1
	s.Transparency = trans or 0; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = o; return s
end
local function tween(o, t, props)
	TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Drag custom dengan threshold: tap tipis tetap kedetek sebagai klik,
-- bukan drag (fix dari masalah Draggable bawaan Roblox sebelumnya).
local function makeDraggable(target, handle, onTap)
	local dragging, dragStart, startPos, maxDelta = false, nil, nil, 0
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, maxDelta = true, 0
			dragStart, startPos = input.Position, target.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not dragStart then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		local dist = math.sqrt(delta.X ^ 2 + delta.Y ^ 2)
		if dist > maxDelta then maxDelta = dist end
		if maxDelta > 4 then
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if onTap and maxDelta < 4 then onTap() end
		end
	end)
end

-- ============ GUI ROOT ============
local gui = Instance.new("ScreenGui")
gui.Name = "MekiServerside_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(620, 460)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = T.Bg
main.BorderSizePixel = 0
main.Visible = true
main.Parent = gui
round(main, 14)
outline(main, T.Accent, 1.2, 0.5)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = T.Panel
header.BorderSizePixel = 0
header.Active = true
header.Parent = main
round(header, 14)
local headerFix = Instance.new("Frame") -- nutup sudut bawah header biar gak kebulat
headerFix.Size = UDim2.new(1, 0, 0, 14)
headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = T.Panel
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Text = "MEKI SERVERSIDE"
title.Font = FONTB; title.TextSize = 15; title.TextColor3 = T.Text
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 0); title.Size = UDim2.fromOffset(220, 46)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local counter = Instance.new("TextLabel")
counter.Text = "(0 aksi)"
counter.Font = FONT; counter.TextSize = 12; counter.TextColor3 = T.SubText
counter.BackgroundTransparency = 1
counter.Position = UDim2.fromOffset(178, 0); counter.Size = UDim2.fromOffset(120, 46)
counter.TextXAlignment = Enum.TextXAlignment.Left
counter.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = FONTB; closeBtn.TextSize = 12; closeBtn.TextColor3 = T.SubText
closeBtn.BackgroundColor3 = T.PanelLi
closeBtn.Active = true
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header
round(closeBtn, 8)
closeBtn.MouseEnter:Connect(function() tween(closeBtn, 0.15, { BackgroundColor3 = T.Danger, TextColor3 = T.Text }) end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, 0.15, { BackgroundColor3 = T.PanelLi, TextColor3 = T.SubText }) end)

-- ============ SEARCH ============
local searchBox = Instance.new("Frame")
searchBox.Size = UDim2.new(1, -24, 0, 34)
searchBox.Position = UDim2.fromOffset(12, 56)
searchBox.BackgroundColor3 = T.Panel
searchBox.BorderSizePixel = 0
searchBox.Parent = main
round(searchBox, 8)
outline(searchBox, T.Stroke, 1, 0.4)

local searchInput = Instance.new("TextBox")
searchInput.Text = ""
searchInput.PlaceholderText = "Cari nama remote / path..."
searchInput.PlaceholderColor3 = T.SubText
searchInput.Font = FONT; searchInput.TextSize = 13; searchInput.TextColor3 = T.Text
searchInput.ClearTextOnFocus = false
searchInput.BackgroundTransparency = 1
searchInput.Position = UDim2.fromOffset(12, 0); searchInput.Size = UDim2.new(1, -24, 1, 0)
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.Parent = searchBox

-- ============ SCROLL LIST ============
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -24, 1, -144)
scroll.Position = UDim2.fromOffset(12, 100)
scroll.BackgroundColor3 = T.Panel
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = T.Accent
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main
round(scroll, 10)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll
local padL = Instance.new("UIPadding")
padL.PaddingTop = UDim.new(0, 8); padL.PaddingBottom = UDim.new(0, 8)
padL.PaddingLeft = UDim.new(0, 8); padL.PaddingRight = UDim.new(0, 8)
padL.Parent = scroll

local statusBar = Instance.new("TextLabel")
statusBar.Text = "Scanning..."
statusBar.Font = FONT; statusBar.TextSize = 11; statusBar.TextColor3 = T.SubText
statusBar.BackgroundTransparency = 1
statusBar.Position = UDim2.fromOffset(12, 0); statusBar.Size = UDim2.new(1, -24, 0, 20)
statusBar.AnchorPoint = Vector2.new(0, 0)
statusBar.Position = UDim2.new(0, 12, 1, -28)
statusBar.TextXAlignment = Enum.TextXAlignment.Left
statusBar.Parent = main

-- ============ FLOATING TOGGLE BOX ============
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBox"
toggleBtn.Text = ""
toggleBtn.Size = UDim2.fromOffset(50, 50)
toggleBtn.Position = UDim2.fromOffset(20, 140)
toggleBtn.BackgroundColor3 = T.Panel
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true -- WAJIB true, drag custom butuh InputBegan-nya nyala
toggleBtn.ZIndex = 10
toggleBtn.Parent = gui
round(toggleBtn, 14)
outline(toggleBtn, T.Accent, 1.5, 0.2)

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Text = "M"
toggleIcon.Font = FONTB; toggleIcon.TextSize = 20; toggleIcon.TextColor3 = T.Accent
toggleIcon.BackgroundTransparency = 1
toggleIcon.Size = UDim2.fromScale(1, 1)
toggleIcon.Parent = toggleBtn

local function setMainVisible(v)
	main.Visible = v
end

makeDraggable(main, header)
makeDraggable(toggleBtn, toggleBtn, function()
	setMainVisible(not main.Visible)
end)

closeBtn.MouseButton1Click:Connect(function()
	setMainVisible(false)
end)

-- ============ REMOTE DETECTION ============
local KNOWN = {
	Workspace = 'game:GetService("Workspace")',
	ReplicatedStorage = 'game:GetService("ReplicatedStorage")',
	ReplicatedFirst = 'game:GetService("ReplicatedFirst")',
	Players = 'game:GetService("Players")',
	Lighting = 'game:GetService("Lighting")',
	StarterGui = 'game:GetService("StarterGui")',
	StarterPack = 'game:GetService("StarterPack")',
}
local function safeIndex(name)
	if name:match("^[%a_][%w_]*$") then return "." .. name end
	return "[" .. string.format("%q", name) .. "]"
end
local function pathExpr(inst)
	local segs, cur = {}, inst
	while cur and cur ~= game do table.insert(segs, 1, cur); cur = cur.Parent end
	if #segs == 0 then return "game" end
	local root = segs[1]
	local result = KNOWN[root.Name] or ("game" .. safeIndex(root.Name))
	for i = 2, #segs do result = result .. safeIndex(segs[i].Name) end
	return result
end
local function isRemote(inst)
	local c = inst.ClassName
	return c == "RemoteEvent" or c == "RemoteFunction" or c == "UnreliableRemoteEvent"
end
local function isUseless(inst)
	local cur = inst
	while cur and cur ~= game do
		if cur.Name == "RobloxReplicatedStorage" then return true end
		if cur.ClassName == "Backpack" then return true end
		cur = cur.Parent
	end
	return false
end

-- Parse argumen yang diketik user, format: "nama", 100, true
local function parseArgs(text)
	if not text or text:match("^%s*$") then return {} end
	local fn, err = loadstring("return {" .. text .. "}")
	if not fn then return nil, err end
	local ok, result = pcall(fn)
	if not ok then return nil, result end
	return result
end

local REMOTES = {}
local remoteCount = 0
local searchText = ""

local function matchesFilter(info)
	if searchText == "" then return true end
	local low = searchText:lower()
	return info.name:lower():find(low, 1, true) ~= nil or info.path:lower():find(low, 1, true) ~= nil
end
local function applyFilter()
	for _, info in pairs(REMOTES) do
		if info.row and info.row.Parent then info.row.Visible = matchesFilter(info) end
	end
end
local function updateCounts()
	counter.Text = "(" .. remoteCount .. " aksi)"
end
local function updateStatus(msg)
	if statusBar and statusBar.Parent then statusBar.Text = msg end
end

local function createRow(inst)
	local name, class, path = inst.Name, inst.ClassName, pathExpr(inst)
	local badgeColor, shortClass
	if class == "RemoteEvent" then badgeColor, shortClass = T.Event, "EVENT"
	elseif class == "RemoteFunction" then badgeColor, shortClass = T.Func, "FUNC"
	else badgeColor, shortClass = T.Unrl, "UNRL" end

	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 0)
	row.AutomaticSize = Enum.AutomaticSize.Y
	row.BackgroundColor3 = T.PanelLi
	row.BorderSizePixel = 0
	row.Parent = scroll
	round(row, 8)
	outline(row, T.Stroke, 1, 0.5)

	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
	pad.Parent = row
	local vlist = Instance.new("UIListLayout")
	vlist.Padding = UDim.new(0, 6); vlist.SortOrder = Enum.SortOrder.LayoutOrder
	vlist.Parent = row

	local hdr = Instance.new("Frame")
	hdr.Size = UDim2.new(1, 0, 0, 22)
	hdr.BackgroundTransparency = 1
	hdr.Parent = row

	local badge = Instance.new("TextLabel")
	badge.Text = shortClass
	badge.Font = FONTB; badge.TextSize = 10; badge.TextColor3 = T.Bg
	badge.BackgroundColor3 = badgeColor
	badge.Size = UDim2.fromOffset(56, 20)
	badge.Parent = hdr
	round(badge, 5)

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Text = name
	nameLbl.Font = FONTB; nameLbl.TextSize = 13; nameLbl.TextColor3 = T.Text
	nameLbl.BackgroundTransparency = 1
	nameLbl.Position = UDim2.fromOffset(64, 0); nameLbl.Size = UDim2.new(1, -74, 1, 0)
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
	nameLbl.Parent = hdr

	local pathLbl = Instance.new("TextLabel")
	pathLbl.Text = path
	pathLbl.Font = Enum.Font.Code; pathLbl.TextSize = 10; pathLbl.TextColor3 = T.SubText
	pathLbl.BackgroundTransparency = 1
	pathLbl.Size = UDim2.new(1, 0, 0, 0)
	pathLbl.AutomaticSize = Enum.AutomaticSize.Y
	pathLbl.TextWrapped = true
	pathLbl.TextXAlignment = Enum.TextXAlignment.Left
	pathLbl.Parent = row

	local actionRow = Instance.new("Frame")
	actionRow.Size = UDim2.new(1, 0, 0, 32)
	actionRow.BackgroundTransparency = 1
	actionRow.Parent = row

	local argBox = Instance.new("TextBox")
	argBox.Text = ""
	argBox.PlaceholderText = 'argumen, pisah koma: "nama", 100, true'
	argBox.PlaceholderColor3 = T.SubText
	argBox.Font = Enum.Font.Code; argBox.TextSize = 11; argBox.TextColor3 = T.Text
	argBox.ClearTextOnFocus = false
	argBox.BackgroundColor3 = T.Bg
	argBox.Size = UDim2.new(1, -92, 1, 0)
	argBox.TextXAlignment = Enum.TextXAlignment.Left
	argBox.Parent = actionRow
	round(argBox, 6)
	outline(argBox, T.Stroke, 1, 0.4)
	local argPad = Instance.new("UIPadding")
	argPad.PaddingLeft = UDim.new(0, 8); argPad.PaddingRight = UDim.new(0, 8)
	argPad.Parent = argBox

	local fireBtn = Instance.new("TextButton")
	fireBtn.Text = class == "RemoteFunction" and "INVOKE" or "FIRE"
	fireBtn.Font = FONTB; fireBtn.TextSize = 11; fireBtn.TextColor3 = T.Bg
	fireBtn.BackgroundColor3 = T.Accent
	fireBtn.Size = UDim2.new(0, 82, 1, 0)
	fireBtn.Position = UDim2.new(1, -82, 0, 0)
	fireBtn.Parent = actionRow
	round(fireBtn, 6)

	local resultLbl = Instance.new("TextLabel")
	resultLbl.Text = ""
	resultLbl.Font = Enum.Font.Code; resultLbl.TextSize = 10; resultLbl.TextColor3 = T.SubText
	resultLbl.BackgroundTransparency = 1
	resultLbl.Size = UDim2.new(1, 0, 0, 0)
	resultLbl.AutomaticSize = Enum.AutomaticSize.Y
	resultLbl.TextWrapped = true
	resultLbl.TextXAlignment = Enum.TextXAlignment.Left
	resultLbl.Visible = false
	resultLbl.Parent = row

	fireBtn.MouseButton1Click:Connect(function()
		if not inst.Parent then
			resultLbl.Visible = true
			resultLbl.Text = "Remote sudah tidak ada."
			resultLbl.TextColor3 = T.Danger
			return
		end
		local args, parseErr = parseArgs(argBox.Text)
		if not args then
			resultLbl.Visible = true
			resultLbl.Text = "Argumen tidak valid: " .. tostring(parseErr)
			resultLbl.TextColor3 = T.Danger
			return
		end
		fireBtn.Text = "..."
		local ok, result = pcall(function()
			if class == "RemoteFunction" then
				return inst:InvokeServer(table.unpack(args))
			else
				inst:FireServer(table.unpack(args))
				return nil
			end
		end)
		fireBtn.Text = class == "RemoteFunction" and "INVOKE" or "FIRE"
		resultLbl.Visible = true
		if ok then
			resultLbl.TextColor3 = T.Event
			if class == "RemoteFunction" then
				resultLbl.Text = "OK -> " .. tostring(result)
			else
				resultLbl.Text = "OK (fired)"
			end
		else
			resultLbl.TextColor3 = T.Danger
			resultLbl.Text = "Error: " .. tostring(result)
		end
	end)

	return row, { name = name, class = class, path = path }
end

local function addRemote(inst)
	if not isRemote(inst) then return end
	if inst.Parent == nil then return end
	if REMOTES[inst] then return end
	if isUseless(inst) then return end
	local ok, row, info = pcall(createRow, inst)
	if not ok then warn("[MekiServerside] gagal bikin row:", row) return end
	info.row = row
	REMOTES[inst] = info
	remoteCount = remoteCount + 1
	updateCounts()
	if not matchesFilter(info) then row.Visible = false end
end

local function removeRemote(inst)
	local info = REMOTES[inst]
	if not info then return end
	if info.row and info.row.Parent then info.row:Destroy() end
	REMOTES[inst] = nil
	remoteCount = math.max(0, remoteCount - 1)
	updateCounts()
end

searchInput:GetPropertyChangedSignal("Text"):Connect(function()
	searchText = searchInput.Text
	applyFilter()
end)

local function fullScan()
	updateStatus("Scanning aksi di game...")
	task.wait(0.05)
	local clock = os.clock()
	for _, inst in ipairs(game:GetDescendants()) do
		if isRemote(inst) then
			local ok, err = pcall(addRemote, inst)
			if not ok then warn("[MekiServerside] skip", inst, err) end
		end
		if os.clock() - clock > 1 / 60 then
			task.wait()
			clock = os.clock()
		end
	end
	updateStatus(("Ready - %d aksi ditemukan"):format(remoteCount))
	applyFilter()
end
fullScan()

game.DescendantAdded:Connect(function(inst)
	if isRemote(inst) then
		local ok, err = pcall(addRemote, inst)
		if not ok then warn("[MekiServerside] skip", inst, err) end
	end
end)
game.DescendantRemoving:Connect(function(inst)
	if not isRemote(inst) then return end
	task.defer(function()
		if inst.Parent ~= nil then return end
		removeRemote(inst)
	end)
end)

print("[MEKI SERVERSIDE] Loaded")
