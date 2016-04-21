function tf = isflat(se)
%ISFLAT Return true for flat structuring element.
%   ISFLAT(SE) returns true (1) if the structuring element SE is flat;
%   otherwise it returns false (0).  If SE is a STREL array, then TF is
%   the same size as SE.
%
%   See also STREL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/08/23 05:53:26 $

% Testing notes
% se:           STREL array; can be empty
%
% tf:           double logical array, same size as se, containing 0s and
%               1s. 

tf = false(size(se));
for k = 1:numel(se)
    tf(k) = ~any(se(k).height(:));
end
