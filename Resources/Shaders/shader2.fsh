
varying mediump vec2 v_uv;


uniform sampler2D s_texture;
uniform sampler2D s_overlay;


void main()
{
	lowp vec4 albedo = texture2D (s_texture, v_uv);
	lowp vec4 normal = texture2D (s_overlay, v_uv);
	
	
	if(v_uv.x > 0.50)
		gl_FragColor = albedo;
	else
		gl_FragColor = normal;
}