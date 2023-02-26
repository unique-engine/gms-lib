/**
 * Setup a basic camera and world projection, likely used to get started with the 3D environment
 */
function ue_setup_basic_camera() {
	global.ue_world = {
		x: 20,
		y: 60,
		z: 40,
		direction: 110,
		zdir: 20,
		xto: 0,
		yto: 0,
		zto: 0,
		cameraFov: 60,
		cameraAspectRatio: view_get_wport(0) / view_get_hport(0),
		camera: camera_create()
	};
	
	gpu_set_zwriteenable(true);
	gpu_set_ztestenable(true);
	gpu_set_texrepeat(true);
	gpu_set_alphatestenable(true);
	gpu_set_tex_filter(true);
	gpu_set_tex_mip_enable(true);		
	
	// Set the projection matrix
	var projMat = matrix_build_projection_perspective_fov(
		-global.ue_world.cameraFov, 
		-global.ue_world.cameraAspectRatio, 
		1,
		32000
	);
	camera_set_proj_mat(global.ue_world.camera, projMat);
	
	// Set the view settings
	view_enabled = true;
	view_visible = true;
	view_set_camera(0, global.ue_world.camera);
	camera_set_update_script(global.ue_world.camera, ue_update_basic_camera);
}