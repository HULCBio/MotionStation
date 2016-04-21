function setSlice(this,Section,B,GridSize)
%GETSLICE  Extracts multi-dimensional slice from value array.
%
%   SETSLICE(ValueArray,Section,Array,GridSize)

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:04 $

% RE: Assumes B is a subarray of A
Ns = prod(GridSize);
GridSizeB = cellfun('length',Section);
NsB = prod(GridSizeB);
isCellofSampleB = (isa(B,'cell') && prod(size(B))==NsB);

% Get current array
A = getArray(this); 

% Align formats of A and B (cell array of samples vs. compound array
% aggregating grid and sample dimensions for evenly sized samples)
if isempty(A)
   % Creating new array
   if isCellofSampleB
      % Try converting data to homogenous array
      try
         [B,SampleSize] = utCell2Array(this,B);
      catch
         SampleSize = [1 1];
      end
   end
   if isempty(B)
      return
   end
   % Create new array of size grid size and data type inherited from SLICE
   if this.GridFirst
      A = hdsNewArray(B,[GridSize SampleSize]);
   else
      A = hdsNewArray(B,[SampleSize GridSize]);
   end
   
elseif isscalar(A)
   % Special handling for scalar storage
   SampleSize = [1 1];
   if isscalar(B) && localIsEqual(A,B)
      % No change
      return
   else
      % Turn A into full-size array
      if isCellofSampleB && ~isa(A,'cell')
         A = {A};
      end
      A = hdsReplicateArray(A,GridSize);
   end

else
   % Modifying existing array
   SampleSize = this.SampleSize;
   isCellofSampleA = (isa(A,'cell') && isequal(SampleSize,[1 1]));
   if isCellofSampleB && ~isCellofSampleA
      % A is a compound array. Try converting B to same format
      if isscalar(B)
         % Optimization
         B_Array = B{1};
         SampleSizeB = size(B_Array);
      else
         try
            [B_Array,SampleSizeB] = utCell2Array(this,B);
         catch
            SampleSizeB = [];
         end
      end
      if isequal(SampleSize,SampleSizeB)
         % Conversion successful
         B = B_Array;
      else
         % Must convert A to cell format
         A = this.utArray2Cell(A);
         SampleSize = [1 1];
      end
   elseif isCellofSampleA && ~isCellofSampleB
      % Convert B to cell format
      B = this.utArray2Cell(B);
   end
end
this.SampleSize = SampleSize;

% Perform assignment
if length(Section)==1
   % Absolute indexing
   A = this.utReshape(A,[Ns 1]);
   B = this.utReshape(B,[NsB 1]);
end
is(:,1:length(SampleSize)) = {':'};
if this.GridFirst
   A = hdsSetSlice(A,[Section is],B);
else
   A = hdsSetSlice(A,[is Section],B);
end
if length(Section)==1
   % Absolute indexing
   A = this.utReshape(A,GridSize);
end
this.setArray(A)

%------------- Local Function -------------

function boo = localIsEqual(A,B)
if isa(A,'cell')
   A = A{1};
end
if isa(B,'cell')
   B = B{1};
end
boo = isequal(A,B);