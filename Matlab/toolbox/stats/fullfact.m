function design = fullfact(levels)
%FULLFACT Mixed-level full-factorial designs.
%   DESIGN=FULLFACT(LEVELS) creates a matrix DESIGN containing the
%   factor settings for a full factorial design. The vector LEVELS
%   specifies the number of unique settings in each column of the design.
%
%   Example:
%       LEVELS = [2 4 3];
%       DESIGN = FULLFACT(LEVELS);
%   This generates a 24 run design with 2 levels in the first column,
%   4 in the second column, and 3 in the third column.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.9.4.3 $  $Date: 2004/01/24 09:33:51 $

[m,n] = size(levels);
if ~isfloat(levels)
   levels = double(levels);
end

if min(m,n) ~= 1
   error('stats:fullfact:VectorRequired','Requires a vector input.');
end

if any((floor(levels) - levels) ~= 0)  | any(levels <= 1)
   error('stats:fullfact:IntegersRequired',...
         'The input values must be integers greater than one.');
end

ssize = prod(levels);
ncycles = ssize;
cols = max(m,n);

design = zeros(ssize,cols,class(levels));

for k = 1:cols
   settings = (1:levels(k));
   ncycles = ncycles./levels(k);
   nreps = ssize./(ncycles*levels(k));
   settings = settings(ones(1,nreps),:);
   settings = settings(:);
   settings = settings(:,ones(1,ncycles));
   design(:,k) = settings(:);
end
