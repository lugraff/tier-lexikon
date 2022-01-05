extends Control

signal back_to_menu

onready var next_button = $Add/HBoxNavi/Next
onready var prev_button = $Add/HBoxNavi/Prev
onready var confirm = $Confirmation

onready var page1 = $Add/Page1
onready var name_edit = $Add/Page1/HBoxName/Name
onready var name_edit_box = $Add/Page1/HBoxName
onready var textbox_cont = $Add/Page1/TextBoxContainer
onready var button_auswahl_text = $Add/Page1/HBoxText/ButtonAuswahlTextBox
onready var button_add_text = $Add/Page1/HBoxText/ButtonAddTextBox
onready var tier_auswahl_box = $Add/Page1/HBoxAuswahl
onready var tier_auswahl = $Add/Page1/HBoxAuswahl/ButtonAuswahl

onready var tierliste_scroll = $TierScroll
onready var tierliste = $TierScroll/Tierliste

onready var page2 = $Add/Page2
onready var f_url_m = $Add/Page2/HBoxFurlM/FurlM
onready var f_p_url_m = $Add/Page2/HBoxFPurlM/FPurlM
onready var f_urheber_m = $Add/Page2/HBoxFurheberM/FurheberM
onready var f_lizenz_m = $Add/Page2/FlizenzM
onready var f_filename_m = $Add/Page2/HBoxFFnameM/FFnameM

onready var page3 = $Add/Page3
onready var f_url_w = $Add/Page3/HBoxFurlW/FurlW
onready var f_p_url_w = $Add/Page3/HBoxFPurlW/FPurlW
onready var f_urheber_w = $Add/Page3/HBoxFurheberW/FurheberW
onready var f_lizenz_w = $Add/Page3/FlizenzW
onready var f_filename_w = $Add/Page3/HBoxFFnameW/FFnameW

onready var rahmen = $Add/Page2/Rahmen
onready var foto_1 = $Add/Page2/Rahmen/Foto1
onready var foto_2 = $Add/Page3/Rahmen/Foto2

onready var page4 = $Add/Page4
onready var item_name_input = $Add/Page4/NewItem/ItemName
onready var new_item_button = $Add/Page4/NewItem/NewItemButton
onready var items = $Add/Page4/Scroll/Items
onready var new_item_typ = $Add/Page4/NewItem/OptionItemTyp

onready var label = $Add/HeadBox/Label

var drag_area = 0 #for Android
var foto_speed = 1 #for Desktop
var foto_1_scale = 1
var foto_1_pos = Vector2.ZERO
var foto_2_scale = 1
var foto_2_pos = Vector2.ZERO

var new_entry = {}
var new_checked_name = ""
var new_item_popup
var text_auswahl_popup
var tier_auswahl_popup
var scroll_cont_vscroll
var change = false
var auswahl = ""
var temp_ersteller = ""
var temp_bearbeiter = ""

func _change_mode(mode):
	change = mode

func _ready():
	if change: label.set_text("Eintrag Bearbeitung")
	next_button.set_text("Weiter")
	if OS.has_touchscreen_ui_hint():
		set_process(false)
	drag_area = rahmen.get_position().y
	page1.set_visible(true)
	page2.set_visible(false)
	page3.set_visible(false)
	page4.set_visible(false)
	popup_config()
	
	if change:
		name_edit_box.set_visible(false)
		tier_auswahl_box.set_visible(true)
		load_tier_liste()
	

func popup_config():
	new_item_popup = new_item_typ.get_popup()
	new_item_popup.add_font_override("font",preload("res://font/FontMedium.tres"))
	new_item_popup.add_stylebox_override("panel",preload("res://tres/Popup.tres"))
	new_item_popup.add_stylebox_override("hover",preload("res://tres/PopupH.tres"))
	new_item_popup.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	text_auswahl_popup = button_auswahl_text.get_popup()
	text_auswahl_popup.add_font_override("font",preload("res://font/FontMedium.tres"))
	text_auswahl_popup.add_stylebox_override("panel",preload("res://tres/Popup.tres"))
	text_auswahl_popup.add_stylebox_override("hover",preload("res://tres/PopupH.tres"))
	text_auswahl_popup.add_color_override("font_color_hover",Color(1,0.54,0.31,1))
	text_auswahl_popup.add_constant_override("vseparation",32)
	var confirm_button = confirm.get_ok()
	confirm_button.add_stylebox_override("hover",preload("res://tres/ButtonMenu.tres"))
	confirm_button.add_stylebox_override("pressed",preload("res://tres/ButtonMenu.tres"))
	confirm_button.add_stylebox_override("focus",preload("res://tres/ButtonMenu.tres"))
	confirm_button.add_stylebox_override("disabled",preload("res://tres/ButtonMenu.tres"))
	confirm_button.add_stylebox_override("normal",preload("res://tres/ButtonMenu.tres"))

	
func load_tier_liste():
	yield(get_tree(), "idle_frame")
	for i in G.SW_entries.size():
		if i != 0:
			if G.SW_entries[i][0].begins_with("tier_"):
				if G.SW_entries[i][1] == -1:
					var new_tier_entry = preload("res://scripts/Eintrag.tscn").instance()
					new_tier_entry._set_name(G.SW_entries[i][0])
					new_tier_entry.connect("eintrag_pressed", self, "_on_ButtonAuswahl_item_selected", [tierliste.get_child_count()])
					tierliste.add_child(new_tier_entry)
	var tier_list = G.db_query("select name from Tiere")
	var loading_entries_array = []
	for i in tier_list.size():
		var temp_text = tier_list[i]["name"]
		temp_text = G._to_normal_name(temp_text)
		loading_entries_array.append(temp_text)
	loading_entries_array.sort()
	for i in loading_entries_array.size():
		var new_tier_entry = preload("res://scripts/Eintrag.tscn").instance()
		new_tier_entry._set_name(loading_entries_array[i])
		new_tier_entry.connect("eintrag_pressed", self, "_on_ButtonAuswahl_item_selected", [tierliste.get_child_count()])
		tierliste.add_child(new_tier_entry)

func _on_ButtonOpenContext_pressed():
	G._fake_right_click()

func _on_ButtonBackAdd_pressed():
	emit_signal("back_to_menu")
	queue_free()

func reset_textboxes():
	for i in textbox_cont.get_child_count():
		textbox_cont.get_child(i).set_visible(false)
	textbox_cont.get_child(0).set_visible(true)

func _on_Prev_pressed():
	if page2.is_visible():
		page2.set_visible(false)
		page1.set_visible(true)
		prev_button.set_disabled(true)
		reset_textboxes()
		#textbox1 anzeigen #alle anderen ausblenden
	elif page3.is_visible():
		page3.set_visible(false)
		page2.set_visible(true)
	elif page4.is_visible():
		next_button.set_text("Weiter")
		page4.set_visible(false)
		page3.set_visible(true)
	
func _on_Min_pressed():
	if OS.has_touchscreen_ui_hint():
# warning-ignore:return_value_discarded
		OS.shell_open("https://") 
	else:
		OS.set_window_minimized(true)
	
func _on_Next_pressed():
	if page1.is_visible():
		if yield(check_name(), "completed"):
			yield(check_textboxes(), "completed")
			page1.set_visible(false)
			page2.set_visible(true)
			page3.set_visible(false)
			prev_button.set_disabled(false)
			resize()
	elif page2.is_visible():
		if check_foto_1():
			page1.set_visible(false)
			page2.set_visible(false)
			page3.set_visible(true)
			resize()
	elif page3.is_visible():
		if check_foto_2():
			page1.set_visible(false)
			page2.set_visible(false)
			page3.set_visible(false)
			page4.set_visible(true)
			next_button.set_text("Fertig->")
	elif page4.is_visible():
		if new_checked_name == "":
			name_edit.set_self_modulate(ColorN("Red"))
			page4.set_visible(false)
			next_button.set_text("Weiter")
			reset_textboxes()
			page1.set_visible(true)
			return
		for i in items.get_child_count():
			if items.get_child(i).has_method("_is_checked"):
				if not items.get_child(i)._is_checked():
					return
		confirm.set_visible(true)
		
func _on_Confirmation_confirmed():
	create_the_entry()
	
func create_the_entry():
		get_node("/root/Base/ImgMaker").start_load_circle()
		set_visible(false)
		get_node("/root/Base")._show_info("Eintrag wird geprüft...")
		if not change:
			new_entry["ersteller"] = str(G.my_name)
			new_entry["bearbeiter"] = null
		elif change:
			new_entry["ersteller"] = temp_ersteller
			if str(G.my_name) != temp_ersteller:
				new_entry["bearbeiter"] = str(G.my_name)+", "+str(temp_bearbeiter)
			get_node("/root/Base/ImgMaker").remove_img_by_name(new_checked_name)
		new_entry["name"] = new_checked_name
		var temp_beschreibung = {}
		var temp_url = {}
		var temp_lizenz = {}
		for i in textbox_cont.get_child_count():
			temp_beschreibung[i] = textbox_cont.get_child(i)._get_beschreibung()
			temp_url[i] = textbox_cont.get_child(i)._get_url()
			temp_lizenz[i] = textbox_cont.get_child(i)._get_lizenz()
		new_entry["t_beschreibung"] = var2str(temp_beschreibung)
		new_entry["t_url"] = var2str(temp_url)
		new_entry["t_lizenz"] = var2str(temp_lizenz)
		new_entry["f_url_m"] = f_url_m.get_text()
		new_entry["f_p_url_m"] = f_p_url_m.get_text()
		new_entry["f_urheber_m"] = f_urheber_m.get_text()
		if f_lizenz_m.get_selected() > 0:
			new_entry["f_lizenz_m"] = f_lizenz_m.get_selected()-1
		else: new_entry["f_lizenz_m"] = null
		new_entry["f_filename_m"] = f_filename_m.get_text()
		new_entry["f_form_m"] = var2str({"scale" : foto_1_scale,"pos_x" : foto_1_pos.x,"pos_y" : foto_1_pos.y,"flip" : foto_1.is_flipped_h()})
		new_entry["f_url_w"] = f_url_w.get_text()
		new_entry["f_p_url_w"] = f_p_url_w.get_text()
		new_entry["f_urheber_w"] = f_urheber_w.get_text()
		if f_lizenz_w.get_selected() > 0:
			new_entry["f_lizenz_w"] = f_lizenz_w.get_selected()-1
		else: new_entry["f_lizenz_w"] = null
		new_entry["f_filename_w"] = f_filename_w.get_text()
		new_entry["f_form_w"] = var2str({"scale" : foto_2_scale,"pos_x" : foto_2_pos.x,"pos_y" : foto_2_pos.y,"flip" : foto_2.is_flipped_h()})
		new_entry["t_besonderes"] = get_node("Add/Page4/Scroll/Items/Besonderes/Text").get_text()
		for i in G.SW_entries.size():#----------make Item Tier-entries:
			if i != 0:
				if G.SW_entries[i][0] != "item_Lizenz":
					if G.SW_entries[i][0].begins_with("item_"):
						if G.SW_entries[i][0].begins_with("item_zahl_"):
							var item_zahl = get_node("Add/Page4/Scroll/Items/"+str(G.SW_entries[i][0])+"/Wert").get_text()
							if item_zahl == "": item_zahl = null
							new_entry[G.SW_entries[i][0]] = item_zahl
						elif G.SW_entries[i][0].begins_with("item_mul_"):
							var item_mul = get_node("Add/Page4/Scroll/Items/"+str(G.SW_entries[i][0]))._select_getter()
							if item_mul == {}: item_mul = null
							new_entry[G.SW_entries[i][0]] = str(item_mul)
							var all_item_names = get_node("Add/Page4/Scroll/Items/"+str(G.SW_entries[i][0]))._all_item_getter()
							yield(get_tree().create_timer(0.3), "timeout")
							get_node("/root/Base")._show_info(str(G.SW_entries[i][0]) + " wird beschrieben...")
							yield(G.post_SW_data(G.SW_entries[i][0],all_item_names), "completed")
						else:
							var full_item_name = G.SW_entries[i][0]
							var item_name = full_item_name
							item_name.erase(0, 5)
							var item_node = get_node("Add/Page4/Scroll/Items/"+str(full_item_name)+"/Select")
							if not item_node.get_text().ends_with(" auswählen:"):
								var temp_entry_text = item_node.get_text()
								if temp_entry_text == "Eigenschafts-Typ erstellen":
									var item_line = get_node("Add/Page4/Scroll/Items/"+str(full_item_name)+"/HBoxNew/NewRow")
									var item_line_text = item_line.get_text()
									var item_line_id = get_node("Add/Page4/Scroll/Items/"+str(full_item_name)).get_selected_entry()
									if item_line_text != "":
										var aktual_item_rows = yield(G.get_SW_data(full_item_name), "completed")
										for r in aktual_item_rows.size():
											if aktual_item_rows[r] == item_line_text:
												item_line.set_self_modulate(ColorN("Red"))
												set_visible(true)
												get_node("/root/Base/ImgMaker").stop_load_circle()
												return
										item_line.set_self_modulate(Color(1,1,1,1))
										yield(create_new_item_row(full_item_name,aktual_item_rows,item_line_id,item_line_text), "completed")
										new_entry[full_item_name] = item_line_id
										#Achtung! Wenn jetzt noch ein neuer row erstellt wird und der abbricht ist der zuvor erstellte nicht anwählbar!
									else:
										item_line.set_self_modulate(ColorN("Red"))
										set_visible(true)
										get_node("/root/Base/ImgMaker").stop_load_circle()
										return
								else:
									new_entry[full_item_name] = get_node("Add/Page4/Scroll/Items/"+str(full_item_name)).get_selected_entry()
							else: 
								new_entry[full_item_name] = null
		if yield(G.create_new_tier_in_sw(new_entry,change), "completed"):
			yield(get_tree().create_timer(1.0), "timeout")
			yield(G.scan_for_new_entries(), "completed")
			get_node("/root/Base/ImgMaker").stop_load_circle()
			_on_ButtonBackAdd_pressed()
		set_visible(true)
		get_node("/root/Base/ImgMaker").stop_load_circle()
 
func create_new_item_row(sw_item,sw_item_rows,new_row_id,new_row_text):
	yield(get_tree(), "idle_frame")
	get_node("/root/Base")._show_info(str(new_row_text) + " wird erstellt...")
	sw_item_rows[new_row_id] = new_row_text
	yield(G.post_SW_data(sw_item,sw_item_rows), "completed")
	yield(get_tree().create_timer(0.2), "timeout")

func _on_NewItemButton_pressed():
	new_item_button.set_disabled(true)
	next_button.set_disabled(true)
	var new_item_name = item_name_input.get_text()
	new_item_name = G._to_valid_name(new_item_name)
	if new_item_name == "" or not new_item_name.is_valid_identifier() or new_item_name.length() > 31:
		item_name_input.set_self_modulate(ColorN("Red"))
		new_item_button.set_disabled(false)
		next_button.set_disabled(false)
		return
	var new_full_item_name = ""
	if new_item_typ.get_selected() == 0:
		new_full_item_name = "item_"+str(new_item_name)
	elif new_item_typ.get_selected() == 1:
		new_full_item_name = "item_zahl_"+str(new_item_name)
	elif new_item_typ.get_selected() == 2:
		new_full_item_name = "item_mul_"+str(new_item_name)
	var aktual_entries = yield(G.get_SW_data("entries"), "completed")
	var exists_already = false
	for i in aktual_entries.size():
		if i != 0:
			if new_full_item_name == G.SW_entries[i][0]:
				exists_already = true
	if exists_already:
		get_node("/root/Base")._show_info(str(new_item_name)+" existiert bereits!")
		item_name_input.set_self_modulate(ColorN("Red"))
		new_item_button.set_disabled(false)
		next_button.set_disabled(false)
		return
	item_name_input.set_self_modulate(Color(1,1,1,1))
	get_node("/root/Base")._show_info("Eigenschaft "+str(new_item_name)+" wird erstellt...")
	yield(G.post_SW_data(new_full_item_name,{}), "completed")
	yield(get_tree().create_timer(1), "timeout")
	yield(G.scan_for_new_entries(), "completed")
	yield(get_tree().create_timer(0.1), "timeout")
	if new_item_typ.get_selected() == 0:
		new_text_item(new_full_item_name)
	elif new_item_typ.get_selected() == 1:
		new_zahl_item(new_full_item_name)
	elif new_item_typ.get_selected() == 2:
		new_multi_item(new_full_item_name)
	item_name_input.set_text("")
	new_item_button.set_disabled(false)
	next_button.set_disabled(false)
		
func new_text_item(full_item_name):
	var new_item_text = preload("res://scripts/Item.tscn").instance()
	new_item_text._set_item(full_item_name)
	items.add_child(new_item_text)
	
func new_zahl_item(full_item_name):
	var new_item_zahl = preload("res://scripts/ItemZahl.tscn").instance()
	new_item_zahl._set_item(full_item_name)
	items.add_child(new_item_zahl)

func new_multi_item(full_item_name):
	var new_item_multi = preload("res://scripts/ItemMulti.tscn").instance()
	new_item_multi._set_item(full_item_name)
	items.add_child(new_item_multi)


#-------------Page1-Funktions---------------------------------------------------
func check_name():
	yield(get_tree(), "idle_frame")
	if change:
		tier_auswahl.set_self_modulate(Color(1,1,1,1))
		new_checked_name = auswahl
		return true
	else:
		if name_edit.get_text() == "":
			return true
		var new_name = "tier_"+str(name_edit.get_text())
		if new_name.length() < 8:
			name_edit.set_self_modulate(ColorN("Red"))
			return false
		new_name = G._to_valid_name(new_name)
		if not new_name.is_valid_identifier():
			name_edit.set_self_modulate(ColorN("Red"))
			return false
		if new_name.length() > 30:
			name_edit.set_self_modulate(ColorN("Red"))
			return false
		var exists_already = false
		for i in G.SW_entries.size():
			if i != 0:
				if new_name == G.SW_entries[i][0]:
					exists_already = true
		if exists_already:
			name_edit.set_self_modulate(ColorN("Red"))
			return false
		name_edit.set_self_modulate(Color(1,1,1,1))
		new_checked_name = new_name
		return true

func check_textboxes():
	yield(get_tree(), "idle_frame")
	for i in textbox_cont.get_child_count():
		if i != 0:
			if textbox_cont.get_child(i)._get_beschreibung() == "":
				textbox_cont.get_child(i).queue_free()
				button_add_text.set_disabled(false)
	button_auswahl_text.clear()
	yield(get_tree().create_timer(0.3), "timeout")
	for i in textbox_cont.get_child_count():
		button_auswahl_text.add_item("Textbox "+ str(i+1))


func _on_ButtonAuswahl_toggled(button_pressed):
	tierliste_scroll.set_visible(button_pressed)
func _on_ButtonAuswahl_item_selected(index):
	tierliste_scroll.set_visible(false)
	tier_auswahl.set_pressed(false)
	foto_1.set_texture(null)
	f_lizenz_m._select_int(0)
	foto_2.set_texture(null)
	f_lizenz_w._select_int(0)
	var selected_tier_name = tierliste.get_child(index)._get_name()
	tier_auswahl.set_text(selected_tier_name)
	if selected_tier_name.begins_with("tier_"):
		auswahl = selected_tier_name
		load_unchecked_tier(selected_tier_name)
	else:
		auswahl = "tier_"+str(selected_tier_name)
		auswahl = G._to_valid_name(auswahl)
		load_tier(auswahl)

func load_tier(this_auswahl):
	var result = G.db_query("select * from Tiere WHERE name = '"+this_auswahl+"'")
	temp_ersteller = result[0]["ersteller"]
	temp_bearbeiter = result[0]["bearbeiter"]
	if temp_bearbeiter == null:
		temp_bearbeiter = ""
	var beschreibungen = str2var(result[0]["t_beschreibung"])
	var beschr_url = str2var(result[0]["t_url"])
	var beschr_lizenz = str2var(result[0]["t_lizenz"])
	for i in beschreibungen.size():
		if i != 0:
			var new_textbox = preload("res://scripts/TextBox.tscn").instance()
			new_textbox.set_visible(false)
			textbox_cont.add_child(new_textbox)
			button_auswahl_text.add_item("Textbox "+str(i+1))
		textbox_cont.get_child(i)._set_beschreibung(beschreibungen[i])
		textbox_cont.get_child(i)._set_beschr_url(beschr_url[i])
		textbox_cont.get_child(i)._set_beschr_lizenz(beschr_lizenz[i])
	var foto_1_url = result[0]["f_url_m"]
	if foto_1_url != "":
		f_url_m.set_text(foto_1_url)
		page2._load_foto_for_change(foto_1_url)
	f_p_url_m.set_text(result[0]["f_p_url_m"])
	f_filename_m.set_text(result[0]["f_filename_m"])
	f_urheber_m.set_text(result[0]["f_urheber_m"])
	if result[0]["f_lizenz_m"] != null:
		f_lizenz_m._select_int(result[0]["f_lizenz_m"]+1)
	var temp_form_1 = str2var(result[0]["f_form_m"])
	foto_1_scale = temp_form_1["scale"]
	foto_1_pos = Vector2(temp_form_1["pos_x"],temp_form_1["pos_y"])
	foto_1.set_flip_h(temp_form_1["flip"])
	
	var foto_2_url = result[0]["f_url_w"]
	if foto_2_url != "":
		#yield(get_tree().create_timer(1.1), "timeout")
		f_url_w.set_text(foto_2_url)
		page3._load_foto_for_change(foto_2_url)
	f_p_url_w.set_text(result[0]["f_p_url_w"])
	f_filename_w.set_text(result[0]["f_filename_w"])
	f_urheber_w.set_text(result[0]["f_urheber_w"])
	if result[0]["f_lizenz_w"] != null:
		f_lizenz_w._select_int(result[0]["f_lizenz_w"]+1)
	var temp_form_2 = str2var(result[0]["f_form_w"])
	foto_2_scale = temp_form_2["scale"]
	foto_2_pos = Vector2(temp_form_2["pos_x"],temp_form_2["pos_y"])
	foto_2.set_flip_h(temp_form_2["flip"])
	
	
	get_node("Add/Page4/Scroll/Items/Besonderes")._set_text(result[0]["t_besonderes"])
	
	
	for i in items.get_child_count():
		var item_node = items.get_child(i)
		var item_full_name = item_node.get_name()
		if item_full_name.begins_with("item_zahl_"):
			var temp = result[0][item_full_name]
			if temp != null:
				temp = str(temp).to_float()
				item_node._set_it(temp)
		elif item_full_name.begins_with("item_mul_"):
			var temp = result[0][item_full_name]
			if temp != null:
				temp = str2var(temp)
				item_node._set_it(temp)
		elif item_full_name.begins_with("item_"):
			var temp = result[0][item_full_name]
			if temp != null:
				temp = str(temp).to_int()
				item_node._set_it(temp+1)
			
			
func load_unchecked_tier(sw_tier_name):
	tier_auswahl.set_disabled(true)
	next_button.set_disabled(true)
	var unchecked_tier_entries = yield(G.get_SW_data(sw_tier_name), "completed")
	temp_ersteller = unchecked_tier_entries["ersteller"]
	print(unchecked_tier_entries)
	temp_bearbeiter = unchecked_tier_entries["bearbeiter"]
	var beschreibungen = str2var(unchecked_tier_entries["t_beschreibung"])
	var beschr_url = str2var(unchecked_tier_entries["t_url"])
	var beschr_lizenz = str2var(unchecked_tier_entries["t_lizenz"])
	for i in beschreibungen.size():
		if i != 0:
			var new_textbox = preload("res://scripts/TextBox.tscn").instance()
			new_textbox.set_visible(false)
			textbox_cont.add_child(new_textbox)
			button_auswahl_text.add_item("Textbox "+str(i+1))
		textbox_cont.get_child(i)._set_beschreibung(beschreibungen[i])
		textbox_cont.get_child(i)._set_beschr_url(beschr_url[i])
		textbox_cont.get_child(i)._set_beschr_lizenz(beschr_lizenz[i])
	var foto_1_url = unchecked_tier_entries["f_url_m"]
	if foto_1_url != "":
		f_url_m.set_text(foto_1_url)
		page2._load_foto_for_change(foto_1_url)
	f_p_url_m.set_text(unchecked_tier_entries["f_p_url_m"])
	f_filename_m.set_text(unchecked_tier_entries["f_filename_m"])
	f_urheber_m.set_text(unchecked_tier_entries["f_urheber_m"])
	if unchecked_tier_entries["f_lizenz_m"] != null:
		f_lizenz_m._select_int(unchecked_tier_entries["f_lizenz_m"]+1)
	var temp_form_1 = str2var(unchecked_tier_entries["f_form_m"])
	foto_1_scale = temp_form_1["scale"]
	foto_1_pos = Vector2(temp_form_1["pos_x"],temp_form_1["pos_y"])
	
	var foto_2_url = unchecked_tier_entries["f_url_w"]
	if foto_2_url != "":
		#yield(get_tree().create_timer(1.1), "timeout")
		f_url_w.set_text(foto_2_url)
		page3._load_foto_for_change(foto_2_url)
	f_p_url_w.set_text(unchecked_tier_entries["f_p_url_w"])
	f_filename_w.set_text(unchecked_tier_entries["f_filename_w"])
	f_urheber_w.set_text(unchecked_tier_entries["f_urheber_w"])
	if unchecked_tier_entries["f_lizenz_w"] != null:
		f_lizenz_w._select_int(unchecked_tier_entries["f_lizenz_w"]+1)
	var temp_form_2 = str2var(unchecked_tier_entries["f_form_w"])
	foto_2_scale = temp_form_2["scale"]
	foto_2_pos = Vector2(temp_form_2["pos_x"],temp_form_2["pos_y"])
	tier_auswahl.set_disabled(false)
	next_button.set_disabled(false)
	
	
	get_node("Add/Page4/Scroll/Items/Besonderes")._set_text(unchecked_tier_entries["t_besonderes"])
	
	
	for i in items.get_child_count():
		var item_node = items.get_child(i)
		var item_full_name = item_node.get_name()
		if item_full_name.begins_with("item_zahl_"):
			var temp = unchecked_tier_entries[item_full_name]
			if temp != "":
				temp = str(temp).to_float()
				item_node._set_it(temp)
		elif item_full_name.begins_with("item_mul_"):
			var temp = unchecked_tier_entries[item_full_name]
			if temp != null:
				temp = str2var(temp)
				item_node._set_it(temp)
		elif item_full_name.begins_with("item_"):
			var temp = unchecked_tier_entries[item_full_name]
			if temp != null:
				temp = str(temp).to_int()
				item_node._set_it(temp+1)
#------------Page2-Funktions----------------------------------------------------
func check_foto_1():
	if f_url_m.get_text().length() == 0:
		f_url_m.set_self_modulate(Color(1,1,1,1))
		return true
	elif not foto_1.get_texture() == null:
		f_url_m.set_self_modulate(Color(1,1,1,1))
		if not f_p_url_m.get_text() == "":
			f_p_url_m.set_self_modulate(Color(1,1,1,1))
			if not f_urheber_m.get_text() == "":
				f_urheber_m.set_self_modulate(Color(1,1,1,1))
				if not f_filename_m.get_text() == "":
					f_filename_m.set_self_modulate(Color(1,1,1,1))
					if f_lizenz_m.get_selected() > 0:
						f_lizenz_m.set_self_modulate(Color(1,1,1,1))
						return true
					else:
						f_lizenz_m.set_self_modulate(ColorN("Red"))
						return false
				else:
					f_filename_m.set_self_modulate(ColorN("Red"))
					return false
			else:
				f_urheber_m.set_self_modulate(ColorN("Red"))
				return false
		else:
			f_p_url_m.set_self_modulate(ColorN("Red"))
			return false
	else: 
		f_url_m.set_self_modulate(ColorN("Red"))
		return false
#------------Page3-Funktions----------------------------------------------------
func check_foto_2():
	if f_url_w.get_text().length() == 0:
		f_url_w.set_self_modulate(Color(1,1,1,1))
		return true
	elif not foto_2.get_texture() == null:
		f_url_w.set_self_modulate(Color(1,1,1,1))
		if not f_p_url_w.get_text() == "":
			f_p_url_w.set_self_modulate(Color(1,1,1,1))
			if not f_urheber_w.get_text() == "":
				f_urheber_w.set_self_modulate(Color(1,1,1,1))
				if not f_filename_w.get_text() == "":
					f_filename_w.set_self_modulate(Color(1,1,1,1))
					if f_lizenz_w.get_selected() > 0:
						f_lizenz_w.set_self_modulate(Color(1,1,1,1))
						return true
					else:
						f_lizenz_w.set_self_modulate(ColorN("Red"))
						return false
				else:
					f_filename_w.set_self_modulate(ColorN("Red"))
					return false
			else:
				f_urheber_w.set_self_modulate(ColorN("Red"))
				return false
		else:
			f_p_url_w.set_self_modulate(ColorN("Red"))
			return false
	else: 
		f_url_w.set_self_modulate(ColorN("Red"))
		return false
#--------------------------------------Foto-Funktions-----------------------------------------------
func _input(event):
	if G.touch_input:
		if page2.is_visible():
			if foto_1.get_texture() != null:
				if event is InputEventScreenDrag:
					var drag_start_pos = event.get_position()
					if drag_start_pos.y > drag_area and drag_start_pos.y < drag_area+1080:
						var new_pos = -event.get_speed()/50
						var old_pos = foto_1.get_region_rect().position
						foto_1_pos = old_pos+new_pos
						foto_1.set_region_rect(Rect2(old_pos.x+new_pos.x,old_pos.y+new_pos.y,1080/foto_1_scale,1080/foto_1_scale))
		elif page3.is_visible():
			if foto_2.get_texture() != null:
				if event is InputEventScreenDrag:
					var drag_start_pos = event.get_position()
					if drag_start_pos.y > drag_area and drag_start_pos.y < drag_area+1080:
						var new_pos = -event.get_speed()/50
						var old_pos = foto_2.get_region_rect().position
						foto_2_pos = old_pos+new_pos
						foto_2.set_region_rect(Rect2(old_pos.x+new_pos.x,old_pos.y+new_pos.y,1080/foto_1_scale,1080/foto_1_scale))

func _process(_delta):
	if not G.touch_input:
		if page2.is_visible():
			if foto_1.get_texture() != null:
				if Input.is_action_pressed("ui_shift"): foto_speed = 10
				else: foto_speed = 1
				if Input.is_action_pressed("ui_left"): foto_1_pos.x += foto_speed
				elif Input.is_action_pressed("ui_right"): foto_1_pos.x -= foto_speed
				elif Input.is_action_pressed("ui_up"): foto_1_pos.y += foto_speed
				elif Input.is_action_pressed("ui_down"): foto_1_pos.y -= foto_speed
				foto_1.set_region_rect(Rect2(foto_1_pos.x,foto_1_pos.y,1080/foto_1_scale,1080/foto_1_scale))
		elif page3.is_visible():
			if foto_2.get_texture() != null:
				if Input.is_action_pressed("ui_shift"): foto_speed = 10
				else: foto_speed = 1
				if Input.is_action_pressed("ui_left"): foto_2_pos.x += foto_speed
				elif Input.is_action_pressed("ui_right"): foto_2_pos.x -= foto_speed
				elif Input.is_action_pressed("ui_up"): foto_2_pos.y += foto_speed
				elif Input.is_action_pressed("ui_down"): foto_2_pos.y -= foto_speed
				foto_2.set_region_rect(Rect2(foto_2_pos.x,foto_2_pos.y,1080/foto_2_scale,1080/foto_2_scale))

func _on_ButtonZoomOut1_pressed():
	foto_1_scale -= 0.01
	resize()
func _on_ButtonZoomOut1H_pressed():
	foto_1_scale -= 0.1
	resize()
func _on_ButtonZoomIn1H_pressed():
	foto_1_scale += 0.1
	resize()
func _on_ButtonZoomIn1_pressed():
	foto_1_scale += 0.01
	resize()
func _on_ButtonZoomOut2_pressed():
	foto_2_scale -= 0.01
	resize()
func _on_ButtonZoomOut2H_pressed():
	foto_2_scale -= 0.1
	resize()
func _on_ButtonZoomIn2H_pressed():
	foto_2_scale += 0.1
	resize()
func _on_ButtonZoomIn2_pressed():
	foto_2_scale += 0.01
	resize()
func _on_DefaultZoom1_pressed():
	foto_1_scale = 1.0
	resize()
func _on_DefaultZoom2_pressed():
	foto_2_scale = 1.0
	resize()
func _on_ButtonFlip1_toggled(button_pressed):
	foto_1.set_flip_h(button_pressed)
func _on_ButtonFlip2_toggled(button_pressed):
	foto_2.set_flip_h(button_pressed)
func resize():
	if page2.is_visible():
		foto_1.set_scale(Vector2(foto_1_scale,foto_1_scale))
		foto_1.set_region_rect(Rect2(foto_1_pos.x,foto_1_pos.y,1080/foto_1_scale,1080/foto_1_scale))
	elif page3.is_visible():
		foto_2.set_scale(Vector2(foto_2_scale,foto_2_scale))
		foto_2.set_region_rect(Rect2(foto_2_pos.x,foto_2_pos.y,1080/foto_2_scale,1080/foto_2_scale))





