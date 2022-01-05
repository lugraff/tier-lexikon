extends VBoxContainer

onready var beschreibung = $TBeschreibung
onready var keyboard_button = $HBox/ButtonKeyboard
onready var lizenz_menu = $HBoxTextPageLink/Textlizenz
onready var url_text = $HBoxTextPageLink/TextPageLink

var lizenz_menu_popup
var date_text = ""

func _ready():
	if not G.touch_input:
		keyboard_button.set_pressed(false)
		keyboard_button.set_disabled(true)
	var aktual_date = OS.get_date()
	date_text = "Der Text wurde am "+str(aktual_date["day"])+"."+str(aktual_date["month"])+"."+str(aktual_date["year"])+" erstellt."
	popup_config()
	load_lizenz_menu()
	modify_text()
	
func popup_config():
	lizenz_menu_popup = lizenz_menu.get_popup()
	lizenz_menu_popup.add_font_override("font",preload("res://font/FontMedium.tres"))
	lizenz_menu_popup.add_stylebox_override("panel",preload("res://tres/Popup.tres"))
	lizenz_menu_popup.add_stylebox_override("hover",preload("res://tres/PopupH.tres"))
	lizenz_menu_popup.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	lizenz_menu_popup.add_constant_override("vseparation",7)

func load_lizenz_menu():
	var menu_list = G.db_query("select name from item_Lizenz")
	for i in menu_list.size():
		lizenz_menu_popup.add_radio_check_item(menu_list[i]["name"])

func _on_ButtonEinfTBeschreibung_pressed():
	var aktueller_text = beschreibung.get_text()
	if aktueller_text.begins_with("Beschreibung..."):
		aktueller_text = ""
	beschreibung.set_text(aktueller_text+str(OS.get_clipboard())+"\n\n"+date_text)

func modify_text():
	if G.text_size == 1:
		beschreibung.add_font_override("font",preload("res://font/FontMedSmall.tres"))
	elif G.text_size == 3:
		beschreibung.add_font_override("font",preload("res://font/FontMedBig.tres"))
	else:
		beschreibung.add_font_override("font",preload("res://font/FontMedium.tres"))
	if get_index() == 0:
		beschreibung.set_text("Beschreibung...\n\n...verwende [u]Text[/u] um Text zu unterstreichen.\n\n"+date_text)

func _on_ButtonUndo_pressed():
	beschreibung.undo()

func _on_ButtonRedo_pressed():
	beschreibung.redo()

func _on_ButtonKeyboard_toggled(button_pressed):
	beschreibung.set_virtual_keyboard_enabled(button_pressed)

func _on_ButtonTextPageEinf_pressed():
	url_text.set_text(OS.get_clipboard())

func _get_beschreibung():
	return beschreibung.get_text()

func _get_url():
	return url_text.get_text()

func _get_lizenz():
	return lizenz_menu.get_selected()

func _set_beschreibung(setter):
	beschreibung.set_text(setter)

func _set_beschr_url(setter):
	url_text.set_text(setter)

func _set_beschr_lizenz(setter):
	lizenz_menu._select_int(setter)

func _on_Textlizenz_item_selected(index):
	if index > 0:
		lizenz_menu.add_color_override("font_color",Color(1,0.54,0.31,1))
		lizenz_menu.add_color_override("font_color_focus",Color(1,0.54,0.31,1))
		lizenz_menu.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	else:
		lizenz_menu.add_color_override("font_color",Color(1,1,1,1))
		lizenz_menu.add_color_override("font_color_focus",Color(1,1,1,1))
		lizenz_menu.add_color_override("font_color_hover",Color(1,1,1,1))
