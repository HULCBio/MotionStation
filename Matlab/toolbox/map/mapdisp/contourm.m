function varargout = contourm(varargin)
%CONTOURM Project a contour plot of data onto the current map axes.
%
%  CONTOURM(lat,lon,map) produces a contour plot of map data projected
%  onto the current map axes.  The input latitude and longitude vectors
%  can be the size of map (as in a general matrix map), or can specify the 
%  corresponding row and column dimensions for the map.
%
%  CONTOURM(map,maplegend) produces a contour plot of map data in a 
%  regular matrix map.
%
%  CONTOURM(lat,lon,map,'LineSpec') uses any valid LineSpec string
%  to draw the contour lines.
%
%  CONTOURM(lat,lon,map,'PropertyName',PropertyValue,...) uses the
%  line properties specified to draw the contours.
%
%  CONTOURM(lat,lon,map,n,...) draws n contour levels, where n is a scalar.
%
%  CONTOURM(lat,lon,map,v,...) draws contours at the levels specified
%  by the input vector v.
%
%  CONTOURM(map,maplegend,...) takes any of the optional arguments 
%  described above.
%
%  c = CONTOURM(...) returns a standard contour matrix, with the first
%  row representing longitude data and the second row represents
%  latitude data.
%
%  [c,h] = CONTOURM(...) returns the contour matrix and the handles
%  to the contour lines drawn.
%
%  CONTOURM, without any inputs, will activate a GUI to project contour
%  lines onto the current map axes.
%
%  See also CONTOUR3M, CONTOUR, PLOT.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:18:10 $

msg = nargoutchk(0,2,nargout);
if (~isempty(msg))
   eid = sprintf('%s:%s:tooManyOutputs', getcomp, mfilename);
   error(eid, '%s', msg)
end

c=[]; 
h=[]; 
if nargin == 0            
   contour3m;
 else
   % Check input arguments
   checknargin(2,inf,nargin,mfilename);

   %  Compute and project the contour levels
   [c,h,msg] = contour3m(varargin{:});
   if ~isempty(msg)
      eid = sprintf('%s:%s:contour3mError', getcomp, mfilename);
      error(eid,'%s',msg);   
   end

   %  Set the zdata to the zero plane
   if ~isempty(h)
	   zdatam(h,0);
   end
end

%  Set the output arguments
switch nargout
  case 0
    varargout{1} = [];
  case 1
    varargout{1} = c;
  case 2
    varargout{1} = c;
    varargout{2} = h;
end

