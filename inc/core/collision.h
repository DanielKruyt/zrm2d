#ifndef __collision_h__
#define __collision_h__

#include <vector>

struct vec2f
{
	float x,y;
	vec2f operator+( const vec2f& other )
	{
		vec2f ret;
		ret.x = x+other.x;
		ret.y = y+other.y;
		return ret;
	}
	vec2f operator-( const vec2f& other )
	{
		vec2f ret;
		ret.x = x-other.x;
		ret.y = y-other.y;
		return ret;
	}
	vec2f operator*( const float s )
	{
		vec2f ret;
		ret.x = x*s;
		ret.y = y*s;
		return ret;
	}
	vec2f operator/( const float s )
	{
		vec2f ret;
		ret.x = x/s;
		ret.y = y/s;
		return ret;
	}
	vec2f operator-()
	{
		vec2f ret;
		ret.x = -x;
		ret.y = -y;
		return ret;
	}
	float dot( const vec2f& other )
	{
		return x*other.x + y*other.y;
	}
	float lensqrd()
	{
		return( x*x + y*y );
	}
};

struct transform
{
	vec2f pos;
	float rot;
};

struct aabb
{
	float bl_x, bl_y;
	float tr_x, tr_y;
};

struct triangle_mesh
{
	std::vector<int> idxBuf;
	std::vector<vec2f> vertBuf;
};

struct polygon
{
	std::vector<vec2f> vert;
};

struct ellipse
{
	float w, h;
};

bool intersects( polygon &p1, transform t1, polygon &p2, transform t2 );
bool intersects( polygon p, transform t1, float radius, vec2f pos );
bool intersects( triangle_mesh& m1, transform t1, triangle_mesh& m2, transform t2 );

#endif
