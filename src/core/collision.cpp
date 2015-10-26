#include "core/collision.h"

#include <stdio.h>
#include <math.h>

#define min(x,y) ((x<y)?x:y)
#define max(x,y) ((x>y)?x:y)
bool intersects( polygon& p1, transform t1, polygon& p2, transform t2 )
{
	// TODO: apply rotations in intersects() function
	for( int i = 0; i < p1.vert.size(); i++ )
	{
		vec2f A = p1.vert[(i+p1.vert.size()-1)%p1.vert.size()]+t1.pos;
		vec2f B = p1.vert[i]+t1.pos;
		for( int j = 0; j < p2.vert.size(); j++ )
		{
			vec2f C = p2.vert[(j+p2.vert.size()-1)%p2.vert.size()]+t2.pos;;
			vec2f D = p2.vert[j]+t2.pos;
			
			// calc determinants
			float det_lu = (A.x-C.x)*(B.y-C.y) - (A.y-C.y)*(B.x-C.x);
			float det_ru = (A.x-D.x)*(B.y-D.y) - (A.y-D.y)*(B.x-D.x);
			float det_ld = (C.x-A.x)*(D.y-A.y) - (C.y-A.y)*(D.x-A.x);
			float det_rd = (C.x-B.x)*(D.y-B.y) - (C.y-B.y)*(D.x-B.x);
			// get their signs
			det_lu /= fabsf( det_lu );
			det_ru /= fabsf( det_ru );
			det_ld /= fabsf( det_ld );
			det_rd /= fabsf( det_rd );
			
			if( det_lu == -det_ru && det_ld == -det_rd )
				return true;
		}
	}
	return false;
}

bool intersects( vec2f v0, vec2f v1, vec2f v2 )
{
	float dot00 = v0.dot( v0 );
	float dot01 = v0.dot( v1 );
	float dot02 = v0.dot( v2 );
	float dot11 = v1.dot( v1 );
	float dot12 = v1.dot( v2 );

	float invDenom = 1/( dot00*dot11 - dot01*dot01 );
	float u = ( dot11*dot02 - dot01*dot12 ) * invDenom;
	float v = ( dot00*dot12 - dot01*dot02 ) * invDenom;

	return( u >= 0 && v >= 0 && (u+v) < 1 );
}

bool intersects( triangle_mesh& m1, transform t1, triangle_mesh& m2, transform t2 )
{
	for( int t = 0; t < m1.idxBuf.size(); t += 3 )
	{
		vec2f v0 = m1.vertBuf[m2.idxBuf[t+1]] - m1.vertBuf[m2.idxBuf[t]];
		vec2f v1 = m2.vertBuf[m2.idxBuf[t+2]] - m1.vertBuf[m2.idxBuf[t]];

		for( int p = 0; p < m1.vertBuf.size(); p++ )
		{
			vec2f v2 = m1.vertBuf[p] - (t1.pos-t2.pos) - m2.vertBuf[m2.idxBuf[t]];
			if( intersects( v0, v1, v2 ) )
				return true;
		}
	}
	for( int t = 0; t < m2.idxBuf.size(); t += 3 )
	{
		vec2f v0 = m2.vertBuf[m1.idxBuf[t+1]] - m2.vertBuf[m1.idxBuf[t]];
		vec2f v1 = m1.vertBuf[m1.idxBuf[t+2]] - m2.vertBuf[m1.idxBuf[t]];

		for( int p = 0; p < m2.vertBuf.size(); p++ )
		{
			vec2f v2 = m2.vertBuf[p] - (t2.pos-t1.pos) - m1.vertBuf[m1.idxBuf[t]];
			if( intersects( v0, v1, v2 ) )
				return true;
		}
	}
	return false;
}

// circle intersection with triangle
bool intersects( triangle_mesh& m, transform t1, float r, transform t2 )
{
	vec2f wtt = t2.pos - t1.pos;
	for( int v = 0; v < m.vertBuf.size(); v++ )
	{
		vec2f delta = m.vertBuf[v] - wtt;
		if( delta.lensqrd() <= r*r )
			return true;
	}

	for( int t = 0; t < m.idxBuf.size(); t += 3 )
	{
		vec2f center = (m.vertBuf[m.idxBuf[t]]+m.vertBuf[m.idxBuf[t+1]]+m.vertBuf[m.idxBuf[t+2]])/3;
		wtt = t2.pos - center;

		vec2f AB = m.vertBuf[m.idxBuf[t+1]] - m.vertBuf[m.idxBuf[t]];
		vec2f AC = m.vertBuf[m.idxBuf[t+2]] - m.vertBuf[m.idxBuf[t]];
		vec2f BC = m.vertBuf[m.idxBuf[t+2]] - m.vertBuf[m.idxBuf[t+1]];

		vec2f n0;
			n0.x = AB.y;
			n0.y = -AB.x;
			if( n0.dot( AC ) > 0 ){ n0.x = -n0.x; n0.y = -n0.y; }
			float m0 = n0.y/n0.x;
			n0 = n0/sqrtf(n0.lensqrd())*r;
		vec2f n1;
			n1.x = AC.y;
			n1.y = -AC.x;
			if( n1.dot( AB ) > 0 ){ n1.x = -n1.x; n1.y = -n1.y; }
			float m1 = n1.y/n1.x;
			n1 = n1/sqrtf(n1.lensqrd())*r;
		vec2f n2;
			n2.x = BC.y;
			n2.y = -BC.x;
			if( n2.dot( -AB ) > 0 ){ n2.x = -n2.x; n2.y = -n2.y; }
			float m2 = n2.y/n2.x;
			n2 = n2/sqrtf(n2.lensqrd())*r;

		float mc = wtt.y/wtt.x;
		float dm0 = fabsf( m0 - mc );
		float dm1 = fabsf( m1 - mc );
		float dm2 = fabsf( m2 - mc );

		bool test = false;
		if( dm0 < dm2 )
		{
			if( dm0 < dm1 )
			{
				test = intersects( AB, AC, wtt-m.vertBuf[m.idxBuf[t]]-n0 );
			} else {
				test = intersects( AB, AC, wtt-m.vertBuf[m.idxBuf[t]]-n1 );
			}
		} else {
			if( dm1 < dm2 )
			{
				test = intersects( AB, AC, wtt-m.vertBuf[m.idxBuf[t]]-n1 );
			} else {
				test = intersects( AB, AC, wtt-m.vertBuf[m.idxBuf[t]]-n2 );
			}
		}

		if( test || intersects( AB, AC, wtt-m.vertBuf[m.idxBuf[t]] ) )
			return true;
	}
	return false;
}
