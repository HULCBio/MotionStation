function pt = gcpmap(hndl)

%GCPMAP  Gets the current point from a map
%
%  mat = GCPMAP will compute the current point on a map axes
%  in Greenwich coordinates.  GCPMAP works much like
%  get(gca,'CurrentPoint') except that the returned
%  matrix is [lat lon z], not [x y z].
%
%  mat = GCPMAP(h) returns the current map point from the axes
%  specified by the handle h.
%
%  See also  INPUTM, AXES ('CurrentPoint' property)

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
    hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
    if isempty(hndl);  error('No axes in current figure');  end
end

%  Ensure that handle object is an axes.

[mflag,msg] = ismap(hndl);
if ~mflag;  error(msg);   end

%  Get the current point

pt = get(hndl,'CurrentPoint');
x = pt(:,1);     y = pt(:,2);    z = pt(:,3);

%  Compute the inverse transformation for the selected projection
%  Use text as an object to represent a point calculation

[lat,long] = minvtran(x,y,z);

%  Set the output matrix

pt = [lat long pt(:,3)];

