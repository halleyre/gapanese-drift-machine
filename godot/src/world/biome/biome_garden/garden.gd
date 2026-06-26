extends Node2D


@export var hex_size: int = 20
@export var grid_size: int = 20

@export var show_debug: bool = true:
	set(value):
		show_debug = value
		queue_redraw()
@export var debug_size: int = 2

# hex to world
var h2w := Transform2D(
	Vector2( 2,      0 ),
	Vector2( 1, sqrt(3)),
	Vector2( 0,      0 )
) * hex_size / 2

# world to hex
var w2h := h2w.affine_inverse()

# q+r+s = 0, s = -q-r
# store by qr for [qrs displacment, texture]
var grid: Dictionary[Vector2i, Array]
const QAXIS_R = Vector2i( 0, 1)
const RAXIS_S = Vector2i( 1, 0)
const SAXIS_Q = Vector2i( 1,-1)
const adj = [-RAXIS_S, SAXIS_Q,-QAXIS_R, # upper hemisphere
			  RAXIS_S,-SAXIS_Q, QAXIS_R] # lower hemisphere

func distance(a: Vector2i, b:= Vector2i.ZERO):
	var q = a.x - b.x # column delta
	var r = a.y - b.y # row delta
	return sqrt(q*q + q*r + r*r)

var edge_noise: FastNoiseLite
const EDGE_THRESHOLD = 0.2
func init_noise():
	edge_noise = FastNoiseLite.new()
	edge_noise.seed = randi()
	edge_noise.frequency = 0.001
	edge_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

enum {APOS, TERRAIN}
enum {CLEAR, EDGE}
func gen_hex(pos: Vector2i):
	var jitter = Vector3.ZERO

	var terrain = CLEAR
	if abs(edge_noise.get_noise_2dv(h2w * Vector2(pos))) > EDGE_THRESHOLD:
		terrain = EDGE
	if distance(pos) > grid_size:
		terrain = EDGE

	return [Vector2(pos.x + jitter.x - jitter.z/2,
					pos.y + jitter.y - jitter.z/2),
			terrain]

func _init() -> void:
	init_noise()
	
	var pos = Vector2i.ZERO
	grid[pos] = gen_hex(pos)

	var dfs = [0]
	while dfs:
		if dfs.back() >= len(adj):
			if len(dfs) <= 1:
				break # stop after unwinding to first hex
			dfs.pop_back()
			pos += adj[(dfs.back()+3)%6] # invert last search
			continue # unwind after each full rotation
			
		var new_pos = pos + adj[dfs.back()];
		if grid.has(new_pos):
			dfs[-1] += 1
			continue

		var new_hex = gen_hex(new_pos)
		grid[new_pos] = new_hex
		if new_hex[TERRAIN] == 1:
			dfs[-1] += 1
			continue

		pos = new_pos
		dfs.append(0)

const debug_colours = [Color.AQUA,
					   Color.BLACK]

func _draw():
	if not show_debug: return

	for hex in grid.values():
		draw_circle(h2w * hex[APOS],
					debug_size,
					debug_colours[hex[TERRAIN]])

func _process(_d):
	if show_debug: queue_redraw()
