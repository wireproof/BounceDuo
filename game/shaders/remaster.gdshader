shader_type canvas_item;
uniform sampler2D ball_art : source_color, filter_linear;
uniform sampler2D brick_art : source_color, filter_linear;
varying vec4 vertex_tint;
void vertex() { vertex_tint = COLOR; }
void fragment() {
 vec4 original = texture(TEXTURE, UV);
 vec2 dimensions = vec2(textureSize(TEXTURE, 0));
 vec4 art = original;
 if (dimensions == vec2(16.0)) {
  art = texture(ball_art, UV);
 } else if (dimensions == vec2(176.0, 144.0)) {
  vec2 p = UV * dimensions;
  if (p.x >= 152.0 && p.x < 164.0 && p.y < 12.0) {
   art = texture(ball_art, (p - vec2(152.0, 0.0))/12.0);
  } else if (p.x >= 128.0 && p.x < 152.0 && (p.y < 12.0 || (p.y >= 24.0 && p.y < 36.0))) {
   vec2 q = mod(p - vec2(128.0, 0.0),12.0)/12.0;
   art = texture(brick_art, q);
   if (p.y >= 24.0) art.rgb = art.bgr * vec3(0.45, 0.8, 1.0);
   if (p.x < 140.0) art.a *= smoothstep(0.99,1.01,q.x+q.y);
  }
 }
 COLOR = art * vertex_tint;
}
