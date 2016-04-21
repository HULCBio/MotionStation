function indices = formatsubs(indices,sizes)
% Formats susbcripts in () reference or assignment.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:36 $

% Check number of indices against number of dimensions
nind = length(indices);
nd = length(sizes); 
if nind==1,
   if nd>2 || min(sizes)>1,
      error('Use multiple indexing for MIMO models or LTI arrays, as in SYS(i,j).');
   elseif sizes(1)==1,  % 2D, single output
      indices = [{':'} indices];
   else                 % 2D, single input
      indices = [indices {':'}];
   end
elseif nind==2 && nd>2,
   % SYS(*,*) for model arrays (no indices into the array). Interpret as 
   % I/O selection or assignment across the entire array:
   %    SYS(1,2,3,4)  <->  Array(3,4) , channel pair (1,2)
   %    SYS(1,2)      <->  Array (entire array), channel pair (1,2)
   indices = [indices repmat({':'},1,nd-2)];
elseif nind==3 && nd==2,
   % For a single model, ensure that sys(:,:,[1 1 1]) produces a 3x1 array
   indices = [indices {':'}];
end

