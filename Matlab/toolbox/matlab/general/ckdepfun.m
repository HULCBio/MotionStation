function [pmissing,pdata,depfun_success] = ckdepfun(funct,varargin)
%CKDEPFUN	runs the function specified by the function pointer FUNCT
%    with arguments VARARGIN. Determines the new functions loaded into memory
%    using 'inmem' and resolves them to files using 'which'. Runs the
%    function through depfun and returns the list of resolved files.
%    Using the two lists of data it returns PMISSING a cell array of files
%    required for execution but not found by depfun and a structure PDATA
%    with the following fields:
%
%      .common		- cell array of files in both lists
%      .depfun_only	- cell array files in the depfun list only.
%
%    IMPORTANT: This tool provides a necessary check for the correctness
%               of depfun, NOT a sufficiency check. Just because it passes
%               doesn't mean depfun is correct!
%
%    Limitations:
%
%    1. 'inmem' does not show builtins.
%    2. MEX files are not currently unloaded. So they will show up only
%       on the first call to this routine. Later calls to this routine
%       will show them to be missing since they will be in the mex list
%       before and after the call to the function.
%
%    Example(s),
%
%       pmissing = ckdepfun(@eig,[1 0; 0 1]);
%       pmissing = ckdepfun(@depfun,'depfun');
%
%    See also CKDEPFUN

%    Copyright (c) 1984-2004 by The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/01/28 23:10:52 $
%-----------------------------------------------------------------------------

arg_error = nargchk(1,inf,nargin);
if ~isempty(arg_error)
   error('MATLAB:CKDEPFUN:NumberOfInputArguments',arg_error);
end
if ~isa(funct,'function_handle')
  error('MATLAB:CKDEPFUN:NotAFunctionHandle','First argument must be a valid function handle.');
end

% Do the best we can to clear any 'unused' function from the inmem list.
% MEX files cannot be cleared.
%
clear functions

[fn,mx] = inmem;
fprintf('-> executing %s . . .\n',func2str(funct));
funct(varargin{:});
[fn2,mx2] = inmem;
fnd = setdiff(fn2,fn);
mxd = setdiff(mx2,mx);
[px] = resolve_name(fnd,mxd);
fprintf('-> executing depfun(%s) . . .\n',func2str(funct));
p = depfun(func2str(funct));
fprintf('-> finding differences . . .\n');
if ~isempty(p)
  pmissing = setdiff(px,p);
  pdata.common = intersect(px,p);
  pdata.depfun_only = setdiff(p,px);
  fprintf('%5d missing files . . .\n',length(pmissing));
else
  fprintf('-> depfun failed . . .\n');
  pmissing = px;
  pdata.common = {};
  pdata.depfun_only = {};
end

%-----------------------------------------------------------------------------
function p = resolve_name(fn,mx)
%RESOLVE_NAME	resolves functions M/P-file names FN and MEX-file names
%   MX to files that are returned in the cell array P.
%
%   Questions:
%
%   1. What about UDD paths?
%
%   WATCH OUT: i and j are builtins. If you happen to use them as loop
%              indicies, which will return not a path, but the string
%              'variable'. This should only happen in the function
%	       list FN.
%
%              In those cases, I will simple include the .bi (builtin)
%	       file.

p = {};
len = length(fn) + length(mx);
if len > 0
  n = 0; 
  p = cell(len,1); [p{:}] = deal('');
  for i = 1:length(fn)
    pw = which(fn{i});
    if isempty(pw)
      fprintf('-> which could not resolve inmem path: path = %s\n',fn{i});
    elseif strcmp(pw,'variable')
      pw = which([fn{i} '.bi']);
      n = n + 1;
      p{n} = pw;
    else
      n = n + 1;
      p{n} = pw;
    end
  end
  for i = 1:length(mx)
    pw = which(mx{i});
    if isempty(pw)
      fprintf('-> which could not resolve inmem path: path = %s\n',mx{i});
    else
      n = n + 1;
      p{n} = pw;
    end
  end

  % Squeeze out any blank entries at the end.
  % 
  p = p(1:n);
end
%-----------------------------------------------------------------------------
