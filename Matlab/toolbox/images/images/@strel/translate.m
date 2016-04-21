function se2 = translate(se1,displacement)
%TRANSLATE Translate structuring element.
%   SE2 = TRANSLATE(SE,V) translates a structuring element SE in N-D
%   space.  V is an N-element vector containing the offsets of the
%   desired translation in each dimension.
%
%   Example
%   -------
%   Dilating with a translated version of STREL(1) is a way to translate
%   the input image in space.  This example translates the cameraman.tif
%   image down and to the right by 25 pixels.
%
%       I = imread('cameraman.tif');
%       se = translate(strel(1), [25 25]);
%       J = imdilate(I,se);
%       imshow(I), title('Original')
%       figure, imshow(J), title('Translated');
%
%   See also STREL, STREL/REFLECT.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2003/08/23 05:53:29 $

% Testing notes
% se1:          STREL array; can be empty.  Required.
%
% v:            Expected to be a vector; if an array is passed in, it
%               is silently reshaped into row vector.  Must be a double
%               vector containing integers.  Required.
%
% se2:          STREL array; same size as se1.  Each individual strel
%               in se2 is the translation of the corresponding strel
%               in se1.
%
% Note that the translation operation forces the size of the strel
% neighborhoods to be odd.  For example:
% >> se = strel(ones(2,2))
% se =
% Flat STREL object containing 4 neighbors.
% 
% Neighborhood:
%      1     1
%      1     1
% >> se2 = translate(se,[1 1])
% se2 =
% Flat STREL object containing 4 neighbors.
% 
% Neighborhood:
%      0     0     0     0     0
%      0     0     0     0     0
%      0     0     0     0     0
%      0     0     0     1     1
%      0     0     0     1     1
%
% GETNHOOD(TRANSLATE(SE),V) should be logical.
%
% TRANSLATE should work even if length(V) is different than
% num_dims(getnhood(se)).

error(nargchk(2,2,nargin, 'struct'))

if ~isa(se1,'strel')
    error('Images:translate:wrongType', 'First input argument must be a STREL object.');
end
if ~isa(displacement,'double')
    error('Images:translate:invalidInput', 'Second input argument must be double.');
end
if any(displacement ~= floor(displacement))
    error('Images:translate:invalidInput', 'Second input argument must contain only integers.');
end

displacement = displacement(:)';

if length(se1) ~= 1
    % Translate every structuring element in the array.
    se2 = se1;
    for k = 1:numel(se2)
        se2(k) = translate(se2(k), displacement);
    end
else
    se2 = se1;
    nhood = getnhood(se1);
    nhood_dims = ndims(nhood);
    displacement_dims = length(displacement);
    if (nhood_dims > displacement_dims)
        displacement = [displacement, zeros(1,nhood_dims - displacement_dims)];
        num_dims = nhood_dims;
        size_nhood = size(nhood);
    
    else
        num_dims = displacement_dims;
        size_nhood = [size(nhood), ones(1,displacement_dims - nhood_dims)];
    end
    
    height = getheight(se1);
    idx = find(nhood);
    sub = cell(1,num_dims);
    [sub{:}] = ind2sub(size_nhood, idx);
    center = floor((size_nhood + 1)/2);
    subs = [sub{:}];
    subs = subs - repmat(center, size(subs,1), 1);
    subs = subs + repmat(displacement, size(subs,1), 1);
    max_abs_subs = max(abs(subs),[],1);
    new_size = 2*abs(max_abs_subs) + 1;
    new_center = floor((new_size + 1)/2);
    subs = subs + repmat(new_center, size(subs,1), 1);
    for k = 1:num_dims
        sub{k} = subs(:,k);
    end
    new_idx = sub2ind(new_size, sub{:});
    new_nhood = zeros(new_size);
    new_height = zeros(new_size);
    new_nhood(new_idx) = 1;
    new_nhood = logical(new_nhood);
    new_height(new_idx) = height(idx);
    
    se2.nhood = logical(new_nhood);
    se2.height = new_height;
    if (~isempty(se2.decomposition))
        se2.decomposition(1) = translate(se2.decomposition(1),displacement);
    end
    
end

