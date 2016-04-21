function obj = getoutput(ff)
% GETOUTPUT. Returns the function's output object.
%  outputObj = GETOUTPUT(ff) Returns the output object outputObj associated with the 
%  function's return value. If the return value is 'void', outputObj is empty.
%
%  Note: outputObj can be also accessed through 
%         outputObj = ff.outputvar
%
%  For example,
%  CCS:  int foo(int _a, int b);  /* return value is of type 'int' */
%  MATLAB:
%  ff = createobj(cc,'foo');
%  outputobj = getoutput(cc)  % Method 1: gives the correct output object
%  outputobj = ff.outputvar   % Method 2: gives the correct output object through direct access
% 
%  See also GETINPUT, GET.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/11/30 23:08:25 $

error(nargchk(1,1,nargin));

if ~ishandle(ff),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a valid FUNCTION handle. ');
end

% Output object must exist first before attempting to return it
if isempty(ff.outputvar) && ~strcmp(ff.type,'void') % not created
    error(generateccsmsgid('CannotAccessOutput'),['Cannot return the output object, it is not yet created. ']);
end

% Return the input requested
obj = ff.outputvar;

% [EOF] getoutput.m