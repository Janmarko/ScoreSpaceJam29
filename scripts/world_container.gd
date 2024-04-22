extends Resource

#tile constants
const BLOCKER = 999
const FLOOR_1 = 1
const FLOOR_2 = 2
const FLOOR_3 = 3
const FLOOR_DOOR = 4
const OCCLUDER = 5
const WINDOW = 6
const SPACE_DEFAULT = 7
const SPACE_1 = 8
const SPACE_2 = 9
const SPACE_3 = 10
const SPACE_4 = 11
const SPACE_5 = 12
const SPACE_6 = 13
const SPACE_7 = 14
const SPACE_8 = 15
const OCCLUDER_2 = 16

#tile id to Atlas coordinates map
const TILE_COORDS = {
	BLOCKER: Vector2i(8, 8),
	FLOOR_1: Vector2i(0, 0),
	FLOOR_2: Vector2i(1, 0),
	FLOOR_3: Vector2i(2, 0),
	FLOOR_DOOR: Vector2i(3, 0),
	OCCLUDER: Vector2i(0, 2),
	WINDOW: Vector2i(0, 9),
	SPACE_DEFAULT: Vector2i(5, 9),
	SPACE_1: Vector2i(1, 9),
	SPACE_2: Vector2i(2, 9),
	SPACE_3: Vector2i(3, 9),
	SPACE_4: Vector2i(4, 9),
	SPACE_5: Vector2i(6, 9),
	SPACE_6: Vector2i(7, 9),
	SPACE_7: Vector2i(8, 9),
	SPACE_8: Vector2i(9, 9),
	OCCLUDER_2: Vector2i(4, 3),
}
var COORDS_TILE = {} #inverse to the above, populated in constructor

#chances per floor tile generation
const FLOOR_TILES = [FLOOR_1, FLOOR_2, FLOOR_3]
const FLOOR_CHANCES = [92, 4, 4]
var FLOOR_CHANCE_ARRAY = [] #populated in constructor

#chances per space tile generation
const SPACE_TILES = [SPACE_DEFAULT, SPACE_1, SPACE_2, SPACE_3, SPACE_4, SPACE_5, SPACE_6, SPACE_7, SPACE_8]
const SPACE_CHANCES = [76, 3, 3, 3, 3, 3, 3, 3, 3]
var SPACE_CHANCE_ARRAY = [] #populated in constructor

#chance for a window to appear where possible
const WINDOW_CHANCE = 0.1

#4-dir field, 0123 = up right down left
const DIRX4 = [0, 1, 0, -1]
const DIRY4 = [-1, 0, 1, 0]

#8-dir field, 01234567 = clockwise, starting from up
const DIRX8 = [0, 1, 1, 1, 0, -1, -1, -1]
const DIRY8 = [-1, -1, 0, 1, 1, 1, 0, -1]

#delta field, for making rooms
const DLTX = [1, 1, -1, -1]
const DLTY = [1, -1, 1, -1]

#door patterns
const DOOR_PATTERN_DIR = [0, 1, 2, 6, 7]
const DOOR_PATTERNS = [[true, true, false, false, true],
						[true, false, false, false, true],
						[true, true, false, false, false]]

#references - set up in constructor
var tile_map = null
var rng = null

#world data
var loaded_chunk = null
var generated_chunks = {}
var room_ids = {}
var room_centers = {}
var hallway_coords = {}
var graph = {}
var tile_map_backend = {}

func _init(new_tile_map):
	tile_map = new_tile_map
	rng = RandomNumberGenerator.new()
	rng.randomize()
	for k in TILE_COORDS:
		COORDS_TILE[TILE_COORDS[k]] = k

	for i in range(0, len(FLOOR_TILES)):
		for j in range(0, FLOOR_CHANCES[i]):
			FLOOR_CHANCE_ARRAY.append(FLOOR_TILES[i])
	for i in range(0, len(SPACE_TILES)):
		for j in range(0, SPACE_CHANCES[i]):
			SPACE_CHANCE_ARRAY.append(SPACE_TILES[i])


func _ready():
	pass

func choose_floor():
	return FLOOR_CHANCE_ARRAY[rng.randi_range(0, 99)]

func choose_space():
	return SPACE_CHANCE_ARRAY[rng.randi_range(0, 99)]

func generate_room(x_center, y_center):
	#Generates a room and returns a dictionary representing the room in global coords
	#Returned dict:
	#	key: Vector2i -> representing x,y coords in global space
	#	value: tile_id constant (like FLOOR_1 etc.)
	var room_coords = {}
	for i in range(y_center-0, y_center+0+1):
		for j in range(x_center-0, x_center+0+1):
			room_coords[Vector2i(j, i)] = choose_floor()

	var room_cnt = rng.randi_range(1, 4)
	var overlapped = false
	for i in range(0, room_cnt):
		var key = room_coords.keys().pick_random()
		var kx = key[0]
		var ky = key[1]

		var dir = rng.randi_range(0, 3)
		var ylen = rng.randi_range(4, 8)
		var xlen = rng.randi_range(4, 8)

		var room_part = {}
		for y in range(0, ylen):
			var ny = ky + y*DLTY[dir]
			for x in range(0, xlen):
				var nx = kx + x*DLTX[dir]
				room_part[Vector2i(nx, ny)] = choose_floor()
		
		var overlap = false
		for k in room_part:
			if k in tile_map_backend:
				overlap = true
				break

		if not overlap:
			overlapped = true
			room_coords.merge(room_part)

	if not overlapped:
		for k in room_coords:
			room_coords = { Vector2i(x_center, y_center): BLOCKER }
	
	return room_coords

func extend_room(room, tile_id):
	#Surrounds given room by 1 space and puts tile_id in 8 directions around room edges
	var ext = {}
	for k in room.keys():
		for d in range(0, 8):
			var nx = k[0] + DIRX8[d]
			var ny = k[1] + DIRY8[d]
			if Vector2i(nx, ny) not in room:
				ext[Vector2i(nx, ny)] = tile_id
	room.merge(ext)
	return room

func show_tile(tile_id, x, y):
	#Adds a tile to the world
	#tile_id = one of the constants on top of this file like FLOOR_1 etc.
	#x, y = tile map coords in the world
	tile_map.set_cell(0, Vector2i(x, y), 0, TILE_COORDS[tile_id], 0)

func show_chunk(x_chunk, y_chunk):
	var x_center = x_chunk * 25 + 12
	var y_center = y_chunk * 25 + 12
	
	tile_map.clear()
	for i in range(y_center-40, y_center+40+1):
		for j in range(x_center-40, x_center+40+1):
			if Vector2i(j, i) in tile_map_backend:
				show_tile(tile_map_backend[Vector2i(j, i)], j, i)
	
	loaded_chunk = Vector2i(x_chunk, y_chunk)

func save_room(room):
	for k in room.keys():
		if room[k] == BLOCKER:
			if k in tile_map_backend:
				continue
		tile_map_backend[k] = room[k]

func generate_hallway(from_x, from_y, to_x, to_y, from_id, to_id):
	#Generates a hallway between 2 coordinates
	#Returned dict:
	#	key: Vector2i -> representing x,y coords in global space
	#	value: tile_id constant (like FLOOR_1 etc.)
	var dx = sign(to_x - from_x)
	var dy = sign(to_y - from_y)

	var cx = from_x
	var cy = from_y
	var hallway = []
	while true:
		if cx == to_x and cy == to_y:
			break
		
		tile_map_backend[Vector2i(cx, cy)] = choose_floor()
		hallway.append(Vector2i(cx, cy))

		for d in range(0, 8):
			var nx = cx + DIRX8[d]
			var ny = cy + DIRY8[d]
			if Vector2i(nx, ny) not in tile_map_backend:
				tile_map_backend[Vector2i(nx, ny)] = OCCLUDER
			elif tile_map_backend[Vector2i(nx, ny)] == BLOCKER:
				tile_map_backend[Vector2i(nx, ny)] = OCCLUDER

		if cx != to_x:
			cx += dx
		else:
			cy += dy

	for h in hallway:
		cx = h[0]
		cy = h[1]
		var found = false
		for p in DOOR_PATTERNS:
			for k in range(0, 4):
				var all_true = true
				for i in range(0, 5):
					var nx = cx + DIRX8[(DOOR_PATTERN_DIR[i] + k*2)%8]
					var ny = cy + DIRY8[(DOOR_PATTERN_DIR[i] + k*2)%8]

					if (tile_map_backend[Vector2i(nx, ny)] == OCCLUDER or tile_map_backend[Vector2i(nx, ny)] == OCCLUDER_2) == p[i]:
						all_true = false
						break
				if all_true:
					#manual check if 2 in front is occluder - that's a weird hallway pattern
					var nx = cx + 2*DIRX4[k]
					var ny = cy + 2*DIRY4[k]

					if tile_map_backend[Vector2i(nx, ny)] == OCCLUDER or tile_map_backend[Vector2i(nx, ny)] == OCCLUDER_2:
						continue
					else:
						#manual check if left and right from the one 2 in front are both occluders
						var nx1 = nx + DIRX4[(k+1)%4]
						var ny1 = ny + DIRY4[(k+1)%4]
						var nx2 = nx + DIRX4[(k+3)%4]
						var ny2 = ny + DIRY4[(k+3)%4]

						if (tile_map_backend[Vector2i(nx1, ny1)] == OCCLUDER or tile_map_backend[Vector2i(nx1, ny1)] == OCCLUDER_2) and \
							(tile_map_backend[Vector2i(nx2, ny2)] == OCCLUDER or tile_map_backend[Vector2i(nx2, ny2)] == OCCLUDER_2):
								continue

					found = true
					tile_map_backend[Vector2i(cx, cy)] = FLOOR_DOOR
					break
			if found:
				break

var first_gen = true
func generate_env(x_center, y_center):
	#Generates environment around given point
	#Generates rooms and hallways
	var x_chunk = floor(x_center / 400)
	var y_chunk = floor(y_center / 400)
	if Vector2i(x_chunk, y_chunk) not in generated_chunks:
		generated_chunks[Vector2i(x_chunk, y_chunk)] = null
		x_center = x_chunk * 25 + 12
		y_center = y_chunk * 25 + 12
	else:
		if loaded_chunk != Vector2i(x_chunk, y_chunk):
			show_chunk(x_chunk, y_chunk)
		return

	#take the starting room from engine
	var new_rooms = []
	if first_gen:
		first_gen = false

		var room = {}
		for i in range(y_center-50, y_center+50+1):
			for j in range(x_center-50, x_center+50+1):
				var tile = tile_map.get_cell_atlas_coords(0, Vector2i(j, i))
				if tile[0] != -1:
					room[Vector2i(j, i)] = COORDS_TILE[tile]

		var current_room = len(room_centers)
		var sum_x = 0
		var sum_y = 0
		var count = 0
		for k in room:
			if room[k] != BLOCKER:
				room_ids[k] = current_room
				sum_x += k[0]
				sum_y += k[1]
				count += 1
		room_centers[current_room] = Vector2i(round(sum_x / count), round(sum_y / count))
		new_rooms.append(current_room)

		room = extend_room(room, OCCLUDER)
		room = extend_room(room, BLOCKER)
		save_room(room)

	var free_tiles = {}
	for i in range(y_center-50, y_center+50+1):
		for j in range(x_center-50, x_center+50+1):
			if Vector2i(j, i) not in tile_map_backend:
				free_tiles[Vector2i(j, i)] = null

	#generate other rooms
	while len(free_tiles.keys()) > 0:
		var room_anchor = free_tiles.keys().pick_random()
		var room = generate_room(room_anchor[0], room_anchor[1])
		if len(room) > 10:
			var current_room = len(room_centers)
			var sum_x = 0
			var sum_y = 0
			var count = 0
			for k in room:
				if room[k] != BLOCKER:
					room_ids[k] = current_room
					sum_x += k[0]
					sum_y += k[1]
					count += 1
			room_centers[current_room] = Vector2i(round(sum_x / count), round(sum_y / count))
			new_rooms.append(current_room)
			
		if len(room) > 10:
			room = extend_room(room, OCCLUDER)
		else:
			room = extend_room(room, BLOCKER)
		room = extend_room(room, BLOCKER)
		for k in room:
			free_tiles.erase(k)
		save_room(room)

	#generate hallways
	for i in range(0, len(room_centers)):
		if i not in graph:
			graph[i] = {}

	for nr in new_rooms:
		var nrx = room_centers[nr][0]
		var nry = room_centers[nr][1]
		var close_rooms = {}
		for i in range(nry-15, nry+15+1):
			for j in range(nrx-15, nrx+15+1):
				if Vector2i(j, i) in room_ids:
					if nr != room_ids[Vector2i(j, i)]:
						close_rooms[room_ids[Vector2i(j, i)]] = null

		var dists = []
		for next in close_rooms:
			var dist = abs(room_centers[nr][0] - room_centers[next][0]) + \
					   abs(room_centers[nr][1] - room_centers[next][1])
			dists.append(Vector2i(dist, next))
		dists.sort()

		var halls = 0
		if len(dists) >= 1:
			halls = 1
		if len(dists) >= 2:
			halls = 2
		if len(dists) >= 3:
			if rng.randf() >= 0.5:
				halls = 3

		for h in range(0, halls):
			if dists[h][1] in graph[nr]:
				continue
			graph[nr][dists[h][1]] = null
			graph[dists[h][1]][nr] = null
			generate_hallway(room_centers[nr][0], room_centers[nr][1], \
							 room_centers[dists[h][1]][0], room_centers[dists[h][1]][1], \
							 nr, dists[h][1])

	#add space tiles outside
	for i in range(y_center-50, y_center+50+1):
		for j in range(x_center-50, x_center+50+1):
			if Vector2i(j, i) not in tile_map_backend:
				continue
			if tile_map_backend[Vector2i(j, i)] == BLOCKER:
				tile_map_backend[Vector2i(j, i)] = choose_space()

	#add windows - x axis
	var occluder_coords = {}
	for i in range(y_center-50, y_center+50+1):
		for j in range(x_center-50, x_center+50+1):
			#5 occluders in row
			var found = true
			for k in range(-2, 3):
				var nx = j+k
				if Vector2i(nx, i) not in tile_map_backend:
					found = false
					break
				if tile_map_backend[Vector2i(nx, i)] != OCCLUDER:
					found = false
					break
				occluder_coords[Vector2i(nx, i)] = null
			if not found:
				continue

			#3 spaces next to occluder on each side are not occluders
			found = true
			for k in range(-1, 2):
				var nx = j+k
				if Vector2i(nx, i-1) not in tile_map_backend:
					found = false
					break
				if tile_map_backend[Vector2i(nx, i-1)] == OCCLUDER or tile_map_backend[Vector2i(nx, i-1)] == OCCLUDER_2:
					found = false
					break
				occluder_coords[Vector2i(nx, i-1)] = null
			if not found:
				continue

			found = true
			for k in range(-1, 2):
				var nx = j+k
				if Vector2i(nx, i+1) not in tile_map_backend:
					found = false
					break
				if tile_map_backend[Vector2i(nx, i+1)] == OCCLUDER or tile_map_backend[Vector2i(nx, i+1)] == OCCLUDER_2:
					found = false
					break
				occluder_coords[Vector2i(nx, i+1)] = null
			if not found:
				continue

			if rng.randf() <= WINDOW_CHANCE:
				for k in range(-1, 2):
					var nx = j+k
					tile_map_backend[Vector2i(nx, i)] = WINDOW

	#add windows - y axis
	for i in range(y_center-50, y_center+50+1):
		for j in range(x_center-50, x_center+50+1):
			var found = true
			for k in range(-2, 3):
				var ny = i+k
				if Vector2i(j, ny) not in tile_map_backend:
					found = false
					break
				if tile_map_backend[Vector2i(j, ny)] != OCCLUDER:
					found = false
					break
				occluder_coords[Vector2i(j, ny)] = null
			if not found:
				continue

			#y-axis - 3 spaces next to occluder on each side are not occluders
			found = true
			for k in range(-1, 2):
				var ny = i+k
				if Vector2i(j-1, ny) not in tile_map_backend:
					found = false
					break
				if tile_map_backend[Vector2i(j-1, ny)] == OCCLUDER or tile_map_backend[Vector2i(j-1, ny)] == OCCLUDER_2:
					found = false
					break
				occluder_coords[Vector2i(j-1, ny)] = null
			if not found:
				continue

			found = true
			for k in range(-1, 2):
				var ny = i+k
				if Vector2i(j+1, ny) not in tile_map_backend:
					found = false
					break
				if tile_map_backend[Vector2i(j+1, ny)] == OCCLUDER or tile_map_backend[Vector2i(j+1, ny)] == OCCLUDER_2:
					found = false
					break
				occluder_coords[Vector2i(j+1, ny)] = null
			if not found:
				continue

			if rng.randf() <= WINDOW_CHANCE:
				for k in range(-1, 2):
					var ny = i+k
					tile_map_backend[Vector2i(j, ny)] = WINDOW

	for k in occluder_coords:
		if tile_map_backend[k] == OCCLUDER:
			tile_map_backend[k] = OCCLUDER_2
	
	if loaded_chunk != Vector2i(x_chunk, y_chunk):
		show_chunk(x_chunk, y_chunk)
		
