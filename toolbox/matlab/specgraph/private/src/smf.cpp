/* Copyright 1993-2002 The MathWorks, Inc.   */

/*
  Source file for reducep MEX file
*/

static char rcsid[] = "$Revision: 1.5 $";


#include "std.h"
#include "smf.h"

//inline int streq(const char *a,const char *b) { return strcmp(a,b)==0; }


/*
int SMF_Model::in_Face(const buffer<int>&)
{
    fatal_error("SMF: Arbitrary face definitions not supported.");
    return false;
}
*/

int SMF_Model::in_Unparsed(const char *, string_buffer&)
{
    return false;
}

int SMF_Model::in_VNormal(const Vec3&) { return true; }
int SMF_Model::in_VColor(const Vec3&) { return true; }
int SMF_Model::in_FColor(const Vec3&) { return true; }

int SMF_Model::note_Vertices(int) { return true; }
int SMF_Model::note_Faces(int) { return true; }
int SMF_Model::note_BBox(const Vec3&, const Vec3&) { return true; }
int SMF_Model::note_BSphere(const Vec3&, real) { return true; }
int SMF_Model::note_PXform(const Mat4&) { return true; }
int SMF_Model::note_MXform(const Mat4&) { return true; }
int SMF_Model::note_Unparsed(const char *,string_buffer&) { return true; }

