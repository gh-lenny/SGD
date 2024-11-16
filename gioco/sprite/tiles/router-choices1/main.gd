extends Node2D

# Configurazioni iniziali
var ip_left
var ip_right
var least_packets_to_win = 12
var all_packets = 20
var malicious_percent = 25
var malicious_packets = int(all_packets*malicious_percent/100)
var packets_sent = 0
var packets_sent_correctly = 0
var dst_ip
const malicious_texture = "res://packets/malicious-mail.png"

# Riferimenti ai nodi
@onready var signal1 = $static/Signal
@onready var signal2 = $static/Signal2
@onready var porta_left = $"static/Porta left"
@onready var porta_right = $"static/Porta right"
@onready var right_ip = $"dynamic/right ip"
@onready var left_ip = $"dynamic/left ip"
@onready var score_text = $"dynamic/Packets"
@onready var packets_folder = $"dynamic/packets_container"
@onready var packet_nodes = []

@onready var label = $dynamic/Label
@onready var button = $dynamic/Button

# Variabili per il trascinamento
var is_dragging = false
var dragged_packet = null
var original_position = Vector2()

var texture_paths = {}

# Funzione chiamata al caricamento
func _ready() -> void:
	label.visible = false
	button.visible = false
	
	# Inizializza i pacchetti
	initialize_packets()

	# Invia i pacchetti
	for packet in packet_nodes:
		# Imposta gli indirizzi IP
		ip_left = str(randi_range(1, 254))+".0.0.0"
		ip_right = str(randi_range(1, 254))+".0.0.0"
		
		left_ip.text = ip_left
		right_ip.text = ip_right
		
		dst_ip = generate_random_ip()
		score_text.text = "Packets sent: " + str(packets_sent_correctly) + "/" + str(packets_sent) + "\n" + "Dst IP: " + dst_ip
		var direction = choose_random_direction()
		var signal_to_start = get_signal_for_direction(direction)
		
		# Imposta l'icona casuale del pacchetto
		set_random_icon(packet)
		
		# Avvia l'animazione di scorrimento
		start_scroll_animation(packet, direction, signal_to_start)
		
		# Incrementa il contatore dei pacchetti inviati
		if not is_malicious_packet(packet):
			packets_sent += 1
		
		# Attende 10 secondi prima di inviare il prossimo pacchetto
		await get_tree().create_timer(8).timeout
	score_text.text = "Packets sent: " + str(packets_sent_correctly) + "/" + str(packets_sent)
	if packets_sent_correctly >= least_packets_to_win:
		label.text = "HAI VINTO!"
		label.add_theme_color_override("font_color", Color.GREEN)
		button.text = "AVANTI"
		button.pressed.connect(next_scene)
	else:
		label.text = "HAI PERSO!"
		label.add_theme_color_override("font_color", Color.RED)
		button.text = "RESTART"
		button.pressed.connect(restart)
	
	label.visible = true
	button.visible = true

func is_malicious_packet(pkt):
	return "malicious" in texture_paths[str(pkt.texture).split("-")[1].split(">")[0]]

func next_scene():
	pass

func restart():
	get_tree().reload_current_scene()

# Crezione IP random per i pacchetti
func generate_random_ip():
	var n1 = randi_range(1, 254)
	var n2 = randi_range(1, 254)
	var n3 = randi_range(1, 254)
	
	var numbers = [str(n1), str(n2), str(n3)]
	if randi_range(0, 1000) < 500:
		numbers.insert(0, ip_left.split(".")[0])
	else:
		numbers.insert(0, ip_right.split(".")[0])
	return ".".join(numbers)

func create_node(malicious) -> Node2D:
	var nodo = Sprite2D.new()
	if malicious:
		nodo.texture = preload(malicious_texture)
		var texture_id = str(nodo.texture).split("-")[1].split(">")[0]
		if texture_id not in texture_paths:
			texture_paths[texture_id] = malicious_texture
	else:
		nodo.texture = null
	nodo.scale = Vector2(0.2, 0.2)
	nodo.position = Vector2(590, 775)
	return nodo

# Inizializzazione dei pacchetti
func initialize_packets() -> void:
	for i in range(all_packets):
		var nodo = create_node(false)
		packets_folder.add_child(nodo)
		packet_nodes.append(nodo)
	for i in range(malicious_packets):
		var nodo = create_node(true)
		packets_folder.add_child(nodo)
		packet_nodes.append(nodo)
	packet_nodes.shuffle()

# Scegli una direzione casuale per il pacchetto
func choose_random_direction() -> String:
	if randi_range(0, 1) == 0:
		return "DOWN"
	else:
		return "UP"

# Ottieni il segnale corrispondente alla direzione
func get_signal_for_direction(direction: String) -> Node:
	if direction == "DOWN":
		return signal2
	else:
		return signal1

# Avvia l'animazione del segnale
func start_signal_animation(signal_sprite: AnimatedSprite2D) -> void:
	signal_sprite.play()

# Imposta un'icona casuale per il pacchetto
func set_random_icon(pkt: Sprite2D) -> void:
	if pkt.texture == null:
		var random_index = randi_range(1, 3)
		var icon_path = "res://packets/mail-" + str(random_index) + ".png"
		pkt.texture = load(icon_path)
		var texture_id = str(pkt.texture).split("-")[1].split(">")[0]
		if texture_id not in texture_paths:
			texture_paths[texture_id] = icon_path

# Avvia l'animazione di scorrimento
func start_scroll_animation(sprite: Sprite2D, direction: String, signal_: Node) -> void:
	var step = randi_range(3, 6)
	var max
	start_signal_animation(signal_)
	if direction == "DOWN":
		max = 775
		sprite.position.y = -100
	else:
		step = -step
		max = -100
		sprite.position.y = 775

	while true:
		if direction == "DOWN":
			if sprite.position.y > max:
				break
		else:
			if sprite.position.y < max:
				break
		sprite.position.y += step
		await get_tree().create_timer(0.005).timeout

# Funzione _input per rilevare il clic del mouse
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Corretto MOUSE_BUTTON_LEFT
			# Verifica se il clic è avvenuto sopra uno dei pacchetti
			for packet in packet_nodes:
				# Usa "to_local" per ottenere la posizione relativa al pacchetto
				if packet.get_rect().has_point(packet.to_local(event.position)):
					if event.pressed:
						if is_malicious_packet(packet):
							packets_sent_correctly -= 1
							packet.visible = false
							score_text.text = "Packets sent: " + str(packets_sent_correctly) + "/" + str(packets_sent) + "\n" + "Dst IP: " + dst_ip
							break
						else:
							# Inizia a trascinare il pacchetto
							is_dragging = true
							dragged_packet = packet
							original_position = packet.position
							break
					else:
						# Se il mouse è rilasciato, fermiamo il trascinamento
						is_dragging = false
						if dragged_packet:
							# Verifica se c'è collisione con le porte
							check_collision_with_ports(dragged_packet)
							# Rendi il pacchetto trasparente
							if dragged_packet:
								set_packet_transparent(dragged_packet)
							dragged_packet = null

# Funzione _process per spostare lo sprite con il mouse
func _process(delta: float) -> void:
	if is_dragging and dragged_packet:
		# Sposta il pacchetto con il mouse
		dragged_packet.position = get_global_mouse_position()

# Verifica la collisione con le porte
func check_collision_with_ports(packet: Sprite2D) -> void:
	# Controlliamo la posizione globale del pacchetto
	var packet_rect = packet.get_rect()
	var packet_global_position = packet.global_position
	packet_rect.position = packet_global_position

	# Controlliamo la posizione globale della porta sinistra
	var porta_left_rect = porta_left.get_rect()
	var porta_left_global_position = porta_left.global_position
	porta_left_rect.position = porta_left_global_position

	# Controlliamo la posizione globale della porta destra
	var porta_right_rect = porta_right.get_rect()
	var porta_right_global_position = porta_right.global_position
	porta_right_rect.position = porta_right_global_position

	# Debug: Stampa le posizioni e dimensioni dei rettangoli
	#print("Pacchetto Rect:", packet_rect)
	#print("Porta Left Rect:", porta_left_rect)
	#print("Porta Right Rect:", porta_right_rect)

	# Verifica se il pacchetto collide con la porta sinistra
	if porta_left_rect.intersects(packet_rect):
		check_redirect(ip_left)
	# Verifica se il pacchetto collide con la porta destra
	elif porta_right_rect.intersects(packet_rect):
		check_redirect(ip_right)

# Imposta il pacchetto come trasparente
func set_packet_transparent(packet: Sprite2D) -> void:
	packet.visible = false  # Rendi il pacchetto trasparente (alfa = 0.2)

# Controlla se l'utente ha reindirizzato il pacchetto correttamente
func check_redirect(network_ip: String) -> void:
	if dst_ip.split(".")[0] == network_ip.split(".")[0]:
		packets_sent_correctly+=1
