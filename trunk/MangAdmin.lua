﻿-------------------------------------------------------------------------------------------------------------
--
-- MangAdmin Version 1.0
--
-- Copyright (C) 2007 Free Software Foundation, Inc.
-- License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
-- This is free software: you are free to change and redistribute it.
-- There is NO WARRANTY, to the extent permitted by law.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--
-- Official Forums: http://www.manground.de/forums/
-- GoogleCode Website: http://code.google.com/p/mangadmin/
-- Subversion Repository: http://mangadmin.googlecode.com/svn/
--
-------------------------------------------------------------------------------------------------------------

local MAJOR_VERSION = "MangAdmin-1.0"
local MINOR_VERSION = "$Revision: 1 $"
ROOT_PATH     = "Interface\\AddOns\\MangAdmin\\"

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

--[[local]] MangAdmin  = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceHook-2.1", "FuBarPlugin-2.0", "AceDebug-2.0", "AceEvent-2.0")
--[[local]] Locale     = AceLibrary("AceLocale-2.2"):new("MangAdmin")
--[[local]] FrameLib   = AceLibrary("FrameLib-1.0")
--[[local]] Graph      = AceLibrary("Graph-1.0")
local Tablet     = AceLibrary("Tablet-2.0")

MangAdmin:RegisterDB("MangAdminDb", "MangAdminDbPerChar")
MangAdmin:RegisterDefaults("char", 
  {
    getValueCallHandler = {
      calledGetGuid = false,
      realGuid = nil
    },
    functionQueue = {},
    workaroundValues = {
      flymode = nil
    },
    requests = {
      tpinfo = false,
      ticket = false,
      item = false,
      favitem = false,
      itemset = false,
      spell = false,
      quest = false,
      creature = false,
      object = false,
      tele = false
    },
    nextGridWay = "ahead",
    newTicketQueue = {}
  }
)
MangAdmin:RegisterDefaults("account", 
  {
    language = nil,
    favorites = {
      items = {},
      itemsets = {},
      spells = {},
      quests = {},
      creatures = {},
      objects = {},
      teles = {}
    },
    buffer = {
      tickets = {},
      items = {},
      itemsets = {},
      spells = {},
      quests = {},
      creatures = {},
      objects = {},
      teles = {},
      counter = 0
    },
    tickets = {
      selected = 0,
      count = 0,
      requested = 0,
      playerinfo = {},
      loading = false
    },
    style = {
      transparency = {
        buttons = 1.0,
        frames = 0.7,
        backgrounds = 0.5
      },
      color = {
        buffer = {},
        buttons = {
          r = 33, 
          g = 164, 
          b = 210
        },
        frames = {
          r = 102,
          g = 102,
          b = 102
        },
        backgrounds = {
          r = 0,
          g = 0,
          b = 0
        },
        linkifier = {
          r = 0,
          g = 0,
          b = 150
        }
      }
    }
  }
)

-- Register Translations
Locale:EnableDynamicLocales(true)
--Locale:EnableDebugging()
Locale:RegisterTranslations("enUS", function() return Return_enUS() end)
Locale:RegisterTranslations("deDE", function() return Return_deDE() end)
Locale:RegisterTranslations("frFR", function() return Return_frFR() end)
Locale:RegisterTranslations("itIT", function() return Return_itIT() end)
Locale:RegisterTranslations("fiFI", function() return Return_fiFI() end)
Locale:RegisterTranslations("plPL", function() return Return_plPL() end)
Locale:RegisterTranslations("svSV", function() return Return_svSV() end)
Locale:RegisterTranslations("liLI", function() return Return_liLI() end)
Locale:RegisterTranslations("roRO", function() return Return_roRO() end)
Locale:RegisterTranslations("csCZ", function() return Return_csCZ() end)
Locale:RegisterTranslations("huHU", function() return Return_huHU() end)
Locale:RegisterTranslations("esES", function() return Return_esES() end)
Locale:RegisterTranslations("zhCN", function() return Return_zhCN() end)
Locale:RegisterTranslations("ptPT", function() return Return_ptPT() end)
--Locale:Debug()
--Locale:SetLocale("enUS")

MangAdmin.consoleOpts = {
  type = 'group',
  args = {
    toggle = {
      name = "toggle",
      desc = "Toggles the main window",
      type = 'execute',
      func = function() MangAdmin:OnClick() end
    },
    transparency = {
      name = "transparency",
      desc = "Toggles the transparency (0.5 or 1.0)",
      type = 'execute',
      func = function() MangAdmin:ToggleTransparency() end
    }
  }
}

function MangAdmin:OnInitialize()
  -- initializing MangAdmin
  self:SetLanguage()
  self:CreateFrames()
  self:RegisterChatCommand(Locale["slashcmds"], self.consoleOpts) -- this registers the chat commands
  self:InitButtons() -- this prepares the actions and tooltips of nearly all MangAdmin buttons  
  self:SearchReset()
   -- FuBar plugin config
  MangAdmin.hasNoColor = true
  MangAdmin.hasNoText = false
  MangAdmin.clickableTooltip = true
  MangAdmin.hasIcon = true
  MangAdmin.hideWithoutStandby = true
  MangAdmin:SetIcon(ROOT_PATH.."Textures\\icon.tga")
  -- make MangAdmin frames closable with escape key
  tinsert(UISpecialFrames,"ma_bgframe")
  tinsert(UISpecialFrames,"ma_popupframe")
  -- those all hook the AddMessage method of the chat frames.
  -- They will be redirected to MangAdmin:AddMessage(...)
  for i=1,NUM_CHAT_WINDOWS do
    local cf = getglobal("ChatFrame"..i)
    self:Hook(cf, "AddMessage", true)
  end
  -- initializing Frames, like DropDowns, Sliders, aso
  self:InitLangDropDown()
  self:InitWeatherDropDown()
  self:InitReloadTableDropDown()
  self:InitModifyDropDown()
  self:InitSliders()
  self:InitScrollFrames()
  self:InitTransparencyButton()
  --clear color buffer
  self.db.account.style.color.buffer = {}
  --altering the function setitemref, to make it possible to click links
  MangLinkifier_SetItemRef_Original = SetItemRef
  SetItemRef = MangLinkifier_SetItemRef
end

function MangAdmin:OnEnable()
  self:SetDebugging(true) -- to have debugging through the whole app.    
  -- init guid for callhandler, not implemented yet, comes in next revision
  self.GetGuid()
  self:SearchReset()
  -- register events
  --self:RegisterEvent("ZONE_CHANGED") -- for teleport list update
end

function MangAdmin:OnDisable()
  -- called when the addon is disabled
  self:SearchReset()
end

function MangAdmin:OnClick()
  -- this toggles the MangAdmin frame when clicking on the mini icon
  if IsShiftKeyDown() then
    ReloadUI()
  elseif IsAltKeyDown() then
    self.db.char.newTicketQueue = 0
    MangAdmin:UpdateTooltip()
  elseif ma_bgframe:IsVisible() and not ma_popupframe:IsVisible() then
    FrameLib:HandleGroup("bg", function(frame) frame:Hide() end)
  elseif ma_bgframe:IsVisible() and ma_popupframe:IsVisible() then
    FrameLib:HandleGroup("bg", function(frame) frame:Hide() end)
    FrameLib:HandleGroup("popup", function(frame) frame:Hide() end)
  elseif not ma_bgframe:IsVisible() and ma_popupframe:IsVisible() then
    FrameLib:HandleGroup("bg", function(frame) frame:Show() end)
  else
    FrameLib:HandleGroup("bg", function(frame) frame:Show() end)
  end
end

function MangAdmin:OnTooltipUpdate()
  local tickets = self.db.char.newTicketQueue
  local ticketCount = 0
  table.foreachi(tickets, function() ticketCount = ticketCount + 1 end)
  if ticketCount == 0 then
    local cat = Tablet:AddCategory("columns", 1)
    cat:AddLine("text", Locale["ma_TicketsNoNew"])
    MangAdmin:SetIcon(ROOT_PATH.."Textures\\icon.tga")
  else
    local cat = Tablet:AddCategory(
      "columns", 1,
      "justify", "LEFT",
      "hideBlankLine", true,
      "showWithoutChildren", false,
      "child_textR", 1,
      "child_textG", 1,
      "child_textB", 1
    )
    cat:AddLine(
      "text", string.format(Locale["ma_TicketsNewNumber"], ticketCount),
      "func", function() MangAdmin:ShowTicketTab() end)
    local counter = 0
    local name
    for i, name in ipairs(tickets) do
      counter = counter + 1
      if counter == ticketCount then
        cat:AddLine(
          "text", string.format(Locale["ma_TicketsGoLast"], name),
          "func", function(name) MangAdmin:TelePlayer("gochar", name) end,
          "arg1", name
        )
        cat:AddLine(
          "text", string.format(Locale["ma_TicketsGetLast"], name),
          "func", function(name) MangAdmin:TelePlayer("getchar", name) end,
          "arg1", name
        )
      end
    end
    MangAdmin:SetIcon(ROOT_PATH.."Textures\\icon2.tga")
  end
  Tablet:SetHint(Locale["ma_IconHint"])
end

function MangAdmin:ToggleTabButton(group)
  --this modifies the look of tab buttons when clicked on them 
  FrameLib:HandleGroup("tabbuttons", 
  function(button) 
    if button:GetName() == "ma_tabbutton_"..group then
      getglobal(button:GetName().."_texture"):SetGradientAlpha("vertical", 102, 102, 102, 1, 102, 102, 102, 0.7)
    else
      getglobal(button:GetName().."_texture"):SetGradientAlpha("vertical", 102, 102, 102, 0, 102, 102, 102, 0.7)
    end
  end)
end

function MangAdmin:ToggleContentGroup(group)
  --MangAdmin:LogAction("Toggled navigation point '"..group.."'.")
  self:HideAllGroups()
  FrameLib:HandleGroup(group, function(frame) frame:Show() end)
end

function MangAdmin:InstantGroupToggle(group)
  FrameLib:HandleGroup("bg", function(frame) frame:Show() end)
  MangAdmin:ToggleTabButton(group)
  MangAdmin:ToggleContentGroup(group)
end

function MangAdmin:TogglePopup(value, param)
  -- this toggles the MangAdmin Search Popup frame, toggling deactivated, popup will be overwritten
  --[[if ma_popupframe:IsVisible() then 
    FrameLib:HandleGroup("popup", function(frame) frame:Hide()  end)
  else]]
  if value == "search" then
    FrameLib:HandleGroup("popup", function(frame) frame:Show() end)
    getglobal("ma_ptabbutton_1_texture"):SetGradientAlpha("vertical", 102, 102, 102, 1, 102, 102, 102, 0.7)
    getglobal("ma_ptabbutton_2_texture"):SetGradientAlpha("vertical", 102, 102, 102, 0, 102, 102, 102, 0.7)
    ma_mailscrollframe:Hide()
    ma_maileditbox:Hide()
    ma_var1editbox:Hide()
    ma_var2editbox:Hide()
    ma_var1text:Hide()
    ma_var2text:Hide()
    ma_searchbutton:SetScript("OnClick", function() self:SearchStart(param.type, ma_searcheditbox:GetText()) end)
    ma_searchbutton:SetText(Locale["ma_SearchButton"])
    ma_resetsearchbutton:SetScript("OnClick", function() MangAdmin:SearchReset() end)
    ma_resetsearchbutton:SetText(Locale["ma_ResetButton"])
    ma_resetsearchbutton:Enable()
    ma_ptabbutton_1:SetScript("OnClick", function() MangAdmin:TogglePopup("search", {type = param.type}) end)
    ma_ptabbutton_2:SetScript("OnClick", function() MangAdmin:TogglePopup("favorites", {type = param.type}) end)
    ma_ptabbutton_2:Show()
    ma_selectallbutton:SetScript("OnClick", function() self:Favorites("select", param.type) end)
    ma_deselectallbutton:SetScript("OnClick", function() self:Favorites("deselect", param.type) end)
    ma_modfavsbutton:SetScript("OnClick", function() self:Favorites("add", param.type) end)
    ma_modfavsbutton:SetText("Add selected")
    ma_modfavsbutton:Enable()
    self:SearchReset()
    if param.type == "item" then
      ma_ptabbutton_1:SetText(Locale["ma_ItemButton"])
      ma_var1editbox:Show()
      ma_var1text:Show()
      ma_var1text:SetText(Locale["ma_ItemVar1Button"])
    elseif param.type == "itemset" then
      ma_ptabbutton_1:SetText(Locale["ma_ItemSetButton"])
    elseif param.type == "spell" then
      ma_ptabbutton_1:SetText(Locale["ma_SpellButton"])
    elseif param.type == "quest" then
      ma_ptabbutton_1:SetText(Locale["ma_QuestButton"])
    elseif param.type == "creature" then
      ma_ptabbutton_1:SetText(Locale["ma_CreatureButton"])
    elseif param.type == "object" then
      ma_ptabbutton_1:SetText(Locale["ma_ObjectButton"])
      ma_var1editbox:Show()
      ma_var2editbox:Show()
      ma_var1text:Show()
      ma_var2text:Show()
      ma_var1text:SetText(Locale["ma_ObjectVar1Button"])
      ma_var2text:SetText(Locale["ma_ObjectVar2Button"])
    elseif param.type == "tele" then
      ma_ptabbutton_1:SetText(Locale["ma_TeleSearchButton"])
    elseif param.type == "ticket" then
      ma_modfavsbutton:Hide()
      ma_selectallbutton:Hide()
      ma_deselectallbutton:Hide()
      ma_ptabbutton_2:Hide()
      ma_lookupresulttext:SetText(Locale["ma_TicketCount"].."0")
      ma_ptabbutton_1:SetText(Locale["ma_LoadTicketsButton"])
      ma_searchbutton:SetText(Locale["ma_Reload"])
      ma_searchbutton:SetScript("OnClick", function() self:LoadTickets() end)
      ma_resetsearchbutton:SetText(Locale["ma_LoadMore"])
      ma_resetsearchbutton:SetScript("OnClick", function() MangAdmin.db.account.tickets.loading = true; self:LoadTickets(MangAdmin.db.account.tickets.count) end)
    end
  elseif value == "favorites" then
    self:SearchReset()
    getglobal("ma_ptabbutton_2_texture"):SetGradientAlpha("vertical", 102, 102, 102, 1, 102, 102, 102, 0.7)
    getglobal("ma_ptabbutton_1_texture"):SetGradientAlpha("vertical", 102, 102, 102, 0, 102, 102, 102, 0.7)
    ma_modfavsbutton:SetScript("OnClick", function() self:Favorites("remove", param.type) end)
    ma_modfavsbutton:SetText("Remove selected")
    ma_modfavsbutton:Enable()
    self:Favorites("show", param.type)
  elseif value == "mail" then
    getglobal("ma_ptabbutton_1_texture"):SetGradientAlpha("vertical", 102, 102, 102, 1, 102, 102, 102, 0.7)
    getglobal("ma_ptabbutton_2_texture"):SetGradientAlpha("vertical", 102, 102, 102, 0, 102, 102, 102, 0.7)
    FrameLib:HandleGroup("popup", function(frame) frame:Show() end)
    for n = 1,7 do
      getglobal("ma_PopupScrollBarEntry"..n):Hide()
    end
    ma_lookupresulttext:SetText("Bytes left: 246")
    ma_lookupresulttext:Show()
    ma_resetsearchbutton:Hide()
    ma_PopupScrollBar:Hide()
    ma_searcheditbox:SetScript("OnTextChanged", function() MangAdmin:UpdateMailBytesLeft() end)
    ma_var1editbox:SetScript("OnTextChanged", function() MangAdmin:UpdateMailBytesLeft() end)
    ma_modfavsbutton:Hide()
    ma_selectallbutton:Hide()
    ma_deselectallbutton:Hide()
    if param.recipient then
      ma_searcheditbox:SetText(param.recipient)
    else
      ma_searcheditbox:SetText(Locale["ma_MailRecipient"])
    end
    ma_ptabbutton_1:SetText(Locale["ma_Mail"])
    ma_ptabbutton_2:Hide()
    ma_searchbutton:SetText(Locale["ma_Send"])
    ma_searchbutton:SetScript("OnClick", function() self:SendMail(ma_searcheditbox:GetText(), ma_var1editbox:GetText(), ma_maileditbox:GetText()) end)
    ma_var2editbox:Hide()
    ma_var2text:Hide()
    if param.subject then
      ma_var1editbox:SetText(param.subject)
    else
      ma_var1editbox:SetText(Locale["ma_MailSubject"])
    end
    ma_var1editbox:Show()
    ma_var1text:SetText(Locale["ma_MailSubject"])
    ma_var1text:Show()
    ma_maileditbox:SetText(Locale["ma_MailYourMsg"])
  end
end

function MangAdmin:HideAllGroups()
  FrameLib:HandleGroup("main", function(frame) frame:Hide() end)
  FrameLib:HandleGroup("char", function(frame) frame:Hide() end)
  FrameLib:HandleGroup("tele", function(frame) frame:Hide() end)
  FrameLib:HandleGroup("ticket", function(frame) frame:Hide() end)
  FrameLib:HandleGroup("server", function(frame) frame:Hide() end)
  FrameLib:HandleGroup("misc", function(frame) frame:Hide() end)
  FrameLib:HandleGroup("log", function(frame) frame:Hide() end)
end

function MangAdmin:AddMessage(frame, text, r, g, b, id)
  -- frame is the object that was hooked (one of the ChatFrames)  
  local catchedSth = false

  if id == 11 then --make sure that the message comes from the server, message id = 11, I don't know why exactly this id but i think it's right
    -- hook all uint32 .getvalue requests
    for guid, field, value in string.gmatch(text, "The uint32 value of (%w+) in (%w+) is: (%w+)") do
      catchedSth = true
      output = self:GetValueCallHandler(guid, field, value)
    end
    
    -- hook .gps for gridnavigation
    for x, y in string.gmatch(text, "X: (.*) Y: (.*) Z") do
      for k,v in pairs(self.db.char.functionQueue) do
        if v == "GridNavigate" then
          self:GridNavigate(string.format("%.1f", x), string.format("%.1f", y), nil)
          table.remove(self.db.char.functionQueue, k)
          break
        end
      end
    end
    
    -- hook all item lookups
    for id, name in string.gmatch(text, "|cffffffff|Hitem:(%d+):0:0:0:0:0:0:0|h%[(.-)%]|h|r") do
      if self.db.char.requests.item then
        table.insert(self.db.account.buffer.items, {itId = id, itName = name, checked = false})
        -- for item info in cache
        local itemName, itemLink, itemQuality, _, _, _, _, _, _ = GetItemInfo(id);
        if not itemName then
          GameTooltip:SetOwner(ma_popupframe, "ANCHOR_RIGHT")
          GameTooltip:SetHyperlink("item:"..id..":0:0:0:0:0:0:0")
          GameTooltip:Hide()
        end
        PopupScrollUpdate()
        catchedSth = true
        output = false  
      end
    end
    
    -- hook all itemset lookups
    for id, name in string.gmatch(text, "|cffffffff|Hitemset:(%d+)|h%[(.-)%]|h|r") do
      if self.db.char.requests.itemset then
        table.insert(self.db.account.buffer.itemsets, {isId = id, isName = name, checked = false})
        PopupScrollUpdate()
        catchedSth = true
        output = false
      end
    end
    
    -- hook all spell lookups
    for id, name in string.gmatch(text, "|cffffffff|Hspell:(%d+)|h%[(.-)%]|h|r") do
      if self.db.char.requests.spell then
        table.insert(self.db.account.buffer.spells, {spId = id, spName = name, checked = false})
        PopupScrollUpdate()
        catchedSth = true
        output = false
      end
    end
    
    -- hook all creature lookups
    for id, name in string.gmatch(text, "|cffffffff|Hcreature_entry:(%d+)|h%[(.-)%]|h|r") do
      if self.db.char.requests.creature then
        table.insert(self.db.account.buffer.creatures, {crId = id, crName = name, checked = false})
        PopupScrollUpdate()
        catchedSth = true
        output = false
      end
    end
    
    -- hook all object lookups
    for id, name in string.gmatch(text, "|cffffffff|Hgameobject_entry:(%d+)|h%[(.-)%]|h|r") do
      if self.db.char.requests.object then
        table.insert(self.db.account.buffer.objects, {objId = id, objName = name, checked = false})
        PopupScrollUpdate()
        catchedSth = true
        output = false
      end
    end
    
    -- hook all quest lookups
    for id, name in string.gmatch(text, "|cffffffff|Hquest:(%d+)|h%[(.-)%]|h|r") do
      if self.db.char.requests.quest then
        table.insert(self.db.account.buffer.quests, {qsId = id, qsName = name, checked = false})
        PopupScrollUpdate()
        catchedSth = true
        output = false
      end
    end
 
    -- hook all tele lookups
    for name in string.gmatch(text, "h%[(.-)%]") do
      if self.db.char.requests.tele then
        table.insert(self.db.account.buffer.teles, {tName = name, checked = false})
        PopupScrollUpdate()
        catchedSth = true
        output = false
      end
    end
   
    -- hook all new tickets
    for name in string.gmatch(text, "New ticket from (.*)") do
      -- now need function for: Got new ticket
      table.insert(self.db.char.newTicketQueue, name)
      self:SetIcon(ROOT_PATH.."Textures\\icon2.tga")
      PlaySoundFile(ROOT_PATH.."Sound\\mail.wav")
      self:LogAction("Got new ticket from: "..name)
    end
    
    -- hook ticket count
    for count, status in string.gmatch(text, "Tickets count: (%d+) show new tickets: (%w+)\n") do
      if self.db.char.requests.ticket then
        catchedSth = true
        output = false
        self:LoadTickets(count)
      end
    end
    
    -- get tickets
    for char, category, message in string.gmatch(text, "Ticket of (.*) %(Category: (%d+)%):\n(.*)\n") do
      if self.db.char.requests.ticket then
        local ticketCount = 0
        table.foreachi(MangAdmin.db.account.buffer.tickets, function() ticketCount = ticketCount + 1 end)
        local number = self.db.account.tickets.count - ticketCount
        table.insert(self.db.account.buffer.tickets, {tNumber = number, tChar = char, tCat = category, tMsg = message})
        PopupScrollUpdate()
        self:RequestTickets()
        catchedSth = true
        output = false
      end
    end
    
    -- hook player account info
    for status, char, guid, account, id, level, ip in string.gmatch(text, "Player(.*) (.*) %(guid: (%d+)%) Account: (.*) %(id: (%d+)%) GMLevel: (%d+) Last IP: (.*)") do
      if self.db.char.requests.tpinfo then
        if status == "" then
          status = Locale["ma_Online"]
        else
          status = Locale["ma_Offline"]
        end
        --table.insert(self.db.account.buffer.tpinfo, {char = {pStatus = status, pGuid = guid, pAcc = account, pId = id, pLevel = level, pIp = ip}})
        ma_tpinfo_text:SetText(ma_tpinfo_text:GetText()..Locale["ma_TicketsInfoPlayer"]..char.." ("..guid..")\n"..Locale["ma_TicketsInfoStatus"]..status.."\n"..Locale["ma_TicketsInfoAccount"]..account.." ("..id..")\n"..Locale["ma_TicketsInfoAccLevel"]..level.."\n"..Locale["ma_TicketsInfoLastIP"]..ip)
        catchedSth = true
        output = false
      end
    end
    
    -- hook player account info
    for played, level, money in string.gmatch(text, "Played time: (.*) Level: (%d+) Money: (.*)") do
      if self.db.char.requests.tpinfo then
        ma_tpinfo_text:SetText(ma_tpinfo_text:GetText().."\n"..Locale["ma_TicketsInfoPlayedTime"]..played.."\n"..Locale["ma_TicketsInfoLevel"]..level.."\n"..Locale["ma_TicketsInfoMoney"]..money)
        catchedSth = true
        output = false
        self.db.char.requests.tpinfo = false
      end
    end
    
    -- Check for possible UrlModification
    if catchedSth then
      if output then
        output = MangLinkifier_Decompose(text)
      end
    else
      catchedSth = true
      output = MangLinkifier_Decompose(text)
    end
  else
    -- message is not from server
  end
  
  if not catchedSth then
    -- output
    self.hooks[frame].AddMessage(frame, text, r, g, b, id)
  else
    if output == false then
      -- so far nothing to do here
      -- don't output anything
    elseif output == true then
      self.hooks[frame].AddMessage(frame, text, r, g, b, id)
    else
      -- output
      self.hooks[frame].AddMessage(frame, output, r, g, b, id)
    end
  end
end

function MangAdmin:GetValueCallHandler(guid, field, value)
  -- checks for specific actions and calls functions by checking the function-order
  local called = self.db.char.getValueCallHandler.calledGetGuid
  local realGuid = self.db.char.getValueCallHandler.realGuid
  -- case checking
  if guid == value and field == "0" and not called then
    -- getting GUID and setting db variables and logged text
    self.db.char.getValueCallHandler.calledGetGuid = true
    self.db.char.getValueCallHandler.realGuid = value
    ma_loggedtext:SetText(Locale["logged"]..Locale["charguid"]..guid)
    return false    
  elseif guid == realGuid then
    return true
  else
    MangAdmin:LogAction("DEBUG: Getvalues are: GUID = "..guid.."; field = "..field.."; value = "..value..";")
    return true
  end
end

function MangAdmin:LogAction(msg)
  ma_logframe:AddMessage("|cFF00FF00["..date("%H:%M:%S").."]|r "..msg, 1.0, 1.0, 0.0)
end

function MangAdmin:ChatMsg(msg)
  if not type then local type = "say" end
  SendChatMessage(msg, type, nil, nil)
end

function MangAdmin:GetGuid()
  local called = MangAdmin.db.char.getValueCallHandler.calledGetGuid
  local realGuid = MangAdmin.db.char.getValueCallHandler.realGuid
  if not called then
    if MangAdmin:Selection("self") or MangAdmin:Selection("none") then
      MangAdmin:ChatMsg(".getvalue 0")
    end
  else
    ma_loggedtext:SetText(Locale["logged"]..Locale["charguid"]..realGuid)
  end
end

function MangAdmin:Selection(selection)
  if selection == "player" then
    if UnitIsPlayer("target") then
      return true
    end
  elseif selection == "self" then
    if UnitIsUnit("target", "player") then
      return true
    end
  elseif selection == "none" then
    if not UnitName("target") then
      return true
    end
  else
    error("Argument 'selection' can be 'player',''self', or 'none'!")
    return false
  end
end

function MangAdmin:AndBit(value, test) 
  return mod(value, test*2) >= test 
end


--=================================--
--MangAdmin Commands functions--
--=================================--
function MangAdmin:SetLanguage()
  if self.db.account.language then
    Locale:SetLocale(self.db.account.language)
  else
    self.db.account.language = Locale:GetLocale()
  end
end

function MangAdmin:ChangeLanguage(locale)
  self.db.account.language = locale
  ReloadUI()
end

function MangAdmin:ToggleGMMode(value)
  MangAdmin:ChatMsg(".gm "..value)
  MangAdmin:LogAction("Turned GM-mode to "..value..".")
end

function MangAdmin:ToggleFlyMode(value)
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    MangAdmin:ChatMsg(".flymode "..value)
    MangAdmin:LogAction("Turned Fly-mode "..value.." for "..player..".")
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:ToggleHoverMode(value)
  MangAdmin:ChatMsg(".hover "..value)
  local status
  if value == 1 then
    status = "on"
  else
    status = "off"
  end
  MangAdmin:LogAction("Turned Hover-mode "..status..".")
end

function MangAdmin:ToggleWhisper(value)
  MangAdmin:ChatMsg(".whispers "..value)
  MangAdmin:LogAction("Turned accepting whispers to "..value..".")
end

function MangAdmin:ToggleVisible(value)
  MangAdmin:ChatMsg(".visible "..value)
  if value == "on" then
    MangAdmin:LogAction("Turned you visible.")
  else
    MangAdmin:LogAction("Turned you invisible.")
  end  
end

function MangAdmin:ToggleTaxicheat(value)
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    MangAdmin:ChatMsg(".taxicheat "..value)
    if value == 1 then
      MangAdmin:LogAction("Activated taxicheat to "..player..".")
    else
      MangAdmin:LogAction("Disabled taxicheat to "..player..".")
    end
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:SetSpeed()
  local value = string.format("%.1f", ma_speedslider:GetValue())
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    --self:ChatMsg(".modify speed "..value)
    --self:ChatMsg(".modify fly "..value)
    --self:ChatMsg(".modify swim "..value)
    self:ChatMsg(".modify aspeed "..value)
    self:LogAction("Set speed of "..player.." to "..value..".")
  else
    self:Print(Locale["selectionerror1"])
    ma_speedslider:SetValue(1)
  end
end

function MangAdmin:SetScale()
  local value = string.format("%.1f", ma_scaleslider:GetValue())
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    self:ChatMsg(".modify scale "..value)
    self:LogAction("Set scale of "..player.." to "..value..".")
  else
    self:Print(Locale["selectionerror1"])
    ma_scaleslider:SetValue(1)
  end
end

function MangAdmin:LearnSpell(value, state)
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    local class = UnitClass("target") or UnitClass("player")
    local command = ".learn"
    local logcmd = "Learned"
    if state == "RightButton" then
      command = ".unlearn"
      logcmd = "Unlearned"
    end
    if type(value) == "string" then
      if value == "all" then
        self:ChatMsg(command.." all")
        self:LogAction(logcmd.." all spells to "..player..".")
      elseif value == "all_crafts" then
        self:ChatMsg(command.." all_crafts")
        self:LogAction(logcmd.." all professions and recipes to "..player..".")
      elseif value == "all_gm" then
        self:ChatMsg(command.." all_gm")
        self:LogAction(logcmd.." all default spells for Game Masters to "..player..".")
      elseif value == "all_lang" then
        self:ChatMsg(command.." all_lang")
        self:LogAction(logcmd.." all languages to "..player..".")
      elseif value == "all_myclass" then
        self:ChatMsg(command.." all_myclass")
        self:LogAction(logcmd.." all spells available to the "..class.."-class to "..player..".")
      else
        self:ChatMsg(command.." "..value)
        self:LogAction(logcmd.." spell "..value.." to "..player..".")
      end
    elseif type(value) == "table" then
      for k,v in ipairs(value) do
        self:ChatMsg(command.." "..v)
        self:LogAction(logcmd.." spell "..v.." to "..player..".")
      end
    elseif type(value) == "number" then
      self:ChatMsg(command.." "..value)
      self:LogAction(logcmd.." spell "..value.." to "..player..".")
    end
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:Quest(value, state)
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    local class = UnitClass("target") or UnitClass("player")
    local command = ".addquest"
    local logcmd = "Added"
    local logcmd2 = "to"
    if state == "RightButton" then
      command = ".removequest"
      logcmd = "Removed"
      logcmd2 = "from"
    end
    if type(value) == "string" then
      self:ChatMsg(command.." "..value)
      self:LogAction(logcmd.." quest with id "..value.." "..logcmd2.." "..player..".")
    elseif type(value) == "table" then
      for k,v in ipairs(value) do
        self:ChatMsg(command.." "..v)
        self:LogAction(logcmd.." quest with id "..value.." "..logcmd2.." "..player..".")
      end
    elseif type(value) == "number" then
      self:ChatMsg(command.." "..value)
      self:LogAction(logcmd.." quest with id "..value.." "..logcmd2.." "..player..".")
    end
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:Creature(value, state)
    local command = ".addspw"
    local logcmd = "Spawned"
    if state == "RightButton" then
      command = ".listcreature"
      logcmd = "Listed"
    end
    if type(value) == "string" then
      self:ChatMsg(command.." "..value)
      self:LogAction(logcmd.." creature with id "..value..".")
    elseif type(value) == "table" then
      for k,v in ipairs(value) do
        self:ChatMsg(command.." "..v)
        self:LogAction(logcmd.." creature with id "..value..".")
      end
    elseif type(value) == "number" then
      self:ChatMsg(command.." "..value)
      self:LogAction(logcmd.." creature with id "..value..".")
    end

end

function MangAdmin:AddItem(value, state)
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    local amount = ma_var1editbox:GetText()
    if state == "RightButton" then
      self:ChatMsg(".listitem "..value)
      self:LogAction("Listed item with id "..value..".")
    else
      if amount == "" then
        self:ChatMsg(".additem "..value)
        self:LogAction("Added item with id "..value.." to "..player..".")
      else
        self:ChatMsg(".additem "..value.." "..amount)
        self:LogAction("Added "..amount.." items with id "..value.." to "..player..".")
      end
    end
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:AddItemSet(value)
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    self:ChatMsg(".additemset "..value)
    self:LogAction("Added itemset with id "..value.." to "..player..".")
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:AddObject(value, state)
  local loot = ma_var1editbox:GetText()
  local _time = ma_var2editbox:GetText()
  if state == "RightButton" then
    self:ChatMsg(".addgo "..value.." "..value)
    self:LogAction("Added object id "..value.." with loot template.")
  else
    if loot ~= "" and _time == "" then
      self:ChatMsg(".addgo "..value.. " "..loot)
      self:LogAction("Added object id "..value.." with loot "..loot..".")
    elseif loot ~= "" and _time ~= "" then
      self:ChatMsg(".addgo "..value.. " "..loot.." ".._time)
      self:LogAction("Added object id "..value.." with loot "..loot.." and spawntime ".._time..".")
    else
      self:ChatMsg(".addgo "..value)
      self:LogAction("Added object id "..value..".")
    end
  end
end

function MangAdmin:TelePlayer(value, player)
  if value == "gochar" then
    self:ChatMsg(".goname "..player)
    self:LogAction("Teleported to player "..player..".")
  elseif value == "getchar" then
    self:ChatMsg(".namego "..player)
    self:LogAction("Summoned player "..player..".")
  end
end

function MangAdmin:KickPlayer()
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    self:ChatMsg(".kick")
    self:LogAction("Kicked player "..player..".")
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:RevivePlayer()
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    self:ChatMsg(".revive")
    self:LogAction("Revived player "..player..".")
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:DismountPlayer()
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    self:ChatMsg(".dismount")
    self:LogAction("Dismounted player "..player..".")
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:SavePlayer()
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    self:ChatMsg(".save")
    self:LogAction("Saved player "..player..".")
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:KillSomething()
  local target = UnitName("target") or UnitName("player")
  self:ChatMsg(".die")
  self:LogAction("Killed "..target..".")
end

function MangAdmin:Modify(case, value) 
  -- to dxers: I think it's better to do switch case with names (so other devs can see quicker what it is for) 
  -- and level down is possible: pass negative amount with .levelup
  if self:Selection("player") or self:Selection("self") or self:Selection("none") then
    local player = UnitName("target") or UnitName("player")
    if case == "money" then
      self:ChatMsg(".modify money "..value)
      self:LogAction("Give player "..player.." "..value.." copper).")
    elseif case == "levelup" then
      self:ChatMsg(".levelup "..value)
      self:LogAction("Leveled up player "..player.." by "..value.." levels.")
    elseif case == "leveldown" then
      self:ChatMsg(".levelup "..value*(-1))
      self:LogAction("Leveled down player "..player.." by "..value.." levels.")
    elseif case == "enery" then
      self:ChatMsg(".modify energy "..value)
      self:LogAction("Modified energy for "..player.." to "..value.." energy.")
    elseif case == "rage" then
      self:ChatMsg(".modify rage "..value)
      self:LogAction("Modified rage for "..player.." to "..value.." rage.")
    elseif case == "health" then
      self:ChatMsg(".modify hp "..value)
      self:LogAction("Modified hp for "..player.." to "..value.." healthpoints")
    elseif case == "mana" then
      self:ChatMsg(".modify mana "..value)
      self:LogAction("Modified mana for "..player.." to "..value.." mana")
    end
  else
    self:Print(Locale["selectionerror1"])
  end
end

function MangAdmin:GridNavigate(x, y)
  local way = self.db.char.nextGridWay
  if not x and not y then
    table.insert(self.db.char.functionQueue, "GridNavigate")
    self:ChatMsg(".gps")
  else
    if pcall(function() return ma_gridnavieditbox:GetText() + 10 end) then
      local step = ma_gridnavieditbox:GetText()
      local newy
      local newx
      if way == "back" then
        newy = y - step
        newx = x
      elseif way == "right" then
        newy = y
        newx = x + step
      elseif way == "left" then
        newy = y
        newx = x - step
      else
        newy = y + step
        newx = x
      end
      self:ChatMsg(".goxy "..newx.." "..newy)
      self:LogAction("Navigated to grid position: X: "..newx.." Y: "..newy)
    else
      self:Print("Value must be a number!")
    end
  end
end

function MangAdmin:CreateGuild(leader, name)
  self:ChatMsg(".createguild "..leader.." "..name)
  self:LogAction("Created guild '"..name.."' with leader "..leader..".")
end

function MangAdmin:Screenshot()
  UIParent:Hide()
  Screenshot()
  UIParent:Show()
end

function MangAdmin:Announce(value)
  self:ChatMsg(".announce "..value)
  self:LogAction("Announced message: "..value)
end

function MangAdmin:Shutdown(value)
  if value == "" then
    self:ChatMsg(".shutdown 0")
    self:LogAction("Shut down server instantly.")
  else
    self:ChatMsg(".shutdown "..value)
    self:LogAction("Shut down server in "..value.." seconds.")
  end
end

function MangAdmin:SendMail(recipient, subject, body)
  self:ChatMsg(".sendm "..recipient.." "..subject.." "..body)
  self:LogAction("Sent a mail to "..recipient..". Subject was: "..subject)
end

function MangAdmin:ReloadTable(tablename)
  if not (tablename == "") then
    self:ChatMsg(".reload "..tablename)
    if tablename == "all" then
      self:LogAction("Reloaded all reloadable MaNGOS database tables.")
    else
      self:LogAction("Reloaded the table "..tablename..".")
    end
  end
end

function MangAdmin:ReloadScripts()
  self:ChatMsg(".loadscripts")
  self:LogAction("(Re-)Loaded scripts.")
end

function MangAdmin:ChangeWeather(status)
  if not (status == "") then
    self:ChatMsg(".wchange "..status)
    self:LogAction(".wchange "..status)
    self:LogAction("Changed weather.")
  end
end

function MangAdmin:UpdateMailBytesLeft()
  local bleft = 246 - strlen(ma_searcheditbox:GetText()) - strlen(ma_var1editbox:GetText()) - strlen(ma_maileditbox:GetText())
  if bleft >= 0 then
    ma_lookupresulttext:SetText("Bytes left: |cff00ff00"..bleft.."|r")
  else
    ma_lookupresulttext:SetText("Bytes left: |cffff0000"..bleft.."|r")
  end
end

function MangAdmin:Ticket(value)
  local ticket = self.db.account.tickets.selected
  if value == "delete" then
    self:ChatMsg(".delticket "..ticket["tNumber"])
    self:LogAction("Deleted ticket with number: "..ticket["tNumber"])
    self:ShowTicketTab()
    self:LoadTickets()
  elseif value == "gochar" then
    self:ChatMsg(".goname "..ticket["tChar"])
  elseif value == "getchar" then
    self:ChatMsg(".namego "..ticket["tChar"])
  elseif value == "answer" then
    self:TogglePopup("mail", {recipient = ticket["tChar"], subject = "Ticket("..ticket["tCat"]..")", body = ticket["tMsg"]})
  elseif value == "whisper" then
    ChatFrameEditBox:Show()
    ChatFrameEditBox:Insert("/w "..ticket["tChar"]);
  end
end

function MangAdmin:ToggleTickets(value)
  MangAdmin:ChatMsg(".ticket "..value)
  MangAdmin:LogAction("Turned receiving new tickets "..value..".")
end

function MangAdmin:ShowTicketTab()
  ma_tpinfo_text:SetText(Locale["ma_TicketsNoInfo"])
  ma_ticketeditbox:SetText(Locale["ma_TicketsNotLoaded"])
  ma_deleteticketbutton:Disable()
  ma_answerticketbutton:Disable()
  ma_getcharticketbutton:Disable()
  ma_gocharticketbutton:Disable()
  ma_whisperticketbutton:Disable()
  MangAdmin:InstantGroupToggle("ticket")
end

function MangAdmin:LoadTickets(number)
  self.db.char.newTicketQueue = {}
  self.db.account.tickets.requested = 0
  if number then
    if tonumber(number) > 0 then
      self.db.account.tickets.count = tonumber(number)
      if self.db.char.requests.ticket then
        self:LogAction("Load of tickets requested. Found "..number.." tickets!")
        self:RequestTickets()
        self:SetIcon(ROOT_PATH.."Textures\\icon.tga")
        ma_resetsearchbutton:Enable()
      end
    else
      ma_resetsearchbutton:Disable()
      self:NoResults("ticket")
    end
  else
    self.db.char.requests.ticket = true
    self.db.account.tickets.count = 0
    self.db.account.buffer.tickets = {}
    self:ChatMsg(".ticket")
    self:LogAction("Requesting ticket number!")
  end
end

function MangAdmin:RequestTickets()
  self.db.char.requests.ticket = true
  local count = self.db.account.tickets.count
  local ticketCount = 0
  table.foreachi(MangAdmin.db.account.buffer.tickets, function() ticketCount = ticketCount + 1 end)
  ma_lookupresulttext:SetText(Locale["ma_TicketCount"]..count)
  local tnumber = count - ticketCount
  if tnumber == 0 then
    self:LogAction("Loaded all available tickets! No more to load...")
    ma_resetsearchbutton:Disable()
    --self.db.char.requests.ticket = false -- BUG check in next rev: while MA is activated you won't be able to request tickets in chat!!
  elseif self.db.account.tickets.requested < 7 then
    self:ChatMsg(".ticket "..tnumber)
    MangAdmin.db.account.tickets.requested = MangAdmin.db.account.tickets.requested + 1;
    self:LogAction("Loading ticket "..tnumber.."...")
  end
end

function MangAdmin:Favorites(value, searchtype)
  if value == "add" then
    if searchtype == "item" then
      table.foreachi(self.db.account.buffer.items, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.items, {itId = v["itId"], itName = v["itName"], checked = false}) end end)
    elseif searchtype == "itemset" then
      table.foreachi(self.db.account.buffer.itemsets, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.itemsets, {isId = v["isId"], isName = v["isName"], checked = false}) end end)
    elseif searchtype == "spell" then
      table.foreachi(self.db.account.buffer.spells, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.spells, {spId = v["spId"], spName = v["spName"], checked = false}) end end)
    elseif searchtype == "quest" then
      table.foreachi(self.db.account.buffer.quests, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.quests, {qsId = v["qsId"], qsName = v["qsName"], checked = false}) end end)
    elseif searchtype == "creature" then
      table.foreachi(self.db.account.buffer.creatures, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.creatures, {crId = v["crId"], crName = v["crName"], checked = false}) end end)
    elseif searchtype == "object" then
      table.foreachi(self.db.account.buffer.objects, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.objects, {objId = v["objId"], objName = v["objName"], checked = false}) end end)
    elseif searchtype == "tele" then
      table.foreachi(self.db.account.buffer.teles, function(k,v) if v["checked"] then table.insert(self.db.account.favorites.teles, {tName = v["tName"], checked = false}) end end)
    end
    self:LogAction("Added some "..searchtype.."s to the favorites.")
  elseif value == "remove" then
    if searchtype == "item" then
      for k,v in pairs(self.db.account.favorites.items) do
        if v["checked"] then table.remove(self.db.account.favorites.items, k) end 
      end
    elseif searchtype == "itemset" then
      for k,v in pairs(self.db.account.favorites.itemsets) do
        if v["checked"] then table.remove(self.db.account.favorites.itemsets, k) end 
      end
    elseif searchtype == "spell" then
      for k,v in pairs(self.db.account.favorites.spells) do
        if v["checked"] then table.remove(self.db.account.favorites.spells, k) end 
      end
    elseif searchtype == "quest" then
      for k,v in pairs(self.db.account.favorites.quests) do
        if v["checked"] then table.remove(self.db.account.favorites.quests, k) end 
      end
    elseif searchtype == "creature" then
      for k,v in pairs(self.db.account.favorites.creatures) do
        if v["checked"] then table.remove(self.db.account.favorites.creatures, k) end 
      end
    elseif searchtype == "object" then
      for k,v in pairs(self.db.account.favorites.objects) do
        if v["checked"] then table.remove(self.db.account.favorites.objects, k) end 
      end
    elseif searchtype == "tele" then
      for k,v in pairs(self.db.account.favorites.teles) do
        if v["checked"] then table.remove(self.db.account.favorites.teles, k) end 
      end
    end
    self:LogAction("Removed some favorited "..searchtype.."s from the list.")
    PopupScrollUpdate()
  elseif value == "show" then
    if searchtype == "item" then
      self.db.char.requests.favitem = true
    elseif searchtype == "itemset" then
      self.db.char.requests.favitemset = true
    elseif searchtype == "spell" then
      self.db.char.requests.favspell = true
    elseif searchtype == "quest" then
      self.db.char.requests.favquest = true
    elseif searchtype == "creature" then
      self.db.char.requests.favcreature = true
    elseif searchtype == "object" then
      self.db.char.requests.favobject = true
    elseif searchtype == "tele" then
      self.db.char.requests.favtele = true
    end
    PopupScrollUpdate()
  elseif value == "select" or value == "deselect" then
    local selected = true
    if value == "deselect" then
      selected = false
    end
    if searchtype == "item" then
      if MangAdmin.db.char.requests.item then
        table.foreachi(self.db.account.buffer.items, function(k,v) self.db.account.buffer.items[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favitem then
        table.foreachi(self.db.account.favorites.items, function(k,v) self.db.account.favorites.items[k].checked = selected end)
      end
    elseif searchtype == "itemset" then
      if MangAdmin.db.char.requests.itemset then
        table.foreachi(self.db.account.buffer.itemsets, function(k,v) self.db.account.buffer.itemsets[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favitemset then
        table.foreachi(self.db.account.favorites.itemsets, function(k,v) self.db.account.favorites.itemsets[k].checked = selected end)
      end
    elseif searchtype == "spell" then
      if MangAdmin.db.char.requests.spell then
        table.foreachi(self.db.account.buffer.spells, function(k,v) self.db.account.buffer.spells[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favspell then
        table.foreachi(self.db.account.favorites.spells, function(k,v) self.db.account.favorites.spells[k].checked = selected end)
      end
    elseif searchtype == "quest" then
      if MangAdmin.db.char.requests.quest then
        table.foreachi(self.db.account.buffer.quests, function(k,v) self.db.account.buffer.quests[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favquest then
        table.foreachi(self.db.account.favorites.quests, function(k,v) self.db.account.favorites.quests[k].checked = selected end)
      end
    elseif searchtype == "creature" then
      if MangAdmin.db.char.requests.creature then
        table.foreachi(self.db.account.buffer.creatures, function(k,v) self.db.account.buffer.creatures[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favcreature then
        table.foreachi(self.db.account.favorites.creatures, function(k,v) self.db.account.favorites.creatures[k].checked = selected end)
      end
    elseif searchtype == "object" then
      if MangAdmin.db.char.requests.object then
        table.foreachi(self.db.account.buffer.objects, function(k,v) self.db.account.buffer.objects[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favobject then
        table.foreachi(self.db.account.favorites.objects, function(k,v) self.db.account.favorites.objects[k].checked = selected end)
      end
    elseif searchtype == "tele" then
      if MangAdmin.db.char.requests.tele then
        table.foreachi(self.db.account.buffer.teles, function(k,v) self.db.account.buffer.teles[k].checked = selected end)
      elseif MangAdmin.db.char.requests.favtele then
        table.foreachi(self.db.account.favorites.teles, function(k,v) self.db.account.favorites.teles[k].checked = selected end)
      end
    end
    PopupScrollUpdate()
  end
end

function MangAdmin:SearchStart(var, value)
  if var == "item" then
    self.db.char.requests.item = true
    self.db.account.buffer.items = {}
    self:ChatMsg(".lookup item "..value)
  elseif var == "itemset" then
    self.db.char.requests.itemset = true
    self.db.account.buffer.itemsets = {}
    self:ChatMsg(".lookup itemset "..value)
  elseif var == "spell" then
    self.db.char.requests.spell = true
    self.db.account.buffer.spells = {}
    self:ChatMsg(".lookup spell "..value)
  elseif var == "quest" then
    self.db.char.requests.quest = true
    self.db.account.buffer.quests = {}
    self:ChatMsg(".lookup quest "..value)
  elseif var == "creature" then
    self.db.char.requests.creature = true
    self.db.account.buffer.creatures = {}
    self:ChatMsg(".lookup creature "..value)
  elseif var == "object" then
    self.db.char.requests.object = true
    self.db.account.buffer.objects = {}
    self:ChatMsg(".lookup object "..value)
  elseif var == "tele" then
    self.db.char.requests.tele = true
    self.db.account.buffer.teles = {}
    self:ChatMsg(".lookup tele "..value)
  end
  self.db.account.buffer.counter = 0
  self:LogAction("Searching for "..var.."s with the keyword '"..value.."'.")
end

function MangAdmin:SearchReset()
  ma_searcheditbox:SetScript("OnTextChanged", function() end)
  ma_var1editbox:SetScript("OnTextChanged", function() end)
  ma_searcheditbox:SetText("")
  ma_var1editbox:SetText("")
  ma_var2editbox:SetText("")
  ma_lookupresulttext:SetText(Locale["searchResults"].."0")
  self.db.char.requests.item = false
  self.db.char.requests.favitem = false
  self.db.char.requests.itemset = false
  self.db.char.requests.favitemset = false
  self.db.char.requests.spell = false
  self.db.char.requests.favspell = false
  self.db.char.requests.quest = false
  self.db.char.requests.favquest = false
  self.db.char.requests.creature = false
  self.db.char.requests.favcreature = false
  self.db.char.requests.object = false
  self.db.char.requests.favobject = false
  self.db.char.requests.tele = false
  self.db.char.requests.favtele = false
  self.db.char.requests.ticket = false
  self.db.account.buffer.items = {}
  self.db.account.buffer.itemsets = {}
  self.db.account.buffer.spells = {}
  self.db.account.buffer.quests = {}
  self.db.account.buffer.creatures = {}
  self.db.account.buffer.objects = {}
  self.db.account.buffer.teles = {}
  self.db.account.buffer.counter = 0
  PopupScrollUpdate()
end

function MangAdmin:PrepareScript(object, text, script)
  --if object then
    if text then
      object:SetScript("OnEnter", function() ma_tooltiptext:SetText(text) end)
      object:SetScript("OnLeave", function() ma_tooltiptext:SetText(Locale["tt_Default"]) end)
    end
    if type(script) == "function" then
      object:SetScript("OnClick", script)
    elseif type(script) == "table" then
      for k,v in pairs(script) do
        object:SetScript(unpack(v))
      end
    end
  --end
end

--[[INITIALIZION FUNCTIONS]]
function MangAdmin:InitButtons()
  -- start tab buttons
  self:PrepareScript(ma_tabbutton_main       , Locale["tt_MainButton"]         , function() MangAdmin:InstantGroupToggle("main") end)
  self:PrepareScript(ma_tabbutton_char       , Locale["tt_CharButton"]         , function() MangAdmin:InstantGroupToggle("char") end)
  self:PrepareScript(ma_tabbutton_tele       , Locale["tt_TeleButton"]         , function() MangAdmin:InstantGroupToggle("tele") end)
  self:PrepareScript(ma_tabbutton_ticket     , Locale["tt_TicketButton"]       , function() MangAdmin:ShowTicketTab() end)
  self:PrepareScript(ma_tabbutton_server     , Locale["tt_ServerButton"]       , function() MangAdmin:InstantGroupToggle("server") end)
  self:PrepareScript(ma_tabbutton_misc       , Locale["tt_MiscButton"]         , function() MangAdmin:InstantGroupToggle("misc") end)
  self:PrepareScript(ma_tabbutton_log        , Locale["tt_LogButton"]          , function() MangAdmin:InstantGroupToggle("log") end)
  --end tab buttons
  self:PrepareScript(ma_languagebutton       , Locale["tt_LanguageButton"]     , function() MangAdmin:ChangeLanguage(UIDropDownMenu_GetSelectedValue(ma_languagedropdown)) end)
  self:PrepareScript(ma_speedslider          , Locale["tt_SpeedSlider"]        , {{"OnMouseUp", function() MangAdmin:SetSpeed() end},{"OnValueChanged", function() ma_speedsliderText:SetText(string.format("%.1f", ma_speedslider:GetValue())) end}})
  self:PrepareScript(ma_scaleslider          , Locale["tt_ScaleSlider"]        , {{"OnMouseUp", function() MangAdmin:SetScale() end},{"OnValueChanged", function() ma_scalesliderText:SetText(string.format("%.1f", ma_scaleslider:GetValue())) end}})  
  self:PrepareScript(ma_itembutton           , Locale["tt_ItemButton"]         , function() MangAdmin:TogglePopup("search", {type = "item"}) end)
  self:PrepareScript(ma_itemsetbutton        , Locale["tt_ItemSetButton"]      , function() MangAdmin:TogglePopup("search", {type = "itemset"}) end)
  self:PrepareScript(ma_spellbutton          , Locale["tt_SpellButton"]        , function() MangAdmin:TogglePopup("search", {type = "spell"}) end)
  self:PrepareScript(ma_questbutton          , Locale["tt_QuestButton"]        , function() MangAdmin:TogglePopup("search", {type = "quest"}) end)
  self:PrepareScript(ma_creaturebutton       , Locale["tt_CreatureButton"]     , function() MangAdmin:TogglePopup("search", {type = "creature"}) end)
  self:PrepareScript(ma_objectbutton         , Locale["tt_ObjectButton"]       , function() MangAdmin:TogglePopup("search", {type = "object"}) end)
  self:PrepareScript(ma_telesearchbutton     , Locale["ma_TeleSearchButton"]   , function() MangAdmin:TogglePopup("search", {type = "tele"}) end)
  self:PrepareScript(ma_sendmailbutton       , "Tooltip not yet implemented."  , function() MangAdmin:TogglePopup("mail", {}) end)
  self:PrepareScript(ma_screenshotbutton     , Locale["tt_ScreenButton"]       , function() MangAdmin:Screenshot() end)
  self:PrepareScript(ma_gmonbutton           , Locale["tt_GMOnButton"]         , function() MangAdmin:ToggleGMMode("on") end)
  self:PrepareScript(ma_gmoffbutton          , Locale["tt_GMOffButton"]        , function() MangAdmin:ToggleGMMode("off") end)
  self:PrepareScript(ma_flyonbutton          , Locale["tt_FlyOnButton"]        , function() MangAdmin:ToggleFlyMode("on") end)
  self:PrepareScript(ma_flyoffbutton         , Locale["tt_FlyOffButton"]       , function() MangAdmin:ToggleFlyMode("off") end)
  self:PrepareScript(ma_hoveronbutton        , Locale["tt_HoverOnButton"]      , function() MangAdmin:ToggleHoverMode(1) end)
  self:PrepareScript(ma_hoveroffbutton       , Locale["tt_HoverOffButton"]     , function() MangAdmin:ToggleHoverMode(0) end)
  self:PrepareScript(ma_whisperonbutton      , Locale["tt_WhispOnButton"]      , function() MangAdmin:ToggleWhisper("on") end)
  self:PrepareScript(ma_whisperoffbutton     , Locale["tt_WhispOffButton"]     , function() MangAdmin:ToggleWhisper("off") end)
  self:PrepareScript(ma_invisibleonbutton    , Locale["tt_InvisOnButton"]      ,  function() MangAdmin:ToggleVisible("off") end)
  self:PrepareScript(ma_invisibleoffbutton   , Locale["tt_InvisOffButton"]     , function() MangAdmin:ToggleVisible("on") end)
  self:PrepareScript(ma_taxicheatonbutton    , Locale["tt_TaxiOnButton"]       , function() MangAdmin:ToggleTaxicheat("on") end)
  self:PrepareScript(ma_taxicheatoffbutton   , Locale["tt_TaxiOffButton"]      , function() MangAdmin:ToggleTaxicheat("off") end)
  self:PrepareScript(ma_ticketonbutton       , "Tooltip not yet implemented."  , function() MangAdmin:ToggleTickets("on") end)
  self:PrepareScript(ma_ticketoffbutton      , "Tooltip not yet implemented."  , function() MangAdmin:ToggleTickets("off") end)
  self:PrepareScript(ma_bankbutton           , Locale["tt_BankButton"]         , function() MangAdmin:ChatMsg(".bank") end)
  self:PrepareScript(ma_learnallbutton       , "Tooltip not yet implemented."  , function() MangAdmin:LearnSpell("all") end)
  self:PrepareScript(ma_learncraftsbutton    , "Tooltip not yet implemented."  , function() MangAdmin:LearnSpell("all_crafts") end)
  self:PrepareScript(ma_learngmbutton        , "Tooltip not yet implemented."  , function() MangAdmin:LearnSpell("all_gm") end)
  self:PrepareScript(ma_learnlangbutton      , "Tooltip not yet implemented."  , function() MangAdmin:LearnSpell("all_lang") end)
  self:PrepareScript(ma_learnclassbutton     , "Tooltip not yet implemented."  , function() MangAdmin:LearnSpell("all_myclass") end)
  self:PrepareScript(ma_modifybutton         , "Tooltip not yet implemented."  , function() MangAdmin:Modify(UIDropDownMenu_GetSelectedValue(ma_modifydropdown),ma_modifyeditbox:GetText()) end)
  self:PrepareScript(ma_searchbutton         , "Tooltip not yet implemented."  , function() MangAdmin:SearchStart("item", ma_searcheditbox:GetText()) end)
  self:PrepareScript(ma_resetsearchbutton    , "Tooltip not yet implemented."  , function() MangAdmin:SearchReset() end)
  self:PrepareScript(ma_revivebutton         , "Tooltip not yet implemented."  , function() MangAdmin:RevivePlayer() end)
  self:PrepareScript(ma_killbutton           , "Tooltip not yet implemented."  , function() MangAdmin:KillSomething() end)
  self:PrepareScript(ma_savebutton           , "Tooltip not yet implemented."  , function() MangAdmin:SavePlayer() end)
  self:PrepareScript(ma_dismountbutton       , "Tooltip not yet implemented."  , function() MangAdmin:DismountPlayer() end)
  self:PrepareScript(ma_kickbutton           , Locale["tt_KickButton"]         , function() MangAdmin:KickPlayer() end)
  self:PrepareScript(ma_gridnaviaheadbutton  , "Tooltip not yet implemented."  , function() MangAdmin:GridNavigate(nil, nil); self.db.char.nextGridWay = "ahead" end)
  self:PrepareScript(ma_gridnavibackbutton   , "Tooltip not yet implemented."  , function() MangAdmin:GridNavigate(nil, nil); self.db.char.nextGridWay = "back" end)
  self:PrepareScript(ma_gridnavirightbutton  , "Tooltip not yet implemented."  , function() MangAdmin:GridNavigate(nil, nil); self.db.char.nextGridWay = "right" end)
  self:PrepareScript(ma_gridnavileftbutton   , "Tooltip not yet implemented."  , function() MangAdmin:GridNavigate(nil, nil); self.db.char.nextGridWay = "left" end)
  self:PrepareScript(ma_announcebutton       , Locale["tt_AnnounceButton"]     , function() MangAdmin:Announce(ma_announceeditbox:GetText()) end)
  self:PrepareScript(ma_resetannouncebutton  , "Tooltip not yet implemented."  , function() ma_announceeditbox:SetText("") end)
  self:PrepareScript(ma_shutdownbutton       , Locale["tt_ShutdownButton"]     , function() MangAdmin:Shutdown(ma_shutdowneditbox:GetText()) end)
  self:PrepareScript(ma_closebutton          , "Tooltip not yet implemented."  , function() FrameLib:HandleGroup("bg", function(frame) frame:Hide() end) end)
  self:PrepareScript(ma_popupclosebutton     , "Tooltip not yet implemented."  , function() FrameLib:HandleGroup("popup", function(frame) frame:Hide()  end) end)
  self:PrepareScript(ma_showticketsbutton    , "Tooltip not yet implemented."  , function() MangAdmin:TogglePopup("search", {type = "ticket"}); MangAdmin:LoadTickets() end)
  self:PrepareScript(ma_deleteticketbutton   , "Tooltip not yet implemented."  , function() MangAdmin:Ticket("delete") end)
  self:PrepareScript(ma_answerticketbutton   , "Tooltip not yet implemented."  , function() MangAdmin:Ticket("answer") end)
  self:PrepareScript(ma_getcharticketbutton  , "Tooltip not yet implemented."  , function() MangAdmin:Ticket("getchar") end)
  self:PrepareScript(ma_gocharticketbutton   , "Tooltip not yet implemented."  , function() MangAdmin:Ticket("gochar") end)
  self:PrepareScript(ma_whisperticketbutton  , "Tooltip not yet implemented."  , function() MangAdmin:Ticket("whisper") end)
  self:PrepareScript(ma_bgcolorshowbutton    , "Tooltip not yet implemented."  , function() MangAdmin:ShowColorPicker("bg") end)
  self:PrepareScript(ma_frmcolorshowbutton   , "Tooltip not yet implemented."  , function() MangAdmin:ShowColorPicker("frm") end)
  self:PrepareScript(ma_btncolorshowbutton   , "Tooltip not yet implemented."  , function() MangAdmin:ShowColorPicker("btn") end)
  self:PrepareScript(ma_linkifiercolorbutton , "Tooltip not yet implemented."  , function() MangAdmin:ShowColorPicker("linkifier") end)
  self:PrepareScript(ma_applystylebutton     , "Tooltip not yet implemented."  , function() MangAdmin:ApplyStyleChanges() end)
  self:PrepareScript(ma_loadtablebutton      , "Tooltip not yet implemented."  , function() MangAdmin:ReloadTable(UIDropDownMenu_GetSelectedValue(ma_reloadtabledropdown)) end)
  self:PrepareScript(ma_loadscriptsbutton    , "Tooltip not yet implemented."  , function() MangAdmin:ReloadScripts() end)
  self:PrepareScript(ma_changeweatherbutton  , "Tooltip not yet implemented."  , function() MangAdmin:ChangeWeather(UIDropDownMenu_GetSelectedValue(ma_weathertabledropdown)) end)
end

function MangAdmin:InitLangDropDown()
  local function LangDropDownInitialize()
    local level = 1
    local info = UIDropDownMenu_CreateInfo()
    local buttons = {
      {"Czech","csCZ"},
      {"German","deDE"},
      {"English","enUS"},
      {"Spanish","esES"},
      {"Finnish","fiFI"},
      {"French","frFR"},
      {"Hungarian","huHU"},
      {"Italian","itIT"},
      {"Lithuanian","liLI"},
      {"Polish","plPL"},
      {"Portuguese","ptPT"},
      {"Romanian","roRO"},
      {"Swedish","svSV"},
      {"Chinese","zhCN"}
    }
    for k,v in ipairs(buttons) do
      info.text = v[1]
      info.value = v[2]
      info.func = function() UIDropDownMenu_SetSelectedValue(ma_languagedropdown, this.value) end
      if v[2] == Locale:GetLocale() then
        info.checked = true
      else
        info.checked = nil
      end
      info.icon = nil
      info.keepShownOnClick = nil
      UIDropDownMenu_AddButton(info, level)
    end
  end  
  UIDropDownMenu_Initialize(ma_languagedropdown, LangDropDownInitialize)
  UIDropDownMenu_SetWidth(100, ma_languagedropdown)
  UIDropDownMenu_SetButtonWidth(20, ma_languagedropdown)
end

function MangAdmin:InitWeatherDropDown()
  local function WeatherDropDownInitialize()
    local level = 1
    local info = UIDropDownMenu_CreateInfo()
    local buttons = {
      {"Fine","0 0"},
      {"Fog ","0 1"},
      {"Rain","1 1"},
      {"Snow","2 1"},
      {"Sand","3 1"}
    }
    for k,v in ipairs(buttons) do
      info.text = v[1]
      info.value = v[2]
      info.func = function() UIDropDownMenu_SetSelectedValue(ma_weathertabledropdown, this.value) end
      info.checked = nil
      info.icon = nil
      info.keepShownOnClick = nil
      UIDropDownMenu_AddButton(info, level)
    end
  end  
  UIDropDownMenu_Initialize(ma_weathertabledropdown, WeatherDropDownInitialize)
  UIDropDownMenu_SetWidth(100, ma_weathertabledropdown)
  UIDropDownMenu_SetButtonWidth(20, ma_weathertabledropdown)
end

function MangAdmin:InitReloadTableDropDown()
  local function ReloadTableDropDownInitialize()
    local level = 1
    local info = UIDropDownMenu_CreateInfo()
    local buttons = {
      {"all","all"},
      {"all_area","all_area"},
      {"all_loot","all_loot"},
      {"all_quest","all_quest"},
      {"all_spell","all_spell"},
      {"areatrigger_tavern","areatrigger_tavern"},
      {"areatrigger_teleport","areatrigger_teleport"},
      {"command","command"},
      {"creature_questrelation","creature_questrelation"},
      {"creature_involvedrelation","creature_involvedrelation"},
      {"gameobject_questrelation","gameobject_questrelation"},
      {"gameobject_involvedrelation","gameobject_involvedrelation"},
      {"areatrigger_involvedrelation","areatrigger_involvedrelation"},
      {"quest_template","quest_template"},
      {"creature_loot_template","creature_loot_template"},
      {"disenchant_loot_template","disenchant_loot_template"},
      {"fishing_loot_template","fishing_loot_template"},
      {"gameobject_loot_template","gameobject_loot_template"},
      {"item_loot_template","item_loot_template"},
      {"pickpocketing_loot_template","pickpocketing_loot_template"},
      {"prospecting_loot_template","prospecting_loot_template"},
      {"skinning_loot_template","skinning_loot_template"},
      {"reserved_name","reserved_name"},
      {"skill_discovery_template","skill_discovery_template"},
      {"skill_extra_item_template","skill_extra_item_template"},
      {"spell_affect","spell_affect"},
      {"spell_chain","spell_chain"},
      {"spell_learn_skill","spell_learn_skill"},
      {"spell_learn_spell","spell_learn_spell"},
      {"spell_proc_event","spell_proc_event"},
      {"spell_script_target","spell_script_target"},
      {"spell_teleport","spell_teleport"},
      {"button_scripts","button_scripts"},
      {"quest_end_scripts","quest_end_scripts"},
      {"quest_start_scripts","quest_start_scripts"},
      {"spell_scripts","spell_scripts"},
      {"game_graveyard_zone","game_graveyard_zone"}
    }
    for k,v in ipairs(buttons) do
      info.text = v[1]
      info.value = v[2]
      info.checked = nil
      info.func = function() UIDropDownMenu_SetSelectedValue(ma_reloadtabledropdown, this.value) end
      info.icon = nil
      info.keepShownOnClick = nil
      UIDropDownMenu_AddButton(info, level)
    end
  end  
  UIDropDownMenu_Initialize(ma_reloadtabledropdown, ReloadTableDropDownInitialize)
  UIDropDownMenu_SetWidth(100, ma_reloadtabledropdown)
  UIDropDownMenu_SetButtonWidth(20, ma_reloadtabledropdown)
end

function MangAdmin:InitModifyDropDown()
  local function ModifyDropDownInitialize()
    local level = 1
    local info = UIDropDownMenu_CreateInfo()
    local buttons = {
      {"Level up","levelup"},
      {"Level down ","leveldown"},
      {"Money","money"},
      {"Energy","energy"},
      {"Rage","rage"},
      {"Mana","mana"},
      {"Healthpoints","health"}
    }
    for k,v in ipairs(buttons) do
      info.text = v[1]
      info.value = v[2]
      info.func = function() UIDropDownMenu_SetSelectedValue(ma_modifydropdown, this.value) end
      info.checked = nil
      info.icon = nil
      info.keepShownOnClick = nil
      UIDropDownMenu_AddButton(info, level)
    end
  end  
  UIDropDownMenu_Initialize(ma_modifydropdown, ModifyDropDownInitialize)
  UIDropDownMenu_SetWidth(100, ma_modifydropdown)
  UIDropDownMenu_SetButtonWidth(20, ma_modifydropdown)
end

function MangAdmin:InitSliders()
  -- Speed Slider
  ma_speedslider:SetOrientation("HORIZONTAL")
  ma_speedslider:SetMinMaxValues(1, 10)
  ma_speedslider:SetValueStep(0.1)
  ma_speedslider:SetValue(1)
  ma_speedsliderText:SetText("1.0")
  -- Scale Slider
  ma_scaleslider:SetOrientation("HORIZONTAL")
  ma_scaleslider:SetMinMaxValues(0.1, 3)
  ma_scaleslider:SetValueStep(0.1)
  ma_scaleslider:SetValue(1)
  ma_scalesliderText:SetText("1.0")
end

function MangAdmin:InitScrollFrames()
  ma_PopupScrollBar:SetScript("OnVerticalScroll", function() FauxScrollFrame_OnVerticalScroll(30, PopupScrollUpdate) end)
  ma_PopupScrollBar:SetScript("OnShow", function() PopupScrollUpdate() end)
  ma_ticketscrollframe:SetScrollChild(ma_ticketeditbox)
  self:PrepareScript(ma_ticketeditbox, nil, {{"OnTextChanged", function() ScrollingEdit_OnTextChanged() end},
    {"OnCursorChanged", function() ScrollingEdit_OnCursorChanged(arg1, arg2, arg3, arg4) end},
    {"OnUpdate", function() ScrollingEdit_OnUpdate() end}})
  ma_mailscrollframe:SetScrollChild(ma_maileditbox)
  self:PrepareScript(ma_maileditbox, nil, {{"OnTextChanged", function() ScrollingEdit_OnTextChanged(); MangAdmin:UpdateMailBytesLeft() end},
    {"OnCursorChanged", function() ScrollingEdit_OnCursorChanged(arg1, arg2, arg3, arg4) end},
    {"OnUpdate", function() ScrollingEdit_OnUpdate() end}})
end

function MangAdmin:NoResults(var)
  if var == "ticket" then
    -- Reset list and make an entry "No Tickets"
    self:LogAction(Locale["ma_TicketsNoTickets"])
    ma_ticketeditbox:SetText(Locale["ma_TicketsNoTickets"])
    FauxScrollFrame_Update(ma_PopupScrollBar,7,7,30)
    for line = 1,7 do
      getglobal("ma_PopupScrollBarEntry"..line):Disable()
      getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Disable()
      getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
      if line == 1 then
        getglobal("ma_PopupScrollBarEntry"..line):SetText(Locale["ma_TicketsNoTickets"])
        getglobal("ma_PopupScrollBarEntry"..line):Show()
      else
        getglobal("ma_PopupScrollBarEntry"..line):Hide()
      end
    end
  elseif var == "search" then
    ma_lookupresulttext:SetText(Locale["searchResults"].."0")
    FauxScrollFrame_Update(ma_PopupScrollBar,7,7,30)
    for line = 1,7 do
      getglobal("ma_PopupScrollBarEntry"..line):Disable()
      getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Disable()
      getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
      if line == 1 then
        getglobal("ma_PopupScrollBarEntry"..line):SetText(Locale["tt_SearchDefault"])
        getglobal("ma_PopupScrollBarEntry"..line):Show()
      else
        getglobal("ma_PopupScrollBarEntry"..line):Hide()
      end
    end
  elseif var == "favorites" then
    ma_lookupresulttext:SetText("Favorites: ".."0")
    FauxScrollFrame_Update(ma_PopupScrollBar,7,7,30)
    for line = 1,7 do
      getglobal("ma_PopupScrollBarEntry"..line):Disable()
      getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Disable()
      getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
      if line == 1 then
        getglobal("ma_PopupScrollBarEntry"..line):SetText("There are currently no saved favorites!")
        getglobal("ma_PopupScrollBarEntry"..line):Show()
      else
        getglobal("ma_PopupScrollBarEntry"..line):Hide()
      end
    end
  end
end

function PopupScrollUpdate()
  local line -- 1 through 7 of our window to scroll
  local lineplusoffset -- an index into our data calculated from the scroll offset
  
  if MangAdmin.db.char.requests.item or MangAdmin.db.char.requests.favitem then --get items
    local count = 0
    if MangAdmin.db.char.requests.item then
      table.foreachi(MangAdmin.db.account.buffer.items, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favitem then
      table.foreachi(MangAdmin.db.account.favorites.items, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local item
          if MangAdmin.db.char.requests.item then
            item = MangAdmin.db.account.buffer.items[lineplusoffset]
          elseif MangAdmin.db.char.requests.favitem then
            item = MangAdmin.db.account.favorites.items[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..item["itId"].."|r Name: |cffffffff"..item["itName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:AddItem(item["itId"], arg1) end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() GameTooltip:SetOwner(this, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink("item:"..item["itId"]..":0:0:0:0:0:0:0"); GameTooltip:Show() end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() GameTooltip:SetOwner(this, "ANCHOR_RIGHT"); GameTooltip:Hide() end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.item then
            if item["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.items[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.items[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favitem then
            if item["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.items[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.items[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(item["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.item then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favitem then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.itemset or MangAdmin.db.char.requests.favitemset then --get itemsets
    local count = 0
    if MangAdmin.db.char.requests.itemset then
      table.foreachi(MangAdmin.db.account.buffer.itemsets, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favitemset then
      table.foreachi(MangAdmin.db.account.favorites.itemsets, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local itemset
          if MangAdmin.db.char.requests.itemset then
            itemset = MangAdmin.db.account.buffer.itemsets[lineplusoffset]
          elseif MangAdmin.db.char.requests.favitemset then
            itemset = MangAdmin.db.account.favorites.itemsets[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..itemset["isId"].."|r Name: |cffffffff"..itemset["isName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:AddItemSet(itemset["isId"]) end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.itemset then
            if itemset["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.itemsets[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.itemsets[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favitemset then
            if itemset["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.itemsets[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.itemsets[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(itemset["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.itemset then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favitemset then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.quest or MangAdmin.db.char.requests.favquest then --get quests
    local count = 0
    if MangAdmin.db.char.requests.quest then
      table.foreachi(MangAdmin.db.account.buffer.quests, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favquest then
      table.foreachi(MangAdmin.db.account.favorites.quests, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local quest
          if MangAdmin.db.char.requests.quest then
            quest = MangAdmin.db.account.buffer.quests[lineplusoffset]
          elseif MangAdmin.db.char.requests.favquest then
            quest = MangAdmin.db.account.favorites.quests[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..quest["qsId"].."|r Name: |cffffffff"..quest["qsName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:Quest(quest["qsId"], arg1) end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.quest then
            if quest["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.quests[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.quests[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favquest then
            if quest["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.quests[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.quests[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(quest["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.quest then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favquest then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.creature or MangAdmin.db.char.requests.favcreature then --get creatures
    local count = 0
    if MangAdmin.db.char.requests.creature then
      table.foreachi(MangAdmin.db.account.buffer.creatures, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favcreature then
      table.foreachi(MangAdmin.db.account.favorites.creatures, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local creature
          if MangAdmin.db.char.requests.creature then
            creature = MangAdmin.db.account.buffer.creatures[lineplusoffset]
          elseif MangAdmin.db.char.requests.favcreature then
            creature = MangAdmin.db.account.favorites.creatures[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..creature["crId"].."|r Name: |cffffffff"..creature["crName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:Creature(creature["crId"], arg1) end) 
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.creature then
            if creature["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.creatures[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.creatures[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favcreature then
            if creature["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.creatures[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.creatures[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(creature["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.creature then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favcreature then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.spell or MangAdmin.db.char.requests.favspell then --get spells
    local count = 0
    if MangAdmin.db.char.requests.spell then
      table.foreachi(MangAdmin.db.account.buffer.spells, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favspell then
      table.foreachi(MangAdmin.db.account.favorites.spells, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local spell
          if MangAdmin.db.char.requests.spell then
            spell = MangAdmin.db.account.buffer.spells[lineplusoffset]
          elseif MangAdmin.db.char.requests.favspell then
            spell = MangAdmin.db.account.favorites.spells[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..spell["spId"].."|r Name: |cffffffff"..spell["spName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:LearnSpell(spell["spId"], arg1) end)  
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.spell then
            if spell["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.spells[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.spells[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favspell then
            if spell["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.spells[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.spells[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(spell["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.spell then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favspell then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.object or MangAdmin.db.char.requests.favobject then --get objects
    local count = 0
    if MangAdmin.db.char.requests.object then
      table.foreachi(MangAdmin.db.account.buffer.objects, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favobject then
      table.foreachi(MangAdmin.db.account.favorites.objects, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local object
          if MangAdmin.db.char.requests.object then
            object = MangAdmin.db.account.buffer.objects[lineplusoffset]
          elseif MangAdmin.db.char.requests.favobject then
            object = MangAdmin.db.account.favorites.objects[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..object["objId"].."|r Name: |cffffffff"..object["objName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:AddObject(object["objId"], arg1) end)    
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.object then
            if object["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.objects[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.objects[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favobject then
            if object["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.objects[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.objects[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(object["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.object then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favobject then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.tele or MangAdmin.db.char.requests.favtele then --get teles
    local count = 0
    if MangAdmin.db.char.requests.tele then
      table.foreachi(MangAdmin.db.account.buffer.teles, function() count = count + 1 end)
    elseif MangAdmin.db.char.requests.favtele then
      table.foreachi(MangAdmin.db.account.favorites.teles, function() count = count + 1 end)
    end
    if count > 0 then
      ma_lookupresulttext:SetText(Locale["searchResults"]..count)
      FauxScrollFrame_Update(ma_PopupScrollBar,count,7,30)
      for line = 1,7 do
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= count then
          local tele
          if MangAdmin.db.char.requests.tele then
            tele = MangAdmin.db.account.buffer.teles[lineplusoffset]
          elseif MangAdmin.db.char.requests.favtele then
            tele = MangAdmin.db.account.favorites.teles[lineplusoffset]
          end
          local key = lineplusoffset
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Name: |cffffffff"..tele["tName"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() MangAdmin:ChatMsg(".tele "..tele["tName"]) end)    
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
          if MangAdmin.db.char.requests.tele then
            if tele["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.teles[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.buffer.teles[key]["checked"] = true; PopupScrollUpdate() end)
            end
          elseif MangAdmin.db.char.requests.favtele then
            if tele["checked"] then
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.teles[key]["checked"] = false; PopupScrollUpdate() end)
            else
              getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetScript("OnClick", function() MangAdmin.db.account.favorites.teles[key]["checked"] = true; PopupScrollUpdate() end)
            end
          end
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):SetChecked(tele["checked"])
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Enable()
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line.."ChkBtn"):Hide()
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      if MangAdmin.db.char.requests.tele then
        MangAdmin:NoResults("search")
      elseif MangAdmin.db.char.requests.favtele then
        MangAdmin:NoResults("favorites")
      end
    end
    
  elseif MangAdmin.db.char.requests.ticket then --get tickets
    local ticketCount = 0
    table.foreachi(MangAdmin.db.account.buffer.tickets, function() ticketCount = ticketCount + 1 end)
    if ticketCount > 0 then
      --FauxScrollFrame_Update(ma_PopupScrollBar,4,7,30) --for paged mode, only load 4 at a time
      FauxScrollFrame_Update(ma_PopupScrollBar,ticketCount,7,30)
      for line = 1,7 do
        --lineplusoffset = line + ((MangAdmin.db.account.tickets.page - 1) * 4)  --for paged mode
        lineplusoffset = line + FauxScrollFrame_GetOffset(ma_PopupScrollBar)
        if lineplusoffset <= ticketCount then
          local object = MangAdmin.db.account.buffer.tickets[lineplusoffset]
          getglobal("ma_PopupScrollBarEntry"..line):SetText("Id: |cffffffff"..object["tNumber"].."|r Cat: |cffffffff"..object["tCat"].."|r Player: |cffffffff"..object["tChar"].."|r")
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnClick", function() 
            ma_ticketeditbox:SetText(object["tMsg"])
            ma_tpinfo_text:SetText(string.format(Locale["ma_TicketTicketLoaded"], object["tNumber"]))
            MangAdmin.db.char.requests.tpinfo = true
            MangAdmin:ChatMsg(".pinfo "..object["tChar"])
            MangAdmin:LogAction("Loading player info of "..object["tChar"])
            MangAdmin.db.account.tickets.selected = object
            ma_deleteticketbutton:Enable()
            ma_answerticketbutton:Enable()
            ma_getcharticketbutton:Enable()
            ma_gocharticketbutton:Enable()
            ma_whisperticketbutton:Enable()
            MangAdmin:InstantGroupToggle("ticket")
          end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnEnter", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):SetScript("OnLeave", function() --[[Do nothing]] end)
          getglobal("ma_PopupScrollBarEntry"..line):Enable()
          getglobal("ma_PopupScrollBarEntry"..line):Show()
        else
          getglobal("ma_PopupScrollBarEntry"..line):Hide()
        end
      end
    else
      MangAdmin:NoResults("ticket")
    end
    
  else
    MangAdmin:NoResults("search")
  end
end

-- STYLE FUNCTIONS
function MangAdmin:ToggleTransparency()
  if self.db.account.style.transparency.backgrounds < 1.0 then
    self.db.account.style.transparency.backgrounds = 1.0
  else
    self.db.account.style.transparency.backgrounds = 0.5
  end
  ReloadUI()
end

function MangAdmin:InitTransparencyButton()
  if self.db.account.style.transparency.backgrounds < 1.0 then
    ma_checktransparencybutton:SetChecked(true)
  else
    ma_checktransparencybutton:SetChecked(false)
  end
end

function MangAdmin:ShowColorPicker(t)
  if t == "bg" then
    local r,g,b
    if MangAdmin.db.account.style.color.buffer.backgrounds then
      r = MangAdmin.db.account.style.color.buffer.backgrounds.r
      g = MangAdmin.db.account.style.color.buffer.backgrounds.g
      b = MangAdmin.db.account.style.color.buffer.backgrounds.b
    else
      r = MangAdmin.db.account.style.color.backgrounds.r
      g = MangAdmin.db.account.style.color.backgrounds.g
      b = MangAdmin.db.account.style.color.backgrounds.b
    end
    ColorPickerFrame.cancelFunc = function(prev)
      local r,g,b = unpack(prev)
      ma_bgcolorshowbutton_texture:SetTexture(r,g,b)
    end
    ColorPickerFrame.func = function()
      local r,g,b = ColorPickerFrame:GetColorRGB()
      ma_bgcolorshowbutton_texture:SetTexture(r,g,b)
      MangAdmin.db.account.style.color.buffer.backgrounds = {}
      MangAdmin.db.account.style.color.buffer.backgrounds.r = r
      MangAdmin.db.account.style.color.buffer.backgrounds.g = g
      MangAdmin.db.account.style.color.buffer.backgrounds.b = b
    end
    ColorPickerFrame:SetColorRGB(r,g,b)
    ColorPickerFrame.previousValues = {r,g,b}
  elseif t == "frm" then
    local r,g,b
    if MangAdmin.db.account.style.color.buffer.frames then
      r = MangAdmin.db.account.style.color.buffer.frames.r
      g = MangAdmin.db.account.style.color.buffer.frames.g
      b = MangAdmin.db.account.style.color.buffer.frames.b
    else
      r = MangAdmin.db.account.style.color.frames.r
      g = MangAdmin.db.account.style.color.frames.g
      b = MangAdmin.db.account.style.color.frames.b
    end
    ColorPickerFrame.cancelFunc = function(prev)
      local r,g,b = unpack(prev)
      ma_frmcolorshowbutton_texture:SetTexture(r,g,b)
    end
    ColorPickerFrame.func = function()
      local r,g,b = ColorPickerFrame:GetColorRGB()
      ma_frmcolorshowbutton_texture:SetTexture(r,g,b)
      MangAdmin.db.account.style.color.buffer.frames = {}
      MangAdmin.db.account.style.color.buffer.frames.r = r
      MangAdmin.db.account.style.color.buffer.frames.g = g
      MangAdmin.db.account.style.color.buffer.frames.b = b
    end
    ColorPickerFrame:SetColorRGB(r,g,b)
    ColorPickerFrame.previousValues = {r,g,b}
  elseif t == "btn" then
    local r,g,b
    if MangAdmin.db.account.style.color.buffer.buttons then
      r = MangAdmin.db.account.style.color.buffer.buttons.r
      g = MangAdmin.db.account.style.color.buffer.buttons.g
      b = MangAdmin.db.account.style.color.buffer.buttons.b
    else
      r = MangAdmin.db.account.style.color.buttons.r
      g = MangAdmin.db.account.style.color.buttons.g
      b = MangAdmin.db.account.style.color.buttons.b
    end
    ColorPickerFrame.cancelFunc = function(prev)
      local r,g,b = unpack(prev)
      ma_btncolorshowbutton_texture:SetTexture(r,g,b)
    end
    ColorPickerFrame.func = function()
      local r,g,b = ColorPickerFrame:GetColorRGB();
      ma_btncolorshowbutton_texture:SetTexture(r,g,b)
      MangAdmin.db.account.style.color.buffer.buttons = {}
      MangAdmin.db.account.style.color.buffer.buttons.r = r
      MangAdmin.db.account.style.color.buffer.buttons.g = g
      MangAdmin.db.account.style.color.buffer.buttons.b = b
    end
    ColorPickerFrame:SetColorRGB(r,g,b)
    ColorPickerFrame.previousValues = {r,g,b}
  elseif t == "linkifier" then
    local r,g,b
    if MangAdmin.db.account.style.color.buffer.linkifier then
      r = MangAdmin.db.account.style.color.buffer.linkifier.r
      g = MangAdmin.db.account.style.color.buffer.linkifier.g
      b = MangAdmin.db.account.style.color.buffer.linkifier.b
    else
      r = MangAdmin.db.account.style.color.linkifier.r
      g = MangAdmin.db.account.style.color.linkifier.g
      b = MangAdmin.db.account.style.color.linkifier.b
    end
    ColorPickerFrame.cancelFunc = function(prev)
      local r,g,b = unpack(prev)
      ma_linkifiercolorbutton_texture:SetTexture(r,g,b)
    end
    ColorPickerFrame.func = function()
      local r,g,b = ColorPickerFrame:GetColorRGB();
      ma_linkifiercolorbutton_texture:SetTexture(r,g,b)
      MangAdmin.db.account.style.color.buffer.linkifier = {}
      MangAdmin.db.account.style.color.buffer.linkifier.r = r
      MangAdmin.db.account.style.color.buffer.linkifier.g = g
      MangAdmin.db.account.style.color.buffer.linkifier.b = b
    end
    ColorPickerFrame:SetColorRGB(r,g,b)
    ColorPickerFrame.previousValues = {r,g,b}
  end
  ColorPickerFrame.hasOpacity = false
  ColorPickerFrame:Show()
end

function MangAdmin:ApplyStyleChanges()
  if MangAdmin.db.account.style.color.buffer.backgrounds then
    MangAdmin.db.account.style.color.backgrounds = MangAdmin.db.account.style.color.buffer.backgrounds
  end
  if MangAdmin.db.account.style.color.buffer.frames then
    MangAdmin.db.account.style.color.frames = MangAdmin.db.account.style.color.buffer.frames
  end
  if MangAdmin.db.account.style.color.buffer.buttons then
    MangAdmin.db.account.style.color.buttons = MangAdmin.db.account.style.color.buffer.buttons
  end
  if MangAdmin.db.account.style.color.buffer.linkifier then
    MangAdmin.db.account.style.color.linkifier = MangAdmin.db.account.style.color.buffer.linkifier
  end
  if ma_checktransparencybutton:GetChecked() then
    self.db.account.style.transparency.backgrounds = 0.5
  else
    self.db.account.style.transparency.backgrounds = 1.0
  end
  ReloadUI()
end
