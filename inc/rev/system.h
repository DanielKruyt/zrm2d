#ifndef __REV__SYSTEM_H__
#define __REV__SYSTEM_H__

namespace rev
{
	class system
	{
		class engine;
		public:
			virtual void init( rev::engine *e ) = 0;
			virtual void tick() = 0;
			virtual void clean_up() = 0;
	};
}

#endif
