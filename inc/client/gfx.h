#ifndef gfx_h
#define gfx_h

#include <math.h>
#include <vector>

#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

typedef GLuint Texture;
typedef int VertexSet;
struct Color {
	float r, g, b;
};

GLuint loadShadersIntoProgram( const char* frag_fn, const char* vert_fn );


struct DrawBucket {
	struct {
		float x, y;
	} pos;

	struct {
		float r, g ,b;
	} color;

	float h;
	float rot;
	Texture tex;
	VertexSet vert;
};

struct Camera
{
	struct {
		float x, y;
	} pos;
	float vertical_scale, horisontal_scale;
};

class GfxSystem
{
	// TODO: gfx_system
	public:
		GfxSystem( const char* title, int w, int h );

		VertexSet loadVertexSet( int num, float* v );
		VertexSet loadVertexSetFromFile( const char *fn );
		Texture loadTexture( const char* filename ); //BMP only
		void submitBucket( DrawBucket b );
		void drawFrame();

		Camera camera;

	private:
		SDL_Window *window;
		SDL_GLContext glCxt;


		struct vertexSetEntry
		{
			int start, count;
		};
		std::vector<vertexSetEntry> vertexSets;

		std::vector<float> vertices;

		GLuint vbo;
		GLuint vao;
		GLint shaderProgram;

		std::vector<DrawBucket> drawBuckets;
};

#endif
