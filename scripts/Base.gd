extends Node2D

onready var cam = $Camera2D
onready var menu = $Menu
onready var credits = $Credits
onready var background = $Background
onready var title = $Background/Label
onready var info = $Info
onready var version_text = $Menu/Infos/Version
onready var status_text = $Menu/Infos/Status
onready var got_message_button = $Menu/Infos/ButtonGotMessage
onready var anim = $Menu/Infos/ButtonGotMessage/AnimationPlayer
#--------------Menu-Preload-----------------------------------------------------
onready var add_menu = $Menu/Add
onready var change_menu = $Menu/Change
onready var show_user_menu = $Menu/ShowUsers
onready var creator_help_button = $Menu/Help
#-------------Options-Preload---------------------------------------------------
onready var options = $Options
onready var slider_img_max = $Options/OfflineSave/HSliderImgMax
onready var save_img_label = $Options/OfflineSave/SaveImgValue
onready var slider_text_size = $Options/TextSize/HSliderTextSize
onready var text_size_label = $Options/TextSize/TextSizeValue
onready var option_scroll_button = $Options/AutoScroll/OptionScroll
onready var reload = $Options/Reload
onready var del_DB_button = $Options/DelDBConfig
onready var creator_button = $Options/CreatorNew
onready var foto_count_text = $Options/FotoCount
onready var off_sw_button = $Options/SWBox/SWDBTurnOff
onready var on_sw_button = $Options/SWBox/SWDBTurnOn
onready var user_id_window = $Options/UniqueID
onready var window_mode = $Options/WindowMode
onready var window_mode_checkbox = $Options/WindowMode/CheckButtonWindowMode
#-----------------Faktory-------------------------------------------------------
onready var img_maker = $ImgMaker

func _ready():
# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed",self,"resize",[true])
	resize(false)
	popup_config()

func popup_config():
	var popup = option_scroll_button.get_popup()
	popup.add_font_override("font",preload("res://font/FontMedium.tres"))
	popup.add_stylebox_override("panel",preload("res://tres/Popup.tres"))
	popup.add_stylebox_override("hover",preload("res://tres/PopupH.tres"))
	popup.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	popup.add_constant_override("vseparation",32)
func resize(save_aktual_size):
	var zoom_x = 0
	var zoom_y = 0
	if save_aktual_size:
		G.saved_window_size = OS.get_window_size()
		G.saved_window_pos = OS.get_window_position()
		zoom_x = G.default_window_size.x/G.saved_window_size.x
		zoom_y = G.default_window_size.y/G.saved_window_size.y
	else:
		zoom_x = G.default_window_size.x/OS.get_window_size().x
		zoom_y = G.default_window_size.y/OS.get_window_size().y
	if zoom_x >= zoom_y:
		G.zoom = zoom_x
	else:
		G.zoom = zoom_y
	cam.set_zoom(Vector2(G.zoom,G.zoom))
	background.set_scale(Vector2(1.0/G.zoom,1.0/G.zoom))
	info.set_scale(Vector2(1.0/G.zoom,1.0/G.zoom))
	

#------------------Buttons------------------------------------------------------
func _on_AnimalABC_pressed():
	var tier_abc_app = load("res://scripts/FotoABC.tscn").instance()
	add_child(tier_abc_app)
	tier_abc_app.connect("back_to_menu",self,"show_menu")
	hide_menu()
	
func _on_SpecialSearch_pressed():
	hide_menu()
func _on_GuessGame_pressed():
	hide_menu()
func _on_Options_pressed():
	hide_menu()
	user_id_window.set_text("USER-ID: "+str(OS.get_unique_id()))
	slider_img_max.set_value(G.save_img_max)
	save_img_label.set_text(str(G.save_img_max))
	slider_text_size.set_value(G.text_size)
	text_size_label.set_text(str(G.text_size))
	option_scroll_button._select_int(G.auto_scroll)
	var foto_anzahl = G.get_savefile_count()
	var mb_circa = foto_anzahl*1.7
	foto_count_text.set_text(str(foto_anzahl)+" Fotos gespeichert (~ "+str(mb_circa)+"MB)")
	if not G.online:
		del_DB_button.set_disabled(true)
		creator_button.set_disabled(true)
	if G.my_status == "ROOT":
		off_sw_button.set_visible(true)
	var check_save_file = File.new()
	if check_save_file.file_exists("user://entries_rescue.save"):
		on_sw_button.set_visible(true)
	if G.my_status == "USER":
		creator_button.set_visible(true)
	check_save_file.close()
	if OS.has_feature("pc"):
		window_mode.set_visible(true)
	options.set_visible(true)
func _on_Add_pressed():
	#hier version update?
	var tier_add_app = load("res://scripts/Add.tscn").instance()
	add_child(tier_add_app)
	tier_add_app.connect("back_to_menu",self,"show_menu")
	hide_menu()
func _on_Help_pressed():
	var help_app = load("res://scripts/Hilfe.tscn").instance()
	add_child(help_app)
	help_app.connect("back_to_menu",self,"show_menu")
	hide_menu()
func _on_Change_pressed():
	var tier_change_app = load("res://scripts/Add.tscn").instance()
	tier_change_app._change_mode(true)
	add_child(tier_change_app)
	tier_change_app.connect("back_to_menu",self,"show_menu")
	hide_menu()
func _on_ShowUsers_pressed():
	var users_app = load("res://scripts/BenutzerVerwaltung.tscn").instance()
	add_child(users_app)
	users_app.connect("back_to_menu",self,"show_menu")
	hide_menu()
func _on_Credits_pressed():
	hide_menu()
	credits.set_visible(true)
func _on_Quit_pressed():
	get_tree().quit()

func show_menu():
	menu.set_visible(true)
	title.set_visible(true)
func hide_menu():
	menu.set_visible(false)
	title.set_visible(false)

func _on_ButtonBackOptions_pressed():
	options.set_visible(false)
	G.save()
	show_menu()
func _on_ButtonBackCredits_pressed():
	credits.set_visible(false)
	show_menu()
	
#----------------Option Funktions-------------------------------------------------------------------
func _on_CheckButtonWindowMode_toggled(button_pressed):
	window_mode_checkbox.set_pressed(button_pressed)
	G.window_mode = button_pressed
	OS.set_borderless_window(!button_pressed)

func _on_HSliderImgMax_value_changed(value):
	G.save_img_max = value
	if value == slider_img_max.get_max():
		G.save_img_max = INF
	save_img_label.set_text(str(G.save_img_max))

func _on_HSliderTextSize_value_changed(value):
	G.text_size = value
	text_size_label.set_text(str(G.text_size))

func _on_OptionButton_item_selected(index):
	G.auto_scroll = index

func _on_ShowIMG_pressed():
# warning-ignore:return_value_discarded
	OS.shell_open(OS.get_user_data_dir()+"/img")
func _on_DeleteIMG_pressed():
	img_maker.remove_all_images()

func _on_DelDBConfig_toggled(button_pressed):
	reload.set_visible(button_pressed)
	if button_pressed:
		del_DB_button.set_disabled(true)
		yield(get_tree().create_timer(3.0), "timeout")
		_on_DelDBConfig_toggled(false)
		del_DB_button.set_disabled(false)

func _on_DelDBConfigOK_pressed():
	del_DB_button.set_pressed(false)
	options.set_visible(false)
	get_node("/root/Base/ImgMaker").start_load_circle()
	yield(img_maker.remove_all_images(), "completed")
	yield(get_tree().create_timer(0.4), "timeout")
	yield(G.delete_db_and_config(), "completed")
	yield(get_tree().create_timer(1.0), "timeout")
	yield(G.check_folders(), "completed")
	yield(G.loading(), "completed")
	yield(G.create_new_db(), "completed")
	get_node("/root/Base").show_menu()
	get_node("/root/Base/ImgMaker").stop_load_circle()
	
func _on_CreatorNew_pressed():
	G.save()
	var become_creator_app = load("res://scripts/BecomeCreator.tscn").instance()
	add_child(become_creator_app)
	become_creator_app.connect("back_to_menu",self,"show_menu")
	options.set_visible(false)
	
func _on_SWDBTurnOff_pressed():
	if G.my_status == "ROOT":
		yield(get_tree(), "idle_frame")
		var rescue = yield(G.get_SW_data("entries"), "completed")
		var rescuefile = File.new()
		rescuefile.open("user://entries_rescue.save", File.WRITE)
		rescuefile.store_var(rescue)
		rescuefile.close()
		yield(G.del_SW_data("entries"), "completed")
		get_node("/root/Base")._show_info("Silent Wolf is OFF")
	
func _on_SWDBTurnOn_pressed():
	yield(get_tree(), "idle_frame")
	var rescuefile = File.new()
	rescuefile.open("user://entries_rescue.save", File.READ)
	var rescue = rescuefile.get_var()
	rescuefile.close()
	yield(get_tree().create_timer(0.1), "timeout")
	yield(SilentWolf.Players.post_player_data("entries",var2str(rescue)), "sw_player_data_posted")
	var dir = Directory.new()
	dir.remove("user://entries_rescue.db")
	get_node("/root/Base")._show_info("Silent Wolf is ON")


#----------------Info-Text------------------------------------------------------
func _show_info(itext):
	var new_info = preload("res://scripts/InfoBox.tscn").instance()
	itext = G._to_normal_name(itext)
	new_info.set_new_text(itext)
	info.add_child(new_info)

#-------------------Status------------------------------------------------------
func _set_status_menu(status):
	status_text.set_text(status)
	if status == "USER":
		pass
	elif status == "CREATOR":
		add_menu.set_visible(true)
		creator_help_button.set_visible(true)
	elif status == "ADMIN":
		add_menu.set_visible(true)
		change_menu.set_visible(true)
	elif status == "ROOT":
		add_menu.set_visible(true)
		change_menu.set_visible(true)
		show_user_menu.set_visible(true)

func _set_version_text(the_text):
	version_text.set_text(the_text)

#------------------------Meta-Click-Funktions-----------------------------------
func _on_CreditText_meta_clicked(meta):
	OS.set_clipboard(meta)
	if meta.begins_with("https://"):
# warning-ignore:return_value_discarded
		OS.shell_open(meta)
	get_node("/root/Base")._show_info("Weblink kopiert")

#--------------------------Show-New-Messages------------------------------------
func _new_message_there():
	got_message_button.set_disabled(false)
	got_message_button.set_self_modulate(Color(1,0.54,0.31,1))
	anim.play("new")

func _message_there():
	if got_message_button.is_disabled():
		got_message_button.set_disabled(false)
		got_message_button.set_self_modulate(Color(1,1,1,1))

func _on_ButtonGotMessage_pressed():
	got_message_button.set_self_modulate(Color(1,1,1,1))
	anim.stop()
	var message_app = load("res://scripts/Messages.tscn").instance()
	add_child(message_app)
	message_app.connect("back_to_menu",self,"show_menu")
	hide_menu()
