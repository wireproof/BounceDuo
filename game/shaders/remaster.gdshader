shader_type canvas_item;
uniform sampler2D ball_art : source_color, filter_linear;
uniform sampler2D brick_art : source_color, filter_linear;
uniform float death_phase = 0.0;
varying vec4 tint;
void vertex(){tint=COLOR;}
float mask(float d){return 1.0-smoothstep(-0.012,0.012,d);}
float box(vec2 p,vec2 b){vec2 q=abs(p)-b;return length(max(q,0.0))+min(max(q.x,q.y),0.0);}
float line(vec2 p,vec2 a,vec2 b,float w){vec2 v=b-a;return length(p-a-v*clamp(dot(p-a,v)/dot(v,v),0.0,1.0))-w;}
vec3 metal(vec3 base,vec2 q){float shine=pow(max(0.0,1.0-abs(q.x+q.y*0.35-0.38)*2.3),12.0);return base*(0.62+0.38*(1.0-q.y))+vec3(shine*0.55);}
vec4 panel(vec2 q,vec3 base){float d=box(q-.5,vec2(.47));float rim=mask(d+.055);return vec4(mix(base*.28,metal(base,q),rim),mask(d));}
vec4 ring(vec2 q,bool wide,bool used){
 // One quarter of the original assembled hoop; scene mirrors/rotates the quarters.
 vec2 radius=vec2(wide?.98:.82,.22);
 vec2 n=(q-vec2(1.0,.5))/radius;
 float d=abs(length(n)-.83)-.16;
 float a=mask(d)*smoothstep(.48,.51,q.y);
 float bevel=clamp(1.0-abs(length(n)-.83)/.16,0.0,1.0);
 vec3 base=used?vec3(.42,.57,.66):vec3(1.0,.56,.015);
 vec3 c=base*(.55+.65*bevel)+pow(bevel,8.0)*vec3(.42,.36,.18);
 return vec4(c,a);
}
vec4 sprite(vec2 q,ivec2 cell){
 vec2 p=q-.5;vec4 c=vec4(0.0);
 if(cell.y==5){return ring(q,cell.x==0||cell.x==2,cell.x>=2);}
 if(cell==ivec2(0,3)){
  float core=box(p-vec2(-.04,0),vec2(.105,.47));
  float teeth=box(p-vec2(-.04,0),vec2(.20-abs(fract(q.y*4.0)-.5)*.24,.46));
  c=vec4(metal(vec3(.25,.3,.35),q),mask(teeth));
  float a=mask(core);c=mix(c,vec4(metal(vec3(.85,.065,.025),q),1),a);
  float gold=mask(box(p-vec2(-.04,-.08),vec2(.055,.33)));
  c.rgb=mix(c.rgb,metal(vec3(1,.72,.025),q),gold);return c;
 }
 if(cell==ivec2(1,3)){
  // Quarter of the mirrored 24x24 moving hazard.
  vec2 n=q-vec2(1);float radial=length(n);
  float rim=abs(radial-.73)-.09;
  float spokes=min(line(q,vec2(.12,.12),vec2(1),.045),min(line(q,vec2(1,.08),vec2(1),.07),line(q,vec2(.08,1),vec2(1),.07)));
  float teeth=abs(radial-(.84+.12*cos(atan(n.y,n.x)*12.0)))-.08;
  float a=mask(min(min(rim,spokes),teeth));
  return vec4(metal(vec3(.13,.47,.72),q),a);
 }
 if(cell==ivec2(2,3)){
  c=panel(q,vec3(.15,.48,.68));
  float seam=mask(abs(fract(q.y*3.0)-.5)-.035);
  c.rgb=mix(c.rgb,vec3(.025,.09,.16),seam*.75);
  c.rgb+=vec3(.05,.23,.28)*mask(length(q-vec2(.25,.25))-.07);return c;
 }
 if(cell==ivec2(3,3)){
  float r=length(p);float a=mask(abs(r-.39)-.035);
  return vec4(vec3(.55,.9,1)+vec3(.45)*pow(max(0.0,1.0-length(p-vec2(-.16,-.2))*4.0),3.0),max(a*.85,mask(r-.38)*.12));
 }
 if(cell==ivec2(0,4)||cell==ivec2(3,4)){
  bool on=cell.x==3;vec3 base=on?vec3(.3,1,.65):vec3(1,.78,.06);
  if(!on){float d=abs(p.x)+abs(p.y)-(.30+.12*cos(atan(p.y,p.x)*4.0));return vec4(metal(base,q),mask(d));}
  float shaft=box(p-vec2(0,-.16),vec2(.11,.22));
  float arrow=max(abs(p.x)*.8+p.y-.32,-p.y-.06);
  return vec4(metal(base,q),mask(min(shaft,arrow)));
 }
 if(cell==ivec2(2,4)||cell==ivec2(3,1)){
  bool grow=cell.y==4;c=panel(q,vec3(.055,.3,.55));
  float circle=abs(length(p)-.31)-.045;
  float plus=min(box(p,vec2(.19,.035)),box(p,vec2(.035,grow?.19:.035)));
  c.rgb=mix(c.rgb,metal(vec3(.45,.9,1),q),mask(min(circle,plus)));return c;
 }
 if(cell==ivec2(1,1)||cell==ivec2(2,2)||cell==ivec2(3,2)){
  c=panel(q,vec3(.08,.35,.78));float symbol=1.0;
  if(cell==ivec2(1,1))symbol=min(line(q,vec2(.23,.66),vec2(.53,.34),.065),line(q,vec2(.48,.66),vec2(.78,.34),.065));
  else if(cell==ivec2(2,2))symbol=min(line(q,vec2(.24,.58),vec2(.5,.28),.06),min(line(q,vec2(.5,.28),vec2(.76,.58),.06),line(q,vec2(.5,.28),vec2(.5,.79),.06)));
  else symbol=min(abs(length(p)-.27)-.045,min(box(p-vec2(-.25,-.18),vec2(.08,.08)),box(p-vec2(.25,.18),vec2(.08,.08))));
  c.rgb=mix(c.rgb,metal(vec3(.78,.95,1),q),mask(symbol));return c;
 }
 if(cell==ivec2(0,1)){
  // Burst silhouette, replacing the dead-ball atlas frame; timing stays game-owned.
  float ang=atan(p.y,p.x);float radius=.20+death_phase*.12+.13*cos(ang*7.0);
  return vec4(metal(vec3(.95,.06,.02),q),mask(length(p)-radius)*(1.0-death_phase*.65));
 }
 if(cell==ivec2(2,0)||cell==ivec2(2,1))return texture(ball_art,q);
 return panel(q,vec3(.08,.36,.65));
}
void fragment(){
 vec2 dimensions=vec2(textureSize(TEXTURE,0));vec4 art=texture(TEXTURE,UV);
 if(dimensions==vec2(16))art=texture(ball_art,UV);
 else if(dimensions==vec2(176,144)){
  vec2 p=UV*dimensions;
  if(p.x>=128.0&&p.y<72.0){ivec2 cell=ivec2(floor((p-vec2(128,0))/12.0));art=sprite(fract((p-vec2(128,0))/12.0),cell);}
 }else{
  // Exit chamber, separate original texture.
  vec2 p=UV-.5;art=panel(UV,vec3(.025,.12,.24));
  float arch=abs(length(p*vec2(1,0.85))-.34)-.055;
  art.rgb+=vec3(.05,.65,.8)*mask(arch)*(0.8+.2*sin(TIME*2.0));
 }
 COLOR=art*tint;
}
