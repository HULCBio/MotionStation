function A = sliceVar(this,var,varargin)
%SLICEVAR  Extracts portion of sample array for a given variable.
%
%   ASUB = SLICEVAR(D,VAR,IDX) collect the sample values IDX for
%   the variable VAR into the array ASUB.
%   
%   ASUB = SLICEVAR(D,VAR,IDX1,...,IDXN) extracts the array of VAR
%   values corresponding to the portion IDX1,...,IDXN of the 
%   the underlying grid of independent variables.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:21 $
GridSize = getGridSize(this);
% Convert indices into absolute indices
ni = nargin-2;
GridSize = [GridSize ones(1,ni-length(GridSize))];
for ct=1:ni
   idx = varargin{ct};
   if islogical(idx)
      varargin{ct} = find(idx);
   elseif ischar(idx)
      varargin{ct} = 1:GridSize(ct);
   end
end

% Localize variable
[v,idx] = findvar(this,var);
if ~isempty(idx)
   % Data variable
   gdim = locateGridVar(this,v);
   if isempty(gdim) || length(this.Grid_)<2
      % Dependent variable or 1-D grid
      A = getSlice(this.Data_(idx),varargin);
   else
      % Grid variable
      A = this.utGridFill(getArray(this.Data_(idx)),GridSize,gdim);
      A = hdsGetSlice(A,varargin);
   end
else
   % Data link
   [v,idx] = findlink(this,var);
   if ~isempty(idx)
      A = this.Children_(idx).Links(varargin{:});
   else
      error('Only available for top-level variables and links.')
   end
end

if ni==1
   A = hdsReshapeArray(A,[length(varargin{1}) 1]);
end
