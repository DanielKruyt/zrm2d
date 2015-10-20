#ifndef __ent_h__
#define __ent_h__

#include <stdint.h>

#include <queue>
#include <unordered_map>

struct entity
{
	uint32_t id : 24;
	uint32_t gen : 8;
};

typedef uint32_t component;

struct entity_template
{
	int num_components;
	component components[];
};

class component_manager
{
	public:

		virtual void	add( entity e );
		virtual void	entity_destroyed( entity e ) = 0;
};

class entity_system
{
	public:
		const int INITIAL_ENTITY_RESERVATION = 4096;
		const int INITIAL_DESTROY_HOOK_RESERVATION = 4096;
		const int INITIAL_CMGR_RESERVATION = 256;
		
		const int CMGR_RESERVE_ON_END = 8;
		const int ENTITY_RESERVE_ON_END = 256;

		entity_system();

		component	add_cmgr( component_manager* c );

		entity	create_entity();
		entity	create_entity( entity_template& t );
		void	add_component( entity e, component c );
		void	destroy_notify( entity e, component_manager* c );
		void	destroy( entity e );
		bool	alive( entity e );

	private:

		struct {
			std::vector<uint8_t> gen;
			std::queue<uint32_t> free; // TODO: more efficient, wrapped queue
		} ent;

		std::vector<component_manager*> cmgr;
		std::unordered_map<entity,std::vector<component_manager*>> destroy_hooks;
};

#endif
