shader_type canvas_item;
varying vec2 local_pos;
void vertex(){local_pos=VERTEX;}
void fragment(){
 float ripples=sin(local_pos.x*.24+TIME*1.2)+sin(local_pos.y*.35-local_pos.x*.11+TIME*.8);
 float caustic=pow(max(0.0,ripples*.5),5.0);
 vec3 c=mix(vec3(.025,.22,.48),vec3(.04,.53,.72),.5+.25*sin(local_pos.y*.045));
 COLOR=vec4(c+vec3(.08,.25,.28)*caustic,.88);
}
