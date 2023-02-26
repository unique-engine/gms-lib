/**
 * Merge the meshes of multiple Unique models into a single mesh, in order to optimize the draw performance
 * Note: good for static objects that have the same texture page
 *
 * Credits: @DragoniteSpam YT
 * 
 * @param {Array<Struct<UniqueModel>>}
 * @return {Struct<UniqueModel>}
 */
//function ue_model_merge(models) {
//	var models_count = array_length(models);
//	var merged_vbuff = vertex_create_buffer();
//	vertex_begin(merged_vbuff, global.ue_vertex_format);
	
//	for (var a=0; a<models_count; a++) {
//		var model = models[a];
//		var meshes = model.meshes;
//		var meshes_count = model.meshes_count;
		
//		for (var b=0; b<meshes_count; b++) {
//			var mesh_raw = buffer_create_from_vertex_buffer(meshes[b], buffer_vbuffer, 1);
//			var mesh_raw_size = buffer_get_size(mesh_raw);
			
//			// Extract the mesh data
//			for (var c=0; c<mesh_raw_size; c+=36) {
//				var xx = buffer_read(mesh_raw, buffer_f32);
//				var yy = buffer_read(mesh_raw, buffer_f32);
//				var zz = buffer_read(mesh_raw, buffer_f32);
//				var nx = buffer_read(mesh_raw, buffer_f32);
//				var ny = buffer_read(mesh_raw, buffer_f32);
//				var nz = buffer_read(mesh_raw, buffer_f32);
//				var xtex = buffer_read(mesh_raw, buffer_f32);
//				var ytex = buffer_read(mesh_raw, buffer_f32);
//				var col_r = buffer_read(mesh_raw, buffer_u8);
//				var col_g = buffer_read(mesh_raw, buffer_u8);
//				var col_b = buffer_read(mesh_raw, buffer_u8);
//				var col_a = buffer_read(mesh_raw, buffer_u8 / 255);
				
//				// Add the position relative to the world matrix
//				var pos_matrix = matrix_build(model.x, model.y, model.z, model.xrot, model.yrot, model.zrot, model.xscale, model.yscale, model.zscale);
//				var pos_transformed = matrix_transform_vertex(pos_matrix, xx, yy, zz);
//				vertex_position_3d(merged_vbuff, pos_transformed[0], pos_transformed[1], pos_transformed[2]);
				
//				// Add the normals with the vectors normalized
//				var normal_matrix = matrix_build(0, 0, 0, model.xrot, model.yrot, model.zrot, model.xscale, model.yscale, model.zscale);
//				var normal_transformed = matrix_transform_vertex(normal_matrix, nx, ny, nz);
//				var normal_magnitude = point_distance_3d(0, 0, 0, normal_transformed[0], normal_transformed[1], normal_transformed[2]);
//				normal_transformed[0] /= normal_magnitude;
//				normal_transformed[1] /= normal_magnitude;
//				normal_transformed[2] /= normal_magnitude;
//				vertex_normal(merged_vbuff, normal_transformed[0], normal_transformed[1], normal_transformed[2]);
				
//				// Add the UV and color
//				vertex_texcoord(merged_vbuff, xtex, ytex);
//				vertex_color(merged_vbuff, make_color_rgb(col_r, col_g, col_b), col_a);
//			}
			
//			buffer_delete(mesh_raw);
//		}
//	}
	
//	vertex_end(merged_vbuff);
//	vertex_freeze(merged_vbuff);
	
//	var first_mesh = models[0].meshes[0];
	
//	return UniqueModel([{
//		vbuff: merged_vbuff,
//		material: new UniqueMaterial()
//		//material_name: first_mesh.material_name,
//		//material_sprite: first_mesh.material_sprite,
//		//texture: first_mesh.texture,
//	}]);
//}