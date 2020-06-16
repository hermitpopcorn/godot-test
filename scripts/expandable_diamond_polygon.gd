extends Polygon2D

var initial_vectors

func _ready():
	self.initial_vectors = self.polygon

func resize_polygon0(new_vector):
	self.polygon[0] = new_vector
	
func resize_polygon1(new_vector):
	self.polygon[1] = new_vector
	
func resize_polygon2(new_vector):
	self.polygon[2] = new_vector

func resize_polygon3(new_vector):
	self.polygon[3] = new_vector

func _shrink_completed():
	self.visible = false
