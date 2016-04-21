function [lat2,lon2] = polyjoin(latcells,loncells)
% POLYJOIN convert polygon segments from cell array to vector format
% 
% [lat2,lon2] = POLYJOIN(latcells,loncells) converts polygons from cell
% array format to vector format. In cell array format, each element of 
% the cell array is a separate polygon. Each polygon may consist of an 
% outer contour followed by holes separated with NaNs. In vector format, 
% each vector may contain multiple faces separated by NaNs. There is no
% distinction between outer contours and holes.
%
% See also POLYSPLIT, POLYBOOL, POLYCUT

%  Written by: W. Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:17:36 $

if nargin<2, error('Incorrect number of input arguments.'), end

if ~iscell(latcells) | ~iscell(loncells)
	error('Inputs must be cell arrays.')
end

if isempty(latcells);

   [lat2,lon2] = deal([],[]);
   return
   
else
   
   [lat2,lon2] = deal(latcells{1},loncells{1});
   
end

for i=2:length(latcells)
   [lat2,lon2] = deal([lat2;NaN;latcells{i}], [lon2;NaN;loncells{i}]);
end


