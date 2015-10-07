attribute vec4 a_position;
attribute vec2 a_texCoord;

uniform mediump mat4 contentTransform;

varying vec2 v_uv;


void main()
{
//	mediump mat4 form2 = mat4(1.0,0.0000000874227765,0.0,0.0,
//							  0.0000000874227765,-1.0,0.0,0.0,
//							  0.0,0.0,-1.0,0.0,
//							  0.0,0.0,0.0,1.0);
//	
//	mediump mat4 form3 = mat4(0.0000000437113883,-1.0,0.0,0.0,
//							  -1.0,0.0000000437113883,-0.0,0.0,
//							  0.0,0.0,0.99999994,0.0,
//							  0.0,0.0,0.0,1.0);
	
	gl_Position =  contentTransform * a_position;
	
	v_uv = a_texCoord;
	
}