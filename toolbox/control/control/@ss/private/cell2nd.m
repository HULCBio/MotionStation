function A = cell2nd(A,nr,nc)
%CELL2ND  Convert cell array of matrices into ND array.
%
%   A = CELL2ND(A,NR,NC) converts A to an ND array.
%   NR and NC specify the number of rows and columns
%   for the case when A is an empty cell array.

%   Author:  P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 06:03:27 $

ArraySizes = size(A);
if ~all(ArraySizes),
   A = zeros([nr,nc,ArraySizes]);
elseif isequal(ArraySizes,[1 1]),
   A = A{1};
else
   A = cat(3,A{:});    
   A = reshape(A,[size(A,1) size(A,2) ArraySizes]);
end
