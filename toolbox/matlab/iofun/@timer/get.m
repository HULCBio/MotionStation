function output = get(obj,varargin)
%GET Get timer object properties.
%
%    GET(OBJ) displays all property names and their current values for
%    timer object OBJ.
%
%    V = GET(OBJ) returns a structure, V, where each field name is the
%    name of a property of OBJ and each field contains the value of that 
%    property.
%
%    V = GET(OBJ,'PropertyName') returns the value, V, of the specified 
%    property, PropertyName, for timer object OBJ. 
%
%    If PropertyName is a 1-by-N or N-by-1 cell array of strings 
%    containing property names, GET returns a 1-by-N cell array
%    of values. If OBJ is a vector of timer objects, V is an 
%    M-by-N cell array of property values where M is equal to the length
%    of OBJ and N is equal to the number of properties specified.
%
%    Example:
%       t = timer
%       get(t, {'StartDelay','Period'})
%       out = get(t, 'UserData')
%       get(t)
%
%    See also TIMER, TIMER/SET.
%

%    RDD 11-20-2001
%    Copyright 2001-2003 The MathWorks, Inc.
%    $Revision: 1.2.4.2 $  $Date: 2004/03/30 13:07:23 $

if ~isa(obj,'timer')
    builtin('get',obj,varargin{:})
end
    
% if given at least one invalid object, pail out now with error.
if ~all(isvalid(obj))
    error('MATLAB:timer:invalid',timererror('MATLAB:timer:invalid'));
end


if ((nargout == 0) && (nargin == 1)) % e.g., "get(OBJ)"
    if (length(obj)>1) % OBJ is not a singleton object - error
        error('MATLAB:timer:nolhswithvector',timererror('MATLAB:timer:nolhswithvector'));
    end
    try % display the builtin get's output
        out = get(obj.jobject);
        disp(out);
    catch % rethrow error from builtin get function
        lerr = fixlasterr;
        error(lerr{:});
    end
else % "r=get(t)" or "get(t,'PN',...)"
    try % calling builtin get
        output = get(obj.jobject, varargin{:}); 
    catch
        lerr = fixlasterr;
        error(lerr{:});
    end
end
