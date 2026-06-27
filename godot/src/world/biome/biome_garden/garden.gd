extends Biome

@export var biome_radius: int = 20

var edge_noise: FastNoiseLite
const EDGE_THRESHOLD = 0.2
func init_noise():
	edge_noise = FastNoiseLite.new()
	edge_noise.seed = randi()
	edge_noise.frequency = 0.001
	edge_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

enum {_NULL, _OOB, _CLEAR}
func get_hex(pos: Vector2i):
	var shift = Vector2.RIGHT.rotated(randf()*2*PI)
	shift *= randf() * cell_size / 2
	shift = w2h * shift

	var terrain = CLEAR
	if abs(edge_noise.get_noise_2dv(h2w * Vector2(pos))) > EDGE_THRESHOLD:
		terrain = OOB
	if cell_distance(pos) > biome_radius:
		terrain = OOB

	return [shift, terrain]

func _init() -> void:
	init_noise()
	init_biome()
