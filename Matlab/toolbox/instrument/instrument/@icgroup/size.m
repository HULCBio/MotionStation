function varargout = size(obj,varargin)
%SIZE Size of device group object array.  
%
%   D = SIZE(OBJ), for M-by-N device group object, OBJ, returns the
%   two-element row vector D = [M, N] containing the number of rows 
%   and columns in the device group object array, OBJ.  
%
%   [M,N] = SIZE(OBJ) returns the number of rows and columns in separate
%   output variables.  
%
%   [M1,M2,M3,...,MN] = SIZE(OBJ) returns the length of the first N 
%   dimensions of OBJ.
%
%   M = SIZE(OBJ,DIM) returns the length of the dimension specified by the 
%   scalar DIM. For example, SIZE(OBJ,1) returns the number of rows.
% 
%   See also ICGROUP/LENGTH, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:00:20 $

% Error checking.
if (nargin > 1)
    if ~isa(obj, 'icgroup')
        error('icgroup:size:invalidOBJ', 'OBJ must be a device group object.');
    elseif ~isnumeric(varargin{1})
        error('icgroup:size:badopt', 'Unknown command option.');
    end
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
    rethrow(lasterror);
end	


