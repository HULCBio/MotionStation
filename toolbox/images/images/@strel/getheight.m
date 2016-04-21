function height = getheight(se)
%GETHEIGHT Get height of structuring element.
%   H = GETHEIGHT(SE) returns an array the same size as GETNHOOD(SE)
%   containing the height associated with each of the structuring element
%   neighbors.  H is all zeros for a flat structuring element.
%
%   Example
%   -------
%       se = strel(ones(3,3),magic(3));
%       getheight(se)
%
%   See also STREL, STREL/GETNHOOD.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:09:43 $

% Testing notes
% Syntaxes
% --------
% HEIGHT = GETHEIGHT(SE)
%
% se:      a 1-by-1 strel array; it may have no neighbors.
% height:  a double array with the same size as NHOOD = GETNHOOD(SE).

if length(se) ~= 1
    error('Images:getheight:wrongType', 'SE must be a 1-by-1 STREL array.');
end

height = se.height;
