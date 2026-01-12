extends Area2D
class_name TerrainDetector

enum TerrainType {GROUND = 0, MUD = 1, WATER = 2}

var _current_terrain: TerrainType
@onready var _character: Character = get_parent()

func reset_terrain():
	_current_terrain = TerrainType.GROUND

func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is TileMap:
		_define_terrain(body_rid, body)


func _define_terrain(tile_rid: RID, tilemap: TileMap):
	var tile_coords = tilemap.get_coords_for_body_rid(tile_rid)
	
	for index in tilemap.get_layers_count():
		var current_layer = tilemap.get_layer_name(index)
		# 'mid' layer is for ground, 'foreground' - for water, bacground is used for trees in mud
		if current_layer != 'mid' && current_layer != 'foreground' && current_layer != 'background':
			continue
		var tile_data = tilemap.get_cell_tile_data(index, tile_coords)
		
		if tile_data is not TileData:
			continue
			
		var terrain_type = tile_data.get_custom_data('terrain_type')
		_update_terrain_type(terrain_type)
		break
		
func _update_terrain_type(terrain_type: TerrainType):
	if terrain_type == _current_terrain:
		return
	
	_current_terrain = terrain_type
	print(_character.name + " stepping on " + TerrainType.find_key(_current_terrain))
	
	_process_terrain_affect()


func _process_terrain_affect():
	match _current_terrain:
		TerrainType.GROUND:
			_character.step_on_ground()
		TerrainType.WATER:
			_character.take_damage(1000, Vector2.ZERO)
		TerrainType.MUD:
			_character.step_on_mud()
