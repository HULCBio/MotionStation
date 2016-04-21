function nhood = getnhood(se)
%GETNHOOD Get structuring element neighborhood.
%   NHOOD = GETNHOOD(SE) returns the neighborhood associated with the
%   structuring element SE.
%
%   Example
%   -------
%
%       se = strel(eye(5));
%       nhood = getnhood(se)
%
%   See also STREL, STREL/GETNEIGHBORS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:09:45 $

% Testing notes
% Syntaxes
% --------
% NHOOD = GETNHOOD(SE)
%
% se:       1-by-1 STREL array
%
% nhood:    Double array containing 0s and 1s.  Should be logical.

if length(se) ~= 1
    error('Images:getnhood:wrongType', 'SE must be a 1-by-1 STREL array.');
end

nhood = se.nhood;
