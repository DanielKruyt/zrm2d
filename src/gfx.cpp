#include "client/gfx.h"

#include <stdio.h>
#include <math.h>

#include <fstream>
#include <sstream>
#include<algorithm>


GfxSystem::GfxSystem( const char* t, int w, int h )
{
	window = SDL_CreateWindow( t,
			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
			w, h,
			SDL_WINDOW_OPENGL );

	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 3 );
	glCxt = SDL_GL_CreateContext( window );
	SDL_GL_MakeCurrent( window, glCxt );
	glewExperimental = GL_TRUE;
	glewInit();
	
	// create & bind VAO
	glGenVertexArrays( 1, &vao );
	glBindVertexArray( vao );

	// creating Vertex Buffer Object
	GLuint vbo;
	glGenBuffers( 1, &vbo );
	glBindBuffer( GL_ARRAY_BUFFER, vbo );


	shaderProgram = loadShadersIntoProgram( "frag.glsl", "vert.glsl" );
	printf( "shaderProgram: %d\n", shaderProgram );
	glUseProgram( shaderProgram );

	// bind vertex attribs
	GLint posAttrib = glGetAttribLocation( shaderProgram, "pos" );
	glEnableVertexAttribArray( posAttrib );
	glVertexAttribPointer( posAttrib, 2,
			GL_FLOAT, GL_FALSE,
			4*sizeof(float), 0 );

	GLint texCoordAttrib = glGetAttribLocation( shaderProgram, "tex_coords" );
	glEnableVertexAttribArray( texCoordAttrib );
	glVertexAttribPointer( texCoordAttrib, 2,
			GL_FLOAT, GL_FALSE,
			4*sizeof(float), (void*)(2*sizeof(float)) );

	
	// set up camera
	const float CAMERA_AREA = 20*20;

	float screen_ratio = (float)w / (float)h;
	float global_unit_pixels = (float)w / sqrtf( screen_ratio*CAMERA_AREA );
	
	printf("Pixels per global unit: %f\n", global_unit_pixels );
	printf("Screen area in Glob.Unit^2: %f\n", (float)w * (float)h / global_unit_pixels/global_unit_pixels );

	camera.vertical_scale = 2*global_unit_pixels/( (float) h );
	camera.horisontal_scale = 2*global_unit_pixels/( (float) w );

	camera.pos.x = 0.f; camera.pos.y = 0.f;
	glClearColor( 0.5f, 0.5f, 0.f, 1.f );
}

Texture GfxSystem::loadTexture( const char* filename )
{
	SDL_Surface* os = SDL_LoadBMP( filename );
	SDL_Surface* s = SDL_ConvertSurfaceFormat( os, SDL_PIXELFORMAT_RGB888, 0);

	GLuint tex;
	glGenTextures( 1, &tex );

	glBindTexture( GL_TEXTURE_2D, tex );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

	glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB,
			os->w, os->h, 0,
			GL_BGR, GL_UNSIGNED_BYTE, os->pixels );

	SDL_FreeSurface( os );
	SDL_FreeSurface( s );

	glGenerateMipmap( GL_TEXTURE_2D );

	return tex;
}

VertexSet GfxSystem::loadVertexSet( int num, float* new_v )
{
	int sz = vertices.size();
	vertices.reserve( sz + num*4 );

	for( int i = 0; i < num*4; i++ )
		vertices.push_back( new_v[i] );

	glBufferData( GL_ARRAY_BUFFER,  sizeof(float)*vertices.size(), vertices.data(), GL_STATIC_DRAW );
	vertexSetEntry e;
		e.start = sz; e.count = num;
	vertexSets.push_back( e );

	return vertexSets.size()-1;
}

VertexSet GfxSystem::loadVertexSetFromFile( const char* fn )
{
	std::ifstream f;
	f.open( fn );
	std::string line;
	std::getline( f, line );
	int num = std::stoi( line );


	float *data = new float[num*4];
	int i = 0;
	while( std::getline( f, line ) )
	{
		std::istringstream iss( line );
		std::string substr;
		for( int j = 0; j < 4; j++ )
		{
			std::getline( iss, substr, ' ' );
			data[i] = std::stof( substr );
			i++;
		}
	}
	return loadVertexSet( num, data );
}

void GfxSystem::submitBucket( DrawBucket b )
{
	drawBuckets.push_back( b );
}

void GfxSystem::drawFrame()
{
	GLint uniformColor = glGetUniformLocation( shaderProgram, "color" );
	GLint uniformCamOffset = glGetUniformLocation( shaderProgram, "camOffset" );
	GLint uniformCamScale = glGetUniformLocation( shaderProgram, "camScale" );
	GLint uniformGlobalPos = glGetUniformLocation( shaderProgram, "globalPos" );
	GLint uniformRotation = glGetUniformLocation( shaderProgram, "rot" );
	std::sort( drawBuckets.begin(), drawBuckets.end(),
			[](DrawBucket a, DrawBucket b){ return a.h < b.h; } );

	glClear( GL_COLOR_BUFFER_BIT );
	for( int i = 0; i < drawBuckets.size(); i++ )
	{
		DrawBucket d = drawBuckets[i];
		vertexSetEntry e = vertexSets[ d.vert ];
		float rotMatrix[4] = {
			cosf( d.rot ), sinf( d.rot ),
			-sinf( d.rot), cosf( d.rot )
		};

		glUniform3f( uniformColor, d.color.r, d.color.g, d.color.b );
		glUniform2f( uniformCamOffset, camera.pos.x, camera.pos.y );
		glUniform2f( uniformCamScale, camera.horisontal_scale, camera.vertical_scale );
		glUniform2f( uniformGlobalPos, d.pos.x, d.pos.y );
		glUniformMatrix2fv( uniformRotation, 1, GL_FALSE, rotMatrix );


		glBindTexture( GL_TEXTURE_2D, d.tex );
		glDrawArrays( GL_TRIANGLES, e.start, e.count );
	}
	SDL_GL_SwapWindow( window );
	drawBuckets.clear();
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

