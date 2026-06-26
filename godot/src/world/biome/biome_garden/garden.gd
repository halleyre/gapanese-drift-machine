extends Biome

@export var biome_radius: int = 20

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
	var jitter = Vector3(randf(),randf(),randf())/2

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
