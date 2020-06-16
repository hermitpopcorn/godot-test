extends Line2D

var initial_vectors

func _ready():
	self.initial_vectors = self.points

func resize_polygon0(new_vector):
	self.points[0] = new_vector
	
func resize_polygon1(new_vector):
	self.points[1] = new_vector
	
func resize_polygon2(new_vector):
	self.points[2] = new_vector

func resize_polygon3(new_vector):
	self.points[3] = new_vector

func resize_polygon4(new_vector):
	self.points[4] = new_vector
