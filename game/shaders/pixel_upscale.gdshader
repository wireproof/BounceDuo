shader_type canvas_item;
render_mode unshaded;
// Scale2x edge reconstruction. Works on the completed low-resolution image,
// so sprite/atlas coordinates and game physics remain untouched.
bool same(vec4 a, vec4 b) { return all(lessThan(abs(a-b),vec4(0.001))); }
void fragment() {
    vec2 pixel = floor(UV / TEXTURE_PIXEL_SIZE);
    vec2 center = (pixel + vec2(0.5)) * TEXTURE_PIXEL_SIZE;
    vec2 lo = TEXTURE_PIXEL_SIZE * 0.5;
    vec2 hi = vec2(1.0) - lo;
    vec4 e = texture(TEXTURE, clamp(center,lo,hi));
    vec4 b = texture(TEXTURE, clamp(center-vec2(0.0,TEXTURE_PIXEL_SIZE.y),lo,hi));
    vec4 d = texture(TEXTURE, clamp(center-vec2(TEXTURE_PIXEL_SIZE.x,0.0),lo,hi));
    vec4 f = texture(TEXTURE, clamp(center+vec2(TEXTURE_PIXEL_SIZE.x,0.0),lo,hi));
    vec4 h = texture(TEXTURE, clamp(center+vec2(0.0,TEXTURE_PIXEL_SIZE.y),lo,hi));
    vec2 part = fract(UV / TEXTURE_PIXEL_SIZE);
    vec4 result = e;
    if (!same(b,h) && !same(d,f)) {
        if (part.y < 0.5) {
            if (part.x < 0.5 && same(d,b)) result=d;
            if (part.x >= 0.5 && same(b,f)) result=f;
        } else {
            if (part.x < 0.5 && same(d,h)) result=d;
            if (part.x >= 0.5 && same(h,f)) result=f;
        }
    }
    COLOR = result;
}
