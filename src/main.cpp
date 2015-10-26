#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <SDL2/SDL_opengl.h>

#include "client/gfx.h"
#include "core/ent.h"
#include "core/collision.h"

#include "client/com/transformComponent.h"
#include "client/com/renderComponent.h"

#include <math.h>
#include <stdlib.h>

struct ColComInst 
{
	int id;
};

class CollisionComponent : ComponentManager
{
	public:
		CollisionComponent( EntitySystem* e, RenderComponent* rc, TransformComponent* tc )
		{
			es = e;
			renderCmgr = rc;
			transformCmgr = tc;
		}
		void add( Entity e )
		{
			lookup[e] = colInst.size();

			collisionInst inst;
			inst.owner = e;
			rand(); rand();
			float ang = (float)rand() / (float)RAND_MAX;
			inst.velx = 7*cosf( 2*M_PI*ang );
			inst.vely = 7*sinf( 2*M_PI*ang );
			colInst.push_back( inst );
		}
		void entityDestroyed( Entity e )
		{
		}

		void tick( float dt )
		{
			for( int i = 0; i < colInst.size(); i++ )
			{
				Entity owner = colInst[i].owner;
				TransformInstance t = transformCmgr->getInstance( owner );
				RenderableInstance r = renderCmgr->getInstance( owner );

				float px = transformCmgr->getPosX( t );
				float py = transformCmgr->getPosY( t );

				Color c; 
				c.r = 1; c.g = 1; c.b = 1;
				renderCmgr->setColor( r, c );
				for( int j = 0; j < colInst.size(); j++ )
				{
					if( j == i )
						continue;

					TransformInstance t2 = transformCmgr->getInstance( colInst[j].owner );
					RenderableInstance r2 = renderCmgr->getInstance( colInst[j].owner );

					transform tr1;
						tr1.pos.x = px;
						tr1.pos.y = py;

					transform tr2;
						tr2.pos.x = transformCmgr->getPosX( t2 );
						tr2.pos.y = transformCmgr->getPosY( t2 );

					if( intersects( *colInst[i].mesh, tr1, *colInst[j].mesh, tr2 ) )
					{
						c.g = 0; c.b = 0;
						renderCmgr->setColor( r, c );
					}
				}

				if( px < -4 )
				{
					colInst[i].velx = ( fabsf( colInst[i].velx) );
				} else if( px > 4 )
				{
					colInst[i].velx = -( fabsf( colInst[i].velx) );
				}

				if( py < -4 )
				{
					colInst[i].vely = ( fabsf( colInst[i].vely) );
				} else if( py > 4 )
				{
					colInst[i].vely = -( fabsf( colInst[i].vely) );
				}

				transformCmgr->setPosX( t, px + dt*colInst[i].velx );
				transformCmgr->setPosY( t, py + dt*colInst[i].vely );
			}
		}

		ColComInst getInstance( Entity e )
		{
			ColComInst i;
			i.id = -1;
			auto it = lookup.find( e );
			if( it != lookup.end() )
			{
				i.id = it->second;
			}
			return i;
		}

		void setMesh( Entity e, triangle_mesh* t )
		{
			colInst[lookup[e]].mesh = t;
		}
	private:
		std::unordered_map<Entity,int> lookup;
		EntitySystem* es;
		RenderComponent* renderCmgr;
		TransformComponent* transformCmgr;
		struct collisionInst
		{
			float velx, vely;
			Entity owner;
			triangle_mesh* mesh;
		};
		std::vector<collisionInst> colInst;
};

int main( int argc, char **argv )
{
	SDL_Init( SDL_INIT_EVERYTHING );

	EntitySystem es;
	GfxSystem gs( "ZRM2D", 1280, 720 );

	SDL_GL_SetSwapInterval( 2 );

	TransformComponent transformCmgr( &es );
	RenderComponent renderCmgr( &es, &gs, &transformCmgr );
	CollisionComponent collisionCmgr( &es, &renderCmgr, &transformCmgr );

	// creating resources for entity
	Texture tex = gs.loadTexture( "test.bmp" );
	Texture tex2 = gs.loadTexture( "test2.bmp" );
	VertexSet triangle = gs.loadVertexSetFromFile( "test.vs" );

	triangle_mesh collision_poly;
		std::vector<vec2f> triangle_poly;
		vec2f point;
		point.x = 0; point.y = 0.5;
			triangle_poly.push_back( point );
		point.x = -0.5; point.y = -0.5;
			triangle_poly.push_back( point );
		point.x = 0.5; point.y = -0.5;
			triangle_poly.push_back( point );
		std::vector<int> idb; idb.push_back( 0 ); idb.push_back( 1 ); idb.push_back( 2 );

		collision_poly.vertBuf = triangle_poly;
		collision_poly.idxBuf = idb;
	

	//creating entities and their components
	Entity e = es.create();
		transformCmgr.add( e );
			TransformInstance t = transformCmgr.getInstance( e );
			transformCmgr.setPosX( t, 0.1 );
			transformCmgr.setPosY( t, -2 );
		renderCmgr.add( e );
			RenderableInstance r = renderCmgr.getInstance( e );
			renderCmgr.setTexture( r, tex );
			renderCmgr.setVertexSet( r, triangle ); 
		collisionCmgr.add( e );
			collisionCmgr.setMesh( e, &collision_poly );

	Entity e2 = es.create();
		transformCmgr.add( e2 );
				TransformInstance t2 = transformCmgr.getInstance( e2 );
			transformCmgr.setPosX( t2, -0.1 );
			transformCmgr.setPosY( t2, 2 );
		renderCmgr.add( e2 );
			RenderableInstance r2 = renderCmgr.getInstance( e2 );
			renderCmgr.setTexture( r2, tex );
			renderCmgr.setVertexSet( r2, triangle );
		collisionCmgr.add( e2 );
			collisionCmgr.setMesh( e2, &collision_poly );
			

	bool running = true;
	float pos_x = 0, pos_y = 0;
	float startTime = ((float)SDL_GetTicks())/1000;
	Uint32 lastFrame = SDL_GetTicks();

	transform tr1;
	transform tr2;

	while( running )
	{
		SDL_Event event;
		while( SDL_PollEvent( &event ) )
		{
			if( event.type == SDL_QUIT )
				running = false;
		}

		Uint32 currentTime = SDL_GetTicks();
		float deltaTime = ((float)(currentTime-lastFrame))/1000;
		printf("DT: %f\n", deltaTime );
		/*
		const Uint8 *kb_state = SDL_GetKeyboardState( NULL );
		if( kb_state[SDL_SCANCODE_D] )
			pos_x += 3*((float)currentTime-(float)lastFrame)/1000.f;
		if( kb_state[SDL_SCANCODE_A] )
			pos_x -= 3*((float)currentTime-(float)lastFrame)/1000.f;

		if( kb_state[SDL_SCANCODE_W] )
			pos_y += 3*((float)currentTime-(float)lastFrame)/1000.f;

		if( kb_state[SDL_SCANCODE_S] )
			pos_y -= 3*((float)currentTime-(float)lastFrame)/1000.f;

		tr1.pos.x = 3*cosf( ((float)SDL_GetTicks())/1000.f - startTime );
		tr1.pos.y = 3*sinf( ((float)SDL_GetTicks())/1000.f - startTime );
		tr2.pos.x = pos_x;
		tr2.pos.y = pos_y;

		r = renderCmgr.getInstance( e );
		t = transformCmgr.getInstance( e );
			transformCmgr.setPosX( t, tr1.pos.x );
			transformCmgr.setPosY( t, tr1.pos.y );
			renderCmgr.setHeight( r, 1.5 );
		r2 = renderCmgr.getInstance( e2 );
		t2 = transformCmgr.getInstance( e2 );
			transformCmgr.setPosX( t2, tr2.pos.x );
			transformCmgr.setPosY( t2, tr2.pos.y );
		if( intersects( collision_poly, tr1, collision_poly, tr2 ) )
		{
			Color c; c.r = 1.0; c.g = 0.0; c.b =0.0;
			renderCmgr.setColor( r, c );
		} else {
			Color c; c.r = 1.0; c.g = 1.0; c.b = 1.0;
			renderCmgr.setColor( r, c );
		}
		*/
		collisionCmgr.tick( deltaTime );
		
		renderCmgr.render_frame();
		lastFrame = currentTime;
	}
	
	SDL_Quit();

	return 0;
}

