extends VBoxContainer

onready var f_lizenz_m = $FlizenzM
onready var f_url_m = $HBoxFurlM/FurlM
onready var f_p_url_m = $HBoxFPurlM/FPurlM
onready var f_filename_m = $HBoxFFnameM/FFnameM
onready var f_urheber_m = $HBoxFurheberM/FurheberM
onready var foto = $Rahmen/Foto1
onready var hinweis_m = $Rahmen/Hinweis

var f_lizenz_m_popup

func _ready():
	popup_config()
	load_lizenz_menu()

func popup_config():
	f_lizenz_m_popup = f_lizenz_m.get_popup()
	f_lizenz_m_popup.add_font_override("font",preload("res://font/FontMedium.tres"))
	f_lizenz_m_popup.add_stylebox_override("panel",preload("res://tres/Popup.tres"))
	f_lizenz_m_popup.add_stylebox_override("hover",preload("res://tres/PopupH.tres"))
	f_lizenz_m_popup.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	f_lizenz_m_popup.add_constant_override("vseparation",7)

func load_lizenz_menu():
	var menu_list = G.db_query("select name from item_Lizenz")
	for i in menu_list.size():
		f_lizenz_m_popup.add_radio_check_item(menu_list[i]["name"])

func _on_ButtonEinfFurlM_pressed():
	f_url_m.set_text(OS.get_clipboard())
	_on_FurlM_text_entered(OS.get_clipboard())
func _on_FurlM_text_entered(new_text):
	foto.set_texture(null)
	if new_text.length() == 0:
		f_url_m.set_self_modulate(Color(1,1,1,1))
	elif new_text.begins_with("https://") and new_text.length() > 12:
		f_url_m.set_self_modulate(Color(1,1,1,1))
		get_image_from_internet(new_text)
	else:
		f_url_m.set_self_modulate(ColorN("Red"))

func _on_ButtonEinfFPurlM_pressed():
	f_p_url_m.set_text(OS.get_clipboard())

func _on_ButtonEinfFFnameM_pressed():
	f_filename_m.set_text(OS.get_clipboard())

func _on_ButtonEinfFurheberM_pressed():
	f_urheber_m.set_text(OS.get_clipboard())

func get_image_from_internet(url):
	get_node("/root/Base")._show_info("Lade Foto...")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	var error = http_request.request(url)
	if not error == OK:
		return 
	return

func _http_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var image = Image.new()
		var error = image.load_jpg_from_buffer(body)
		if error == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image, 4)
			foto.set_texture(texture)
			hinweis_m.set_visible(false)

func _load_foto_for_change(url_text):
	if url_text != "":
		_on_FurlM_text_entered(url_text)

func _on_FlizenzM_item_selected(index):
	if index > 0:
		f_lizenz_m.add_color_override("font_color",Color(1,0.54,0.31,1))
		f_lizenz_m.add_color_override("font_color_focus",Color(1,0.54,0.31,1))
		f_lizenz_m.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	else:
		f_lizenz_m.add_color_override("font_color",Color(1,1,1,1))
		f_lizenz_m.add_color_override("font_color_focus",Color(1,1,1,1))
		f_lizenz_m.add_color_override("font_color_hover",Color(1,1,1,1))
