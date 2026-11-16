shader_type canvas_item;
render_mode unshaded;
// Explicit bilinear reconstruction of the original game framebuffer.
void fragment() {
 vec2 p = UV / TEXTURE_PIXEL_SIZE - 0.5;
 vec2 base = (floor(p) + 0.5) * TEXTURE_PIXEL_SIZE;
 vec2 f = fract(p);
 vec2 lo = TEXTURE_PIXEL_SIZE * 0.5;
 vec2 hi = vec2(1.0) - lo;
 vec4 a = texture(TEXTURE,clamp(base,lo,hi));
 vec4 b = texture(TEXTURE,clamp(base+vec2(TEXTURE_PIXEL_SIZE.x,0.0),lo,hi));
 vec4 c = texture(TEXTURE,clamp(base+vec2(0.0,TEXTURE_PIXEL_SIZE.y),lo,hi));
 vec4 d = texture(TEXTURE,clamp(base+TEXTURE_PIXEL_SIZE,lo,hi));
 COLOR = mix(mix(a,b,f.x),mix(c,d,f.x),f.y);
}
