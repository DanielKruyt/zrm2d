#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

#include <stdio.h>

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

int main( int argc, char **argv )
{
	SDL_Init( SDL_INIT_EVERYTHING );

	SDL_Window *window = SDL_CreateWindow( "sdl",
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			1280, 720,
			SDL_WINDOW_OPENGL );

	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 3 );

	SDL_GLContext gl_cxt = SDL_GL_CreateContext( window );
	glewExperimental = GL_TRUE;
	glewInit();

	// create & bind VAO
	GLuint vao;
	glGenVertexArrays( 1, &vao );
	glBindVertexArray( vao );

	float vertices[6] = {
		0.0f, 0.5f,
		0.5f, -0.5f,
		-0.5f, -0.5f
	};

	// creating, filling Vertex Buffer Object
	GLuint vbo;
	glGenBuffers( 1, &vbo );
	glBindBuffer( GL_ARRAY_BUFFER, vbo );
	glBufferData( GL_ARRAY_BUFFER, sizeof( vertices ), vertices, GL_STATIC_DRAW );

	GLuint shaderProgram = loadShadersIntoProgram( "frag.glsl", "vert.glsl" );
	printf( "shaderProgram: %d\n", shaderProgram );
	glUseProgram( shaderProgram );

	// bind vertex attribs
	glVertexAttribPointer( 0, 2, GL_FLOAT, GL_FALSE, 0, 0 );
	glEnableVertexAttribArray( 0 );

	glClearColor( 0.f, 0.f, 0.f, 1.f );

	SDL_Event event;
	while( true )
	{
		if( SDL_PollEvent( &event ) )
		{
			if( event.type == SDL_QUIT ) break;
		}
		glClear( GL_COLOR_BUFFER_BIT );
		GLint uniformTriColour = glGetUniformLocation( shaderProgram, "triangleColor" );
		glUniform3f( uniformTriColour, 0.f, 0.f, 1.f );
		glDrawArrays( GL_TRIANGLES, 0, 3 );
		SDL_GL_SwapWindow( window );
	}
	
	SDL_GL_DeleteContext( gl_cxt );
	SDL_DestroyWindow( window );
	SDL_Quit();

	return 0;
}
