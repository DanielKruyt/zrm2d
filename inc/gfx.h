#ifndef gfx_h
#define gfx_h

#include <vector>

#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

GLuint loadShadersIntoProgram( const char* frag_fn, const char* vert_fn );

typedef int drawable;
typedef GLuint texture;
typedef int vertex_set;

struct draw_bucket {
	struct {
		float x, y;
	} pos;

	struct {
		float r, g ,b;
	} color;

	float h;
	float rot;
	texture tex;
	vertex_set vert;
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

		vertex_set load_vertex_set( int num, float* v );
		texture load_texture( const char* filename ); //BMP only
		void submit_bucket( draw_bucket b );
		void draw_frame();

		camera camera;


	private:
		SDL_Window *window;
		SDL_GLContext gl_cxt;


		struct vertex_set_entry
		{
			int start, count;
		};
		std::vector<vertex_set_entry> vertex_sets;

		std::vector<float> vertices;

		GLuint vbo;
		GLuint vao;
		GLint shaderProgram;

		std::vector<draw_bucket> draw_buckets;
};

#endif
