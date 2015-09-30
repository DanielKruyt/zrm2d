#include "rev/event.h"

rev::event_system::event_system()
{
	num_flag = 0;
	num_pflag = 0;
	num_triggered = 0;
}

#define mix(h) ({                                       \
                        (h) ^= (h) >> 23;               \
                        (h) *= 0x2127599bf4325c37ULL;   \
                        (h) ^= (h) >> 47; })

uint64_t rev::event_system::hash( const char* str )
{
	uint32_t len;
	for( len = 0; str[len] != '\x00'; len++ );
	const uint64_t m = 0x880355f21e6d1965ULL;
	const uint64_t *pos = (const uint64_t*) str;
	const uint64_t *end = pos + (len/8);
	uint64_t h = 0x243F6A8885A308D3ULL ^ (len*m);
	uint64_t v;
	
	while( pos != end ) {
		v = *pos++;
		h ^= mix(v);
		h *= m;
	}

	v = 0;
	switch(len&7)
	{
	case 7: v ^= (uint64_t)str[6] << 48;
	case 6: v ^= (uint64_t)str[5] << 40;
	case 5: v ^= (uint64_t)str[4] << 32;
	case 4: v ^= (uint64_t)str[3] << 24;
	case 3: v ^= (uint64_t)str[2] << 16;
	case 2: v ^= (uint64_t)str[1] << 8;
	case 1: v ^= (uint64_t)str[0];
			h ^= mix(v);
			h *= m;
	}
	
	return mix(h);
}

uint64_t rev::event_system::register_event( const char* name )
{
	return register_event( hash( name ) );
}

uint64_t rev::event_system::register_event( const uint64_t hash )
{
	if( events.find(hash) == events.end() )
	{
		events[hash] = NULL;
		return hash;
	} 
	return 0;
}

int rev::event_system::register_flag( const char* name, bool persistent )
{
	uint64_t h = hash(name);
	return register_flag( h, persistent );
}

int rev::event_system::register_flag( const uint64_t hash, bool persistent )
{
	int id;
	if( persistent )
	{
		id = (8192*64-1) - num_pflag;
		num_pflag++;
	} else {
		id = num_flag;
		num_flag++;
	}
	return id;
}

void rev::event_system::trigger_event( const uint64_t hash, void* data )
{
	events[hash] = data;
	triggered[num_triggered] = hash;
	num_triggered++;
}

void rev::event_system::trigger_event( const uint64_t hash )
{
	trigger_event( hash, NULL );
}


void* rev::event_system::get_event_data( const uint64_t hash )
{
	return events[hash];
}

bool rev::event_system::get_flag( const uint64_t hash )
{
	return flag[flag_map[hash]];
}

void rev::event_system::add_hook( const uint64_t hash, void(*hkptr)(void*) )
{
	if( hooks.find(hash) == hooks.end() )
	{
		hooks[hash] = std::vector<void*>();
	}
	hooks[hash].push_back( (void*)hkptr );
}

void rev::event_system::run_hooks()
{
	for( int i = 0; i < num_triggered; i++ )
	{
		for( int j = 0; j < hooks[triggered[i]].size(); j++ )
		{
			( (void(*)(void*)) (hooks[triggered[i]][j]) )(events[triggered[i]]);
		}
	}
}
