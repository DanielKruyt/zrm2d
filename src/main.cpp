#include "rev/event.h"

#include <iostream>

int ia[5];

void hook(void* a)
{
	int x = * (int*) a;
	for( int i = 0; i < 5; i++ )
	{
		ia[i] = x*i;
	}
}

int main()
{
	rev::event_system es;
	es.register_event("nomnom");
	uint64_t hash = rev::event_system::hash( "nomnom" );
	es.add_hook( hash, &hook );
	int y = 4;

	es.trigger_event( hash, &y );
	es.run_hooks();
	for( int i = 0; i < 5; i++ )
	{
		std::cout << ia[i] << std::endl;
	}
	return 0;
}
