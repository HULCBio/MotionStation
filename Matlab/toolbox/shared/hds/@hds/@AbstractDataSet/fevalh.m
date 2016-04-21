function yout = fevalh(this,f,varargin)
%FEVALH  Evaluates homogenous function at each grid point.
%
%   Y = D.FEVALH(FCN,ARG1,...,ARGN) evaluates
%   FCN(ARG1,...,ARGN) at each grid point of the 
%   data set D and returns an array Y of function 
%   values.  The function FCN is required to 
%   produce values of the same class and size at
%   each grid point.  The function arguments can
%   be data set variables (@variable objects)
%   or static values.
%
%   D.FEVALH(FCN,ARG1,...,ARGN,'-output',VAR)
%   writes the result directly into some variable 
%   VAR of the data D.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:59 $

% Look for '-output' flag
idx = find(strcmp(varargin,'-output'));
RedirectOutput = ~isempty(idx);
if RedirectOutput
   arglist = varargin(1:idx-1);
   var = varargin{idx+1};
   % RE: Restricted to node variable
   OutputVar = findvar(this,var);
   if isempty(OutputVar)
      if ~isa(var,'char')
         var = var.Name;
      end
      error('Variable %s cannot be found or is not accessible to FEVALH.',var)
   end
   OutputVarName = OutputVar.Name;
   ValueArray = find(this.Data_,'Variable',OutputVar);
else
   arglist = varargin;
end

% Collect list of variables
nargs = length(arglist);
isVar = false(1,nargs);
for ct=1:nargs
   isVar(ct) = isa(arglist{ct},'hds.variable');
end
idxVar = find(isVar);
nvarargs = length(idxVar);
[varArgs,junk,ju] = unique(cat(1,arglist{idxVar}));

% Grid size
GridSize = getGridSize(this);
Ns = prod(GridSize);
GridFirst = ~RedirectOutput || ValueArray.GridFirst;

% Evaluate first sample and initialize output
s = getsample(this,1,varArgs);
for ctv=1:nvarargs
   % Robust to repeated variables
   arglist{idxVar(ctv)} = s.(varArgs(ju(ctv)).Name);
end
r = feval(f,arglist{:});
SampleSize = size(r);
if GridFirst
   y = hdsNewArray(r,[Ns SampleSize]);
else
   y = hdsNewArray(r,[SampleSize Ns]);
end

% Evaluate function over grid 
ind(:,1:length(SampleSize)) = {':'};
try
   for ct=1:prod(GridSize)
      if ct>1
         s = getsample(this,ct,varArgs);
         for ctv=1:nvarargs
            % Robust to repeated variables
            arglist{idxVar(ctv)} = s.(varArgs(ju(ctv)).Name);
         end
         r = feval(f,arglist{:});
         if ~isequal(size(r),SampleSize)
            error('Function values must have uniform size over the entire grid.')
         end
      end
      if GridFirst
         y = hdsSetSlice(y,[{ct} ind],r);
      else
         y = hdsSetSlice(y,[ind {ct}],r);
      end
   end
catch
   rethrow(lasterror)
end

% Reshape array
if GridFirst
   y = hdsReshapeArray(y,[GridSize SampleSize]);
else
   y = hdsReshapeArray(y,[SampleSize GridSize]);
end

if RedirectOutput
   % Write result
   ValueArray.SampleSize = SampleSize;
   ValueArray.setArray(y);
else
   yout = y;
end
