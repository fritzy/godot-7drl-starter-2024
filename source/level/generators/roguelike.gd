# Credit Jeff Lait, Brianna Stafford
# Preserve above Credit because Jeff Lait's POWDER is CC Sampling+ 1.0
# https://creativecommons.org/licenses/sampling+/1.0/
# Ported to GdScript by Nathan Fritz
# Kept isolated from game code for use in other projects.
# Made slightly more idiomatic for gdscript

extends Object
class_name RoguelikeGenerator

var rand: RandomNumberGenerator
var map: GeneratorMap

class Room:
	var minx: int
	var miny: int
	var maxx: int
	var maxy: int

func _init(_rand: RandomNumberGenerator) ->void:
	rand = _rand
	#map = GeneratorMap.new(width, height)

func choose_random_exit(room: Room) -> Array[Vector2i]:
	var posangle: Array[Vector2i] = [Vector2i(0, 0), Vector2i(0,0)]
	match(rand.randi_range(0, 3)):
		0:
			posangle[0].x = room.minx;
			posangle[0].y = rand.randi_range(room.miny + 1, room.maxy - 1);
			posangle[1].x = -1;
			posangle[1].y = 0;
		1:
			posangle[0].x=room.maxx;
			posangle[0].y=rand.randi_range(room.miny+1, room.maxy-1);
			posangle[1].x = 1;
			posangle[1].y=0;
		2:
			posangle[0].x=rand.randi_range(room.minx+1, room.maxx-1);
			posangle[0].y=room.miny;
			posangle[1].x=0;
			posangle[1].y=-1;
		3:
			posangle[0].x=rand.randi_range(room.minx+1, room.maxx-1);
			posangle[0].y=room.maxy;
			posangle[1].x=0;
			posangle[1].y=1;
	return posangle

func build_random_room(room: Room) -> Room:
	room.minx =rand.randi_range(1, map.width - 4);
	room.miny=rand.randi_range(1, map.height - 4);
	room.maxx=rand.randi_range(room.minx+3,min(room.minx+8, map.width-2));
	room.maxy=rand.randi_range(room.miny+3,min(room.miny+8, map.height-2));
	return room;

func check_room_fits(room: Room) -> bool:
  	#Check the room boundaries. We don't want to override any existing level data.
	for y:int in range(room.miny, room.maxy + 1):
		for x:int in range(room.minx, room.maxx + 1):
			if map.get_tile(x, y) != GeneratorTiles.stoneWall.tile_id:
				return false

 	# Check the room's immediate surroundings.
	# We don't want to generate along the map edge or directly adjacent to an existing room.
	# This looks ugly and causes problems with drawing the corridors.
	for x: int in range(room.minx - 1, room.maxx + 1):
		if map.is_map_wall(x, room.miny - 1):
			return false
		if map.is_map_wall(x, room.maxy + 1):
			return false
	for y: int in range(room.miny - 1, room.maxy + 1):
		if map.is_map_wall(room.minx - 1, y):
			return false
		if map.is_map_wall(room.maxx + 1, y):
			return false
	return true

func draw_room(room: Room) -> void:
	for x: int in range(room.minx, room.maxx + 1):
		for y: int in range(room.miny, room.maxy + 1):
			if x == room.minx or x == room.maxx or y == room.miny or y == room.maxy:
				map.set_tile(x, y, GeneratorTiles.roomWall.tile_id)
			else:
				map.set_tile(x, y, GeneratorTiles.roomFloor.tile_id)

# We don't want to indiscriminately place floor Tiles, so this function is used
# to place different path Tiles based on what's currently occupying the space.
func set_path_tile(x: int, y: int) -> void:
	var oldtile: int = map.get_tile(x, y);
	var newtile: int = oldtile
	if oldtile == GeneratorTiles.stoneFloor.tile_id:
		return
	elif oldtile == GeneratorTiles.stoneWall.tile_id:
		newtile = GeneratorTiles.stoneFloor.tile_id
	elif oldtile == GeneratorTiles.door.tile_id  or oldtile == GeneratorTiles.roomWall.tile_id:
		newtile = GeneratorTiles.door.tile_id
	map.set_tile(x, y, newtile)

# Draw a corridor between the two XY pairs.
func find_path(s: Array[int], e: Array[int]) -> bool:
	var d: Array[int] = []
	d.resize(2)
	var dir: int
	var wallhit: int
	var n: Array[int] = []
	n.resize(2)
	var length: int = 0
	var ncnt: int = 0
	
	# Get the initial random axis
	dir = rand.randi_range(0, 1);
	set_path_tile(s[0], s[1])
	
	while s[0] != e[0] or s[1] != e[1]:
		# Find our current direction
		for i: int in range(0, 2):
			d[i] = sign(e[i] - s[i])
	  	# Switch direction
		dir = 1 if dir == 0 else 0
		# If we're facing that direction, switch axis
		if d[dir] == 0:
			dir = 1 if dir == 0 else 0
		wallhit = 0
		# Move in the direction dir until a random chance fails, or we get aligned with a destination.
		while true:
			if rand.randi_range(1, 100) < 40:
		  		#Random exit clause!
				break
			# Alignment. This only counts for straight moves.
			# If bounced off a wall we don't want to trigger.
			if wallhit == 0 and s[dir] == e[dir]: # and wallhit = 0
				break
			# Calculate the next pos...
			n[0] = s[0]
			n[1] = s[1]
			n[dir] += d[dir]
			
			# Check if our current dig direction is valid...
			ncnt = 0
			while map.is_map_wall(n[0], n[1]):
				# Not a valid dig direction!  Rotate 90 degrees and go in a random direction.
				# As we never build walls adjacent and they are square, this (usually) guarantees a non-wall.
				dir = 1 if dir == 0 else 0
				if d[dir] == 0:
					d[dir] = rand.randi_range(0, 1) * 2 - 1;
				n[0] = s[0]
				n[1] = s[1]
				n[dir] += d[dir]
				wallhit = 1
				ncnt += 1
				# TODO: should scale with map size
				if ncnt > floor(map.width as float * map.height as float * 0.1) as int:
					# This fails when we hit the bottom most wall, turn to the left,
					# and then hit the left wall prior to deciding to reset
					# Note that alignment will never trigger as wallhit = true,
					# and we could have been going the wrong way anyways.
					print("---------- fail -------------")
					return false
			# Move in the desired direction...
			s[dir] += d[dir]
			set_path_tile(s[0], s[1])
			length += 1
			# TODO: should scale this with map size
			if length > int(float(map.width) * float(map.height) * 0.1):
				print ("========= othe rfail ------------")
				return false
	return true

func draw_corridor(s: Array[Vector2i], e: Array[Vector2i]) -> bool:
	var start := s[0] + s[1]
	var end := e[0] + e[1]
	var success := find_path([start.x , start.y], [end.x, end.y])
	# Draw our doors.  We only do this if our path creation was successful.
	if success:
		set_path_tile(s[0].x, s[0].y)
		set_path_tile(e[0].x, e[0].y)
	return success

func generate(width: int, height: int, _num_rooms: int, depth: int, stairs: bool) -> GeneratorMap:
	var num_rooms: int = _num_rooms
	var rooms: Array[Room] = []
	var numroom: int = 0
	var fails: int = 0
	var src: int
	var room: int
	var x: int
	var y: int
	
	map = GeneratorMap.new(width, height, depth)
	# Build as many rooms as fits, up to twenty.
	while fails < 40 and numroom < num_rooms:
		rooms.append(build_random_room(Room.new()))
		if check_room_fits(rooms[numroom]):
			draw_room(rooms[numroom])
			numroom += 1
		else:
			rooms.remove_at(numroom)
			fails += 1
	# Now, build corridors...
	# We want every room to be connected. Thus, we have a pool of i connected rooms.
	# We each round take i+1 and connect it to a room that's already been connected to the rest of the dungeon.
	# If we fail to connect 40 times, we declare this dungeon sucky and go again...
	fails = 0
	for i:int in range(rooms.size() - 1):
		src = rand.randi_range(0, i);
		var vecs: Array[Vector2i] = choose_random_exit(rooms[src])
		var vecs2: Array[Vector2i] = choose_random_exit(rooms[i+1])
		# Draw a corridor between these two rooms.
		if !draw_corridor(vecs,vecs2):
			# Failed to draw a corridor, try again.
			i -= 1
			fails += 1
			if fails > 40:
				print("failed to connect room")
				break
			continue
		print("failes %d" % fails)
	if fails > 40: 
		print("We messed that one up, trying again!")
		return generate(width, height, num_rooms, depth, stairs)
	
	# Now, we pick a random up and down stair case
	if stairs:
		while true:
			room = rand.randi_range(0, rooms.size() - 1)
			var rm: Room = rooms[room]
			x = rand.randi_range(rm.minx + 1, rm.maxx - 1)
			y = rand.randi_range(rm.miny + 1, rm.maxy - 1)
			if map.get_tile(x, y) == GeneratorTiles.roomFloor.tile_id:
				map.set_tile(x, y, GeneratorTiles.stairsDown.tile_id)
				break
		while true:
			room = rand.randi_range(0, rooms.size() - 1);
			var rm: Room = rooms[room]
			x = rand.randi_range(rm.minx + 1, rm.maxx - 1)
			y = rand.randi_range(rm.miny + 1, rm.maxy - 1)
			if map.get_tile(x, y) == GeneratorTiles.roomFloor.tile_id:
				map.set_tile(x, y, GeneratorTiles.stairsUp.tile_id)
				break
	return map
