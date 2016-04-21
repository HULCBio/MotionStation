function d = mydistf(pos)
%MYDISTF Example custom distance function.
%
%  Use this function as a template to write your own function.
%  
%     Syntax
%
%    d = mydistf(pos)
%      pos - NxS matrix of S neuron position vectors.
%      d   - SxS matrix of neuron distances.
%
%  Example
%
%    pos = gridtop(3,2);
%    d = mydistf(pos)

% Copyright 1997 The MathWorks, Inc.
% $Revision: 1.3.2.1 $

s = size(pos,2);
for i=1:s
  for j=1:s
  
% ** Replace the following line of code with your own
% ** measure of distance.
  
    d(i,j) = norm(pos(:,i)-pos(:,j),1.5);
    
  end
end
