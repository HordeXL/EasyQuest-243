
local EasyQuest_QuestLogFrameOptimize_BackgroundResources = {
	TopLeft = {
		texture = "Interface\\AddOns\\EasyQuest\\Resources\\Images\\UI-QuestLog-TopLeft";
		xOffset = 3;
		yOffset = 0
	};
	TopMiddle = {
		texture = "Interface\\AddOns\\EasyQuest\\Resources\\Images\\UI-QuestLog-TopMiddle";
		xOffset = 259;
		yOffset = 0
	};
	TopRight = {
		texture = "Interface\\AddOns\\EasyQuest\\Resources\\Images\\UI-QuestLog-TopRight";
		xOffset = 515;
		yOffset = 0
	};
	BotLeft = {
		texture = "Interface\\AddOns\\EasyQuest\\Resources\\Images\\UI-QuestLog-BottomLeft";
		xOffset = 3;
		yOffset = -256
	};
	BotMiddle = {
		texture = "Interface\\AddOns\\EasyQuest\\Resources\\Images\\UI-QuestLog-BottomMiddle";
		xOffset = 259;
		yOffset = -256
	};
	BotRight = {
		texture = "Interface\\AddOns\\EasyQuest\\Resources\\Images\\UI-QuestLog-BottomRight";
		xOffset = 515;
		yOffset = -256
	}
}

function EasyQuest_QuestLogFrameOptimize_ChageQuestFrameLayout()
	EasyQuest_QuestLogFrameOptimize_ChageQuestFrameWidthToDouble()
	EasyQuest_QuestLogFrameOptimize_MoveQuestDetailScrollFrameToRight()
	EasyQuest_QuestLogFrameOptimize_ChangeQuestLogListScrollFrameHeight()
	EasyQuest_QuestLogFrameOptimize_ChangeQuestLogBackground()
end

function EasyQuest_QuestLogFrameOptimize_ChageQuestFrameWidthToDouble()
	QuestLogFrame:SetWidth(724) -- Old width is 384
end

function EasyQuest_QuestLogFrameOptimize_MoveQuestDetailScrollFrameToRight()
	QuestLogDetailScrollFrame:SetHeight(359)
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 40, 0)
end

function EasyQuest_QuestLogFrameOptimize_ChangeQuestLogListScrollFrameHeight()
	QuestLogListScrollFrame:SetHeight(359)

	local oldQuestsDisplayed = QUESTS_DISPLAYED
	QUESTS_DISPLAYED = QUESTS_DISPLAYED + 17

	for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
		local questItemButton = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate")
		questItemButton:SetID(i)
		questItemButton:Hide()
		questItemButton:ClearAllPoints()
		questItemButton:SetPoint("TOPLEFT", getglobal("QuestLogTitle" .. (i-1)), "BOTTOMLEFT", 0, 1)
	end
end

function EasyQuest_QuestLogFrameOptimize_ChangeQuestLogBackground()
	local regions = { QuestLogFrame:GetRegions() }
	local matchPATTERN = "^Interface\\QuestFrame\\UI%-QuestLog%-(([A-Z][a-z]+)([A-Z][a-z]+))$"
	for _, region in ipairs(regions) do
		if (region:IsObjectType("Texture")) then
			local _, _, which = string.find(region:GetTexture(), matchPATTERN);

			if which and EasyQuest_QuestLogFrameOptimize_BackgroundResources[which] then
				local backgroundResources = EasyQuest_QuestLogFrameOptimize_BackgroundResources[which]
				region:ClearAllPoints()
				region:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", backgroundResources.xOffset, backgroundResources.yOffset)
				region:SetTexture(backgroundResources.texture)
				region:SetWidth(256)
				region:SetHeight(256)
			end
		end
	end

	local topMiddleTexture = QuestLogFrame:CreateTexture(nil, "ARTWORK")
	local topMiddleBackgroundResource = EasyQuest_QuestLogFrameOptimize_BackgroundResources["TopMiddle"]
	topMiddleTexture:SetTexture(topMiddleBackgroundResource.texture)
	topMiddleTexture:SetWidth(256)
	topMiddleTexture:SetHeight(256)
	topMiddleTexture:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", topMiddleBackgroundResource.xOffset, topMiddleBackgroundResource.yOffset)


	local bottomMiddleTexture = QuestLogFrame:CreateTexture(nil, "ARTWORK")
	local bottomMiddleBackgroundResource = EasyQuest_QuestLogFrameOptimize_BackgroundResources["BotMiddle"]
	bottomMiddleTexture:SetTexture(bottomMiddleBackgroundResource.texture)
	bottomMiddleTexture:SetWidth(256)
	bottomMiddleTexture:SetHeight(256)
	bottomMiddleTexture:SetPoint("TOPLEFT", QuestLogFrame, "TOPLEFT", bottomMiddleBackgroundResource.xOffset, bottomMiddleBackgroundResource.yOffset)
end


function EasyQuest_QuestLogFrameOptimize_UnLockFrame(frame)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(button)
		frame:StartMoving()
	end)
	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		EasyQuest_QuestLogFrameOptimize_SaveQuestLogFramePoint(frame)
	end)

	frame:SetScript("OnShow", function()
		EasyQuest_QuestLogFrameOptimize_SetQuestLogFramePoint(frame)
	end)
end

function EasyQuest_QuestLogFrameOptimize_LockFrame(frame)
	frame:SetMovable(false)
	frame:EnableMouse(false)
	frame:SetClampedToScreen()
	frame:UnRegisterForDrag("LeftButton")
end

function EasyQuest_QuestLogFrameOptimize_SaveQuestLogFramePoint(frame)
	if EasyQuest_QuestLogFrame_Point == nil then
		EasyQuest_QuestLogFrame_Point = {}
	end

	local _, _, _, offsetX, offsetY = frame:GetPoint()
	EasyQuest_QuestLogFrame_Point.offsetX = offsetX
	EasyQuest_QuestLogFrame_Point.offsetY = offsetY
end

function EasyQuest_QuestLogFrameOptimize_SetQuestLogFramePoint(frame)
	if EasyQuest_QuestLogFrame_Point then
		local point, relativeTo, relativePoint, _, _ = frame:GetPoint()
		offsetX = EasyQuest_QuestLogFrame_Point.offsetX
		offsetY = EasyQuest_QuestLogFrame_Point.offsetY
		frame:ClearAllPoints()
		frame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
	end
end


EasyQuest_QuestLogFrameOptimize_ChageQuestFrameLayout()
EasyQuest_QuestLogFrameOptimize_UnLockFrame(QuestLogFrame)


-- ============================================
-- 实时刷新任务完成状态
-- ============================================
local EasyQuest_Refresh = CreateFrame("Frame")

-- 注册游戏事件：任务进度变化时自动刷新
EasyQuest_Refresh:RegisterEvent("QUEST_LOG_UPDATE")           -- 接受/完成/放弃任务
EasyQuest_Refresh:RegisterEvent("QUEST_COMPLETE")             -- 任务目标达成，可提交
EasyQuest_Refresh:RegisterEvent("UNIT_QUEST_LOG_CHANGED")     -- 击杀/拾取计数变化

-- 刷新任务日志列表 + 详情面板（重新选中当前任务以刷新进度数字）
local function EasyQuest_DoRefresh()
	if not QuestLogFrame:IsShown() then return end
	QuestLog_Update()
	local selectedQuest = GetQuestLogSelection()
	if selectedQuest and selectedQuest > 0 then
		QuestLog_SetSelection(selectedQuest)
	end
end

EasyQuest_Refresh:SetScript("OnEvent", function()
	EasyQuest_DoRefresh()
end)

-- OnUpdate 轮询：任务日志打开时每 0.5 秒刷新一次，确保不漏
-- 日志关闭时停止 OnUpdate，打开时恢复，零空闲开销
local function EasyQuest_EnablePolling()
	EasyQuest_Refresh:SetScript("OnUpdate", function(self, elapsed)
		self.eqTimer = (self.eqTimer or 0) + elapsed
		if self.eqTimer > 0.5 then
			self.eqTimer = 0
			EasyQuest_DoRefresh()
		end
	end)
end

local function EasyQuest_DisablePolling()
	EasyQuest_Refresh:SetScript("OnUpdate", nil)
end

-- 改寫 OnShow/OnHide：保留原有位置恢复逻辑 + 动态启停轮询
local origOnShow = QuestLogFrame:GetScript("OnShow")
local origOnHide = QuestLogFrame:GetScript("OnHide")

QuestLogFrame:SetScript("OnShow", function()
	if origOnShow then
		origOnShow(QuestLogFrame)
	else
		EasyQuest_QuestLogFrameOptimize_SetQuestLogFramePoint(QuestLogFrame)
	end
	EasyQuest_DoRefresh()
	EasyQuest_EnablePolling()
end)

QuestLogFrame:SetScript("OnHide", function()
	if origOnHide then
		origOnHide(QuestLogFrame)
	end
	EasyQuest_DisablePolling()
end)

-- 斜杠命令：/easyquest refresh 手动刷新
SLASH_EASYQUEST1 = "/easyquest"
SlashCmdList["EASYQUEST"] = function(msg)
	msg = string.lower(string.gsub(msg or "", "^%s*(.-)%s*$", "%1"))
	if msg == "refresh" then
		if QuestLogFrame:IsShown() then
			EasyQuest_DoRefresh()
			print("|cff58C6FA[EasyQuest]|r 任务进度已刷新")
		else
			print("|cff58C6FA[EasyQuest]|r 请先打开任务日志")
		end
	elseif msg == "help" or msg == "" then
		print("|cffEEE4AE=== EasyQuest 命令 ===|r")
		print("|cff58C6FA/easyquest refresh|r - 刷新任务进度")
	end
end


-- ============================================
-- 在任务日志列表中显示任务等级前缀
-- 格式：[等级] 任务名称
-- ============================================
local function EasyQuest_PrependLevelToTitles()
	local numEntries = GetNumQuestLogEntries()
	if not numEntries or numEntries <= 0 then return end

	local maxShown = QUESTS_DISPLAYED or 20
	for i = 1, maxShown do
		local button = getglobal("QuestLogTitle" .. i)
		if not button then break end

		local _, level, _, _, isHeader = GetQuestLogTitle(i)
		local buttonText = button:GetText()
		if not isHeader and buttonText and buttonText ~= "" then
			if level and level > 0 then
				-- 防止重复前缀
				local cleanText = string.gsub(buttonText, "^%[%d+%]%s*", "")
				button:SetText("[" .. level .. "]" .. cleanText)
			end
		end
	end
end

local EasyQuest_OrigQuestLogUpdate = QuestLog_Update
if type(EasyQuest_OrigQuestLogUpdate) == "function" then
	QuestLog_Update = function(...)
		EasyQuest_OrigQuestLogUpdate(...)
		EasyQuest_PrependLevelToTitles()
	end
end

EasyQuest_PrependLevelToTitles()
