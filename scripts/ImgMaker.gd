extends Node2D

onready var viewport = $Container/Viewport
onready var http = $Container/HTTP
onready var foto = $Container/Viewport/Foto

var akt_auswahl = ""
var akt_m_w = ""

#----------------Loading-Bar----------------------------------------------------
var aktual_angle = TAU
var aktual_angle_2 = PI
var lenght_circ = 0
var count_circ = 0

func _process(delta):
	draw_load_circle(delta)
	
func draw_load_circle(delta):
	if aktual_angle >= TAU: aktual_angle = 0
	aktual_angle += delta * 0.3333
	if aktual_angle_2 <= 0: aktual_angle_2 = TAU
	aktual_angle_2 -= delta * 0.9999
	count_circ += delta
	lenght_circ = sin(count_circ)+PI/2
	update()
func _draw():
	if is_processing():
		draw_arc(Vector2(540,690), 128, aktual_angle, aktual_angle+lenght_circ*1.3333, 32, Color(1,0.6,0.4,1), 5.0, true)
		draw_arc(Vector2(540,690), 112, aktual_angle_2, aktual_angle_2+lenght_circ, 32, Color(1,0.6,0.4,1), 5.0, true)
		
func start_load_circle():
	set_process(true)
	
func stop_load_circle():
	set_process(false)
	update()

#----------------------Internet Img Functions-----------------------------------

func get_image_from_internet(auswahl,m_w,url,scale,pos_x,pos_y,flip):
	if is_processing():
		print("ohoh")
		return false
	else:
		start_load_circle()
		akt_auswahl = auswahl
		akt_m_w = m_w
		var http_request = HTTPRequest.new()
		http.add_child(http_request)
		http_request.connect("request_completed", self, "_http_request_completed")
		var error = http_request.request(url)
		if not error == OK:
			stop_load_circle()
			return false
		foto.set_scale(Vector2(scale,scale))
		foto.set_region_rect(Rect2(pos_x,pos_y,1080/scale,1080/scale))
		foto.set_flip_h(flip)
		return true

func _http_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var image = Image.new()
		var error = image.load_jpg_from_buffer(body)
		if error == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image, 4)
			foto.set_texture(texture)
			yield(save_img(), "completed")
	for i in http.get_child_count():
		http.get_child(i).queue_free()
		stop_load_circle()

func save_img():
	var img_counter = G.save_img_max - yield(count_images(), "completed")
	if img_counter < 0:
		for i in abs(img_counter):
			remove_img(0) #0 ist ältestes gespeichertes Foto
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var check_foto = File.new()
	var image = viewport.get_texture().get_data()
	image.flip_y()
	if akt_m_w == "w":
		if not check_foto.file_exists("user://img/"+akt_auswahl+"_w.png"):
			image.save_png("user://img/"+akt_auswahl+"_w.png")
			G.img_array.append(akt_auswahl+"_w.png")
			G.save()
			get_node("/root/Base/FotoABC")._set_foto2_texture()
	else:
		if not check_foto.file_exists("user://img/"+akt_auswahl+"_m.png"):
			image.save_png("user://img/"+akt_auswahl+"_m.png")
			G.img_array.append(akt_auswahl+"_m.png")
			G.save()
			get_node("/root/Base/FotoABC")._set_foto1_texture()
	check_foto.close()

func count_images():
	yield(get_tree(), "idle_frame")
	var count = 1
	var dir = Directory.new()
	if dir.open("user://img/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				count += 1
			file_name = dir.get_next()
		if count-1 == G.img_array.size():
			return count
		else:
			remove_all_images()
			return 0
	else:
		return 0

func remove_img(idx):
	var dir = Directory.new()
	if dir.file_exists(OS.get_user_data_dir()+"/img/"+G.img_array[idx]):
		dir.remove(OS.get_user_data_dir()+"/img/"+G.img_array[idx])
		G.img_array.remove(idx)
		G.save()

func remove_all_images():
	yield(get_tree(), "idle_frame")
	var dir = Directory.new()
	if dir.open("user://img/") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				dir.remove(OS.get_user_data_dir()+"/img/"+file_name)
			file_name = dir.get_next()
		G.img_array.clear()
		G.save()
		get_node("/root/Base/Options/FotoCount").set_text(str(G.get_savefile_count())+" Fotos gespeichert")
		get_node("/root/Base")._show_info("Alle Fotos entfernt.")
		
func remove_img_by_name(img_name):
	var img_name_m = img_name + "_m.png"
	var img_name_w = img_name + "_w.png"
	var dir = Directory.new()
	if dir.file_exists(OS.get_user_data_dir()+"/img/"+img_name_m):
		if G.img_array.has("img_name_m"):
			dir.remove(OS.get_user_data_dir()+"/img/"+img_name_m)
			var idx = G.img_array.find("img_name_m",0)
			G.img_array.remove(idx)
	if dir.file_exists(OS.get_user_data_dir()+"/img/"+img_name_w):
		if G.img_array.has("img_name_w"):
			dir.remove(OS.get_user_data_dir()+"/img/"+img_name_w)
			var idx = G.img_array.find("img_name_w",0)
			G.img_array.remove(idx)
	G.save()

