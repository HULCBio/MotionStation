function D = slice(this,varargin)
%SLICE  Extract subset of data set.
%
%   DSUB = SLICE(D,IDX) extracts the data set comprised of the data points
%   with absolute index in IDX.
%   
%   DSUB = SLICE(D,IDX1,...,IDXN) extracts a subset of an N-dimensional
%   data set.  The index vector IDX1,...,IDXN specify the selected points
%   along each grid dimension.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:20 $
GridSize = getGridSize(this);
% Convert indices into absolute indices
ni = nargin-1;
GridSize = [GridSize ones(1,ni-length(GridSize))];
GridVarMap = utGridVarMap(this,getvars(this));
for ct=1:ni
   idx = varargin{ct};
   if islogical(idx)
      varargin{ct} = find(idx);
   elseif ischar(idx)
      varargin{ct} = 1:GridSize(ct);
   end
end

% Copy skeleton
L = getlinks(this);
if isempty(L)
   D = feval(class(this),getvars(this));
else
   D = feval(class(this),getvars(this),L);
end
Data = D.Data_;
Links = D.Children_;

% Copy container settings
for ct=1:length(Data)
   Data(ct).GridFirst = this.Data_(ct).GridFirst;
   Data(ct).SampleSize = this.Data_(ct).SampleSize;
end

if ni==1 && length(this.Grid_)>1
   % Absolute indexing into N-D grid with N>=2
   D.Grid_ = this.Grid_(1);
   ns = length(varargin{1});
   D.Grid_.Length = ns;

   % Get value array slices
   for ct=1:length(Data)
      gdim = GridVarMap(ct);
      if gdim==0 || length(this.Grid_)<2
         % Dependent variable or 1-D grid
         Data(ct).Data = getSlice(this.Data_(ct),varargin);
      else
         % Grid variable 
         A = this.utGridFill(getArray(this.Data_(ct)),GridSize,gdim);
         Asub = hdsGetSlice(A,varargin);
         Data(ct).Data = hdsReshapeArray(Asub,[ns 1]);
      end
   end

   % Get link array slices
   for ct=1:length(Links)
      Links(ct).Links = getSlice(copy(this.Children_(ct),true),varargin);
   end

else
   % Multi-dimensional indexing
   % Set grid dimensions
   D.Grid_ = this.Grid_;
   for ct=1:ni
      D.Grid_(ct).Length = length(varargin{ct});
   end

   % Get value array slices
   % RE: In-memory model
   for ct=1:length(Data)
      gdim = GridVarMap(ct);
      if gdim==0
         % Regular variable
         Data(ct).Data = getSlice(this.Data_(ct),varargin);
      else
         % Grid variable
         Data(ct).Data = getSlice(this.Data_(ct),varargin(gdim));
      end
   end

   % Get link array slices
   for ct=1:length(Links)
      Links(ct).Links = getSlice(copy(this.Children_(ct),true),varargin);
   end
end