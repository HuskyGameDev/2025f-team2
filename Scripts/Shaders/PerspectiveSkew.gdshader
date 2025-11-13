// godot shader 

// 伪3d效果, 而且在启用region的节点下也能正常工作

shader_type canvas_item;

varying vec4 vertex_color; 

// Camera FOV

uniform float fov : hint_range(1, 179) = 90;

uniform bool cull_back = true;

uniform float y_rot : hint_range(-180, 180) = 0.0;

uniform float x_rot : hint_range(-180, 180) = 0.0;

uniform float inset : hint_range(0, 1) = 0.0;

uniform float rotation = 0.0;

varying flat vec2 o;

varying vec3 p;

varying flat vec2 pivot;

varying flat vec2 region_rate;

varying flat mat3 inv_rot_mat;

vec2 rotate(vec2 uv, vec2 pivot_r, float angle)
{
	mat2 rotation_mat = mat2(vec2(cos(angle), -sin(angle)),

						vec2(sin(angle), cos(angle)));
	uv -= pivot_r;
	uv = uv * rotation_mat;
	uv += pivot_r;
	return uv;
}

// Creates rotation matrix

void vertex(){
	vertex_color = COLOR;
	vec2 my_region_rate = abs(VERTEX) *2.0;
	region_rate = TEXTURE_PIXEL_SIZE * my_region_rate;
	if(VERTEX_ID == 0 )
	{
		pivot = UV;
	}
	if(VERTEX_ID == 1)
	{
		pivot = UV - vec2(0.0, region_rate.y);
	}
	if(VERTEX_ID == 2)
	{
		pivot = UV - vec2(region_rate.x, region_rate.y);
	}
	if(VERTEX_ID == 3)
	{
		pivot = UV - vec2(region_rate.x, 0.0);
	}
	float sin_b = sin(y_rot / 180.0 * PI);
	float cos_b = cos(y_rot / 180.0 * PI );
	float sin_c = sin(x_rot / 180.0 * PI );
	float cos_c = cos(x_rot / 180.0 * PI );
	inv_rot_mat;
	inv_rot_mat[0][0] = cos_b;
	inv_rot_mat[0][1] = 0.0;
	inv_rot_mat[0][2] = -sin_b;
	inv_rot_mat[1][0] = sin_b * sin_c;
	inv_rot_mat[1][1] = cos_c;
	inv_rot_mat[1][2] = cos_b * sin_c;
	inv_rot_mat[2][0] = sin_b * cos_c;
	inv_rot_mat[2][1] = -sin_c;
	inv_rot_mat[2][2] = cos_b * cos_c;
	vec2 uv = (UV - pivot ) / region_rate;
	float t = tan(fov / 360.0 * PI);
	VERTEX += (uv - 0.5) * 1.0 *my_region_rate * t * (1.0 - inset);
}

void fragment(){
	vec2 uv = (UV - pivot ) / region_rate;
	float t = tan(fov / 360.0 * PI);
	p = inv_rot_mat * vec3((uv - 0.5), 0.5 / (t));
	float v = (0.7 / (t)) + 0.7;
	p.xy *= v * inv_rot_mat[2].z;
	o = v * inv_rot_mat[2].xy;
	if (cull_back && p.z <= 0.0) discard;
	uv = (p.xy / p.z).xy - o;
	uv += 0.5;
	float asp = (region_rate/TEXTURE_PIXEL_SIZE).y/ (region_rate/TEXTURE_PIXEL_SIZE).x;
	uv.y *= asp;
	uv = rotate(uv, vec2(0.5, 0.5), rotation);
	uv.y /= asp;
	if(uv.x >1.0 || uv.x < 0.0){
		discard;
	}
	if(uv.y >1.0 || uv.y < 0.0){
		discard;
	}
	uv = pivot + uv * region_rate;
	
	COLOR = vertex_color*texture(TEXTURE, uv);
}