function [L,numComponents] = bwlabel(BW,mode)
%BWLABEL Label connected components in binary image.
%   L = BWLABEL(BW,N) returns a matrix L, of the same size as BW, containing
%   labels for the connected components in BW. N can have a value of either
%   4 or 8, where 4 specifies 4-connected objects and 8 specifies
%   8-connected objects; if the argument is omitted, it defaults to 8.
%
%   The elements of L are integer values greater than or equal to 0.  The
%   pixels labeled 0 are the background.  The pixels labeled 1 make up one
%   object, the pixels labeled 2 make up a second object, and so on.
%
%   [L,NUM] = BWLABEL(BW,N) returns in NUM the number of connected objects
%   found in BW.
%
%   Note: Comparing BWLABEL and BWLABELN
%   ------------------------------------
%   BWLABEL supports 2-D inputs only, whereas BWLABELN support any 
%   input dimension.  In some cases you might prefer to use BWLABELN even
%   for 2-D problems because it can be faster.  If you have a 2-D input
%   whose objects are relatively "thick" in the vertical direction,
%   BWLABEL will probably be faster; otherwise BWLABELN will probably be
%   faster.
%
%   Class Support
%   -------------
%   BW can be logical or numeric, and it must be real, 2-D, and
%   nonsparse.  L is double.
%
%   Example
%   -------
%       BW = logical([1 1 1 0 0 0 0 0
%                     1 1 1 0 1 1 0 0
%                     1 1 1 0 1 1 0 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 0 1 0
%                     1 1 1 0 0 1 1 0
%                     1 1 1 0 0 0 0 0]);
%       L = bwlabel(BW,4);
%       [r,c] = find(L == 2);
%
%   See also BWEULER, BWLABELN, BWSELECT.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.29.4.2 $  $Date: 2003/05/03 17:50:09 $

checknargin(1,2,nargin,mfilename);
checkinput(BW, {'logical' 'numeric'}, {'real', '2d', 'nonsparse'}, ...
           mfilename, 'BW', 1);

if (nargin < 2)
    mode = 8;
else
    checkinput(mode, 'double', 'scalar', mfilename, 'N', 2);
end

if ~islogical(BW)
    BW = BW ~= 0;
end


[M,N] = size(BW);

% Compute run-length encoding and assign initial labels.
[sr,er,sc,labels,i,j] = bwlabel1(BW,mode);
numRuns = length(sr);
if (isempty(labels))
    numLabels = 0;
else
    numLabels = max(labels);
end

% Create a sparse matrix representing the equivalence graph.
tmp = (1:numLabels)';
A = sparse([i;j;tmp], [j;i;tmp], 1, numLabels, numLabels);

% Determine the connected components of the equivalence graph
% and compute a new label vector.

% Find the strongly connected components of the adjacency graph
% of A.  dmperm finds row and column permutations that transform
% A into upper block triangular form.  Each block corresponds to
% a connected component; the original source rows in each block
% correspond to the members of the corresponding connected
% component.  The first two output% arguments (row and column
% permutations, respectively) are the same in this case because A
% is symmetric.  The vector r contains the locations of the
% blocks; the k-th block as indices r(k):r(k+1)-1.
[p,p,r] = dmperm(A);

% Compute vector containing the number of elements in each
% component.
sizes = diff(r);
numComponents = length(sizes);  % Number of components.

blocks = zeros(1,numLabels);
blocks(r(1:numComponents)) = 1;
blocks = cumsum(blocks);
blocks(p) = blocks;
labels = blocks(labels);

% Given label information, create output matrix.
L = bwlabel2(sr, er, sc, labels, M, N);
