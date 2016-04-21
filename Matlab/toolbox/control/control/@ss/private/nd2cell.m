function Aout = nd2cell(A,ArraySizes)
%ND2CELL  Convert ND array to cell array.

%   Author:  P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:03:30 $

if iscell(A),
   Aout = A;
elseif issparse(A)
   % Sparse 2D
   Aout = {A};
elseif isequal(A,[]),
   % Ensure correct processing of [] shorthand for empty arrays
   Aout = cell(ArraySizes);
else
   s = size(A);
   Aout = cell([s(3:end) 1 1]);
   for k=1:prod(s(3:end)),
      Aout{k} = A(:,:,k);
   end
end
