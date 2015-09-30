#ifndef __SYSTEM_H__
#define __SYSTEM_H__

namespace rev
{
	class engine;
	typedef void (*system)( engine* e );

	namespace sys
	{
		static void render_2d( engine* e )
		{
		}
		static void gui( engine* e )
		{
		}
	};
}

#endif
