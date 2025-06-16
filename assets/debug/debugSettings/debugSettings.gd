extends GameSaveableBase;

################################################################################

# NOTE: This script pertains to features useful to debugging the game.

################################################################################

var colliders_visible : bool = false;
var render_wireframe : bool = false;

################################################################################

func getFileLocation() -> String:
	return "debug.txt"
	
func _ready():
	loadSaveable();
	
	updateDebugCollisionHint();
	bindValueChanged("colliders_visible", updateDebugCollisionHint);
	
	RenderingServer.set_debug_generate_wireframes(true)
	updateWireframeView()
	bindValueChanged("render_wireframe", updateWireframeView);
	

func updateDebugCollisionHint():
	# Update visibility hint.
	if (get_tree().debug_collisions_hint == colliders_visible): return;
	get_tree().debug_collisions_hint = colliders_visible;
	
	# Tree recurse to update from hint.
	var queueStack : Array[Node] = [ get_tree().get_root() ];
	
	# Traverse tree to call update methods where available.
	while (!queueStack.is_empty()):
		# Get node.
		var node : Node = queueStack.pop_back()
		if (!is_instance_valid(node)): continue;
		
		# Update node.
		if (node is CollisionShape3D):
			# Force redraw by re-adding to tree.
			var parent: Node = node.get_parent()
			if (parent != null):
				parent.remove_child(node);
				parent.add_child(node);
		
		# Recurse children.
		var children_count : int = node.get_child_count()
		for child_index in range(0, children_count):
			queueStack.push_back(node.get_child(child_index))

func updateWireframeView():
	if (render_wireframe):
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
	else:
		get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED

################################################################################
