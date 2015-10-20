#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

#include "gfx.h"
#include "ent.h"

class positionCmgr : component_manager
{

};

int main( int argc, char **argv )
{
	SDL_Init( SDL_INIT_EVERYTHING );

	gfx_system gs( "sdl window", 1280, 720 );
	float vertices[12] = {
		 0.0f,  0.5f, 0.5f, 0.0f,
		 0.5f, -0.5f, 1.0f, 1.0f,
		-0.5f, -0.5f, 0.0f, 1.0f
	};
	vertex_set triangle = gs.load_vertex_set( 3, vertices );
	texture tex = gs.load_texture( "test.bmp" );

	bool running = true;
	SDL_Event event;
	float startTime = ((float)SDL_GetTicks())/1000;
	Uint32 lastFrame = SDL_GetTicks();
	float pos;
	while( running )
	{
		while( SDL_PollEvent( &event ) )
		{
			if( event.type == SDL_QUIT )
				running = false;
		}

		Uint32 currentTime = SDL_GetTicks();
		const Uint8 *kb_state = SDL_GetKeyboardState( NULL );
		if( kb_state[SDL_SCANCODE_D] )
			pos += 3*((float)currentTime-(float)lastFrame)/1000.f;
		if( kb_state[SDL_SCANCODE_A] )
			pos -= 3*((float)currentTime-(float)lastFrame)/1000.f;

		draw_bucket b;
			b.vert = triangle;
			b.tex = tex;
			b.pos.x = 3*cosf( ((float)SDL_GetTicks())/1000.f - startTime );
			b.pos.y = 3*sinf( ((float)SDL_GetTicks())/1000.f - startTime );
			b.rot = -4*( ((float)SDL_GetTicks())/1000.f - startTime );

			b.color.r = 1.f; b.color.g = 1.f; b.color.b = 1.f;
			b.h = 1;

		gs.submit_bucket(b); 
			b.pos.x = 3*sinf( ((float)SDL_GetTicks())/1000.f - startTime );
			b.pos.y = 3*cosf( ((float)SDL_GetTicks())/1000.f - startTime );
		gs.submit_bucket(b); 
		
		gs.camera.pos_x = pos;
		gs.draw_frame();
		lastFrame = currentTime;
		
	}
	
	SDL_Quit();

	return 0;
}
