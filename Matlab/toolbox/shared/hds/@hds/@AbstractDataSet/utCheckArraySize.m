function [ArrayValue,GridSize,SampleSize] = ...
   utCheckArraySize(this,ArrayValue,Variable,GridFirstFlag)
%UTCHECKARRAYSIZE  Checks if data is compatible with grid size.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:23 $

% REVISIT: remove {1} when dispatching on first arg can be enforced
ArrayValue = ArrayValue{1};

% Get array size 
ArraySize = hdsGetSize(ArrayValue);

% Current grid size
GridSize = [this.Grid_.Length];
ndims = length(GridSize);
ngs = prod(GridSize) * (ndims>0);    % number of samples currently in data set

% Determine if the variable belongs to the grid
GridDim = this.locateGridVar(Variable);

% Separate sampling dimensions from data dimensions
% RE: Data array must be dimensioned as 
%       * [sampling dimensions x unit sample size] if rec.GridLast=0
%       * [unit sample size x sampling dimensions] otherwise
%     Can't guess if sampling dims come first or last in general, 
%     cf 2x2x3x2x2 data on 2x2 grid (is the data 2x2x3 or 3x2x2?)
[ArraySize,SampleSize] = ...
   LocalParseDim(ArraySize,GridSize,GridDim,GridFirstFlag,Variable.Name);
nas = prod(ArraySize);   % number of samples in submitted array

% Scalar expansion
if nas==1 && ngs>0
   GridSize = [GridSize,1]; %repmat does not appreciate scalar size inputs
   ArrayValue = hdsReplicateArray(ArrayValue,GridSize);
   ArraySize = GridSize;
   nas = ngs;
end

% Size checking and data set size inference
errmsg = sprintf('Bad or ambiguous data sizing for variable %s',Variable.Name);
if ndims<2 
   % Mono-dimensional grid
   if ngs==0 && sum(ArraySize>1)>1
      error('Multi-dimensional data: first specify the grid dimensionality using SETGRID.')
   elseif ngs>0 && ngs~=nas
      error(errmsg)
   else
      GridSize = nas;
   end
   
elseif ~isempty(GridDim)
   % Grid variable
   sdim = GridSize(GridDim);
   if sdim==0
      % Dimension length unknown: set grid size to number of data samples
      GridSize(GridDim) = nas;
   elseif nas==ngs
      % Data over entire grid as in d.x = 2*d.x
      % Project data along grid dimension for grid variables
      % RE: Grid vars are scalar valued
      subs = repmat({1},[1 ndims]);
      subs{GridDim} = ':';
      ArrayValue = hdsGetSlice(ArrayValue,subs{:});
   elseif nas~=sdim
      error(errmsg)
   end
   
else
   % Multi-dimensional data for non-grid variable: infer grid size
   undef = (GridSize==0);  % undefined grid dimensions
   dL = length(GridSize)-length(ArraySize);
   ArraySize = [ArraySize ones(1,dL)];
   if nas==1
      % Scalar value
      if any(GridSize>1)
         error('Scalar assignment not allowed until grid dimensions are fully specified.')
      else
         GridSize(undef) = 1;
      end
   elseif ngs~=nas && ~isequal(GridSize(~undef),ArraySize(~undef))
      % Require that the total number of samples match, or that dimension
      % lengths match where defined
      error(errmsg)
   else
      % Inherit undefined sizes from data array
      GridSize(undef) = ArraySize(undef);
   end
end

% Update grid size (should be fully defined at this point)
for ct=1:length(GridSize)
   this.Grid_(ct).Length = GridSize(ct);
end

% Return grid size as seen from the variable
if ~isempty(GridDim)
   GridSize = [GridSize(GridDim) 1];
end

%----------------------- Local functions -----------------------------


function [ArraySize,SampleSize] = LocalParseDim(ArraySize,GridSize,GridDim,GridFirstFlag,VarName)
% Separates sampling dimensions from data dimensions using grid size info
grid_errmsg = 'Use cell arrays for grid variables with non-scalar values.';
% ArraySize: size of data array
% GridSize: grid size
ndims = length(GridSize);
ArraySize = [ArraySize ones(1,ndims-length(ArraySize))];
nddims = length(ArraySize);
if ndims==0
   % Assume unit sample size
   SampleSize = [1 1];
elseif all(GridSize>0)
   % Grid size fully determined: look for GRIDSIZE or PROD(GRIDSIZE) in
   % ARRAYSIZE
   if isempty(GridDim)
      % Not a grid variable
      [ArraySize,SampleSize] = LocalLocateGrid(ArraySize,GridSize,false,GridFirstFlag,VarName);
   else
      % Grid variable
      % RE: Not allowing non-scalar data samples for grid vars in order to 
      %     accomodate syntax d.x = 2*d.x (specifies grid. var values over
      %     entire grid)
      SampleSize = [1 1];
      if prod(ArraySize)~=GridSize(GridDim)
         % Assume samples over full grid as in d.x = 2*d.x 
         [ArraySize,SampleSize] = LocalLocateGrid(ArraySize,GridSize,true,GridFirstFlag,VarName);
         if ~isequal(SampleSize,[1 1])
            error(grid_errmsg)
         end
      end
   end
else
   % Partially specified grid (empty data set with some grid length specified)
   if isempty(GridDim)
      % Not a grid variable
      if all(ArraySize==1)
         % Assume scalar data and data size = grid size
         SampleSize = [1 1];
      elseif GridFirstFlag
         SampleSize = ArraySize(ndims+1:nddims);
         ArraySize = ArraySize(1:ndims);
      else
         SampleSize = ArraySize(1:nddims-ndims);
         ArraySize = ArraySize(nddims-ndims+1:nddims);
      end
      SampleSize = [SampleSize ones(1,2-length(SampleSize))];
      ArraySize = [ArraySize ones(1,2-length(ArraySize))];
   else
      % Grid variable -> assumed 1x1 sample values
      % RE: no scalar expansion for grid vars (don't want values to be equal...)
      SampleSize = [1 1];
      if sum(ArraySize>1)>1
         error(grid_errmsg)
      else
         ArraySize = [prod(ArraySize) 1];
      end
   end
end


function [ArraySize,SampleSize] = ...
   LocalLocateGrid(ArraySize,GridSize,GridVarFlag,GridFirstFlag,VarName)
% Looks for GRIDSIZE or prod(GRIDSIZE) dimensions at the beginning of the data array size
% Returns dimensions DSIZE of sample array and size SAMPLESIZE of individual samples.
% RE: All grid sizes must be positive.
if ~GridFirstFlag
    % Remove all trailing singleton dims
    GridSize = GridSize(1:max([1 find(GridSize>1)]));
    ArraySize = ArraySize(1:max([1 find(ArraySize>1)]));
end  
ndims = length(GridSize);
nddims = length(ArraySize);
ngs = prod(GridSize);
nas = prod(ArraySize);
if ngs==1 | nas==1
   % Single sample or data set of unit size
   SampleSize = [ArraySize , ones(1,2-nddims)];
   ArraySize = [1 1];
elseif (GridFirstFlag && nddims>=ndims && all(ArraySize(1:ndims)==GridSize))
   % First data sizes match grid size
   SampleSize = [ArraySize(ndims+1:nddims) , ones(1,2-(nddims-ndims))];
   ArraySize = [GridSize ones(1,2-ndims)];
elseif (~GridFirstFlag && nddims>=ndims && all(ArraySize(nddims-ndims+1:nddims)==GridSize))
   % First data sizes match grid size
   SampleSize = [ArraySize(1:nddims-ndims) , ones(1,2-(nddims-ndims))];
   ArraySize = [GridSize ones(1,2-ndims)];
elseif (GridFirstFlag && ArraySize(1)==ngs)
   % First data size matches total number of samples
   SampleSize = [ArraySize(2:nddims) , ones(1,3-nddims)];
   ArraySize = [ArraySize(1) , 1];
elseif (~GridFirstFlag & ArraySize(nddims)==ngs)
   % First data size matches total number of samples
   SampleSize = [ArraySize(1:nddims-1) , ones(1,3-nddims)];
   ArraySize = [ArraySize(nddims) , 1];
elseif nddims==2 & ngs==nas
   % 1xN = Nx1
   SampleSize = [1 1];
   ArraySize = [ngs 1];
elseif GridVarFlag
   % Error messages for grid variable
   % Scalar data samples, non-scalar caught by caller
   error(sprintf(...
      'Size of data array for grid variable %s does not match grid size.',VarName))
else
   % Error messages for non-grid variable
   str = 'Check array size or use PERMUTE to reorder its dimensions.';
   if nddims<=max(2,ndims)
      % Scalar data
      error(sprintf(...
         'Size of data array for variable %s does not match number of samples in data set.\n%s',VarName,str))
   elseif GridFirstFlag
      error(sprintf(...
         'First dimension(s) of data array for variable %s must match grid size or\ntotal number of samples. %s',...
         VarName,str));
   else
      error(sprintf(...
         'Last dimension(s) of data array for variable %s must match grid size or\ntotal number of samples. %s',...
         VarName,str));
   end
end