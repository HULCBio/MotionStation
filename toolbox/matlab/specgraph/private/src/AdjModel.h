/* Copyright 1993-2002 The MathWorks, Inc.  */

/*
  Source file for reducep MEX file
*/

/* $Revision: 1.4.4.1 $ */

#ifndef NAUTILUS_ADJMODEL_INCLUDED // -*- C++ -*-
#define NAUTILUS_ADJMODEL_INCLUDED

/************************************************************************

  Adjacency model representation.

 ************************************************************************/

#include "AdjPrims.h"
#include "smf.h"


class Model : public SMF_Model
{
protected:
    vert_buffer vertices;
    edge_buffer edges;
    face_buffer faces;

private:

    void maybeFixFace(Face *);

public:
    Model() { validVertCount=0; validEdgeCount=0; validFaceCount=0;}
    ~Model();

    Bounds bounds;

    int validVertCount;
    int validEdgeCount;
    int validFaceCount;

    //
    // Basic model accessor functions
    //
    Vertex *vertex(int i) { return vertices(i); }
    Edge *edge(int i) { return edges(i); }
    Face *face(int i) { return faces(i); }

    int vertCount() { return vertices.length(); }
    int edgeCount() { return edges.length();    }
    int faceCount() { return faces.length();    }

    vert_buffer& allVertices() { return vertices; }
    edge_buffer& allEdges()    { return edges;    }
    face_buffer& allFaces()    { return faces;    }

    //
    // Simplification primitives
    //
    Vertex   *newVertex(real x=0.0, real y=0.0, real z=0.0);
    Edge     *newEdge(Vertex *,Vertex *);
    Face *newFace(Vertex *, Vertex *, Vertex *);

    void killVertex(Vertex *);
    void killEdge(Edge *);
    void killFace(Face *);

    void reshapeVertex(Vertex *, real, real, real);
    void remapVertex(Vertex *from, Vertex *to);

    void contract(Vertex *v1, Vertex *v2, const Vec3& to,
		  face_buffer& changed);

    void contract(Vertex *v1, 
		  const vert_buffer& others,
		  const Vec3& to,
		  face_buffer& changed);


    //
    // Simplification convenience procedures
    //
    void removeDegeneracy(face_buffer& changed);
    void contractionRegion(Vertex *v1, Vertex *v2, face_buffer& changed);
    void contractionRegion(Vertex *v1,
			   const vert_buffer& vertices,
			   face_buffer& changed);

    //
    // SMF reader functions
    //
    int in_Vertex(const Vec3&);
  //virtual int in_Face(const buffer<int> &) {};
    int in_Face(int v1, int v2, int v3);
#ifdef SUPPORT_VCOLOR
    int in_VColor(const Vec3&);
#endif
#ifdef SUPPORT_FCOLOR
    int in_FColor(const Vec3&);
#endif

    //
    // Some random functions that are mostly temporary
    //

    Vec3 synthesizeNormal(Vertex *);
};

extern std::ostream& operator<<(std::ostream&, Model&);
extern void out_annotate(std::ostream&, Model&);
extern void out_annotate(std::ostream&,Vertex *);
extern void out_annotate(std::ostream&,Face *);

// NAUTILUS_ADJMODEL_INCLUDED
#endif
