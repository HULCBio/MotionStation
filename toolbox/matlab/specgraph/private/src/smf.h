/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
*/

/* $Revision: 1.4.4.1 $ */

#ifndef GFX_SMF_INCLUDED // -*- C++ -*-
#define GFX_SMF_INCLUDED

/************************************************************************

  SMF Model methods.

 ************************************************************************/

#include "Buffer.h"
#include "Vec3.h"
#include "Mat4.h"

#define SMF_MAXLINE 4096


typedef buffer<char *> string_buffer;


class SMF_Model
{
public:

    ////////////////////////////////////////////////////////////////////////
    //
    // SMF input methods
    //

    //
    // These are the REQUIRED methods
    virtual int in_Vertex(const Vec3&) = 0;
    virtual int in_Face(int v1, int v2, int v3) = 0;

    //
    // By default, arbitrary faces are flagged as errors
    //virtual int in_Face(const buffer<int> &);
    // 
    // as are unknown commands
    virtual int in_Unparsed(const char *, string_buffer&);

    //
    // These methods are optional.  By default, they'll be ignored
    virtual int in_VColor(const Vec3&);
    virtual int in_VNormal(const Vec3&);
    virtual int in_FColor(const Vec3&);

    virtual int note_Vertices(int);
    virtual int note_Faces(int);
    virtual int note_BBox(const Vec3& min, const Vec3& max);
    virtual int note_BSphere(const Vec3&, real);
    virtual int note_PXform(const Mat4&);
    virtual int note_MXform(const Mat4&);
    virtual int note_Unparsed(const char *,string_buffer&);

    ////////////////////////////////////////////////////////////////////////
    //
    // SMF output methods
    //

//     virtual void annotate_header(FILE *);
//     virtual void annotate_Vertex(FILE *,int);
//     virtual void annotate_Face(FILE *,int);
};

class SMF_State;

//
// Internal SMF variables
// (not accessible via 'set' commands)
//
struct SMF_ivars
{
    int next_vertex;
    int next_face;
};


// GFX_SMF_INCLUDED
#endif
