function tree = kdtree(varargin)
%KDTREE Optimized k-d tree of a set of points.
%   TREE = KDTREE(POINTS,BUCKET_SIZE) computes the optimized k-d tree
%   corresponding to POINTS, which is M-by-N matrix whose rows are points
%   in N-space.  BUCKET_SIZE is the desired average number of points per
%   leaf node of the tree.  TREE is a complete binary tree stored as a
%   structure array.  Each element of TREE represents a node of the
%   tree.  The elements are stored in breadth-first left-to-right order.
%   Element 1 is the tree's root.  Elements 2 and 3 are the left and
%   right children of element 1.  Elements 4 and 5 are the left and right
%   children of element 2, and so on.
%
%   The structure array TREE contains these fields:
%
%       dimension    - Coordinate dimension along which this node is
%                      split.  Empty for leaf nodes.
%
%       partition    - The value along the coordinate dimension that is
%                      the boundary of the split.  Empty for leaf nodes.
%
%       lower_bounds - An N-element vector specifying the lower bounds
%                      of this node along each dimension.
%
%       upper_bounds - An N-element vector specifying the upper bounds
%                      of this node along each dimension.
%
%       idx          - A vector of indices into the rows of POINTS; this
%                      represents a list of points that belong to this
%                      node.  Empty for nonleaf nodes.
%
%   BUCKET_SIZE defaults to 25 if not specified.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/08/01 18:11:19 $

% Reference: Jerome H. Friedman, Jon Louis Bentley, and Raphael Ari
% Finkel, "An Algorithm for Finding Best Matches in Logarithmic Expected
% Time," ACM Transactions on Mathematical Software, Vol. 3, No. 3,
% September 1977, pages 209-226.

[points, bucket_size] = parse_inputs(varargin{:});

num_points = size(points,1);

if num_points == 0
    num_nodes = 0;
else
    % The number of terminal (leaf) nodes in a complete binary tree must
    % be a power of two.
    num_terminal_nodes = 2^ceil(log2(max(num_points/bucket_size,1)));
    num_nodes = 2*num_terminal_nodes - 1;
end

% Initialize structure array to represent the tree.
empties = repmat({[]}, num_nodes, 1);
tree = struct('dimension', empties, 'partition', empties, ...
              'lower_bounds', empties, 'upper_bounds', empties, ...
              'idx', empties);

if num_nodes == 0
    % Degenerate case; nothing else to do.
    return
end

num_dims = size(points, 2);

% Initialize root node of the tree with all points.  Bounds include the
% entire space.
tree(1).lower_bounds = -Inf * ones(1, num_dims);
tree(1).upper_bounds =  Inf * ones(1, num_dims);
tree(1).idx = (1:num_points)';
    
last_nonterminal_node = ((num_nodes + 1) / 2) - 1;

for node = 1:last_nonterminal_node
    % Split this node.
    
    idx = tree(node).idx;
    if isempty(idx)
        % There are no points left in this node.
        % Do something arbitrary.  Split the box at its midpoint
        % along the first dimension.
        dim = 1;
        p = (tree(node).lower_bounds(dim) + tree(node).upper_bounds(dim))/2;
    
    else        
        % Find the dimension with the greatest spread.
        [junk,dim] = max(max(points(idx,:),[],1) - ...
                         min(points(idx,:),[],1),[],2);
    
        % Find the partition point along the spread dimension.
        % We want to do this:
        %   p = median(points(idx,dim));
        % but the call to median is more expensive than it needs to be.
        % Use sort directly instead.
        vec = sort(points(idx,dim));
        p = vec(ceil(end/2));
    end
    
    tree(node).dimension = dim;
    tree(node).partition = p;

    % Find the points belonging to the left and right partitions.
    on_the_left = points(idx,dim) <= p;
    
    % Find the new bounds for the left partition.
    left_lower_bounds = tree(node).lower_bounds;
    left_upper_bounds = tree(node).upper_bounds;
    left_upper_bounds(dim) = p;
    
    % Find the new bounds for the right partition.
    right_lower_bounds = tree(node).lower_bounds;
    right_upper_bounds = tree(node).upper_bounds;
    right_lower_bounds(dim) = p;
    
    % Assign values to the left child.
    left_node = 2*node;
    tree(left_node).lower_bounds = left_lower_bounds;
    tree(left_node).upper_bounds = left_upper_bounds;
    tree(left_node).idx = idx(on_the_left);
    
    % Assign values to the right child.
    right_node = left_node + 1;
    tree(right_node).lower_bounds = right_lower_bounds;
    tree(right_node).upper_bounds = right_upper_bounds;
    tree(right_node).idx = idx(~on_the_left);
    
    % Now that the points belonging to this node have been distributed to
    % its children, empty this node's bucket.
    tree(node).idx = [];
end

%--------------------------------------------------
function [points, bucket_size] = parse_inputs(varargin)

error(nargchk(1,2,nargin, 'struct'))

points = varargin{1};
if nargin < 2
    bucket_size = 25;
else
    bucket_size = varargin{2};
end

if ndims(points) > 2 | ~isreal(points)
    error('Images:kdtree:pointsReal2D', 'POINTS must be a 2-D real matrix.');
end
if isa(points, 'single')
    error('Images:kdtree:singlePoints', '"single" input class not supported for POINTS.');
end

if (prod(size(bucket_size)) ~= 1) | ~isnumeric(bucket_size) | ...
        ~isreal(bucket_size) | (floor(bucket_size) ~= bucket_size) | ...
        (bucket_size <= 0)
    error('Images:kdtree:bucketSizeType', 'BUCKET_SIZE must be a positive integer scalar.');
end
bucket_size = double(bucket_size);
