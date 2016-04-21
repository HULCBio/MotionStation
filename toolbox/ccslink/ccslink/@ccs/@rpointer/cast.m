function resp = cast(pp,datatype,siz)
%CAST Creates a new object from a pointer object.
%  O = CAST(PP,DATATYPE,SIZ) Created a new object O based on the type
%  information supplied in DATATYPE and re-sizes the new object to size SIZ.
%  The new object created can be another RPOINTER object, a STRUCTURE OBJECT, 
%  or any Memoryobj-derived object (NUMERIC,STRING,ENUM,POINTER).
%
%  O = CAST(PP,DATATYPE) Same as above except O is not re-sized.
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
% 	>> cast(x,'struct mystruct')
% 	??? Error using ==> cast
% 	You cannot cast a register object into a Structure object.
% 	
% 	>> new_obj1  = cast(x,'int')
% 	NUMERIC Object stored in register(s): 
%       Symbol name              : rptr_int
%       Register                 : B4
%       Datatype                 : int
%       Wordsize                 : 32 bits
%       Register units per value : 1 ru
%       Representation           : signed
%       Size                     : [ 1 ]
%       Total register units     : 1 ru
%       Array ordering           : row-major
% 	
% 	>> new_obj2  = cast(x,'enum CC_RSTAT')
% 	ENUM Object stored in register(s):
%       Symbol name              : rptr_int
%       Register                 : B4
%       Wordsize                 : 32 bits
%       Register units per value : 1 ru
%       Representation           : signed
%       Size                     : [ 1 ]
%       Total register units     : 1 ru
%       Array ordering           : row-major
%       Labels & values          : CC_OK=0, CC_ERR=1, CC_WARN=2
% 
%  See also CONVERT, COPY.

% Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:11:53 $

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
    elseif strcmp(eqvType.uclass,'structure')
        errId = generateccsmsgid('Cast2StructObjNotAllowed');
        error(errId,'You cannot cast a register object into a Structure object.');
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
newobj = ccs.rnumeric;
pointerProps = get(pp);
for prop=fieldnames(pointerProps)'
    if strcmp('typestring',prop) % this list should also include 'represent','wordsize','binarypt'
        continue;
    else
        setprop(newobj,prop{1},pointerProps.(prop{1}));
    end
end
setprop(newobj,'procsubfamily',getprop(pp,'procsubfamily'));
setprop(newobj,'regid',getprop(pp,'regid'));
convert(newobj,datatype); % properties 'represent','wordsize','binarypt' are overwritten

%------------------------------------
function newobj = CreateNewObject(pp,datatype)
if ~strcmp(datatype.uclass(1),'r')
    datatype.uclass = ['r' datatype.uclass]; % inherit uclass
end
datatype = parser_wrapper(pp.link,datatype);
datatype.regname = pp.regname; % inherit regname
datatype.regid   = pp.regid; % inherit regid
datatype.size    = pp.size; % inherit size
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