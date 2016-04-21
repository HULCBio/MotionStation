%PDEBOUND Boundary M-file.
%
%       The Boundary M-file can be used to specify the boundary
%       conditions of a PDE problem.
%
%       [Q,G,H,R]=PDEBOUND(P,E,U,TIME) produces values of boundary
%       conditions.
%
%       The matrices P and E are mesh data. E need only
%       be a subset of the edges in the mesh. See INITMESH for details.
%
%       The input arguments U and TIME are used for the nonlinear
%       solver and time stepping algorithms respectively.
%
%       The solution U is represented as the MATLAB column vector U.
%       See ASSEMPDE for details.
%
%       Q and G must contain the value of the matrices q and g on the mid
%       point of each boundary. Thus we have SIZE(Q)=[N^2 NE], where
%       N is the dimension of the system, and NE the number of
%       edges in E, and  SIZE(G)=[N NE]. For the Dirichlet case,
%       the corresponding values must be zeros.
%
%       H and R must contain the values of the matrices h and r at the
%       first point on each edge followed by the value at the second point on
%       each edge. Thus we have SIZE(H)=[N^2 2*NE], where N
%       is the dimension of the system, and NE the number of edges in
%       E, and SIZE(R)=[N 2*NE]. When M<N, h and r must be
%       padded with N-M rows of zeros.
%
%       The elements of the matrices q, and h are stored in column
%       wise ordering in the MATLAB matrices Q and H.

%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:13 $

