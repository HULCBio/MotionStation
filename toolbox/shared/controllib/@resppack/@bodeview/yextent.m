function hy = yextent(this,VisFilter)
%YEXTENT  Gathers all handles contributing to Y limits.
%
%  HY is a 3D array where HY(:,:,1) contains the visible
%  mag. handles over the I/O grid, and HY(:,:,2) contains 
%  the visible phase handles 

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:39 $

% Handles contributing to mag extent
hmag = this.MagCurves;
hmag(~VisFilter(:,:,1)) = handle(-1);

% Handles contributing to mag extent
hphase = this.PhaseCurves;
hphase(~VisFilter(:,:,2)) = handle(-1);

% Form HY array
hy = cat(3,hmag,hphase);
