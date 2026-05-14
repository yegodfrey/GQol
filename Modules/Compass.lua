local GQol = _G.GQol

local Utils = GQol.Utils
local Constants = GQol.Constants

GQol.Compass = GQol.Compass or {}
local Compass = GQol.Compass
Compass.minimapFrame = nil
Compass.minimapLine = nil
Compass.worldMapFrame = nil
Compass.worldMapLine = nil
Compass.worldMapLineStartPoint = nil
Compass.worldMapLineEndPoint = nil
Compass.playerFacing = 0
Compass.lastWorldMapUpdate = 0
Compass.lastMinimapUpdate = 0
Compass.isMoving = false
Compass.worldMapUpdated = false
Compass.lastMinimapFacing = 0

local function GetCompassDB()
	return GQol.db.global.compass
end

local function ShouldCompassRun(db, shownFrame)
	return db.enabled and shownFrame:IsShown()
end

local function UpdateLineAppearance(line, db, scale)
	line:SetVertexColor(db.lineColor.r, db.lineColor.g, db.lineColor.b, db.lineColor.a)
	if scale then
		line:SetThickness(db.worldMapLineThickness / scale)
	else
		line:SetThickness(db.minimapLineThickness)
	end
end

local function GetMapSize()
	local currentMapID = WorldMapFrame:GetMapID()
	if not currentMapID then return end

	local mapID, topleft = C_Map.GetWorldPosFromMapPos(currentMapID, {x = 0, y = 0})
	local mapID2, bottomright = C_Map.GetWorldPosFromMapPos(currentMapID, {x = 1, y = 1})
	if not mapID then return end

	local left, top = topleft.y, topleft.x
	local right, bottom = bottomright.y, bottomright.x
	local width, height = left - right, top - bottom
	return left, top, right, bottom, width, height, mapID
end

local function GetLineIntersect(px, py, a, sx, sy, ex, ey)
	if a then
		a = (a + Constants.PI / 2) % (Constants.PI * 2)
		local dx, dy = -math.cos(a), math.sin(a)
		local d = dx * (sy - ey) + dy * (ex - sx)
		if d ~= 0 and dx ~= 0 then
			local s = (dx * (sy - py) - dy * (sx - px)) / d
			if s >= 0 and s <= 1 then
				local r = (sx + (ex - sx) * s - px) / dx
				if r >= 0 then
					return sx + (ex - sx) * s, sy + (ey - sy) * s, r, s
				end
			end
		end
	end
end

local function MinimapLine_OnUpdate(_, elapsed)
	Compass.lastMinimapUpdate = Compass.lastMinimapUpdate + elapsed
	local db = GetCompassDB()
	local throttle = db.minimapThrottle
	if Compass.lastMinimapUpdate < throttle then return end
	Compass.lastMinimapUpdate = 0

	if not ShouldCompassRun(db, Minimap) then
		Compass.minimapLine:Hide()
		return
	end

	local facing = GetPlayerFacing()
	if not facing then
		Compass.minimapLine:Hide()
		return
	end

	if facing == Compass.lastMinimapFacing then return end
	Compass.lastMinimapFacing = facing

	Compass.minimapLine:Show()
	local length = Compass.minimapFrame:GetWidth() / 2
	local dx = -math.cos(facing - (Constants.PI/2)) * length
	local dy = -math.sin(facing - (Constants.PI/2)) * length
	Compass.minimapLine:SetEndPoint("CENTER", Compass.minimapFrame, dx, dy)
	UpdateLineAppearance(Compass.minimapLine, db)
end

local function CalculateMapIntersections(px, py, angle, left, top, right, bottom)
	return {
		top    = {GetLineIntersect(px, py, angle, left, top, right, top)},
		bottom = {GetLineIntersect(px, py, angle, left, bottom, right, bottom)},
		left   = {GetLineIntersect(px, py, angle, left, top, left, bottom)},
		right  = {GetLineIntersect(px, py, angle, right, top, right, bottom)},
	}
end

local function CollectIntersectionPoints(edges)
	local points = {}

	for side, data in pairs(edges) do
		if data[1] then
			table.insert(points, {
				x = data[1],
				y = data[2],
				r = data[3],
				s = data[4],
				side = side,
			})
		end
	end

	return points
end

local function GetPointFromSide(side, mWidth, mHeight, ms)
	if side == 'top' then
		return mWidth * ms, 0, 'TOPLEFT'
	elseif side == 'bottom' then
		return mWidth * ms, 0, 'BOTTOMLEFT'
	elseif side == 'left' then
		return 0, -mHeight * ms, 'TOPLEFT'
	elseif side == 'right' then
		return 0, -mHeight * ms, 'TOPRIGHT'
	end
	return 0, 0, 'CENTER'
end

local function UpdateWorldMapLineWithTwoPoints(p1, p2, worldMapButton, mWidth, mHeight, db)
	local first, second = p1, p2
	if p2.r < p1.r then
		first, second = p2, p1
	end

	Compass.worldMapLineStartPoint:ClearAllPoints()
	Compass.worldMapLineEndPoint:ClearAllPoints()

	local x1, y1, anchor1 = GetPointFromSide(first.side, mWidth, mHeight, first.s)
	local x2, y2, anchor2 = GetPointFromSide(second.side, mWidth, mHeight, second.s)
	Compass.worldMapLineStartPoint:SetPoint("CENTER", worldMapButton, anchor1, x1, y1)
	Compass.worldMapLineEndPoint:SetPoint("CENTER", worldMapButton, anchor2, x2, y2)

	UpdateLineAppearance(Compass.worldMapLine, db, WorldMapFrame:GetCanvas():GetScale() or 1)
	Compass.worldMapLine:Show()
end

local function UpdateWorldMapLineWithPlayerPosition(p, mx, my, worldMapButton, mWidth, mHeight, db)
	Compass.worldMapLineStartPoint:ClearAllPoints()
	Compass.worldMapLineEndPoint:ClearAllPoints()

	Compass.worldMapLineStartPoint:SetPoint("CENTER", worldMapButton, "TOPLEFT", mWidth * mx, -mHeight * my)
	local x2, y2, anchor2 = GetPointFromSide(p.side, mWidth, mHeight, p.s)
	Compass.worldMapLineEndPoint:SetPoint("CENTER", worldMapButton, anchor2, x2, y2)

	UpdateLineAppearance(Compass.worldMapLine, db, WorldMapFrame:GetCanvas():GetScale() or 1)
	Compass.worldMapLine:Show()
end

local function WorldMapLine_OnUpdate(_, elapsed)
	Compass.lastWorldMapUpdate = Compass.lastWorldMapUpdate + elapsed
	local db = GetCompassDB()
	local throttle = db.worldMapThrottle
	if Compass.lastWorldMapUpdate < throttle then return end
	Compass.lastWorldMapUpdate = 0

	if not ShouldCompassRun(db, WorldMapFrame) then
		Compass.worldMapLine:Hide()
		return
	end

	local angle = GetPlayerFacing()
	local isGliding = C_PlayerInfo.GetGlidingInfo()

	if not angle and Compass.worldMapLine:IsShown() then
		Compass.worldMapLine:Hide()
		return
	end

	if Compass.worldMapUpdated or Compass.isMoving or angle ~= Compass.playerFacing or isGliding then
		Compass.worldMapUpdated = false
		Compass.playerFacing = angle
		Compass.worldMapLine:Hide()

		if UnitOnTaxi("player") then return end

		local bestMap = C_Map.GetBestMapForUnit("player")
		if not bestMap then return end
		local playerMapPos = C_Map.GetPlayerMapPosition(bestMap, "player")
		if not playerMapPos then return end

		local pMapID, loc = C_Map.GetWorldPosFromMapPos(bestMap, {x = playerMapPos.x, y = playerMapPos.y})
		local px, py = loc.y, loc.x
		if not px then return end

		local left, top, right, bottom, width, height, mapMapID = GetMapSize()
		if not width or width == 0 then return end

		local sameInstanceish = pMapID == mapMapID
		local onMap = false
		local mx, my = 0, 0
		if sameInstanceish and (px <= left and px >= right and py <= top and py >= bottom) then
			mx, my = (left - px) / width, (top - py) / height
			onMap = true
		end

		if sameInstanceish then
			local edges = CalculateMapIntersections(px, py, angle, left, top, right, bottom)
			local points = CollectIntersectionPoints(edges)

			local worldMapButton = WorldMapFrame:GetCanvas()
			local mWidth, mHeight = worldMapButton:GetSize()

			if #points >= 2 then
				UpdateWorldMapLineWithTwoPoints(points[1], points[2], worldMapButton, mWidth, mHeight, db)
			elseif onMap and #points >= 1 then
				UpdateWorldMapLineWithPlayerPosition(points[1], mx, my, worldMapButton, mWidth, mHeight, db)
			end
		end
	end
end

function Compass:SetupWorldMapVisibilityHandler()
	if not self.worldMapFrame then return end
	WorldMapFrame:HookScript("OnShow", function()
		if GetCompassDB().enabled then
			self.worldMapFrame:SetScript("OnUpdate", WorldMapLine_OnUpdate)
			self.worldMapUpdated = true
			if self.movementFrame then
				self.movementFrame:RegisterEvent("PLAYER_STARTED_MOVING")
				self.movementFrame:RegisterEvent("PLAYER_STOPPED_MOVING")
			end
		end
	end)
	WorldMapFrame:HookScript("OnHide", function()
		self.worldMapFrame:SetScript("OnUpdate", nil)
		if self.worldMapLine then
			self.worldMapLine:Hide()
		end
		if self.movementFrame then
			self.movementFrame:UnregisterAllEvents()
		end
		self.isMoving = false
	end)

	hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
		self.worldMapUpdated = true
	end)

	hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", function()
		local scale = WorldMapFrame:GetCanvas():GetScale()
		if self.worldMapLine then
			self.worldMapLine:SetThickness(GetCompassDB().worldMapLineThickness / scale)
		end
	end)
end

function Compass:OnInitialize()
	if self.minimapFrame then return end

	self.minimapFrame = CreateFrame("Frame", "GQol_MinimapLineFrame", Minimap)
	self.minimapFrame:SetAllPoints()

	self.minimapLine = self.minimapFrame:CreateLine("GQol_MinimapCompassLine", "OVERLAY")
	self.minimapLine:SetTexture("Interface/Buttons/WHITE8x8")
	self.minimapLine:SetStartPoint("CENTER", self.minimapFrame, 0, 0)
	self.minimapLine:SetThickness(2)
	self.minimapLine:Hide()

	local worldMapButton = WorldMapFrame:GetCanvas()
	self.worldMapFrame = CreateFrame("Frame", "GQol_WorldMapLineFrame", worldMapButton)
	self.worldMapFrame:SetAllPoints()
	self.worldMapFrame:SetFrameStrata("HIGH")
	self.worldMapFrame:SetFrameLevel(14999)

	self.worldMapLineStartPoint = CreateFrame("Frame", nil, self.worldMapFrame)
	self.worldMapLineStartPoint:SetSize(1, 1)
	self.worldMapLineEndPoint = CreateFrame("Frame", nil, self.worldMapFrame)
	self.worldMapLineEndPoint:SetSize(1, 1)

	self.worldMapLine = self.worldMapFrame:CreateLine("GQol_WorldMapCompassLine", "OVERLAY")
	self.worldMapLine:Hide()
	self.worldMapLine:SetTexture("Interface/Buttons/WHITE8x8")
	self.worldMapLine:SetThickness(2)
	self.worldMapLine:SetStartPoint("CENTER", self.worldMapLineStartPoint, 0, 0)
	self.worldMapLine:SetEndPoint("CENTER", self.worldMapLineEndPoint, 0, 0)

	self.movementFrame = CreateFrame("Frame", nil, self.worldMapFrame)
	self.movementFrame:SetScript("OnEvent", function(_, event)
		self.isMoving = (event == "PLAYER_STARTED_MOVING")
	end)

	self:SetupWorldMapVisibilityHandler()
end

function Compass:OnEnable()
	if not self.minimapFrame then
		self:OnInitialize()
	end
	self.minimapFrame:SetScript("OnUpdate", MinimapLine_OnUpdate)
	self.worldMapUpdated = true
end

function Compass:OnDisable()
	if self.minimapFrame then
		self.minimapFrame:SetScript("OnUpdate", nil)
	end
	if self.minimapLine then
		self.minimapLine:Hide()
	end
	if self.worldMapFrame then
		self.worldMapFrame:SetScript("OnUpdate", nil)
	end
	if self.worldMapLine then
		self.worldMapLine:Hide()
	end
	if self.movementFrame then
		self.movementFrame:UnregisterAllEvents()
	end
	self.isMoving = false
end

function Compass:SetEnabled(val)
	if val then
		self:OnEnable()
		Utils:SendApplyMessage("COMPASS_ENABLED")
	else
		self:OnDisable()
		Utils:SendApplyMessage("COMPASS_DISABLED")
	end
end

function Compass:GetOptions()
	local CH = Utils.ConfigHelpers
	return {
		enabled = CH.GlobalToggle(91, "COMPASS_ENABLE_CBOX", "compass.enabled", function(val)
			self:SetEnabled(val)
		end),
		minimapThickness = CH.GlobalRange(92, "COMPASS_MINIMAP_THICKNESS_SLIDER", "compass.minimapLineThickness", 1, 10, 0.5),
		worldMapThickness = CH.GlobalRange(93, "COMPASS_WORLDMAP_THICKNESS_SLIDER", "compass.worldMapLineThickness", 1, 10, 0.5),
		minimapThrottle = CH.GlobalRange(94, "COMPASS_MINIMAP_THROTTLE_SLIDER", "compass.minimapThrottle", 0.05, 1.0, 0.05),
		worldMapThrottle = CH.GlobalRange(95, "COMPASS_WORLDMAP_THROTTLE_SLIDER", "compass.worldMapThrottle", 0.05, 1.0, 0.05),
		lineColor = CH.Color(96, "COMPASS_LINE_COLOR", "compass.lineColor", true, { r = 1, g = 0, b = 0, a = 0.8 }),
	}
end