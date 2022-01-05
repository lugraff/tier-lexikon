extends Node

var internet_check_sites = ["https://spacebase1.wordpress.com/","https://commons.wikimedia.org/","https://itch.io/","https://silentwolf.com/","https://de.wikipedia.org/"]
var lizenz_links = {"CC0 1.0":"https://creativecommons.org/publicdomain/zero/1.0/deed.de",
					"Public Domain":"https://creativecommons.org/publicdomain/mark/1.0/deed.de",
					"CC BY 1.0":"https://creativecommons.org/licenses/by/1.0/deed.de",
					"CC BY 2.0":"https://creativecommons.org/licenses/by/2.0/deed.de",
					"CC BY 2.5":"https://creativecommons.org/licenses/by/2.5/deed.de",
					"CC BY 3.0":"https://creativecommons.org/licenses/by/3.0/deed.de",
					"CC BY 4.0":"https://creativecommons.org/licenses/by/4.0/deed.de",
					"CC BY-SA 1.0":"https://creativecommons.org/licenses/by-sa/1.0/deed.de",
					"CC BY-SA 2.0":"https://creativecommons.org/licenses/by-sa/2.0/deed.de",
					"CC BY-SA 2.5":"https://creativecommons.org/licenses/by-sa/2.5/deed.de",
					"CC BY-SA 3.0":"https://creativecommons.org/licenses/by-sa/3.0/deed.de",
					"CC BY-SA 4.0":"https://creativecommons.org/licenses/by-sa/4.0/deed.de",
					"CC BY-NC 1.0":"https://creativecommons.org/licenses/by-nc/1.0/deed.de",
					"CC BY-NC 2.0":"https://creativecommons.org/licenses/by-nc/2.0/deed.de",
					"CC BY-NC 2.5":"https://creativecommons.org/licenses/by-nc/2.5/deed.de",
					"CC BY-NC 3.0":"https://creativecommons.org/licenses/by-nc/3.0/deed.de",
					"CC BY-NC 4.0":"https://creativecommons.org/licenses/by-nc/4.0/deed.de",
					"CC BY-NC-SA 1.0":"https://creativecommons.org/licenses/by-nc-sa/1.0/deed.de",
					"CC BY-NC-SA 2.0":"https://creativecommons.org/licenses/by-nc-sa/2.0/deed.de",
					"CC BY-NC-SA 2.5":"https://creativecommons.org/licenses/by-nc-sa/2.5/deed.de",
					"CC BY-NC-SA 3.0":"https://creativecommons.org/licenses/by-nc-sa/3.0/deed.de",
					"CC BY-NC-SA 4.0":"https://creativecommons.org/licenses/by-nc-sa/4.0/deed.de"}

#--------------------Arbeitsvariablen-------------------------------------------
var SW_entries = {}
var my_version = -1
var config = {}
var main_table = {}
var zoom = 1 #Zoom to all Screensizes
var img_array = []
var long_touch = 0
var touch_pos_history = []
var last_touch = Vector2.ZERO
var users = {} #für Benutzerverwaltung
var touch_input = true
var online = false
var swipe_start = null
var message_per_instance = 20
var readed_messages = []
var message_data = {}
#--------------------Default Werte----------------------------------------------
var my_name = ""
var my_status = "USER"
var save_img_max = 30
var text_size = 3
var auto_scroll = 1
var minimum_drag = 100
var db_path = "user://TierLexikon.db"
var window_mode = false
var saved_window_size = null
var saved_window_pos = null
#----------------Konstanten-----------------------------------------------------
const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
const default_window_size = Vector2(1080,1920)

func _ready():
	randomize()
	yield(check_folders(), "completed")#-------------------------------------Ckeck User Ordner (IMG)
	yield(loading(), "completed")#------------------------------------------------------Check Config
	if OS.has_feature("pc"):#---------------------------------------Check for Desktop
		touch_input = false
		set_process(false)
		get_node("/root/Base")._on_CheckButtonWindowMode_toggled(G.window_mode)
		if G.saved_window_size != null:
			OS.set_window_size(G.saved_window_size)
			OS.set_window_position(G.saved_window_pos)
		else:
			OS.set_window_size(Vector2((OS.get_screen_size().y-30)/1.8,OS.get_screen_size().y-30))
			OS.set_window_position(Vector2(OS.get_screen_size().x-OS.get_window_size().x+30,0))
	get_node("/root/Base/ImgMaker").start_load_circle()
	get_node("/root/Base")._show_info("Starte Tier Lexikon")
	check_internet()
	
func check_internet():#---------------------------------------------------------------Check Internet
	var http_request = HTTPRequest.new()
	get_node("/root/Base/ImgMaker/Container/HTTP").add_child(http_request)
	http_request.connect("request_completed", self, "_internet_check_completed")
	var error = http_request.request(internet_check_sites[randi()%internet_check_sites.size()])
	if not error == OK:
		online = false
		_offline_ready()

func _internet_check_completed(_result, response_code, _headers, _body):
	if response_code == 200:
		online = true
		_online_ready()
	else:
		online = false
		_offline_ready()
		
func _offline_ready():
	if check_sql_db() == false:#--------------------------------------------------Check SQL DB vorhanden
		yield(create_new_db(), "completed")
	get_node("/root/Base").show_menu()
	get_node("/root/Base/ImgMaker").stop_load_circle()

func _online_ready():
	SilentWolf.configure({
				"api_key": "",
				"game_id": "",
				"game_version": "",
				"log_level": 0
			  })
	yield(get_tree().create_timer(1.0), "timeout")#----------SilentWolf.configure zeit geben (Debug)
	SW_entries = yield(get_SW_data("entries"), "completed")#---------------------Lade entries von SW
	if SW_entries.size() == 0:#--------------------------------------------Check Online DB vorhanden
		get_node("/root/Base")._show_info("Online DB nicht erreichbar!")
		_offline_ready()
		return
	if check_sql_db() == false:#--------------------------------------------------Check SQL DB vorhanden
		yield(create_new_db(), "completed")
	else:
		if SW_entries[0][0] < my_version:
			get_node("/root/Base")._show_info("Datenbank wird wegen Aktualisierungen neu erstellt!")
			yield(get_tree().create_timer(1), "timeout")
			yield(get_node("/root/Base/ImgMaker").remove_all_images(), "completed")
			yield(get_tree().create_timer(0.4), "timeout")
			yield(G.delete_db_and_config(), "completed")
			yield(get_tree().create_timer(1.0), "timeout")
			yield(G.loading(), "completed")
			yield(G.create_new_db(), "completed")
		else:
			yield(scan_for_new_entries(), "completed")#-----------------------------------Lade neue Einträge
	yield(check_status(), "completed")
	yield(scan_dev_mails(), "completed")
	get_node("/root/Base").show_menu()
	get_node("/root/Base/ImgMaker").stop_load_circle()


#---------------------------------Input-Functions---------------------------------------------------
func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			touch_pos_history.append(event.get_position())
			if touch_pos_history.size() > 2: 
				touch_pos_history.pop_front()
				last_touch = touch_pos_history.front()
			swipe_start = event.get_position()
		else:
			_calculate_swipe(event.get_position())

func _calculate_swipe(swipe_end):
	if swipe_start == null: 
		return
	var swipe = swipe_end - swipe_start
	if abs(swipe.x) > minimum_drag:
		var fotoabc = get_node_or_null("/root/Base/FotoABC")
		if swipe.x > 0:#---------------------Swipe Right
			if fotoabc != null:
				fotoabc._right_swipe()
		else:#-------------------------------Swipe Left
			if fotoabc != null:
				fotoabc._left_swipe()
	#elif abs(swipe.y) > minimum_drag:
	#	if swipe.y > 0:
	#		print("swipe_up")
	#	else:
	#		print("swipe_down")

func _process(delta):
	if OS.has_touchscreen_ui_hint():
		if Input.is_mouse_button_pressed(1):
			long_touch += delta
		else:
			if long_touch != 0: long_touch = 0
		if long_touch > 1:
			_fake_right_click()
func _fake_right_click():
	var fake_input = InputEventMouseButton.new()
	fake_input.button_index = BUTTON_RIGHT
	fake_input.position = last_touch
	fake_input.pressed = true
	get_tree().input_event(fake_input)
	fake_input.pressed = false
	get_tree().input_event(fake_input)


#----------------------------Load and Save--------------------------------------
func check_folders():
	yield(get_tree(), "idle_frame")
	var dir = Directory.new()
	if dir.open("user://") == OK:
		if not dir.dir_exists("user://img"):
			var error = dir.make_dir("user://img")
			if error != OK:
				get_node("/root/Base")._show_info("Speichern fehlgeschlagen")
				get_tree().quit()

func loading():
	yield(get_tree(), "idle_frame")
	var savefile = File.new()
	if not savefile.file_exists("user://config.save"):
		yield(save(), "completed")
	savefile.open("user://config.save", File.READ)
	config = savefile.get_var()
	my_version = config["my_version"]
	save_img_max = config["save_img_max"]
	text_size = config["text_size"]
	auto_scroll = config["auto_scroll"]
	img_array = config["img_array"]
	SW_entries = config["SW_entries"]
	window_mode = config["window_mode"]
	saved_window_size = config["saved_window_size"]
	saved_window_pos = config["saved_window_pos"]
	readed_messages = config["readed_messages"]
	savefile.close()

func save():
	yield(get_tree(), "idle_frame")
	var savefile = File.new()
	savefile.open("user://config.save", File.WRITE)
	config = {"my_version": my_version,
			"save_img_max": save_img_max,
			"text_size": text_size,
			"auto_scroll": auto_scroll,
			"img_array": img_array,
			"SW_entries": SW_entries,
			"window_mode": window_mode,
			"saved_window_size": saved_window_size,
			"saved_window_pos": saved_window_pos,
			"readed_messages": readed_messages}
	savefile.store_var(config)
	savefile.close()

func get_savefile_count():
	var files = []
	var dir = Directory.new()
	dir.open("user://img")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files.size()

#----------------------------------DB Funktions-and-SilentWolf--------------------------------------
func check_status():
	yield(get_tree(), "idle_frame")
	var my_id = OS.get_unique_id()
	var check_users = yield(get_SW_data("status"), "completed")
	if check_users.keys().has(my_id):
		my_name = check_users[my_id][0]
		my_status = check_users[my_id][1]
	else:
		if check_users.size() >= 1:
			var aktual_date = OS.get_date()
			check_users[my_id] = ["","USER",[0],str(aktual_date["day"])+"."+str(aktual_date["month"])+"."+str(aktual_date["year"])]
			yield(SilentWolf.Players.post_player_data("status",var2str(check_users)), "sw_player_data_posted")
	get_node("/root/Base")._set_status_menu(my_status)

func version_aktualisieren():
	my_version = SW_entries[0][0]
	var tier_anzahl = 0
	for i in SW_entries.size():
		if i != 0:
			if SW_entries[i][0].begins_with("tier_"):
				tier_anzahl += 1
	G.save()
	get_node("/root/Base")._set_version_text("Tiere: "+str(tier_anzahl))

func check_sql_db():
	var has_db = File.new()
	if not has_db.file_exists(db_path):
		return false
	else:
		return true

func delete_db_and_config():
	yield(get_tree(), "idle_frame")
	get_node("/root/Base")._show_info("DB gelöscht.")
	var dir = Directory.new()
	dir.remove(db_path)
	dir.remove("user://config.save")

func db_query(string):
	var db = SQLite.new()
	db.path = db_path
	db.read_only = true
	db.open_db()
	print(string)
	db.query(string)
	db.close_db()
	return(db.query_result)

func get_SW_data(sw_name):
	yield(get_tree(), "idle_frame")
	yield(SilentWolf.Players.get_player_data(sw_name), "sw_player_data_received")
	var result = SilentWolf.Players.player_data
	if typeof(result) == TYPE_DICTIONARY:
		if result.size() == 0:
			return result
	return str2var(result)
	
func post_SW_data(sw_name,data):
	yield(get_tree(), "idle_frame")
	if sw_name != "entries":
		if sw_name != "status":
			var aktual_entries = yield(get_SW_data("entries"), "completed")
			aktual_entries[0][0] += 1
			var version_nr = aktual_entries[0][0]
			var new_entry = true
			for i in aktual_entries.size():
				if i != 0:
					if aktual_entries[i][0] == sw_name:
						aktual_entries[i] = [sw_name,version_nr]
						new_entry = false
						break
			if new_entry:
				if my_status == "CREATOR":
					aktual_entries.append([sw_name,-1])
				else:
					aktual_entries.append([sw_name,version_nr])
			yield(SilentWolf.Players.post_player_data("entries",var2str(aktual_entries)), "sw_player_data_posted")
			yield(get_tree().create_timer(1.1), "timeout")
			if not sw_name.begins_with("item_zahl_"):
				yield(SilentWolf.Players.post_player_data(sw_name,var2str(data)), "sw_player_data_posted")
				
func del_SW_data(sw_name):
	yield(get_tree(), "idle_frame")
	yield(SilentWolf.Players.delete_player_data(sw_name, ""), "sw_player_data_removed")

func create_new_db():
	yield(get_tree(), "idle_frame")
	get_node("/root/Base")._show_info("Erstelle SQL DB")
	var dir = Directory.new()
	if dir.file_exists("res://TierLexikon.db"):
		var error = dir.copy("res://TierLexikon.db",db_path)
		if error == OK: 
			var file = File.new()
			file.open("res://TierLexikonVersion.json", File.READ)
			var file_data = str2var(file.get_line())
			my_version = file_data["version"]
			file.close()
			yield(get_tree().create_timer(0.5), "timeout")
			yield(scan_for_new_entries(), "completed")
			return
	my_version = -1
	var db = SQLite.new()
	db.path = db_path
	db.open_db()
	main_table = {
				"name": {"data_type": "text", "primary_key": true, "not_null": true},
				"t_beschreibung": {"data_type": "text"},
				"t_url": {"data_type": "text"},
				"t_lizenz": {"data_type": "text"},
				"f_url_m": {"data_type": "text"},
				"f_p_url_m": {"data_type": "text"},
				"f_urheber_m": {"data_type": "text"},
				"f_lizenz_m": {"data_type": "int"},
				"f_filename_m": {"data_type": "text"},
				"f_form_m": {"data_type": "text"},
				"f_url_w": {"data_type": "text"},
				"f_p_url_w": {"data_type": "text"},
				"f_urheber_w": {"data_type": "text"},
				"f_lizenz_w": {"data_type": "int"},
				"f_filename_w": {"data_type": "text"},
				"f_form_w": {"data_type": "text"},
				"ersteller": {"data_type": "text"},
				"bearbeiter": {"data_type": "text"},
				"t_besonderes": {"data_type": "text"}
				}
	db.create_table("Tiere", main_table)
	db.close_db()
	yield(get_tree().create_timer(0.5), "timeout")
	yield(scan_for_new_entries(), "completed")

func create_new_tier_in_sw(entry_data,override = false):
	yield(get_tree(), "idle_frame")
	var aktual_entries = yield(get_SW_data("entries"), "completed")
	var exists_already = false
	for i in aktual_entries.size():
		if i != 0:
			if entry_data["name"] == G.SW_entries[i][0]:
				exists_already = true
	if exists_already and not override:
		get_node("/root/Base")._show_info(str(entry_data["name"])+" existiert bereits!")
		return false
	else:
		get_node("/root/Base")._show_info(str(entry_data["name"])+" wird erstellt...")
		yield(post_SW_data(str(entry_data["name"]),entry_data), "completed")
		yield(get_tree().create_timer(1.1), "timeout")
		var check_upload = yield(get_SW_data(str(entry_data["name"])), "completed")
		if check_upload.size() > 0:
			if check_upload["name"] == entry_data["name"]:
				return true
		get_node("/root/Base")._show_info("fehlgeschlagen!\nÜberprüfe deine Internet Verbindung.")
		var new_aktual_entries = yield(get_SW_data("entries"), "completed")#delete entries entry
		for i in new_aktual_entries.size():
			if i != 0:
				if new_aktual_entries[i][0] == entry_data["name"]:
					new_aktual_entries.erase(new_aktual_entries[i])
					yield(post_SW_data("entries",new_aktual_entries), "completed")
		return false
		
		
func scan_for_new_entries():
	yield(get_tree(), "idle_frame")
	if not G.online: return
	get_node("/root/Base")._show_info("Suche neue Einträge...")
	var db = SQLite.new()
	db.path = db_path
	db.open_db()
	SW_entries = yield(get_SW_data("entries"), "completed")
	var max_load = SW_entries.size()-1
	var status_load = 0
	var load_anzeige = get_node("/root/Base/ImgMaker/LoadingPercent")
	for i in SW_entries.size():
		yield(get_tree().create_timer(0.01), "timeout")
		status_load = 50/max_load*i
		load_anzeige.set_text(str(status_load)+"%")
		if i != 0:
			if SW_entries[i][1] > my_version:#---------------------bei höherer Version:-------------
				if SW_entries[i][0].begins_with("item_"):#------------update Items------------------
					if SW_entries[i][0].begins_with("item_zahl_"):
						db.query("ALTER TABLE Tiere ADD "+SW_entries[i][0]+" int")
					elif SW_entries[i][0].begins_with("item_mul_"):
						var tier_table = G.db_query("select name from sqlite_master WHERE type = 'table' AND name LIKE 'item_mul_%'")
						var exists_already = false
						for k in tier_table.size():
							if SW_entries[i][0] == tier_table[k]["name"]:
								exists_already = true
								db.drop_table(SW_entries[i][0])
								break
						db.create_table(SW_entries[i][0], {"id": {"data_type": "int", "primary_key": true, "not_null": true},
															"name": {"data_type": "text", "not_null": true}
															})
						var new_rows = yield(get_SW_data(SW_entries[i][0]), "completed")
						for r in new_rows.size():
							db.insert_row(SW_entries[i][0], {"id": r,"name": new_rows[r]})
						if not exists_already: 
							db.query("ALTER TABLE Tiere ADD "+SW_entries[i][0]+" text")
					else:# bei item_
						var tier_table = G.db_query("select name from sqlite_master WHERE type = 'table' AND name LIKE 'item_%'")
						var exists_already = false
						for k in tier_table.size():
							if SW_entries[i][0] == tier_table[k]["name"]:
								exists_already = true
								db.drop_table(SW_entries[i][0])
								break
						db.create_table(SW_entries[i][0], {"id": {"data_type": "int", "primary_key": true, "not_null": true},
															"name": {"data_type": "text", "not_null": true}
															})
						var new_rows = yield(get_SW_data(SW_entries[i][0]), "completed")
						print(new_rows)
						for r in new_rows.size():
							db.insert_row(SW_entries[i][0], {"id": r,"name": new_rows[r]})
						if not exists_already: 
							db.query("ALTER TABLE Tiere ADD "+SW_entries[i][0]+" int")
					get_node("/root/Base")._show_info(str(SW_entries[i][0]) + " aktualisiert")
	for i in SW_entries.size():
		yield(get_tree().create_timer(0.01), "timeout")
		status_load = 50+50/max_load*i
		load_anzeige.set_text(str(status_load)+"%")
		if i != 0:
			if SW_entries[i][1] > my_version:#---------------------bei höherer Version:-------------

				if SW_entries[i][0].begins_with("tier_"):#--------------update Tiere----------------
					var tier_table = G.db_query("select name from Tiere")
					var new_tier = yield(get_SW_data(SW_entries[i][0]), "completed")
					var exists_already = false
					for k in tier_table.size():
						if SW_entries[i][0] == tier_table[k]["name"]:
							exists_already = true
							break
					if exists_already:
						db.update_rows("Tiere","name = '"+new_tier["name"]+"'",new_tier)
						get_node("/root/Base")._show_info(str(SW_entries[i][0]) + " aktualisiert")
					else:
						for k in tier_table.size():
							if new_tier["name"] == tier_table[k]["name"]:
								exists_already = true
								break
						if exists_already:
							db.update_rows("Tiere","name = '"+new_tier["name"]+"'",new_tier)
							get_node("/root/Base")._show_info(str(SW_entries[i][0]) + " aktualisiert")
						else:
							db.insert_row("Tiere", new_tier)
							get_node("/root/Base")._show_info(str(SW_entries[i][0]) + " hinzugefügt")
	db.close_db()
	load_anzeige.set_text("")
	version_aktualisieren()
#----------------------------------------Dev-Message-Funktions--------------------------------------
func scan_dev_mails():
	yield(get_tree(), "idle_frame")
	yield(SilentWolf.Scores.get_high_scores(0, "dev"), "sw_scores_received")
	for score in SilentWolf.Scores.scores:
		var data = {"id":str(score.score),"receiver":str(score.player_name),"header":str(score.metadata["header"]),"message":str(score.metadata["message"])}
		if data["receiver"] == "All" or data["receiver"] == str(OS.get_unique_id()):
			message_data[data["id"]] = {"message":data["message"],"header":data["header"]}
			if not readed_messages.has(data["id"]):
				get_node("/root/Base")._new_message_there()
	get_node("/root/Base")._message_there()
			
			
#------------------------------------Namens-Veränderung-Funktionen----------------------------------
func _to_normal_name(this_name):
	if this_name.begins_with("item_zahl_"):
		this_name.erase(0,10)
	elif this_name.begins_with("item_mul_"):
		this_name.erase(0,9)
	elif this_name.begins_with("tier_") or this_name.begins_with("item_"):
		this_name.erase(0,5)
	this_name = this_name.replace("A1","Afghanische")
	this_name = this_name.replace("A2","Afrikanische")
	this_name = this_name.replace("A3","Ägyptische")
	this_name = this_name.replace("A4","Altdeutscher")
	this_name = this_name.replace("A5","Amerikanische")
	this_name = this_name.replace("A6","Asiatische")
	this_name = this_name.replace("A7","Atlantische")
	this_name = this_name.replace("A8","Australische")
	this_name = this_name.replace("B1","Bayerische")
	this_name = this_name.replace("B2","Belgische")
	this_name = this_name.replace("C1","Chinesische")
	this_name = this_name.replace("D1","Deutsche")
	this_name = this_name.replace("D2","Dsungarischer")
	this_name = this_name.replace("E1","Englische")
	this_name = this_name.replace("F1","Finnische")
	this_name = this_name.replace("F2","Französische")
	this_name = this_name.replace("G1","Galapagos")
	this_name = this_name.replace("G2","Gespenst")
	this_name = this_name.replace("G3","Große")
	this_name = this_name.replace("H1","Holländische")
	this_name = this_name.replace("I1","Indische")
	this_name = this_name.replace("I2","Indochinesische")
	this_name = this_name.replace("I3","Irische")
	this_name = this_name.replace("J1","Japanische")
	this_name = this_name.replace("K1","Kalifornische")
	this_name = this_name.replace("K2","Kanadische")
	this_name = this_name.replace("K3","Katalanische")
	this_name = this_name.replace("K4","Kaukasische")
	this_name = this_name.replace("K5","Kleine")
	this_name = this_name.replace("K6","Kroatische")
	this_name = this_name.replace("L1","Langhaar")
	this_name = this_name.replace("L2","Lappländische")
	this_name = this_name.replace("M1","Meeres")
	this_name = this_name.replace("M2","Mexikanische")
	this_name = this_name.replace("N1","Nordamerikanische")
	this_name = this_name.replace("N2","Norwegische")
	this_name = this_name.replace("N3","Nördliche")
	this_name = this_name.replace("O1","Östlicher")
	this_name = this_name.replace("P1","Peruanische")
	this_name = this_name.replace("P2","Polnische")
	this_name = this_name.replace("P3","Portugiesische")
	this_name = this_name.replace("P4","Pyrenäen")
	this_name = this_name.replace("R1","Riesen")
	this_name = this_name.replace("R2","Russische")
	this_name = this_name.replace("S1","Schottische")
	this_name = this_name.replace("S2","Schwedische")
	this_name = this_name.replace("S3","Spanische")
	this_name = this_name.replace("S4","Südliche")
	this_name = this_name.replace("T1","Tschechoslowakische")
	this_name = this_name.replace("W1","Wasser")
	this_name = this_name.replace("W2","Westliche")
	this_name = this_name.replace("Z1","Zwerg")
	this_name = this_name.replace("_", " ")
	this_name = this_name.replace("S0", "ß")
	this_name = this_name.replace("a0","ä")
	this_name = this_name.replace("o0","ö")
	this_name = this_name.replace("u0","ü")
	this_name = this_name.replace("A0","Ä")
	this_name = this_name.replace("O0","Ö")
	this_name = this_name.replace("D0","Ø")
	this_name = this_name.replace("X0","-/")
	this_name = this_name.replace("X1","/")
	return this_name

func _to_valid_name(this_name):
	this_name = this_name.replace("Afghanische","A1")
	this_name = this_name.replace("Afrikanische","A2")
	this_name = this_name.replace("Ägyptische","A3")
	this_name = this_name.replace("Altdeutscher","A4")
	this_name = this_name.replace("Amerikanische","A5")
	this_name = this_name.replace("Asiatische","A6")
	this_name = this_name.replace("Atlantische","A7")
	this_name = this_name.replace("Australische","A8")
	this_name = this_name.replace("Bayerische","B1")
	this_name = this_name.replace("Belgische","B2")
	this_name = this_name.replace("Chinesische","C1")
	this_name = this_name.replace("Deutsche","D1")
	this_name = this_name.replace("Dsungarischer","D2")
	this_name = this_name.replace("Englische","E1")
	this_name = this_name.replace("Finnische","F1")
	this_name = this_name.replace("Französische","F2")
	this_name = this_name.replace("Galapagos","G1")
	this_name = this_name.replace("Gespenst","G2")
	this_name = this_name.replace("Große","G3")
	this_name = this_name.replace("Holländische","H1")
	this_name = this_name.replace("Indische","I1")
	this_name = this_name.replace("Indochinesische","I2")
	this_name = this_name.replace("Irische","I3")
	this_name = this_name.replace("Japanische","J1")
	this_name = this_name.replace("Kalifornische","K1")
	this_name = this_name.replace("Kanadische","K2")
	this_name = this_name.replace("Katalanische","K3")
	this_name = this_name.replace("Kaukasische","K4")
	this_name = this_name.replace("Kleine","K5")
	this_name = this_name.replace("Kroatische","K6")
	this_name = this_name.replace("Langhaar","L1")
	this_name = this_name.replace("Lappländische","L2")
	this_name = this_name.replace("Meeres","M1")
	this_name = this_name.replace("Mexikanische","M2")
	this_name = this_name.replace("Nordamerikanische","N1")
	this_name = this_name.replace("Norwegische","N2")
	this_name = this_name.replace("Nördliche","N3")
	this_name = this_name.replace("Östlicher","O1")
	this_name = this_name.replace("Peruanische","P1")
	this_name = this_name.replace("Polnische","P2")
	this_name = this_name.replace("Portugiesische","P3")
	this_name = this_name.replace("Pyrenäen","P4")
	this_name = this_name.replace("Riesen","R1")
	this_name = this_name.replace("Russische","R2")
	this_name = this_name.replace("Schottische","S1")
	this_name = this_name.replace("Schwedische","S2")
	this_name = this_name.replace("Spanische","S3")
	this_name = this_name.replace("Südliche","S4")
	this_name = this_name.replace("Tschechoslowakische","T1")
	this_name = this_name.replace("Wasser","W1")
	this_name = this_name.replace("Westliche","W2")
	this_name = this_name.replace("Zwerg","Z1")
	this_name = this_name.replace(" ", "_")
	this_name = this_name.replace("ß", "S0")
	this_name = this_name.replace("ä","a0")
	this_name = this_name.replace("ö","o0")
	this_name = this_name.replace("ü","u0")
	this_name = this_name.replace("Ä","A0")
	this_name = this_name.replace("Ö","O0")
	this_name = this_name.replace("Ü","U0")
	this_name = this_name.replace("ø","Ø")
	this_name = this_name.replace("Ø","D0")
	this_name = this_name.replace("-/","X0")
	this_name = this_name.replace("/","X1")
	return this_name


