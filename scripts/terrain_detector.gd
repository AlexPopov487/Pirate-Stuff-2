extends Area2D

class_name TerrainDetector
enum TerrainType {GROUND = 0, MUD = 1}

signal terrain_type_changed(updated_terrain: TerrainType)

var current_terrain: TerrainType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMap:
		define_terrain(body_rid, body)


func define_terrain(tile_rid: RID, tilemap: TileMap):
	var tile_coords = tilemap.get_coords_for_body_rid(tile_rid)
	
	for index in tilemap.get_layers_count():
		var current_layer = tilemap.get_layer_name(index)
		if current_layer != 'mid':
			continue
		var tile_data = tilemap.get_cell_tile_data(index, tile_coords)
		
		if tile_data is not TileData:
			continue
			
		var terrain_type = tile_data.get_custom_data('terrain_type')
		update_terrain_type(terrain_type)
		break
		
func update_terrain_type(terrain_type: int):
	if terrain_type == current_terrain:
		return
	
	current_terrain = terrain_type
	terrain_type_changed.emit(current_terrain)
	print("player stepping on " + TerrainType.find_key(current_terrain))
