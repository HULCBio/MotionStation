function addGridPoints(this,varargin)
%ADDGRIDPOINTS  Adds points along particular grid dimensions.
%
%   ADDGRIDPOINTS(D,X1,X2,..,XN) adds the grid points X1 to
%   the first grid dimension, X2 to the second grid dimension, etc.
%   Each Xj is either a vector for scalar-valued grid variables,
%   or a cell array for string or array-valued grid variables.
%   Set Xj=[] if no grid point are to be added along the j-th 
%   dimension. For example
%      d.addGridPoints([1 2],{'foo' 'bar'})
%   adds the values 1,2 along the first grid dimension, and the
%   values 'foo', 'bar' along the second grid dimension.
%
%   ADDGRIDPOINTS(D,VAR1,DATA1,VAR2,DATA2,...) specifies new grid
%   points for individual grid variables. For example
%      d.addGridPoints('x',[1 2],'y',{'foo' 'bar'})
%   add two new values for the grid variables x and y.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:56 $
% Reduce input arguments to syntax ADDGRIDPOINTS(D,X1,X2,..,XN)
try
   NewGridPoints = LocalParseData(this,varargin);
catch
   rethrow(lasterror)
end
oldGridSize = [this.Grid_.Length];

% Loop over each grid dimension
AllVars = getvars(this);
idx_new = find(cellfun('length',NewGridPoints));
for ct=idx_new
   % Check user input
   Xj = NewGridPoints{ct};
   if sum(size(Xj)>1)>1
      % Interpret non-scalar data as single sample
      Xj = {Xj};
   end
   nv = length(this.Grid_(ct).Variable);
   if nv==1
      Xj = {Xj};
   elseif ~isa(Xj,'cell') || length(Xj)~=nv
      error('Xj must be a cell array with as many entries as variables along grid dimension.')
   end
   ns = cellfun('length',Xj);
   if any(diff(ns))
      error('Number of grid points must be the same for all variables along a grid dimension.')
   end
   % Update grid dimension length
   this.Grid_(ct).Length = this.Grid_(ct).Length + ns(1);
   % Update data for grid variables
   for ctv=1:nv
      c = this.Data_(this.Grid_(ct).Variable(ctv)==AllVars);
      % REVISIT: should automatically convert to cell array when fails
      c.setArray([getArray(c) ; Xj{ctv}(:)]);
   end
end

% Built index locating old grid inside new grid
idx = cell(1,length(oldGridSize));
for ct=1:length(oldGridSize)
   idx{ct} = 1:oldGridSize(ct);
end
newGridSize = [this.Grid_.Length];

% Grow value arrays for dependent values
[junk,idx_dv] = setdiff(AllVars,[this.Grid_.Variable]);
for c=this.Data_(idx_dv)'
   % for each value array
   B = getArray(c);
   if ~isempty(B)
      SampleSize = c.SampleSize;
      is = repmat({':'},[1 length(SampleSize)]);
      if c.GridFirst
         A = hdsNewArray(B,[newGridSize SampleSize]);
         A = hdsSetSlice(A,[idx is],B);
      else
         A = hdsNewArray(B,[SampleSize newGridSize]);
         A = hdsSetSlice(A,[is idx],B);
      end
      c.setArray(A);
   end
end

% Grow link arrays
for ct=1:length(this.Children_)
   c = this.Children_(ct);
   B = c.Links;
   if ~isempty(B)
      % Create array of the right size
      A = cell(newGridSize);
      A(idx{:}) = B;
      c.Links = A;
   end
end

%----------------- Local Functions ------------------------

function NewGridPoints = LocalParseData(this,ArgList)
% Parses argument list and recognize supported syntax
ndims = length(this.Grid_);
nargs = length(ArgList);
if nargs>0 && rem(nargs,2)==0 && ~isempty(findvar(this,ArgList{1}))
   % Syntax ADDGRIDPOINTS(D,VAR1,DATA1,...)
   NewGridPoints = cell(1,ndims);
   for ct=1:2:nargs
      v = findvar(this,ArgList{ct});
      if isempty(v)
         error('Invalid syntax or unknown variable.')
      else
         gdim = locateGridVar(this,v);
         gvars = this.Grid_(gdim).Variable;
         if isempty(gdim)
            error(sprintf('Variable %s does not belong to the grid.',v.Name))
         elseif length(gvars)==1 
            % Single variable along grid dimension
            NewGridPoints{gdim} = ArgList{ct+1};
         else
            % Multiple variables along grid dimension
            if isempty(NewGridPoints{gdim})
               NewGridPoints{gdim} = cell(length(gvars),1);
            end
            NewGridPoints{gdim}{gvars==v} = ArgList{ct+1};
         end
      end
   end
else
   % Syntax ADDGRIDPOINTS(D,X1,X2,..,XN)
   NewGridPoints = ArgList;
   if length(NewGridPoints)~=ndims
      error('Number of arguments does not match number of grid dimensions.')
   end
end
  
   