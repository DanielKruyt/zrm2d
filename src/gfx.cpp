#include "gfx.h"

#include <stdio.h>
#include <math.h>
#include<algorithm>

gfx_system::gfx_system( const char* t, int w, int h )
{
	window = SDL_CreateWindow( t,
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			w, h,
			SDL_WINDOW_OPENGL );

	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 2 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 1 );
	gl_cxt = SDL_GL_CreateContext( window );
	glewExperimental = GL_TRUE;
	glewInit();
	
	// create & bind VAO
	glGenVertexArrays( 1, &vao );
	glBindVertexArray( vao );

	// creating, filling Vertex Buffer Object
	GLuint vbo;
	glGenBuffers( 1, &vbo );
	glBindBuffer( GL_ARRAY_BUFFER, vbo );


	GLuint shaderProgram = loadShadersIntoProgram( "frag.glsl", "vert.glsl" );
	printf( "shaderProgram: %d\n", shaderProgram );
	glUseProgram( shaderProgram );

	// bind vertex attribs
	glVertexAttribPointer( 0, 2, GL_FLOAT, GL_FALSE, 0, 0 );
	glEnableVertexAttribArray( 0 );

	glClearColor( 0.f, 0.f, 0.f, 1.f );
}

drawable gfx_system::make_drawable( int num_vertices, float *new_vertices, float r, float g, float b )
{
	int sz = vertices.size();
	vertices.reserve( sz + num_vertices*2 );

	for( int i = 0; i < 2*num_vertices; i++ )
	{
		vertices[i+sz] = new_vertices[i];
	}

	drawable_entry e;
		e.start = sz; e.count = num_vertices;
		e.r = r; e.g = g; e.b = b;
	draw_entries.push_back( e );

	glBufferData( GL_ARRAY_BUFFER,  vertices.size(), &(vertices[0]), GL_STATIC_DRAW );

	return draw_entries.size()-1;
}

void gfx_system::draw_frame()
{
	struct {
		bool operator()( draw_bucket a, draw_bucket b )
		{
			return a.h < b.h;
		}
	} sorter;
	std::sort( draw_buckets.begin(), draw_buckets.end(), sorter );

	for( int i = 0; i < draw_buckets.size(); i++ )
	{
		drawable_entry e = draw_entries[ draw_buckets[i].d ];
		glUniform3f(  0, e.r, e.g, e.b );
		glDrawArrays( GL_TRIANGLES, e.start, e.count );
	}
}

GLuint loadShadersIntoProgram( const char* frag_fn, const char* vert_fn )
{
	// load shader sources
	//
	FILE *fs_file = fopen( frag_fn, "r" );

	fseek( fs_file, 0, SEEK_END );
	long size = ftell( fs_file );
	fseek( fs_file, 0, SEEK_SET );
	char *fs_src = (char*) malloc( size+1 );
	fread( fs_src, size, 1, fs_file );
	fs_src[size] = 0;


	FILE *vs_file = fopen( vert_fn, "r" );

	fseek( vs_file, 0, SEEK_END );
	size = ftell( vs_file );
	fseek( vs_file, 0, SEEK_SET );
	char *vs_src = (char*) malloc( size+1 );
	fread( vs_src, size, 1, vs_file );
	vs_src[size] = 0;

	// create shaders

	GLuint fragShader = glCreateShader( GL_FRAGMENT_SHADER );
	GLuint vertShader = glCreateShader( GL_VERTEX_SHADER );

	glShaderSource( fragShader, 1, &fs_src, NULL );
	glShaderSource( vertShader, 1, &vs_src, NULL );

	// compiling shaders
	GLint status;
	char buf[512];

	glCompileShader( vertShader );
		glGetShaderiv( vertShader, GL_COMPILE_STATUS, &status );
		{
			glGetShaderInfoLog( vertShader, 512, NULL, buf );
			printf( "----- VERTEX SHADER COMPILE ERRORS: \n%s", buf );
		}

	glCompileShader( fragShader );
		glGetShaderiv( vertShader, GL_COMPILE_STATUS, &status );
		{
			glGetShaderInfoLog( vertShader, 512, NULL, buf );
			printf( "----- VERTEX SHADER COMPILE ERRORS:\n%s", buf );
		}
	
	// creating/linking shader program
	GLuint shaderProgram = glCreateProgram();
	glAttachShader( shaderProgram, vertShader );
	glAttachShader( shaderProgram, fragShader );

	glBindFragDataLocation( shaderProgram, 0, "outColor" );
	glLinkProgram( shaderProgram );
		
	return shaderProgram;
}
