function Slice = getSlice(this,Section,CellOutputFlag)
%GETSLICE  Extracts time slice from timeseries storage array.
%
%   Array = GETSLICE(ValueArray,Section)
%
%   Array = GETSLICE(ValueArray,Section,'cell')
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:34:01 $

A = this.metadata.getData(this.data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% Remaining code copied from parent %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get full array
if ~isempty(A)
   % Expand grid dimensions
   SampleSize = this.SampleSize;
   SizeA = hdsGetSize(A);
   if length(Section)==1
      % Absolute indexing: collapse grid dimensions
      A = this.utReshape(A,[prod(SizeA)/prod(SampleSize) 1]);
   end
   
   % Extract slice, taking sample size into account
   is = repmat({':'},[1 length(SampleSize)]);
   if this.GridFirst
      A = hdsGetSlice(A,[Section is]);
   else
      A = hdsGetSlice(A,[is Section]);
   end
   
end

% Format output
if nargin<3 || ~strcmp(CellOutputFlag,'cell')
   Slice = A;
elseif isa(A,'cell') && prod(SampleSize)==1
   % Cell array with one sample per cell
   Slice = A;
else
   % Convert to cell array with one data point per cell
   Slice = this.utArray2Cell(A);
end