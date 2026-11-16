shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
 vec4 tex = texture(TEXTURE, UV);
 if (tint.b > tint.r + 0.1) tex.rgb = vec3(dot(tex.rgb,vec3(0.65,0.25,0.10))) * tint.rgb;
 COLOR = vec4(tex.rgb,tex.a * tint.a);
}
