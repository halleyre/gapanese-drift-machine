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
enum {SHIFT, TERRAIN}
var grid_map: Dictionary[Vector2i, Array]

# flat array for passing to shader
class GridArray:
	enum {Q, R}
	var shift := PackedFloat32Array([])
	var trn   := PackedByteArray([])
	var qmin  := 0 # column
	var qend  := 0 # - exclusive
	var rmin  := 0 # row
	var rend  := 0 # - exclusive
var grid := GridArray.new()

enum {NULL, OOB, CLEAR} # ...
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

		# check if search has already passed this direction
		var new_pos = pos + adj[dfs.back()];
		if grid_map.has(new_pos):
			dfs[-1] += 1
			continue

		grid.qmin = min(grid.qmin, new_pos.x)
		grid.qend = max(grid.qend, new_pos.x + 1)
		grid.rmin = min(grid.rmin, new_pos.y)
		grid.rend = max(grid.rend, new_pos.y + 1)

		# check if search can continue this direction
		var new_hex = get_hex(new_pos)
		grid_map[new_pos] = new_hex
		if new_hex[TERRAIN] == OOB:
			dfs[-1] += 1
			continue

		# search around new cell
		pos = new_pos
		dfs.append(0)

func init_biome():
	init_grid()
	for r in range(grid.rmin, grid.rend):
		for q in range(grid.qmin, grid.qend):
			var hex = grid_map.get(Vector2i(q,r), [Vector2.ZERO, NULL])
			grid.shift.append_array([hex[SHIFT].x, hex[SHIFT].y])
			grid.trn.append(hex[TERRAIN])


const debug_colours = [Color.GRAY,
					   Color.AQUA,
					   Color.BLACK]
func _draw():
	if not show_debug: return

	for hex in grid_map.keys():
		var v = grid_map[hex]
		draw_circle(h2w * (Vector2(hex) +  v[SHIFT]),
					debug_size,
					debug_colours[v[TERRAIN]])

	for r in range(grid.rmin, grid.rend):
		for q in range(grid.qmin, grid.qend):
			var i = ((r - grid.rmin) * (grid.qend - grid.qmin)
					 + q - grid.qmin)
			var pos = Vector2(q + grid.shift[2*i + grid.Q],
							  r + grid.shift[2*i + grid.R])
			
			draw_circle(h2w * pos,
						debug_size * 2,
						debug_colours[grid.trn[i]],
						false)

func _process(_d):
	if show_debug: queue_redraw()
