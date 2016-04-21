/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
*/

/* $Revision: 1.4 $ */


#include "AdjModel.h"
#include "Mat4.h"


extern Mat4 quadrix_vertex_constraint(const Vec3&);
extern Mat4 quadrix_plane_constraint(real a, real b, real c, real d);
extern Mat4 quadrix_plane_constraint(Face& T);
extern Mat4 quadrix_plane_constraint(const Vec3& n, real);
extern Mat4 quadrix_plane_constraint(const Vec3&, const Vec3&, const Vec3&);
extern real quadrix_evaluate_vertex(const Vec3& v, const Mat4& K);


extern bool check_for_discontinuity(Edge *);
extern Mat4 quadrix_discontinuity_constraint(Edge *, const Vec3&);
extern Mat4 quadrix_discontinuity_constraint(Edge *);


extern bool quadrix_find_local_fit(const Mat4& Q,
				   const Vec3& v1, const Vec3& v2,
				   Vec3& candidate);
extern bool quadrix_find_line_fit(const Mat4& Q,
				  const Vec3& v1, const Vec3& v2,
				  Vec3& candidate);
extern bool quadrix_find_best_fit(const Mat4& Q, Vec3& candidate);
extern real quadrix_pair_target(const Mat4& Q,
				Vertex *v1,
				Vertex *v2,
				Vec3& candidate);
