-- ====================== 指南针模块（小地图线 + 世界地图线颜色已统一） ======================
local PI = math.pi
local GQol = _G.GQol

local minimapLineFrame = CreateFrame('Frame', nil, Minimap)
minimapLineFrame:SetAllPoints()
local minimapCompassLine = minimapLineFrame:CreateLine(nil, 'OVERLAY')
minimapCompassLine:SetTexture('Interface/Buttons/WHITE8x8')
minimapCompassLine:SetStartPoint('CENTER', minimapLineFrame, 0, 0)

-- 小地图OnUpdate
minimapLineFrame:SetScript('OnUpdate', function(self)
    local db = GQol.db.profile.compass
    if not db or not db.enabled or not Minimap:IsShown() then
        minimapCompassLine:Hide()
        return
    end
    
    local facing = GetPlayerFacing()
    if facing then
        minimapCompassLine:Show()
        local length = (self:GetWidth() / 2) 
        local dx = -math.cos(facing - (PI/2)) * length
        local dy = -math.sin(facing - (PI/2)) * length
        minimapCompassLine:SetEndPoint('CENTER', self, dx, dy)
        minimapCompassLine:SetThickness(db.minimapLineThickness)
        minimapCompassLine:SetVertexColor(db.lineColor.r, db.lineColor.g, db.lineColor.b, db.lineColor.a)
    else
        minimapCompassLine:Hide()
    end
end)

-- 世界地图部分
local WorldMapButton = WorldMapFrame:GetCanvas()
local worldMapLineFrame = CreateFrame('frame', nil, WorldMapButton)
worldMapLineFrame:SetAllPoints()
worldMapLineFrame:SetFrameLevel(15000)

local worldMapLineStartPoint = CreateFrame('frame', nil, worldMapLineFrame)
worldMapLineStartPoint:SetSize(1, 1)
local worldMapLineEndPoint = CreateFrame('frame', nil, worldMapLineFrame)
worldMapLineEndPoint:SetSize(1, 1)

local worldMapCompassLine = worldMapLineFrame:CreateLine(nil, 'OVERLAY')
worldMapCompassLine:Hide()
worldMapCompassLine:SetTexture('interface/buttons/white8x8')
worldMapCompassLine:SetStartPoint('CENTER', worldMapLineStartPoint, 0, 0)
worldMapCompassLine:SetEndPoint('CENTER', worldMapLineEndPoint, 0, 0)

local function worldMap_GetMapSize()
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

local function worldMap_GetLineIntersect(px, py, a, sx, sy, ex, ey)
	if a then 
		a = (a + PI / 2) % (PI * 2)
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

local function updateWorldMapCompassLineAppearance()
    local db = GQol.db.profile.compass
    if db then
        worldMapCompassLine:SetVertexColor(db.lineColor.r, db.lineColor.g, db.lineColor.b, db.lineColor.a)
        local scale = WorldMapButton:GetScale() or 1
        worldMapCompassLine:SetThickness(db.worldMapLineThickness / scale)
    end
end

local worldMapUpdated, playerFacing = false, 0
-- 世界地图OnUpdate
worldMapLineFrame:SetScript('OnUpdate', function(self)
    local db = GQol.db.profile.compass
    if not db or not db.enabled then 
        worldMapCompassLine:Hide()
        return 
    end

    local angle = GetPlayerFacing()
    local isGliding, _, forwardSpeed = C_PlayerInfo.GetGlidingInfo()
    local speed = isGliding and forwardSpeed or GetUnitSpeed("player")

    if not angle then
        worldMapCompassLine:Hide()
        return
    end

    if worldMapUpdated or speed > 0 or angle ~= playerFacing then
        worldMapUpdated = false
        playerFacing = angle
        worldMapCompassLine:Hide()
        
        if UnitOnTaxi('player') then return end
        
        local bestMap = C_Map.GetBestMapForUnit("player")
        if not bestMap then return end
        local playerMapPos = C_Map.GetPlayerMapPosition(bestMap,"player")
        if not playerMapPos then return end
            
        local pMapID,loc = C_Map.GetWorldPosFromMapPos(bestMap,{x=playerMapPos.x,y=playerMapPos.y})
        local px = loc.y
        local py = loc.x
        if not px then return end 

        local left, top, right, bottom, width, height, mapMapID = worldMap_GetMapSize()
        if not width or width == 0 then return end 
        
        local sameInstanceish = pMapID == mapMapID
        local onMap = false
        local mx, my = 0, 0
        if sameInstanceish and (px <= left and px >= right and py <= top and py >= bottom) then
            mx, my = (left - px) / width, (top - py) / height
            onMap = true
        end
        
        if mapMapID == pMapID or onMap or sameInstanceish then
			local topX, topY, topRi, topSi = worldMap_GetLineIntersect(px, py, angle, left, top, right, top)
			local bottomX, bottomY, bottomRi, bottomSi = worldMap_GetLineIntersect(px, py, angle, left, bottom, right, bottom)
			local leftX, leftY, leftRi, leftSi = worldMap_GetLineIntersect(px, py, angle, left, top, left, bottom)
			local rightX, rightY, rightRi, rightSi = worldMap_GetLineIntersect(px, py, angle, right, top, right, bottom)
			
			local mx1, my1, mr1, ms1
			local mx2, my2, mr2, ms2
			local m1Side, m2Side 
			
			if topX then mx1, my1, mr1, ms1 = topX, topY, topRi, topSi; m1Side = 'top' end
			if bottomX then
				if not mx1 then mx1, my1, mr1, ms1 = bottomX, bottomY, bottomRi, bottomSi; m1Side = 'bottom'
				else mx2, my2, mr2, ms2 = bottomX, bottomY, bottomRi, bottomSi; m2Side = 'bottom' end
			end
			if leftX then
				if not mx1 then mx1, my1, mr1, ms1 = leftX, leftY, leftRi, leftSi; m1Side = 'left'
				else mx2, my2, mr2, ms2 = leftX, leftY, leftRi, leftSi; m2Side = 'left' end
			end
			if rightX then
				if not mx1 then mx1, my1, mr1, ms1 = rightX, rightY, rightRi, rightSi; m1Side = 'right'
				else mx2, my2, mr2, ms2 = rightX, rightY, rightRi, rightSi; m2Side = 'right' end
			end
			
			local mWidth, mHeight = WorldMapButton:GetSize()
			if m1Side and m2Side then 
				worldMapLineStartPoint:ClearAllPoints(); worldMapLineEndPoint:ClearAllPoints()
				if mr1 < mr2 then 
					if m1Side == 'top' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', mWidth * ms1, 0)
					elseif m1Side == 'bottom' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'BOTTOMLEFT', mWidth * ms1, 0)
					elseif m1Side == 'left' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', 0, -mHeight * ms1)
					elseif m1Side == 'right' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPRIGHT', 0, -mHeight * ms1) end

					if m2Side == 'top' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', mWidth * ms2, 0)
					elseif m2Side == 'bottom' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'BOTTOMLEFT', mWidth * ms2, 0)
					elseif m2Side == 'left' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', 0, -mHeight * ms2)
					elseif m2Side == 'right' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPRIGHT', 0, -mHeight * ms2) end
				else 
					if m2Side == 'top' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', mWidth * ms2, 0)
					elseif m2Side == 'bottom' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'BOTTOMLEFT', mWidth * ms2, 0)
					elseif m2Side == 'left' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', 0, -mHeight * ms2)
					elseif m2Side == 'right' then worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPRIGHT', 0, -mHeight * ms2) end
					
					if m1Side == 'top' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', mWidth * ms1, 0)
					elseif m1Side == 'bottom' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'BOTTOMLEFT', mWidth * ms1, 0)
					elseif m1Side == 'left' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', 0, -mHeight * ms1)
					elseif m1Side == 'right' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPRIGHT', 0, -mHeight * ms1) end
				end
                updateWorldMapCompassLineAppearance()
				worldMapCompassLine:Show()
			elseif m1Side and onMap then
				worldMapLineStartPoint:ClearAllPoints(); worldMapLineEndPoint:ClearAllPoints()
				worldMapLineStartPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', mWidth * mx, -mHeight * my)
				if m1Side == 'top' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', mWidth * ms1, 0)
				elseif m1Side == 'bottom' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'BOTTOMLEFT', mWidth * ms1, 0)
				elseif m1Side == 'left' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPLEFT', 0, -mHeight * ms1)
				elseif m1Side == 'right' then worldMapLineEndPoint:SetPoint('CENTER', WorldMapButton, 'TOPRIGHT', 0, -mHeight * ms1) end
                updateWorldMapCompassLineAppearance()
				worldMapCompassLine:Show()
			end
		end
	end
end)

-- 事件监听
hooksecurefunc(WorldMapFrame, 'OnMapChanged', function() worldMapUpdated = true end)
hooksecurefunc(WorldMapFrame, 'OnCanvasScaleChanged', function(self)
	local scale = self:GetCanvas():GetScale()
	local db = GQol.db.profile.compass
	if db then-- ====================== GQol 指南针模块 ======================
local PI = math.pi
local GQol = _G.GQol

-- ====================== 小地图指南针线（固定贴边，不会伸出） ======================
local minimapLineFrame = CreateFrame('Frame', nil, Minimap)
minimapLineFrame:SetAllPoints()

local minimapCompassLine = minimapLineFrame:CreateLine(nil, 'OVERLAY')
minimapCompassLine:SetTexture('Interface/Buttons/WHITE8x8')
minimapCompassLine:SetStartPoint('CENTER', minimapLineFrame, 0, 0)

minimapLineFrame:SetScript('OnUpdate', function(self)
    local db = GQol.db.profile.compass
    if not db or not db.enabled then
        minimapCompassLine:Hide()
        return
    end

    local facing = GetPlayerFacing()
    if not facing or not Minimap:IsShown() then
        minimapCompassLine:Hide()
        return
    end

    -- 核心：固定取小地图半径，自动贴四角，永远不伸出
    local radius = self:GetWidth() / 2
    local dx = -math.cos(facing - PI/2) * radius
    local dy = -math.sin(facing - PI/2) * radius

    minimapCompassLine:Show()
    minimapCompassLine:SetEndPoint('CENTER', self, dx, dy)
    minimapCompassLine:SetThickness(db.minimapLineThickness)
    minimapCompassLine:SetVertexColor(db.lineColor.r, db.lineColor.g, db.lineColor.b, db.lineColor.a)
end)

-- ====================== 世界地图指南针线 ======================
local WorldMapButton = WorldMapFrame:GetCanvas()
local worldMapLineFrame = CreateFrame('frame', nil, WorldMapButton)
worldMapLineFrame:SetAllPoints()
worldMapLineFrame:SetFrameLevel(15000)

local worldMapLineStartPoint = CreateFrame('frame', nil, worldMapLineFrame)
worldMapLineStartPoint:SetSize(1, 1)
local worldMapLineEndPoint = CreateFrame('frame', nil, worldMapLineFrame)
worldMapLineEndPoint:SetSize(1, 1)

local worldMapCompassLine = worldMapLineFrame:CreateLine(nil, 'OVERLAY')
worldMapCompassLine:Hide()
worldMapCompassLine:SetTexture('interface/buttons/white8x8')
worldMapCompassLine:SetStartPoint('CENTER', worldMapLineStartPoint, 0, 0)
worldMapCompassLine:SetEndPoint('CENTER', worldMapLineEndPoint, 0, 0)

-- 世界地图尺寸获取
local function worldMapLine_GetMapSize()
    local currentMapID = WorldMapFrame:GetMapID()
    if not currentMapID then return end

    local mapID, topleft = C_Map.GetWorldPosFromMapPos(currentMapID, {x=0,y=0})
    local mapID2, bottomright = C_Map.GetWorldPosFromMapPos(currentMapID, {x=1,y=1})
    if not mapID then return end

    local left, top = topleft.y, topleft.x
    local right, bottom = bottomright.y, bottomright.x
    local width, height = left - right, top - bottom
    return left, top, right, bottom, width, height, mapID
end

-- 世界地图线段交点计算
local function worldMapLine_GetIntersect(px, py, a, sx, sy, ex, ey)
    if not a then return end
    a = (a + PI/2) % (PI*2)
    local dx, dy = -math.cos(a), math.sin(a)
    local d = dx*(sy-ey) + dy*(ex-sx)
    if d == 0 or dx == 0 then return end

    local s = (dx*(sy-py) - dy*(sx-px)) / d
    if s < 0 or s > 1 then return end

    local r = (sx + (ex-sx)*s - px) / dx
    if r < 0 then return end

    return sx+(ex-sx)*s, sy+(ey-sy)*s, r, s
end

-- 世界地图线条外观更新
local function worldMapLine_UpdateAppearance()
    local db = GQol.db.profile.compass
    if not db or not db.enabled then return end

    worldMapCompassLine:SetVertexColor(db.lineColor.r, db.lineColor.g, db.lineColor.b, db.lineColor.a)
    local scale = WorldMapButton:GetScale() or 1
    worldMapCompassLine:SetThickness(db.worldMapLineThickness / scale)
end

local worldMapLine_needUpdate, worldMapLine_lastFacing = false, 0

worldMapLineFrame:SetScript('OnUpdate', function(self)
    local db = GQol.db.profile.compass
    if not db or not db.enabled then
        worldMapCompassLine:Hide()
        return
    end

    local angle = GetPlayerFacing()
    if not angle then
        worldMapCompassLine:Hide()
        return
    end

    local speed = GetUnitSpeed("player")
    if not (worldMapLine_needUpdate or speed > 0 or angle ~= worldMapLine_lastFacing) then
        return
    end

    worldMapLine_needUpdate = false
    worldMapLine_lastFacing = angle
    worldMapCompassLine:Hide()

    if UnitOnTaxi("player") then return end

    local bestMap = C_Map.GetBestMapForUnit("player")
    local pos = C_Map.GetPlayerMapPosition(bestMap, "player")
    if not bestMap or not pos then return end

    local _, loc = C_Map.GetWorldPosFromMapPos(bestMap, pos)
    local px, py = loc.y, loc.x
    if not px then return end

    local left, top, right, bottom, w, h, mapID = worldMapLine_GetMapSize()
    if not w or w == 0 then return end

    local tx,ty,tr,ts = worldMapLine_GetIntersect(px,py,angle, left,top,right,top)
    local bx,by,br,bs = worldMapLine_GetIntersect(px,py,angle, left,bottom,right,bottom)
    local lx,ly,lr,ls = worldMapLine_GetIntersect(px,py,angle, left,top,left,bottom)
    local rx,ry,rr,rs = worldMapLine_GetIntersect(px,py,angle, right,top,right,bottom)

    local p1x,p1y,p1r,p1s, side1
    local p2x,p2y,p2r,p2s, side2

    if tx then p1x,p1y,p1r,p1s,side1 = tx,ty,tr,ts,"top" end
    if bx then
        if not p1x then p1x,p1y,p1r,p1s,side1 = bx,by,br,bs,"bottom"
        else p2x,p2y,p2r,p2s,side2 = bx,by,br,bs,"bottom" end
    end
    if lx then
        if not p1x then p1x,p1y,p1r,p1s,side1 = lx,ly,lr,ls,"left"
        else p2x,p2y,p2r,p2s,side2 = lx,ly,lr,ls,"left" end
    end
    if rx then
        if not p1x then p1x,p1y,p1r,p1s,side1 = rx,ry,rr,rs,"right"
        else p2x,p2y,p2r,p2s,side2 = rx,ry,rr,rs,"right" end
    end

    local mw, mh = WorldMapButton:GetSize()
    if side1 and side2 then
        worldMapLineStartPoint:ClearAllPoints()
        worldMapLineEndPoint:ClearAllPoints()

        local s1,s2 = p1s, p2s
        if p1r > p2r then s1,s2 = p2s,p1s end

        if side1 == "top" then worldMapLineStartPoint:SetPoint("CENTER", WorldMapButton, "TOPLEFT", mw*s1, 0)
        elseif side1 == "bottom" then worldMapLineStartPoint:SetPoint("CENTER", WorldMapButton, "BOTTOMLEFT", mw*s1, 0)
        elseif side1 == "left" then worldMapLineStartPoint:SetPoint("CENTER", WorldMapButton, "TOPLEFT", 0, -mh*s1)
        elseif side1 == "right" then worldMapLineStartPoint:SetPoint("CENTER", WorldMapButton, "TOPRIGHT", 0, -mh*s1) end

        if side2 == "top" then worldMapLineEndPoint:SetPoint("CENTER", WorldMapButton, "TOPLEFT", mw*s2, 0)
        elseif side2 == "bottom" then worldMapLineEndPoint:SetPoint("CENTER", WorldMapButton, "BOTTOMLEFT", mw*s2, 0)
        elseif side2 == "left" then worldMapLineEndPoint:SetPoint("CENTER", WorldMapButton, "TOPLEFT", 0, -mh*s2)
        elseif side2 == "right" then worldMapLineEndPoint:SetPoint("CENTER", WorldMapButton, "TOPRIGHT", 0, -mh*s2) end

        worldMapLine_UpdateAppearance()
        worldMapCompassLine:Show()
    end
end)

hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
    worldMapLine_needUpdate = true
end)

hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", function(self)
    local db = GQol.db.profile.compass
    if not db or not db.enabled then return end
    local scale = self:GetCanvas():GetScale()
    worldMapCompassLine:SetThickness(db.worldMapLineThickness / scale)
end)

-- 对外接口
GQol.Compass = {}
GQol.Compass.RefreshMinimapLine = function() end
GQol.Compass.RefreshWorldMapLine = function() end
GQol.Compass.Refresh = function() end
		worldMapCompassLine:SetThickness(db.worldMapLineThickness / scale)
	end
end)

-- 暴露刷新接口
GQol.Compass = GQol.Compass or {}
GQol.Compass.RefreshMinimapLine = function()
    -- 小地图线条刷新：触发OnUpdate逻辑
    if minimapLineFrame then
        minimapLineFrame:GetScript('OnUpdate')(minimapLineFrame)
    end
end
GQol.Compass.RefreshWorldMapLine = function()
    -- 世界地图线条刷新：触发OnUpdate逻辑
    if worldMapLineFrame then
        worldMapLineFrame:GetScript('OnUpdate')(worldMapLineFrame)
    end
end
GQol.Compass.Refresh = function()
    -- 统一刷新接口（兼容原有调用）
    GQol.Compass.RefreshMinimapLine()
    GQol.Compass.RefreshWorldMapLine()
end