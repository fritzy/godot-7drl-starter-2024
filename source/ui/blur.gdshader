shader_type canvas_item;

// Radius that the shader was designed for.
const float DEFAULT_RADIUS = 10.000000;

// Unit vector: (1, 0) or (0, 1)
//uniform vec2 step = vec2(1,1);
// Desired blur radius.
const float radius = 3.5;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;

void fragment() {
	vec2 step = vec2(1,0);
	vec2 s = radius / DEFAULT_RADIUS * step / vec2(textureSize(screen_texture, 0));
	vec3 col1  =
		0.011194727 * texture(screen_texture, SCREEN_UV - 10.000000000 * s).rgb +
		0.039368696 * texture(screen_texture, SCREEN_UV - 8.415809477 * s).rgb +
		0.071308558 * texture(screen_texture, SCREEN_UV - 6.435363708 * s).rgb +
		0.110237219 * texture(screen_texture, SCREEN_UV - 4.455121108 * s).rgb +
		0.145451038 * texture(screen_texture, SCREEN_UV - 2.475020813 * s).rgb +
		0.163798995 * texture(screen_texture, SCREEN_UV - 0.495000167 * s).rgb +
		0.157439298 * texture(screen_texture, SCREEN_UV + 1.485004498 * s).rgb +
		0.129158204 * texture(screen_texture, SCREEN_UV + 3.465057055 * s).rgb +
		0.090434685 * texture(screen_texture, SCREEN_UV + 5.445220765 * s).rgb +
		0.054043977 * texture(screen_texture, SCREEN_UV + 7.425557483 * s).rgb +
		0.027564604 * texture(screen_texture, SCREEN_UV + 9.406126897 * s).rgb;
	step = vec2(0,1);
	s = radius / DEFAULT_RADIUS * step / vec2(textureSize(screen_texture, 0));
	vec3 col2 =
		0.011194727 * texture(screen_texture, SCREEN_UV - 10.000000000 * s).rgb +
		0.039368696 * texture(screen_texture, SCREEN_UV - 8.415809477 * s).rgb +
		0.071308558 * texture(screen_texture, SCREEN_UV - 6.435363708 * s).rgb +
		0.110237219 * texture(screen_texture, SCREEN_UV - 4.455121108 * s).rgb +
		0.145451038 * texture(screen_texture, SCREEN_UV - 2.475020813 * s).rgb +
		0.163798995 * texture(screen_texture, SCREEN_UV - 0.495000167 * s).rgb +
		0.157439298 * texture(screen_texture, SCREEN_UV + 1.485004498 * s).rgb +
		0.129158204 * texture(screen_texture, SCREEN_UV + 3.465057055 * s).rgb +
		0.090434685 * texture(screen_texture, SCREEN_UV + 5.445220765 * s).rgb +
		0.054043977 * texture(screen_texture, SCREEN_UV + 7.425557483 * s).rgb +
		0.027564604 * texture(screen_texture, SCREEN_UV + 9.406126897 * s).rgb;
	//COLOR.rgb = texture(screen_texture, SCREEN_UV - 10.000000000 * s).rgb;
	COLOR.a = 1.0;
	COLOR.rgb = ((col1 * 0.5) + (col2 * 0.5)) * 0.5;
}