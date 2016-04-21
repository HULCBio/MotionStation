/* Copyright 1993-2002 The MathWorks, Inc.   */

/*
  Source file for reducep MEX file
*/

static char rcsid[] = "$Revision: 1.4.4.1 $";

#include "std.h"
#include "avars.h"
#include "AdjModel.h"

int face_target = 0;
real error_tolerance = HUGE;


bool will_use_plane_constraint = true;
bool will_use_vertex_constraint = false;

bool will_preserve_boundaries = false;
bool will_preserve_mesh_quality = false;
bool will_constrain_boundaries = false;
real boundary_constraint_weight = 1.0;

bool will_weight_by_area = false;

int placement_policy = PLACE_OPTIMAL;

real pair_selection_tolerance = 0.0;


