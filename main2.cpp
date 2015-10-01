#include "rev/engine.h"

class simple_component : public rev::component_manager
{
public:
	simple_component()
	{
		n = 0;
		open.push_back( 3 );
		open.push_back( 2 );
		open.push_back( 1 );
		open.push_back( 0 );
	}
	std::vector<int> data;
	std::vector<rev::entity_handle> owner;
	std::vector<uint32_t> open;

	int n;
	rev::component_handle create( rev::entity_handle h )
	{
			rev::component_handle ch;
		if(open.size()==0)
		{
			n++;

			data.push_back( n );
			owner.push_back( h );
			
			ch.id = data.size()-1;
		} else {
			ch.id = open[open.size() - 1];
			open.pop_back();
		}
		return ch;
	}

	void* get( rev::component_handle h )
	{
		return &data[h.id];
	}

	void destroy( rev::component_handle h )
	{
		open.push_back(h.id);
	}

	void gc()
	{
		for(  int i = 0; i < data.size(); i++ )
		{
			if( !eng->alive( owner[i]))
			{
				rev::component_handle ch;
				ch.id=i;
				destroy(ch); 
			}
		}
	}
};

int main( int argc, char** argv )
{
	rev::event_system es;
	rev::engine engine( &es );

	simple_component sc;

	rev::component_type simple_type = engine.register_component( &sc );
	rev::component_handle h = simple_type.create( 
}
