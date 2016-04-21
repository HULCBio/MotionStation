function varargout = size(obj,varargin)
%SIZE Size of timer object array.  
%
%    D = SIZE(OBJ), for M-by-N timer object array, OBJ, returns  
%    the two-element row vector D = [M, N] containing the number of 
%    rows and columns in the timer object array, OBJ.  
%
%    [M,N] = SIZE(OBJ) returns the number of rows and columns in separate
%    output variables.  
%
%    [M1,M2,M3,...,MN] = SIZE(OBJ) returns the length of the first N 
%    dimensions of OBJ.
%
%    M = SIZE(OBJ,DIM) returns the length of the dimension specified by 
%    the scalar DIM. For example, SIZE(OBJ,1) returns the number of rows.
% 
%    See also TIMER/LENGTH.
%

%    RDD 1/8/2002
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.2 $  $Date: 2002/03/14 14:34:52 $

% Error checking.
if ~isa(obj, 'timer')
    error('MATLAB:timer:noTimerObj',timererror('MATLAB:timer:noTimerObj'));
end

% Determine the number of output arguments.
numOut = nargout;
if (numOut == 0)
    % If zero output modify to 1 (ans) so that the expression below
    % evaluates without error.
    numOut = 1;
end

% Call the builtin size function on the java object.  The jobject field
% of the object indicates the number of objects that are concatenated
% together.
try
    [varargout{1:numOut}] = builtin('size', obj.jobject, varargin{:});
 catch
    lerr = fixlasterr;
    error(lerr{:});
end	
