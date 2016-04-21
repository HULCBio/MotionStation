function Slice = getSlice(this,Section,Format)
%GETSLICE  Extracts multi-dimensional slice from value array.
%
%   SLICE = GETSLICE(VALUEARRAY,SECTION) extracts a section
%   of the value array in the native storage format.
%
%   SLICE = GETSLICE(VALUEARRAY,SECTION,'cell') extracts a 
%   section and packages it as a cell array of sample values.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:01 $

% Get full array
A = getArray(this);
SampleSize = this.SampleSize;
if ~isempty(A) && ~isscalar(A)
   % Expand grid dimensions
   if length(Section)==1 && this.GridFirst
      % Absolute indexing: collapse grid dimensions if grid comes first
      SizeA = hdsGetSize(A);
      % A = this.utReshape(A,[prod(SizeA)/prod(SampleSize) 1]);
      NewGridSize = [prod(SizeA)/prod(SampleSize) 1];
      A = hdsReshapeArray(A,[NewGridSize SampleSize]);
   end

   % Extract slice, taking sample size into account
   is(:,1:length(SampleSize)) = {':'};
   if this.GridFirst
      A = hdsGetSlice(A,[Section is]);
   else
      A = hdsGetSlice(A,[is Section]);
   end
end

% Format output
if nargin==3 && strcmp(Format,'cell')
   % Return cell array of sample values
   isCellA = isa(A,'cell');
   if isCellA && prod(SampleSize)==1
      % Cell array with one sample per cell
      Slice = A;
   elseif ~isCellA && isequal(size(A),SampleSize)
      % Optimization for single sample
      Slice = {A};
   else
      % Convert to cell array with one data point per cell
      Slice = this.utArray2Cell(A);
   end
else
   % Return native array (e.g., double array of scalar values)
   Slice = A;
end