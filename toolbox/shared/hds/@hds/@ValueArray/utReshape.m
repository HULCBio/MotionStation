function A = utReshape(this,A,GridSize)
% Reshapes array to specified grid size

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:07 $
if ~isempty(A)
   if this.GridFirst
      A = hdsReshapeArray(A,[GridSize this.SampleSize]);
   else
      A = hdsReshapeArray(A,[this.SampleSize GridSize]);
   end
end