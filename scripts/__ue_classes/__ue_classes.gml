function UniqueMaterial() constructor {
	gml_pragma("forceinline");
	
	textures = {};
	color_diffuse = [];
	color_ambient = [];
	color_specular = [];
	color_emissive = [];
}

function UniqueMesh() constructor {
	gml_pragma("forceinline");
	
	vbuff = undefined;
	material = undefined;
}

function UniqueTexture(texture_path, texture_type, sprite) constructor {
	gml_pragma("forceinline");
	
	id = texture_path;
	type = texture_type;
	self.sprite = sprite;
	texture = sprite_get_texture(sprite, 0);
}