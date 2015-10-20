#version 330

uniform vec3 color;

in vec2 texCoords;

out vec4 outColor;

uniform sampler2D tex;

void main()
{
	outColor = texture(tex, texCoords)*vec4( color, 1.0 );
}
