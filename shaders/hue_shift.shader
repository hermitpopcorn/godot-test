shader_type canvas_item;

uniform float shift_amount : hint_range(0, 1);

vec3 rgb2hsb(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz),
                vec4(c.gb, K.xy),
                step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r),
                vec4(c.r, p.yzx),
                step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

vec3 hsb2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),
                    6.0)-3.0)-1.0,
                    0.0,
                    1.0 );
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
	// Get color from the sprite texture at the current pixel we are rendering
    vec4 original_color = texture(TEXTURE, UV);
    vec3 col = original_color.rgb;
    // If not greyscale
    if(col[0] != col[1] || col[1] != col[2]) {
        vec3 hsb = rgb2hsb(col);
        // Shift the color by shift_amount, but rolling over the value goes over 1
        hsb.x = mod(hsb.x + shift_amount, 1.0);
        col = hsb2rgb(hsb);
    }
    COLOR = vec4(col.rgb, original_color.a);
}