function se2 = reflect(se1)
%REFLECT Reflect structuring element.
%   SE2 = REFLECT(SE) reflects a structuring element through its center.
%   The effect is the same as if you rotated the structuring element's
%   domain 180 degrees around its center (for a 2-D structuring element).
%   If SE is an array of structuring element objects, then REFLECT(SE)
%   reflects each element of SE, and SE2 has the same size as SE.
%
%   Example
%   -------
%       se = strel([0 0 1; 0 0 0; 0 0 0])
%       se2 = reflect(se)
%
%   See also STREL.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/08/23 05:53:27 $

% Testing notes
% se1:          STREL array; can be empty
%
% se2:          STREL array; same size as se1.  Each individual strel
%               in se2 is the reflection of the corresponding strel
%               in se1.
%
% Note that the reflection operation forces the size of the strel
% neighborhoods to be odd.  For example:
% >> se = strel(ones(2,2))
% se =
% Flat STREL object containing 4 neighbors.
% 
% Neighborhood:
%      1     1
%      1     1
% >> se2 = reflect(se)
% se2 =
% Flat STREL object containing 4 neighbors.
% 
% Neighborhood:
%      1     1     0
%      1     1     0
%      0     0     0
%
% GETNHOOD(REFLECT(SE)) should be logical.

se2 = se1;

if length(se1) ~= 1
    % Translate every structuring element in the array.
    for k = 1:numel(se2)
        se2(k) = reflect(se2(k));
    end
else
    nhood = getnhood(se2);
    height = getheight(se2);
    num_dims = ndims(nhood);
    subs = cell(1,num_dims);
    size_nhood = size(nhood);
    for k = 1:num_dims
        subs{k} = size_nhood(k):-1:1;
    end
    nhood = nhood(subs{:});
    height = height(subs{:});
    new_size = size_nhood + (rem(size_nhood,2) ~= 1);
    if any(new_size > size_nhood)
        nhood = padarray(nhood, new_size - size_nhood,0,'post');
        height = padarray(height, new_size - size_nhood,0,'post');
    end

    se2.nhood = logical(nhood);
    se2.height = height;
    if ~isempty(se2.decomposition)
        se2.decomposition = reflect(getsequence(se1));
    end
end
