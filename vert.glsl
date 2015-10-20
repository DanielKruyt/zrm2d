#version 330

uniform vec2 camOffset;
uniform vec2 camScale;
uniform vec2 globalPos;
uniform mat2 rot;

in vec2 pos;
in vec2 tex_coords;

out vec2 texCoords;

void main()
{
	vec2 rotPos = rot*pos;
	vec2 screenPos = vec2( (globalPos.x+rotPos.x-camOffset.x), (globalPos.y+rotPos.y-camOffset.y) );
	texCoords = tex_coords;
	gl_Position = vec4( screenPos.x*camScale.x, screenPos.y*camScale.y, 0.0, 1.0 );
}
