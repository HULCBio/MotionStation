%PDEGEOM Geometry M-file.
%
%       NE=PDEGEOM is the number of boundary segments
%
%       D=PDEGEOM(BS) is a matrix with one column for each boundary segment
%       specified in BS.
%       Row 1 contains the start parameter value.
%       Row 2 contains the end parameter value.
%       Row 3 contains the label of the left-hand region.
%       Row 4 contains the label of the right-hand region.
%
%       [X,Y]=PDEGEOM(BS,S) produces coordinates of boundary points.
%       bs specifies the boundary segments and s the corresponding
%       parameter values. BS can be a scalar.
%
%       See also INITMESH, REFINEMESH

%       A. Nordmark 4-26-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:15 $

