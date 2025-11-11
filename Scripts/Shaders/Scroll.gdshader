shader_type canvas_item;

uniform float rate = 0.05;

void vertex() {
	float pi = 3.141592653589793;
	VERTEX *= .5 + (sin(fract(TIME * rate) * pi * 4.) + 3.) / 4.;
}

void fragment() {
	vec2 uv = UV;
	uv.x += uv.y*sin(TIME*rate);
	uv += vec2(TIME*rate, TIME*rate);
	COLOR = texture(TEXTURE, uv); // Get pixel color from the image texture
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
