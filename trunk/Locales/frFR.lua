-------------------------------------------------------------------------------------------------------------
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

function Return_frFR()
  return {
    ["slashcmds"] = { "/mangadmin", "/ma" },
    ["lang"] = "French",
    ["logged"] = "|cFF00FF00Royaume:|r "..GetCVar("realmName").." |cFF00FF00Personnage:|r "..UnitName("player").." ",
    ["charguid"] = "|cFF00FF00Guid:|r ",
    ["gridnavigator"] = "Grid-Navigator",
    ["selectionerror1"] = "S\195\169lectionnez quelqu'un ou rien !",
    ["selectionerror2"] = "S\195\169lectionnez-vous ou rien!",
    ["selectionerror3"] = "S\195\169lectionner uniquement un autre joueur!",
    ["selectionerror4"] = "S\195\169lectionner uniquement un PNJ!",
    ["searchResults"] = "|cFF00FF00R\195\169sultats de recherche:|r ",
    ["tabmenu_Main"] = "Accueil",
    ["tabmenu_Char"] = "Personnage",
    ["tabmenu_Tele"] = "T\195\169l\195\169portations",
    ["tabmenu_Ticket"] = "Support",
    ["tabmenu_Misc"] = "Divers",
    ["tabmenu_Server"] = "Serveur",
    ["tabmenu_Log"] = "Log",
    ["tt_Default"] = "D\195\169placez votre curseur sur une icone pour Act. l'outil correspondant.",
    ["tt_MainButton"] = "Cliquez sur ce bouton pour Act. la page de garde.",
    ["tt_CharButton"] = "Click to toggle a window with character-specific actions.",
    ["tt_TeleButton"] = "Click to toggle a window with teleport-functions.",
    ["tt_TicketButton"] = "Click to toggle a window which shows all tickets and lets you administrate them.",
    ["tt_MiscButton"] = "Click to toggle a window with miscellaneous actions.",
    ["tt_ServerButton"] = "Cliquez sur ce bouton pour avoir des infomations sur le serveur.",
    ["tt_LogButton"] = "Cliquez sur ce bouton pour acc\195\169der au protocole de gestion des ench\195\168res.",
    ["tt_LanguageButton"] = "Appuyez sur ce bouton pour changer la langue et recharger MangAdmin.",
    ["tt_GMOnButton"] = "Cliquez pour activer le GM-mode sur vous.",
    ["tt_GMOffButton"] = "Cliquez pour d\195\169sactiver le GM-mode sur vous.",
    ["tt_FlyOnButton"] = "Cliquez pour activer le Fly-mode pour le personnage selection\195\169.",
    ["tt_FlyOffButton"] = "Cliquez pour d\195\169sactiver le Fly-mode pour le personnage selection\195\169.",
    ["tt_HoverOnButton"] = "Cliquez pour activer le Hover-mode sur vous.",
    ["tt_HoverOffButton"] = "Cliquez pour d\195\169sactiver le Hover-mode sur vous.",
    ["tt_WhispOnButton"] = "Cliquez pour accepter les messages priv\195\169s des joueurs.",
    ["tt_WhispOffButton"] = "Cliquez pour refuser les messages priv\195\169s des joueurs.",
    ["tt_InvisOnButton"] = "Cliquez pour devenir invisible.",
    ["tt_InvisOffButton"] = "Cliquez pour redevenir visible.",
    ["tt_TaxiOnButton"] = "Cliquez pour activer tous les transports sur le joueur s\195\169lectionn\195\169 (Cheat). D\195\169sactiv\195\169 \195\160 la d\195\169connexion.",
    ["tt_TaxiOffButton"] = "Cliquez pour d\195\169sactiver tous les transports sur le joueur s\195\169lectionn\195\169 et restaurer les transports connus.",
    ["tt_BankButton"] = "Cliquez pour afficher votre banque.",
    ["tt_ScreenButton"] = "Cliquez pour prendre un Screenshot.",
    ["tt_SpeedSlider"] = "D\195\169placez le curseur pour augmenter ou r\195\169duire la vitesse du personnage s\195\169lection\195\169.",
    ["tt_ScaleSlider"] = "D\195\169placez le curseur pour augmenter ou r\195\169duire la taille du personnage s\195\169lection\195\169.",
    ["tt_ItemButton"] = "Cliquez pour ouvrir un popup pour rechercher des objets et pour g\195\169rer vos favoris.",
    ["tt_ItemSetButton"] = "Cliquez pour ouvrir un popup pour rechercher des Set d'objets et pour g\195\169rer vos favoris.",
    ["tt_SpellButton"] = "Cliquez pour ouvrir un popup pour rechercher des sorts et pour g\195\169rer vos favoris.",
    ["tt_QuestButton"] = "Cliquez pour ouvrir un popup pour rechercher des qu\195\170tes et pour g\195\169rer vos favoris.",
    ["tt_CreatureButton"] = "Cliquez pour ouvrir un popup pour rechercher des cr\195\169atures et pour g\195\169rer vos favoris.",
    ["tt_ObjectButton"] = "Cliquez pour ouvrir un popup pour rechercher des Game-objects et pour g\195\169rer vos favoris.",
    ["tt_SearchDefault"] = "Vous pouvez maintenant entrer un mot clef et commencer votre recherche.",
    ["tt_AnnounceButton"] = "Cliquez pour envoyer un message Systeme.",
    ["tt_KickButton"] = "Cliquez pour expulser le personnage selection\195\169.",
    ["tt_ShutdownButton"] = "Cliquez pour eteindre le serveur dans le temps en seconde du champs, si vide le serveur s'arrete im\195\169diatement.",
    ["ma_ItemButton"] = "Rech. objets",
    ["ma_ItemSetButton"] = "Rech. grp objets",
    ["ma_SpellButton"] = "Rech. sorts",
    ["ma_QuestButton"] = "Rech. qu\195\170tes",
    ["ma_CreatureButton"] = "Rech. cr\195\169atures",
    ["ma_ObjectButton"] = "Rech. d\195\169cors",
    ["ma_TeleSearchButton"] = "Rech. t\195\169leport",
    ["ma_LanguageButton"] = "Changer langue",
    ["ma_GMOnButton"] = "Act.mode MJ",
    ["ma_FlyOnButton"] = "Act.mode vol",
    ["ma_HoverOnButton"] = "Act.mode survol",
    ["ma_WhisperOnButton"] = "Act. Message priv\195\169",
    ["ma_InvisOnButton"] = "Act. Invisibilit\195\169",
    ["ma_TaxiOnButton"] = "Act. Taxi",
    ["ma_ScreenshotButton"] = "Screenshot",
    ["ma_BankButton"] = "Banque",
    ["ma_OffButton"] = "off",
    ["ma_LearnAllButton"] = "Tous les Sorts",
    ["ma_LearnCraftsButton"] = "Toutes professions et recettes",
    ["ma_LearnGMButton"] = "Sorts MJ par d\195\169faut",
    ["ma_LearnLangButton"] = "Toutes les langues",
    ["ma_LearnClassButton"] = "Sorts de toutes les classes",
    ["ma_LevelUpButton"] = "Monter de niveau",
    ["ma_SearchButton"] = "Rechercher...",
    ["ma_ResetButton"] = "Effacer",
    ["ma_KickButton"] = "Expulser",
    ["ma_KillButton"] = "Tuer",
    ["ma_DismountButton"] = "Quitter monture",
    ["ma_ReviveButton"] = "Ressuciter",
    ["ma_SaveButton"] = "Sauvegarder",
    ["ma_AnnounceButton"] = "Annonce",
    ["ma_ShutdownButton"] = "Eteindre serveur",
    ["ma_ItemVar1Button"] = "Quantit\195\169",
    ["ma_ObjectVar1Button"] = "Loot Template",
    ["ma_ObjectVar2Button"] = "Temps de spawn",
    ["ma_LoadTicketsButton"] = "Montrer les billets",
    ["ma_GetCharTicketButton"] = "Amener joueur",
    ["ma_GoCharTicketButton"] = "Aller joueur",
    ["ma_AnswerButton"] = "R\195\169pondre",
    ["ma_DeleteButton"] = "Supprimer",
    ["ma_TicketCount"] = "|cFF00FF00Billets:|r ",
    ["ma_TicketsNoNew"] = "Vous n'avez pas de nouveau billet.",
    ["ma_TicketsNewNumber"] = "Vous avez |cffeda55f%s|r nouveaux billets!",
    ["ma_TicketsGoLast"] = "Go to last ticket creator (%s).",
    ["ma_TicketsGetLast"] = "Get him (%s).",
    ["ma_IconHint"] = "|cffeda55fCliquez|r pour ouvrir MangAdmin. |cffeda55fShift-Cliquez|r pour recharger l'interface utilisateur. |cffeda55fAlt-Cliquez|r pour recharger le nombre de billet.",
    ["ma_Reload"] = "Rafraichir",
    ["ma_LoadMore"] = "Charger plus...",
    ["ma_MailRecipient"] = "R\195\169cipient",
    ["ma_Mail"] = "Envoyer lettre",
    ["ma_Send"] = "Envoyer",
    ["ma_MailSubject"] = "Sujet",
    ["ma_MailYourMsg"] = "Ici votre message!",
    ["ma_Online"] = "En-ligne",
    ["ma_Offline"] = "Hors-ligne",
    ["ma_TicketsInfoPlayer"] = "|cFF00FF00Personnage:|r ",
    ["ma_TicketsInfoStatus"] = "|cFF00FF00Status:|r ",
    ["ma_TicketsInfoAccount"] = "|cFF00FF00Compte:|r ",
    ["ma_TicketsInfoAccLevel"] = "|cFF00FF00Niveau d'acc\195\168s:|r ",
    ["ma_TicketsInfoLastIP"] = "|cFF00FF00Derni\195\168re IP:|r ",
    ["ma_TicketsInfoPlayedTime"] = "|cFF00FF00Temps de Jeu:|r ",
    ["ma_TicketsInfoLevel"] = "|cFF00FF00Niveau:|r ",
    ["ma_TicketsInfoMoney"] = "|cFF00FF00Or:|r ",
    ["ma_TicketsNoInfo"] = "Pas d'information sur le billet...",
    ["ma_TicketsNotLoaded"] = "Aucun billet charg\195\169...",
    ["ma_TicketsNoTickets"] = "Il n'y a pas de billet disponible",
    ["ma_TicketTicketLoaded"] = "|cFF00FF00Loaded Ticket-Nr:|r %s\n\nPlayer Information\n\n"
  }
end
