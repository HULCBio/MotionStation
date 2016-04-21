function [c,map] = cmunique(varargin)
%CMUNIQUE Find unique colormap colors and corresponding image.
%   [Y,NEWMAP] = CMUNIQUE(X,MAP) returns the indexed image Y and 
%   associated colormap NEWMAP that produce the same image as
%   (X,MAP) but with the smallest possible colormap. CMUNIQUE
%   removes duplicate rows from the colormap and adjusts the
%   indices in the image matrix accordingly.
%
%   [Y,NEWMAP] = CMUNIQUE(RGB) converts the truecolor image RGB
%   to the indexed image Y and its associated colormap
%   NEWMAP. NEWMAP is the smallest possible colormap for the
%   image, containing one entry for each unique color in
%   RGB. (Note that NEWMAP may be very large, as much as P-by-3
%   where P is the number of pixels in RGB.) 
%
%   [Y,NEWMAP] = CMUNIQUE(I) converts the intensity image I to an
%   indexed image Y and its associated colormap NEWMAP. NEWMAP is
%   the smallest possible colormap for the image, containing one
%   entry for each unique intensity level in I. 
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or double. 
%   The class of the output image Y is uint8 if the length of 
%   NEWMAP is less than or equal to 256. If the length of 
%   NEWMAP is greater than 256, Y is of class double.
%
%   Example
%   -------
%      X = magic(4);
%      map = [gray(8); gray(8)];
%      [Y, newmap] = cmunique(X, map);
%      imview(X, map, 'initialmag', 'fit')
%      imview(Y, newmap, 'initialmag', 'fit')
%
%   See also RGB2IND, GRAY2IND.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.18.4.4 $  $Date: 2003/08/23 05:52:10 $

%   I/O Spec
%   ========
%   IN
%      X      - image of class uint8, uint16, or double
%      MAP    - M-by-3 array of doubles (colormap)
%   OUT
%      Y      - uint8 if NEWMAP has <= 256 entries, double 
%               if NEWMAP has > 256 entries.
%      NEWMAP - M-by-3 array of doubles (colormap)

checknargin(1,3,nargin,mfilename);
checkinput(varargin{1},{'double' 'uint8' 'uint16'},{'real' 'nonsparse'}, mfilename,'X',1);

% Convert all possible input arguments to an indexed image.
if nargin==1, % cmunique(I) or cmunique(RGB)
    arg1 = varargin{1};
    if ndims(arg1)==3, % cmunique(RGB)
        [c,map] = rgbToInd(arg1);
    else % cmunique(I)
        [c,map] = grayToInd(arg1);
    end
elseif nargin==2, % cmunique(a,cm)
    c = varargin{1}; map = varargin{2};
elseif nargin==3, % cmunique(r,g,b)
    warning('Images:cmunique:obsoleteSyntax',['CMUNIQUE(r,g,b) is an obsolete syntax.',...
    'Use a three dimensional array to represent RGB image.']);
    [c,map] = rgbToInd(cat(3,varargin{1},varargin{2},varargin{3}));
end

if ~isa(c, 'double')    % The promotion is necessary for the indexing into
    c = im2double(c, 'indexed');  % pos below --  ...loc(pos(c))...
end

tol = 1/1024;

% Quantize colormap entries to help matching below.
map = round(map/tol)*tol;

%  
% Remove matching entries from colormap
%
 
% Sort colormap entries
[dum,ndx1] = sort(map(:,1));
[dum,ndx2] = sort(map(ndx1,2));
[dum,ndx3] = sort(map(ndx1(ndx2),3));
                % ndx maps from sorted cm to original cm
ndx = ndx1(ndx2(ndx3));
                % pos maps from original cm to sorted cm
pos = zeros(size(ndx)); pos(ndx) = 1:length(ndx);

% Find matching entries
                % d indicates the location of matching entries
d = all(abs(diff(map(ndx,:)))'<tol)';

% Mapping from full cm to compressed cm
                % loc maps from sorted cm to compressed cm
loc = [1:length(ndx)]' - [0;cumsum(d)]; 
c(:) = loc(pos(c));

% Remove matching entries (compress cm)
ndx(find(d)) = [];
map = map(ndx,:);

%
% Remove colormap entries that are not used in c
%
[n,x] = imhist(c,map);
d = (n==0); % Find unused colormap entries
loc = [1:size(map,1)]' - cumsum(d);

% Update image values
c(:) = loc(c);

% Remove unused entries (compress cm)
map(find(d),:) = [];

if max(c(:))<=256    % Output a uint8 array if we can
    c = uint8(c-1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,map] = rgbToInd(rgb)
% Convert rgb image to indexed by stuffing all pixel colors into a big
% colormap.

m = size(rgb,1);
n = size(rgb,2);
map = im2double(reshape(rgb,m*n,3));
x = reshape(1:m*n, m, n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,map] = grayToInd(I)
% Convert intensity image to indexed by stuffing all pixel colors into a
% big colormap.

[m,n] = size(I);
map = im2double(repmat(I(:),1,3));
x = reshape(1:m*n, m, n);

