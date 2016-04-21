function map = terrain(m)
%TERRAIN Color map for displaying terrain relief.
%   private function to psoutputwashington.

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:16 $

error(nargchk(0,1,nargin));
if nargin == 0
    m = size(get(gcf,'colormap'),1);
elseif ~isa(m,'double') || any(~isreal(m))...
        || length(m) ~= 1 || any(ceil(m) ~= m)
    error('Input must be real double, 1-by-1, and integer-valued.');
end

% The color map consists of two linear segments in HSV space.
% The lower 2/3 follows a linear trajectory from [0.3 0.3 0.5]
% to [0.1 0.8 0.8].  The upper 1/3 continues on to [0 0 0.95].

p1 = [0.3  0.3  0.5 ];
p2 = [0.1  0.8  0.8 ];
p3 = [0.0  0.0  0.95];

m1 = max(2,ceil((2/3)*m));  % First segment, including both p1 and p2
m2 = max(1,m - m1);         % Upper segment, ending at p3

hsv1 = repmat(p1,[m1 1]) + ((0:m1-1)/(m1-1))' * (p2 - p1);
hsv2 = repmat(p2,[m2 1]) +   ((1:m2)/m2)'     * (p3 - p2);

map = hsv2rgb([hsv1; hsv2]);
