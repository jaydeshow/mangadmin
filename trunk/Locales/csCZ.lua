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
--   Official Website    : http://mangadmin.all-mag.de
-- GoogleCode Website    : http://code.google.com/p/mangadmin/
-- Subversion Repository : http://mangadmin.googlecode.com/svn/
--
-------------------------------------------------------------------------------------------------------------

-- Czech Mangos Testing  : http://wow.fakaheda.eu/
-- Czech Mangos Support  : http://wow.fakaheda.eu/forum

function Return_csCZ()
  return {
    ["slashcmds"] = { "/mangadmin", "/ma" },
    ["lang"] = "Czech",
    ["logged"] = "|cFF00FF00Realm:|r "..GetCVar("realmName").." |cFF00FF00Char:|r "..UnitName("player").." ",
    ["charguid"] = "|cFF00FF00Guid:|r ",
    ["gridnavigator"] = "Grid-Navigator",
    ["selectionerror1"] = "Prosím vyberte sebe, jiný charakter nebo nic!",
    ["selectionerror2"] = "Please select only yourself or nothing!",
    ["selectionerror3"] = "Please select only another player!",
    ["selectionerror4"] = "Please select only a NPC!",
    ["searchResults"] = "|cFF00FF00Search-Results:|r ",
    ["tabmenu_Main"] = "Hlavní",
    ["tabmenu_Char"] = "Postava",
    ["tabmenu_Tele"] = "Teleport",
    ["tabmenu_Ticket"] = "Ticket System",
    ["tabmenu_Misc"] = "Miscellaneous",
    ["tabmenu_Server"] = "Server",
    ["tabmenu_Log"] = "Záznam",
    ["tt_Default"] = "Prejeďte kurzorem přes element pro aktivaci nápovědy!",
    ["tt_MainButton"] = "Klikni sem pro návrat na hlavní obrazovku MangAdmina.",
    ["tt_CharButton"] = "Klikni sem pro přepnutí na editaci postav.",
    ["tt_TeleButton"] = "Klikni sem pro přepnutí na obrazovku teleportací.",
    ["tt_TicketButton"] = "Klikni sem pro přepnutí na správu ticketu.",
    ["tt_MiscButton"] = "Click to toggle a window with miscellaneous actions.",
    ["tt_ServerButton"] = "Klikni sem pro zobrazení informací o serveru a pro nastavení věcí týkajících se serveru.",
    ["tt_LogButton"] = "Klikni sem pro zobrazení záznamu všech akcí provedených MangAdminem.",
    ["tt_LanguageButton"] = "Klikni sem pro změnu výchozího jazyka a restart MangAdmina.",
    ["tt_GMOnButton"] = "Click to activate your GM-mode.",
    ["tt_GMOffButton"] = "Click to deactivate your GM-mode.",
    ["tt_FlyOnButton"] = "Click to activate the Fly-mode for the selected character.",
    ["tt_FlyOffButton"] = "Click to deactivate the Fly-mode for the selected character.",
    ["tt_HoverOnButton"] = "Click to activate your Hover-mode.",
    ["tt_HoverOffButton"] = "Click to deactivate your Hover-mode.",
    ["tt_WhispOnButton"] = "Click to accept whispers from other players.",
    ["tt_WhispOffButton"] = "Click to not accept whispers from other players.",
    ["tt_InvisOnButton"] = "Click to make you invisible.",
    ["tt_InvisOffButton"] = "Click to make you visible.",
    ["tt_TaxiOnButton"] = "Click to show all taxi-routes to the selected player. This cheat will be deactivated on logout.",
    ["tt_TaxiOffButton"] = "Click to deactivate the taxi-cheat and restore the players known taxi-routes.",
    ["tt_BankButton"] = "Click to show your bank.",
    ["tt_ScreenButton"] = "Click to make a screenshot.",
    ["tt_SpeedSlider"] = "Posunutím jezdce zvětšíš nebo zmenšíš rychlost vybrané postavy.",
    ["tt_ScaleSlider"] = "Posunutím jezdce zvětšíš nebo zmenšíš vybranou postavu.",
    ["tt_ItemButton"] = "Klikni sem pro přepnutí na správu předmetů, funkce hledání věcí, správu položek oblíbených.",
    ["tt_ItemSetButton"] = "Klikni pro přepnutí nabídky s hledáním setových věcí a správou záložek.",
    ["tt_SpellButton"] = "Klikni sem pro přepnutí na správu kouzel, funce hledání kouzel, správu položek oblíbených.",
    ["tt_QuestButton"] = "Klikni pro přepnutí nabídky s hledáním questů a správou záložek.",
    ["tt_CreatureButton"] = "Klikni pro přepnutí nabídky s hledáním NPC a správou záložek..",
    ["tt_ObjectButton"] = "Klikni pro přepnutí nabídky s hledáním objektů a správou záložek.",
    ["tt_SearchDefault"] = "Vložte klíčové slovo a můžete spustit vyhledávání.",
    ["tt_AnnounceButton"] = "Klikni pro odeslání systémové zprávy.",
    ["tt_KickButton"] = "Klikni pro vykopnutí vybraného hráče ze serveru.",
    ["tt_ShutdownButton"] = "Klikni pro vypnutí serveru za definované množství sekund. Pokud nespecifikováno, server bude vypnut okamžitě!",
    ["ma_ItemButton"] = "Předmety",
    ["ma_ItemSetButton"] = "Hledání Setů",
    ["ma_SpellButton"] = "Kouzla",
    ["ma_QuestButton"] = "Hledání Questů",
    ["ma_CreatureButton"] = "Hledání NPC",
    ["ma_ObjectButton"] = "Hledání Object",
    ["ma_LanguageButton"] = "Změnit Jazyk",
    ["ma_GMOnButton"] = "GM-mode on",
    ["ma_FlyOnButton"] = "Fly-mode on",
    ["ma_HoverOnButton"] = "Hover-mode on",
    ["ma_WhisperOnButton"] = "Whisper on",
    ["ma_InvisOnButton"] = "Invisibility on",
    ["ma_TaxiOnButton"] = "Taxicheat on",    
    ["ma_ScreenshotButton"] = "Screenshot",
    ["ma_BankButton"] = "Bank",
    ["ma_OffButton"] = "Off",
    ["ma_LearnAllButton"] = "Všechna kouzla",
    ["ma_LearnCraftsButton"] = "Všechny profese a recepty",
    ["ma_LearnGMButton"] = "Základní GM kouzla",
    ["ma_LearnLangButton"] = "Všechny jazyky",
    ["ma_LearnClassButton"] = "Všechna kouzla dané profese",
    ["ma_LevelUpButton"] = "Levelup",
    ["ma_SearchButton"] = "Hledat...",
    ["ma_ResetButton"] = "Reset",
    ["ma_KickButton"] = "Vykopnout",
    ["ma_KillButton"] = "Kill",
    ["ma_DismountButton"] = "Dismount",
    ["ma_ReviveButton"] = "Revive",
    ["ma_SaveButton"] = "Save",
    ["ma_AnnounceButton"] = "Zveřejnit",
    ["ma_ShutdownButton"] = "Vypnout!",
    ["ma_ItemVar1Button"] = "Množství",
    ["ma_ObjectVar1Button"] = "Šablona lootu",
    ["ma_ObjectVar2Button"] = "Čas respawnu"
  }
end
