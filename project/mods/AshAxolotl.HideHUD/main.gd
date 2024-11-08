extends Node

var DEFAULT_SETTINGS = {
	"Notification Popup": false, 
	"Badge Popup": false, 
	"Top Right Buttons": false, 
	"HotBar": false, 
	"Game Chat": false, 
	"Game Chat Input": false,
	"Interaction Notification": false,
	"Static Effects": false,
	"Freecam Warning": false,
	"Item Help": false,
	"Bait": false,
	"EMPTY Bait": false,
	"Fishing Minigame": false,
	"Dialogue": false,
	"Own Name": false,
	"Own Title": false,
	"Own Speech Bubble": false,
	"Other Name": false,
	"Other Title": false,
	"Other Speech Bubble": false,
	"Saving Icon": false
}

const MOD_ID := "AshAxolotl.HideHUD"

onready var PlayerAPI = get_node_or_null("/root/BlueberryWolfiAPIs/PlayerAPI")
onready var TackleBox = get_node_or_null("/root/TackleBox")

var settings = {}
var gui

func _ready():
	PlayerAPI.connect("_ingame", self, "ingame")
	PlayerAPI.connect("_player_added", self, "player_added")
	get_node("/root/UserSave").connect("child_entered_tree", self, "usersave_child_entered_tree")
	
	# Load Tackle Box / Settings
	if TackleBox == null:
		push_error("HideHUD: TackbleBox was not found using default settings. pls install tacklebox to change settings!")
		settings = DEFAULT_SETTINGS
	else:
		TackleBox.connect("mod_config_updated", self, "mod_config_updated")
		settings = TackleBox.get_mod_config(MOD_ID) 
		if settings.size() != DEFAULT_SETTINGS.size():
			for key in DEFAULT_SETTINGS.keys():
				DEFAULT_SETTINGS[key] = settings.get(key, DEFAULT_SETTINGS[key])
			TackleBox.set_mod_config(MOD_ID, DEFAULT_SETTINGS)
			settings = TackleBox.get_mod_config(MOD_ID)
			
func mod_config_updated(mod_id, new_config):
	if mod_id == MOD_ID:
		settings = new_config
		hide_hud()

func ingame():
	hide_hud()
	gui.get_node("bait").connect("visibility_changed", self, "bait_changed")
	gui.get_node("bait").connect("_update", self, "bait_changed")
	gui.get_node("interact_notif").connect("visibility_changed", self, "interact_notif_visibility_changed")
	gui.get_node("freecamwarning").connect("visibility_changed", self, "freecamwarning_visibility_changed")
	get_node("/root/playerhud").connect("child_entered_tree", self, "new_hud_element")

func player_added(player):
	if player != PlayerAPI.local_player:
		player.get_node("Viewport/player_label/VBoxContainer/Label").visible = !settings["Other Name"]
		player.get_node("Viewport/player_label/VBoxContainer/Label2").visible = !settings["Other Title"]
		player.get_node("Viewport/player_label/bubble_box").visible = !settings["Other Speech Bubble"]

func hide_hud():
	gui = get_node_or_null("/root/playerhud/main/in_game")
	if gui == null:
		push_warning("HideHUD: Gui was not found! are you in game?")
		return
	get_node("/root/playerhud/notif_popup").visible = !settings["Notification Popup"]
	get_node("/root/playerhud/badge_popup").visible = !settings["Badge Popup"]
	get_node("/root/playerhud/main/dialogue/Panel").visible= !settings["Dialogue"]
	gui.get_node("HBoxContainer").visible = !settings["Top Right Buttons"]
	gui.get_node("hotbar").visible = !settings["HotBar"]
	gui.get_node("static_effects").visible = !settings["Static Effects"]
	gui.get_node("item_help").visible = !settings["Item Help"]
	gui.get_node("show_chat").visible = !settings["Game Chat"]
	gui.get_node("gamechat/Panel").visible = !settings["Game Chat"]
	gui.get_node("gamechat/Panel2").visible = !settings["Game Chat"]
	#gui.get_node("gamechat/Button").visible = !settings["Game Chat"] # this is never visible in the vanilla game
	gui.get_node("gamechat/RichTextLabel").visible = !settings["Game Chat"]
	if settings["Game Chat Input"]: # sets the scale to 0 instead of visible to make sure you can still type
		gui.get_node("gamechat/LineEdit").rect_scale = Vector2(0, 0)
	else:
		gui.get_node("gamechat/LineEdit").rect_scale = Vector2(1, 1)
	
	PlayerAPI.local_player.get_node("Viewport/player_label/VBoxContainer/Label").visible = !settings["Own Name"]
	PlayerAPI.local_player.get_node("Viewport/player_label/VBoxContainer/Label2").visible = !settings["Own Title"]
	PlayerAPI.local_player.get_node("Viewport/player_label/bubble_box").visible = !settings["Own Speech Bubble"]
	
	var other_players_list = PlayerAPI.players
	other_players_list.erase(PlayerAPI.local_player)
	for other_player in other_players_list:
		other_player.get_node("Viewport/player_label/VBoxContainer/Label").visible = !settings["Other Name"]
		other_player.get_node("Viewport/player_label/VBoxContainer/Label2").visible = !settings["Other Title"]
		other_player.get_node("Viewport/player_label/bubble_box").visible = !settings["Other Speech Bubble"]

func bait_changed():
	var bait = gui.get_node("bait")
	if bait.visible == true:
		if bait.get_node("HBoxContainer/Label").text == "":
			bait.visible = !settings["EMPTY Bait"]
		else:
			bait.visible = !settings["Bait"]
			
func interact_notif_visibility_changed():
	var interact_notif = gui.get_node("interact_notif")
	if interact_notif.visible == true:
		interact_notif.visible = !settings["Interaction Notification"]

func freecamwarning_visibility_changed():
	var freecamwarning = gui.get_node("freecamwarning")
	if freecamwarning.visible == true:
		freecamwarning.visible = !settings["Freecam Warning"]

func new_hud_element(node):
	if node.name == "fishing3":
		node.visible = !settings["Fishing Minigame"]
		
func usersave_child_entered_tree(node):
	if "anim" in node.name:
		node.visible = !settings["Saving Icon"]
