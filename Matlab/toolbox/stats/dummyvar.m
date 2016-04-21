function D = dummyvar(group)
%DUMMYVAR Dummy variable coding.
%   DUMMYVAR(GROUP) makes a dummy column for
%   each unique value in each column of the 
%   matrix GROUP. The values of the elements
%   in any column of GROUP go from one to the
%   number of members in the group.

%   Example: Suppose we are studying the effects
%   of two machines and three operators on a process.
%   The first column of GROUP would have the values
%   one or two depending on which machine
%   was used. The second column of GROUP would have 
%   the values one, two, or three depending on which
%   operator ran the machine. 

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.8.2.2 $  $Date: 2004/01/16 20:09:10 $

[m,n] = size(group);
if m == 1
  m = n;
  n = 1;
  group = group(:);
end

if any(any(group - round(group))) ~= 0
   error('stats:dummyvar:BadGroup',...
         'Each element of GROUP must be a positive integer.')
end
if ~isfloat(group)
   group = double(group);
end

maxg = max(group);
colstart = [0 cumsum(maxg)];
colstart(n+1) = [];
colstart = reshape(colstart(ones(m,1),:),m*n,1);

colD = sum(maxg);
D = zeros(m,colD,class(group));

row = (1:m)';
row = reshape(row(:,ones(n,1)),m*n,1);

idx = m*(colstart + group(:) - 1) + row;
D(idx) = ones(size(row));
