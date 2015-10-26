#ifndef __ent_h__
#define __ent_h__

#include <stdint.h>

#include <queue>
#include <unordered_map>

struct Entity
{
	uint32_t id : 24;
	uint32_t gen : 8;

	bool operator==(const Entity& other) const
	{
		return (id==other.id)&&(gen==other.gen);
	}
};

namespace std
{
	template<>
	struct hash<Entity>
	{
		std::size_t operator()(const Entity& e) const
		{
			return std::hash<uint32_t>()( (e.id << 8) + e.gen );
		}
	};
}

class ComponentManager
{
	public:

		virtual void add( Entity e ) = 0;
		virtual void entityDestroyed( Entity e ) = 0;
};

class EntitySystem
{
	public:
		const int INITIAL_ENTITY_RESERVATION = 4096;
		const int INITIAL_DESTROY_HOOK_RESERVATION = 4096;
		const int INITIAL_CMGR_RESERVATION = 256;
		
		const int CMGR_RESERVE_ON_END = 8;
		const int ENTITY_RESERVE_ON_END = 256;

		EntitySystem();

		Entity	create();
		void	notifyOnDestroy( Entity e, ComponentManager* c );
		void	destroy( Entity e );
		bool	alive( Entity e );

	private:

		struct {
			std::vector<uint8_t> gen;
			std::queue<uint32_t> free; // TODO: more efficient, wrapped queue
		} ent;

		std::vector<ComponentManager*> cmgr;
		std::unordered_map<Entity,std::vector<ComponentManager*>> destroyHooks;
};

#endif
