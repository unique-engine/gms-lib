/**
 * Update the basic 3D camera
 */
function ue_update_basic_camera() {
	global.ue_world.xto = global.ue_world.x + dcos(global.ue_world.direction) * dcos(-global.ue_world.zdir);
	global.ue_world.yto = global.ue_world.y + dsin(global.ue_world.direction) * -dcos(-global.ue_world.zdir);
	global.ue_world.zto = global.ue_world.z - dsin(global.ue_world.zdir);
	
	camera_set_view_mat(view_camera[0], matrix_build_lookat(
		global.ue_world.x, global.ue_world.y, global.ue_world.z,  // From
		global.ue_world.xto, global.ue_world.yto, global.ue_world.zto, // To
		0, 0, 1 // Up
	));
}