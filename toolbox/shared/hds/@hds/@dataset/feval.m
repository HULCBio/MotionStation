function y = feval(this,f,varargin)
%FEVAL  Evaluates a function at each grid point.
%
%   Y = D.FEVAL(FCN,ARG1,...,ARGN) evaluates
%   FCN(ARG1,...,ARGN) at each grid point of the 
%   data set D and returns the cell array Y of 
%   function values.  The function arguments can
%   be data set variables (@variable objects)
%   or static values.
%
%   D.FEVAL(FCN,ARG1,...,ARGN,'-output',VAR)
%   writes the result directly into some variable 
%   VAR of the data D.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:21 $

% Look for '-output' flag
idx = find(strcmp(varargin,'-output'));
RedirectOutput = ~isempty(idx);
if RedirectOutput
   arglist = varargin(1:idx-1);
   [OutputVar,isLocalVar] = LocalFindVar(this,varargin{idx+1});
   if isempty(OutputVar)
      error('Variable %s cannot be found or is not accessible to FEVAL.',OutputVar)
   end
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
y = cell(GridSize);

% Evaluate function over grid 
try
   for ct=1:prod(GridSize)
      s = getsample(this,ct,varArgs);
      for ctv=1:nvarargs
         % Robust to repeated variables
         arglist{idxVar(ctv)} = s.(varArgs(ju(ctv)).Name);
      end
      r = feval(f,arglist{:});
      if RedirectOutput && ~isLocalVar
         stmp.(OutputVar) = r;
         setsample(this,ct,stmp)
      else
         y{ct} = r;
      end
   end
catch
   rethrow(lasterror)
end

if RedirectOutput
   if isLocalVar
      % Write result
      this.(OutputVar) = y;
   end
   y = [];
end

%------------------ Local Functions ----------------------

function [v,isLocal] = LocalFindVar(this,OutputVar)
% Locates variable among set of variables visible from the root
v = findvar(this,OutputVar);
isLocal = ~isempty(v);
if ~isLocal
   for c=this.Children_'
      if strcmp(c.Transparency,'on') && ~isempty(c.LinkedVariables)
         v = findvar(c.Links{1},OutputVar);
         if ~isempty(v)
            break
         end
      end
   end
end
if ~isempty(v)
   v = v.Name;
end