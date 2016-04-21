function resp = cast(pp,datatype,siz)
%CAST Creates a new object from a pointer object.
%  O = CAST(PP,DATATYPE,SIZ) Created a new object O based on the type
%  information supplied in DATATYPE and re-sizes the new object to size SIZ.
%  The new object created can be another POINTER object, a STRUCTURE OBJECT, 
%  or any Memoryobj-derived object (NUMERIC,STRING,ENUM,POINTER).
%
%  O = CAST(PP,DATATYPE) Same as above except O is not re-sized.
%
%  Example:
%  >> x = createobj(cc,'st_ptr')
% 		POINTER Object stored in memory: 
%           Symbol name             : st_ptr
%           Address                 : [ 2147502192 0]
%           Wordsize                : 32 bits
%           Address units per value : 4 au
%           Representation          : unsigned
%           Size                    : [ 1 ]
%           Total address units     : 4 au
%           Array ordering          : row-major
%           Endianness              : little
%           Pointer datatype        : struct mystruct2 *
% 	
%  >> new_obj  = cast(x,'struct mystruct')
% 		STRUCTURE Object stored in memory: 
%           Symbol name             : st_ptr
%           Address                 : [ 2147502192 0]
%           Address units per value : 40 au
%           Size                    : [ 1 ]
%           Total Address Units     : 40 au
%           Array ordering          : row-major 
%           Members                 : 'a', 'b', 'c', 'd', '_a', '_b'
% 	
%  >> new_obj2  = cast(x,'int')
% 		NUMERIC Object stored in memory: 
%           Symbol name             : st_ptr
%           Address                 : [ 2147502192 0]
%           Datatype                : int
%           Wordsize                : 32 bits
%           Address units per value : 4 au
%           Representation          : signed
%           Size                    : [ 1 ]
%           Total address units     : 4 au
%           Array ordering          : row-major
%           Endianness              : little
% 
%  See also CONVERT, COPY.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2003/11/30 23:10:17 $

error(nargchk(2,3,nargin));
if ~ishandle(pp),
    errId = generateccsmsgid('InvalidHandle');
    error(errId,'First parameter must be a valid POINTER handle.');
end

% Check data type input if valid
if ~ischar(datatype)
    errId = generateccsmsgid('InvalidInput');
    error(errId,'Second parameter must be a string.');
end

% Check input siz if valid
if nargin==3
    siz = p_checkerforsize(pp,siz);
else
    siz = [];
end

% Create a new object
if p_check_type(pp,datatype)   
    % Input datatype is of a numeric type. Therefore, a numeric class
    % object will be created.
    resp = CreateNewNumericObject(pp,datatype); % create a new numeric object
else
    % Use parser to decode type info in 'datatype'
    eqvType = ParseDataType(pp,datatype);
    
    % Create new type
    if strcmp(eqvType.uclass,'pointer')
        % Datatype is a pointer. Therefore, new pointer will only have a different referent.
        resp = CreateNewPointerObject(pp,eqvType);
    elseif strcmp(eqvType.uclass(1),'r')
        errId = generateccsmsgid('Cast2RegObjNotAllowed');
        error(errId,'You cannot cast a memory object into any register-derived object.');
    else
        % Input datatype is a non-pointer non-numeric type (enum, string).
        % Therefore, create the appropriate object.
        resp = CreateNewObject(pp,eqvType);
    end
end

% Reshape new object
reshape(resp,siz);
  
%---------------------------------------
% Create a new pointer that is a copy of pp but has a different referent
function newobj = CreateNewPointerObject(pp,datatype)
newobj = copy(pp);
setprop(newobj,'referent',datatype.referent);
setprop(newobj,'reftype',datatype.type);
setprop(newobj,'typestring',datatype.type);

%---------------------------------------
% Create a new numeric object
function newobj = CreateNewNumericObject(pp,datatype)
newobj = ccs.numeric;
pointerProps = get(pp);
for prop=fieldnames(pointerProps)'
    if strcmp('typestring',prop) % this list should also include 'represent','wordsize','binarypt'
        continue;
    else
        setprop(newobj,prop{1},pointerProps.(prop{1}));
    end
end
setprop(newobj,'procsubfamily',getprop(pp,'procsubfamily'));
setprop(newobj,'maxaddress',getprop(pp,'maxaddress'));
convert(newobj,datatype); % properties 'represent','wordsize','binarypt' are overwritten

%------------------------------------
function newobj = CreateNewObject(pp,datatype)
datatype = parser_wrapper(pp.link,datatype);
datatype.address = pp.address; % inherit address
datatype.size = pp.size; % inherit size
newobj = createobj(pp.link,datatype);

%---------------------------------------
function eqvType = ParseDataType(pp,datatype)
% Use parser to decode type info in 'datatype'
try 
    eqvType = parse(pp.link.type,datatype);
catch
    errId = generateccsmsgid('DataTypeSyntaxError');
    error(errId,sprintf(['A problem occurred while parsing the datatype you supplied:\n',lasterr]));
end

% [EOF] cast.m