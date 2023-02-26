// Create the Unique Vertex Format
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
vertex_format_add_color();
ue_vertex_format = vertex_format_end();

ue_matrix_identity = matrix_build_identity();
ue_model_version = "UniqueModel v1.0.0";

/**
 * UniqueModel Class
 *
 * @param {Array<Struct<UniqueMesh>>} meshes
 * @return {Struct<UniqueModel>}
 */
function UniqueModel(meshes = []) constructor {
	gml_pragma("forceinline");
	
	model_version = global.ue_model_version;
	x = 0;
	y = 0;
	z = 0;
	xrot = 0;
	yrot =180;
	zrot = 180;
	xscale = 1;
	yscale = 1;
	zscale = 1;
	self.meshes = meshes;
	meshes_count = array_length(meshes);
	faces_count = 0;
	triangles_count = 0;
	vertices_count = 0;
	materials_count = 0;
	
	/**
	 * Build the transform matrix and cache it
	 */
	transform = function() {
		gml_pragma("forceinline");
		
		matrix = matrix_build(x, y, z, xrot, yrot, zrot, xscale, yscale, zscale);
	};
	
	/**
	 * Freeze all the meshes vbuffers
	 */
	freeze = function() {
		for (var m=0; m<meshes_count; m++) {
			vertex_freeze(meshes[m].vbuff);
		}
	}
	
	/**
	 * Draw the model
	 */
	draw = function() {
		gml_pragma("forceinline");
		
		matrix_set(matrix_world, matrix);
		
		for (var a=0; a<meshes_count; a++) {
			var mesh = meshes[a];
			var material = mesh.material;
			vertex_submit(mesh.vbuff, pr_trianglelist, variable_struct_exists(material.textures, "diffuse") ? material.textures.diffuse.texture : -1);
		}
		
		matrix_set(matrix_world, global.ue_matrix_identity);
	};
	
	/**
	 * Free the model from the memory
	 */
	destroy = function() {
		gml_pragma("forceinline");
		
		for (var m=0; m<meshes_count; m++) {
			var mesh = meshes[m];
			vertex_delete_buffer(mesh.vbuff);
			
			var textures = mesh.material.textures; 
			var textures_names = variable_struct_get_names(textures);
			var textures_count = array_length(textures_names);
			for (var t=0; t<textures_count; t++) {
				sprite_delete(textures[$ textures_names[t]].sprite);
			}
			
			delete mesh.materials;
		}
		
		meshes = [];
		meshes_count = 0;
		faces_count = 0;
		triangles_count = 0;
		vertices_count = 0;
		materials_count = 0;
	};
	
	/**
	 * Returns a cloned model.
	 * Note: the model's meshes must not be frozen
	 */
	clone = function() {
		gml_pragma("forceinline");
		
		var dst_meshes = [];
		
		for (var m=0; m<meshes_count; m++) {
			var src_mesh = meshes[m];
			var dst_mesh = new UniqueMesh();
			var buff = buffer_create_from_vertex_buffer(src_mesh.vbuff, buffer_vbuffer, 1);
			dst_mesh.vbuff = vertex_create_buffer_from_buffer(buff, global.ue_vertex_format);
			buffer_delete(buff);
			dst_mesh.material = src_mesh.material;
			array_push(dst_meshes, dst_mesh);
		}
		
		return new UniqueModel(dst_meshes);
	};
	
	/** 
	 * Compile the model to a Unique buffer file, by also saving the related textures
	 */
	save = function(path) {
		gml_pragma("forceinline");
		
		var buffer = buffer_create(1024*100, buffer_grow, 1);
		var path_relative = filename_path(path);
		var materials_store = {};
	
		buffer_write(buffer, buffer_string, model_version);
		buffer_write(buffer, buffer_u16, meshes_count);
	
		for (var a=0; a<meshes_count; a++) {
			var mesh = meshes[a];
			var vbuff = mesh.vbuff;
		
			// Write the vbuff bytes size
			var vbuff_buffer = buffer_create_from_vertex_buffer(vbuff, buffer_vbuffer, 1);
			var vbuff_buffer_size = buffer_get_size(vbuff_buffer);
			buffer_write(buffer, buffer_u32, vbuff_buffer_size);
		
			// Write the vbuff
			buffer_copy(vbuff_buffer, 0, vbuff_buffer_size, buffer, buffer_tell(buffer));
			buffer_delete(vbuff_buffer);
			buffer_seek(buffer, buffer_seek_relative, vbuff_buffer_size);
		
			// Write the material textures
			var textures = mesh.material.textures;
			var textures_names = variable_struct_get_names(textures);
			var textures_count = array_length(textures_names);
			
			buffer_write(buffer, buffer_u8, textures_count);
			for (var t=0; t<textures_count; t++) {
				var texture = textures[$ textures_names[t]];
				var texture_id = texture.id;
		
				// Write the texture type and id
				buffer_write(buffer, buffer_string, texture.type);
				buffer_write(buffer, buffer_string, texture_id);
				
				// Write the texture data if not saved yet before
				if (!variable_struct_exists(materials_store, texture_id)) {
					// Write the sprite dimensions
					var sprite = texture.sprite;
					var width = sprite_get_width(sprite);
					var height = sprite_get_width(sprite);
					buffer_write(buffer, buffer_u16, width);
					buffer_write(buffer, buffer_u16, height);
					
					// Write the surface data
					var surface = surface_create(width, height);
					surface_set_target(surface);
					draw_clear_alpha(c_white, 0);
					draw_sprite(sprite, 0, 0, 0);
					surface_reset_target();
					buffer_get_surface(buffer, surface, buffer_tell(buffer));
					surface_free(surface);
				
					materials_store[$ texture_id] = true;
				}
			}
		}
	
		var buffer_compressed = buffer_compress(buffer, 0, buffer_get_size(buffer));
		buffer_delete(buffer);
		buffer_save(buffer_compressed, path);
		buffer_delete(buffer_compressed);
	};
	
	/**
	 * Load a Model directly from a Unique buffer file
	 *
	 * @param {String} path
	 */
	load = function(path) {
		gml_pragma("forceinline");
		
		var path_relative = filename_path(path);
		var raw_buffer = buffer_load(path);
		var buffer = buffer_decompress(raw_buffer);
		buffer_delete(raw_buffer);
		
		// Check the model version
		var model_version = buffer_read(buffer, buffer_string);
		if (model_version != global.ue_model_version) {
			oCtrl.uiNotificationElem.add_item("Warning: the model to load has been exported with a different Unique version" + chr(13) + chr(10) + "and there may be compatibility issues");
		}
		
		// Get the meshes count
		meshes_count = buffer_read(buffer, buffer_u16);
		var materials_store = {};
		
		for (var a=0; a<meshes_count; a++) {
			// Get the vbuff bytes size
			var vbuff_buffer_size = buffer_read(buffer, buffer_u32);
		
			// Read the vbuff
			var vbuff_buffer = buffer_create(vbuff_buffer_size, buffer_vbuffer, 1);
			buffer_copy(buffer, buffer_tell(buffer), vbuff_buffer_size, vbuff_buffer, 0);
			var vbuff = vertex_create_buffer_from_buffer(vbuff_buffer, global.ue_vertex_format);
			buffer_delete(vbuff_buffer);
			buffer_seek(buffer, buffer_seek_relative, vbuff_buffer_size);
			
			// Get the textures count
			var material = new UniqueMaterial();
			var textures = material.textures;
			var textures_count = buffer_read(buffer, buffer_u8);
			
			for (var t=0; t<textures_count; t++) {
				//Get the texture type and id
				var texture_type = buffer_read(buffer, buffer_string);
				var texture_id = buffer_read(buffer, buffer_string);
				
				// Extract the texture
				// A temporary buffer with the surface data is created in order to create the sprite
				if (!variable_struct_exists(materials_store, texture_id)) {
					var sprite_w = buffer_read(buffer, buffer_u16);
					var sprite_h = buffer_read(buffer, buffer_u16);
					var sprite_surface = surface_create(sprite_w, sprite_h);
					var sprite_surface_bytes = sprite_w * sprite_h * 4;
					var sprite_surface_buffer = buffer_create(sprite_surface_bytes, buffer_fixed, 1);
					buffer_copy(buffer, buffer_tell(buffer), sprite_surface_bytes, sprite_surface_buffer, 0);
					buffer_set_surface(sprite_surface_buffer, sprite_surface, 0);
					buffer_delete(sprite_surface_buffer);
					buffer_seek(buffer, buffer_seek_relative, sprite_surface_bytes);
					var sprite = sprite_create_from_surface(sprite_surface_buffer, 0, 0, sprite_w, sprite_h, false, false, 0, 0);
					surface_free(sprite_surface_buffer);
					materials_store[$ texture_id] = new UniqueTexture(texture_id, texture_type, sprite);
				}	
				
				textures[$ texture_type] = materials_store[$ texture_id];
			}
			
			delete materials_store;
			var mesh = new UniqueMesh();
			mesh.vbuff = vbuff;
			mesh.material = material;
			array_push(meshes, mesh);
		}
		
		buffer_delete(buffer);
	};
	
	transform();
}

/**
 * Load the model and its materials from a Unique compressed buffer container
 *
 * @param {String} path Model path
 * @return {Struct<UniqueModel>}
 */
function ue_model_load(path) {
	gml_pragma("forceinline");
	
	var model = new UniqueModel();
	model.load(path);
	return model;
}