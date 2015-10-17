#ifndef gfx_h
#define gfx_h

#include <vector>

#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

GLuint loadShadersIntoProgram( const char* frag_fn, const char* vert_fn );
typedef int drawable;

struct draw_bucket {
	float h;
	float x, y;
	drawable d;
};

struct camera
{
	float pos_x, pos_y;
	float width, height;
	float vertical_scale, horisontal_scale;
};

class gfx_system
{
	// TODO: gfx_system
	public:
		gfx_system( const char* title, int w, int h );

		drawable make_drawable( int num_vertices, float *vertices, float r, float g, float b );
		void submit_bucket( draw_bucket b );
		void draw_frame();

		camera camera;


	private:
		SDL_Window *window;
		SDL_GLContext gl_cxt;

		struct drawable_entry
		{
			int start, count;
			float r, g, b;
		};
		std::vector<float> vertices;
		std::vector<drawable_entry> draw_entries;
		GLuint vbo;
		GLuint vao;

		std::vector<draw_bucket> draw_buckets;
};

#endif
