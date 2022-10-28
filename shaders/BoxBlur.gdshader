shader_type canvas_item;

uniform float multiplier = 1.0;
uniform vec4 colorizer : hint_color;
uniform float color_multiplier = 1.0;
uniform bool blur = false;

void fragment() {
	float mul = 0.5;
	
    vec3 col;
	
	if (blur) {
		col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb * 0.16 * mul;
		
		col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, SCREEN_PIXEL_SIZE.y)).rgb * 0.15 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, -SCREEN_PIXEL_SIZE.y)).rgb * 0.15 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 2.0 * SCREEN_PIXEL_SIZE.y)).rgb * 0.12 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 2.0 * -SCREEN_PIXEL_SIZE.y)).rgb * 0.12 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 3.0 * SCREEN_PIXEL_SIZE.y)).rgb * 0.09 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 3.0 * -SCREEN_PIXEL_SIZE.y)).rgb * 0.09 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 4.0 * SCREEN_PIXEL_SIZE.y)).rgb * 0.05 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, 4.0 * -SCREEN_PIXEL_SIZE.y)).rgb * 0.05 * mul;
		
		
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.15 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(-SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.15 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(2.0 * SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.12 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(2.0 * -SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.12 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(3.0 * SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.09 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(3.0 * -SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.09 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(4.0 * SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.05 * mul;
	    col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(4.0 * -SCREEN_PIXEL_SIZE.x, 0.0)).rgb * 0.05 * mul;
	    
		col += texture(SCREEN_TEXTURE, SCREEN_UV).rgb * 0.1;
	} else {
		col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	}
    
	
	col *=  multiplier;
	
	float grey = (col.r + col.g + col.b ) / 3.0;
	
	col = vec3(grey, grey, grey);
	
	//col *= vec3(1, 1.3, 1);
	col *= colorizer.rgb * color_multiplier;
	
    COLOR.xyz = col;
}