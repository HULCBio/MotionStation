function pp = convert(pp,datatype,size)
%CONVERT Converts a register-pointer object to another register-pointer object 
%  with a different referent.
%  CONVERT(PP,DATATYPE,SIZ) Converts the pointer object PP into another
%  pointer with a different referent. The new referent is created based on 
%  the type information supplied in DATATYPE. This operation also re-sizes 
%  the object to size SIZ.
%
%  CONVERT(PP,DATATYPE) Same as above except PP is not re-sized.
%
%  Example:
% 	>> x = createobj(cc,'rptr_int')
% 	POINTER Object stored in register(s):
%       Symbol name              : rptr_int
%       Register                 : B4
%       Wordsize                 : 32 bits
%       Register units per value : 1 ru
%       Representation           : unsigned
%       Size                     : [ 1 ]
%       Total register units     : 1 ru
%       Array ordering           : row-major
%       Pointer datatype         : int *
% 	
% 	>>  convert(x,'Int **')
% 	POINTER Object stored in register(s):
%       Symbol name              : rptr_int
%       Register                 : B4
%       Wordsize                 : 32 bits
%       Register units per value : 1 ru
%       Representation           : unsigned
%       Size                     : [ 1 ]
%       Total register units     : 1 ru
%       Array ordering           : row-major
%       Pointer datatype         : Int * *
% 	
% 	>> convert(x,'struct mystruct *')
% 	POINTER Object stored in register(s):
%       Symbol name              : rptr_int
%       Register                 : B4
%       Wordsize                 : 32 bits
%       Register units per value : 1 ru
%       Representation           : unsigned
%       Size                     : [ 1 ]
%       Total register units     : 1 ru
%       Array ordering           : row-major
%       Pointer datatype         : struct mystruct *
%
%  See also CAST, COPY.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:11:55 $

error(nargchk(2,3,nargin));
if ~ishandle(pp),
    errId = generateccsmsgid('InvalidHandle');
    error(errId,'First parameter must be a valid RPOINTER handle.');
end

% Check input siz if valid
if nargin==3
    siz = p_checkerforsize(pp,siz);
else
    siz = [];
end

% Convert object into a new pointer type (different referent)
if p_check_type(pp,datatype) % converting to numeric?
    errId = generateccsmsgid('InvalidConvert');
    error(errId,'Pointer objects cannot be converted to any type other than pointer types.');
else
    % Use parser to decode type info in 'datatype'
    eqvType = ParseDataType(pp,datatype);

    % Convert to new pointer type
    if strcmp(eqvType.uclass,'pointer')
        % Datatype is a pointer. Therefore, new pointer will only have a different referent.
        ConvertToNewPointerObject(pp,eqvType);
    else
        errId = generateccsmsgid('InvalidConvert');
        error(errId,'Pointer objects cannot be converted to any type other than pointer types.');
    end
end

% Reshape new object
reshape(pp,siz);
  
%---------------------------------------
% Create a new pointer that is a copy of pp but has a different referent
function ConvertToNewPointerObject(pp,datatype)
setprop(pp,'referent',datatype.referent);
setprop(pp,'reftype',datatype.type);
setprop(pp,'typestring',datatype.type);

%---------------------------------------
function eqvType = ParseDataType(pp,datatype)
% Use parser to decode type info in 'datatype'
try 
    eqvType = parse(pp.link.type,datatype);
catch
    errId = generateccsmsgid('DataTypeSyntaxError');
    error(errId,sprintf(['A problem occurred while parsing the datatype you supplied:\n',lasterr]));
end

% [EOF] convert.m