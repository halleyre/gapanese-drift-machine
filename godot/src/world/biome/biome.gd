@abstract
class_name Biome
extends Node2D


@export var show_debug: bool = true:
	set(value):
		show_debug = value
		queue_redraw()
@export var debug_size: int = 2


@export var cell_size: int = 20 # average distance between cells

# hex (axial coords) to world
var h2w := Transform2D(
	Vector2( 2,      0 ),
	Vector2( 1, sqrt(3)),
	Vector2( 0,      0 )
) * cell_size / 2

# world to hex
var w2h := h2w.affine_inverse()

# axial/cube basis
# q+r+s = 0, s = -q-r
const QAXIS_R = Vector2i( 0, 1)
const RAXIS_S = Vector2i( 1, 0)
const SAXIS_Q = Vector2i( 1,-1)
const adj = [-RAXIS_S, SAXIS_Q,-QAXIS_R, # upper hemisphere
			  RAXIS_S,-SAXIS_Q, QAXIS_R] # lower hemisphere

static func cell_distance(a: Vector2i, b:= Vector2i.ZERO):
	var q = a.x - b.x # column delta
	var r = a.y - b.y # row delta
	return sqrt(q*q + q*r + r*r)

# store by qr for [qrs displacment, texture]
var grid_map: Dictionary[Vector2i, Array]

# flat array for passing to shader
var grid_arr: Array
var ga_qoff := 0 # column offset
var ga_qn   := 1 # column count (stride)
var ga_roff := 0 # row offset
var ga_rn   := 1 # row count

# enum {NULL, OOB, ...
@abstract func get_hex(pos: Vector2i)

func init_grid():
	var pos = Vector2i.ZERO
	grid_map[pos] = get_hex(pos)

	var dfs = [0]
	while dfs:
		if dfs.back() >= len(adj):
			if len(dfs) <= 1:
				break # stop after unwinding to first hex
			dfs.pop_back()
			pos += adj[(dfs.back()+3)%6] # invert last search
			continue # unwind after each full rotation
			
		var new_pos = pos + adj[dfs.back()];
		if grid_map.has(new_pos):
			dfs[-1] += 1
			continue

		var new_hex = get_hex(new_pos)
		grid_map[new_pos] = new_hex
		if new_hex[TERRAIN] == 1:
			dfs[-1] += 1
			continue

		pos = new_pos
		dfs.append(0)
