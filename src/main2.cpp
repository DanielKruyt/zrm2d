#include "ent.h"

struct instance
{
	int i;
};

class simple_component : public component_manager
{
	private:
		 std::vector<int> data;
		 std::unordered_map<uint32_t,int> lookup;
	public:
		void add( entity e )
		{
			
		}

		void get_instance( instance i, entity e )
		{
		}
};

int main( int argc, char **argv )
{
	entity_system es;

}
