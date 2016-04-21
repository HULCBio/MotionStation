function symbobj = createobj(cc,sname,opt,varargin)
% CREATEOBJ Creates a link to an embedded symbol.
% 	O = CREATEOBJ(CC,SYMBOL) - returns an object handle O to the embedded
% 	symbol SYMBOL. SYMBOL can be any variable name or function name. By
% 	default, the embedded variable within scope is created. 
% 	
% 	O = CREATEOBJ(CC,SYMBOL,OPT) - returns an object handle O to the
% 	embedded symbol SYMBOL, the scope of which is specified by OPT. OPT can
% 	be 'local', 'global' or 'static'. OPT can also be 'function' - see more
% 	information below. 
% 	
% 	Depending on the type and storage device of the symbol, object O
% 	created can be fall on any of four major object classes:
% 	
% 	I.  MEMORYOBJ
%         Any symbol that resides in the DSP memory.
%         
%         Derived Classes:
% 		1.  NUMERIC class       -       handle to a primitive data type (float,int,short,...)
%             
%           Derived Classes:
% 			a.  POINTER class   -       handle to a pointer data type (unsigned int)
% 			b.  ENUM class      -       handle to an enumerated data type (int)
% 			c.  STRING class    -       handle to a string data type (char)
%             
% 		2.  BITFIELD class      -       handle to a bitfield data type
% 	
% 	II. REGISTEROBJ
%         Any symbol that resides in a DSP register.
%         
%         Derived Class
% 		  RNUMERIC class        -       handle to a primitive data type (float,int,short,...)
%             
%           Derived Classes:
% 			a.  RPOINTER class  -       handle to a pointer data type (unsigned int)
% 			b.  RENUM class     -       handle to an enumerated data type (int)
% 			c.  RSTRING class   -       handle to a string data type (char)
%             
% 	III.STRUCTURE
% 		Container class for MEMORYOBJ and/or REGISTEROBJ objects.
%         - C struct type
%         - C union type.
% 	
% 	IV. FUNCTION
% 		Any C-callable functions.
%
% 	    O = CREATEOBJ(CC,SYMBOL,'function',OPT1,VALUE1,...) - Creates a
% 	    Function handle, where OPTn can be 'funcdecl', 'filename',
% 	    'allocate'.
%
%       OPTION          VALUE
%       'funcdecl'      C function declaration (string)
%       'filename'      File where function definition is found (string)
%       'allocate'      Cell array containing name of pointer input as the 1st element 
%                       and size of buffer the input points to as the 2nd element
%       Example:
%       ff = createobj(cc,'foo','function','funcdecl','int foo(int *a, int *b, short n)')
%       ff = createobj(cc,'foo','function','filename','c:\MATLAB6p5\work\FilterFFT.c')
%       - constructor uses this information to set I/O properties of the
%       Function object
%
%       ff = createobj(cc,'foo','function','allocate',{'a',5},'allocate',{'b',10})
%       - constructor allocates for inputs 'a' and 'b' each a buffer of size 5 (elements) 
%       on the stack
%
% 	See also LIST.

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.16.2.5 $ $Date: 2004/04/06 01:04:43 $

error(nargchk(2,nargin,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    error(generateccsmsgid('InvalidHandle'),'First parameter must be a valid CCSDSP handle.');
end
if ~ischar(sname) && ~isstruct(sname)
    error(generateccsmsgid('InvalidInput'),'Second parameter must be a string.');
end

if nargin==2 && isstruct(sname) % Private use. % Used for dereferencing pointers, on @function/createinput, on @function/createoutput 
    si = sname; % SNAME is a structure for creating an object. 
else
	% Used for creating objects from symbol name
    if nargin==2,  
        opt = 'local';  args=[]; 
    else
        args = varargin;
    end
    si = GetSymbolInformation(cc,sname,opt,args);
    si.c28xbugcheck = 1;
end

si = checkIfRecursivePointer(si); % If symbol is a structure, check if it is recursive (pts to itself)
symbobj = dispatch(cc,si); % Create object from info - si

C55xBugCheck(symbobj);

% ----------------------------------------------------------------------------
function symtab = dispatch(cc,si),

% Check if UDD class is valid/supported
uci = strmatch(si.uclass,{  
        'numeric'   ,'pointer'   ,'enum'   ,'bitfield'  ,'string'  , ...
        'rnumeric'  ,'rpointer'  ,'renum'  ,'rbitfield' ,'rstring' , ...
        'structure' ,'union'     , ...
        'function'  , ...
        'reference'   ...
        }, 'exact');

if isempty(uci),
    warning(['Unsupported symbol type: ' si.uclass ]);
    symtab = [];
    return;
end

% Add more info to SI
si = SetEmptyName(si);
[uci,si] = CheckIfChar(uci,si);
[si,bitspersu,r_bitspersu,storeunitperval] = SetProcSpecificValues(cc,si);
si = SetEndianValue(info(cc),si);

C28xBugCheck(si);

% Call constructor
switch uci
   
% MEMORY OBJECTS -------------------------------------------------

case 1,  % numeric (->memoryobj)
    % by default, treat char as C strings.
    symtab = ccs.numeric(  'name'               ,si.name, ...
                           'address'            ,si.address, ...
                           'size'               ,si.size, ...  
                           'bitsperstorageunit' ,bitspersu, ...  
                           'endianness'         ,si.dspendian, ...  
                           'timeout'            ,cc.timeout, ...  
                           'procsubfamily'      ,si.procsubfamily, ...
                           'link'               ,cc);
    convert(symtab,si.type);
    
case 2,  % pointer (->numeric->memoryobj)
    si = PreprocessInputs('pointer',si);
    symtab = ccs.pointer(  'name'                   ,si.name, ...
                           'address'                ,si.address, ...
                           'size'                   ,si.size, ...  
                           'bitsperstorageunit'     ,bitspersu, ...  
                           'endianness'             ,si.dspendian, ...  
                           'timeout'                ,cc.timeout, ...  
                           'procsubfamily'          ,si.procsubfamily, ...
                           'storageunitspervalue'   ,storeunitperval, ...       
                           'reftype'                ,si.type, ...
                           'isrecursive'            ,si.member_pts_to_same_struct, ...
                           'referent'               ,si.referent, ...
                           'objectdata'             ,si.objectdata, ...
                           'link'                   ,cc);
    
case 3,  % enumerated type (->numeric->memoryobj)
    symtab = ccs.enum(    'name'                ,si.name, ...
                          'label'               ,si.label, ...
						  'value'               ,si.value, ...
						  'address'             ,si.address, ...  
						  'size'                ,si.size, ...  
						  'bitsperstorageunit'  ,bitspersu, ...  
						  'endianness'          ,si.dspendian, ...  
                          'procsubfamily'       ,si.procsubfamily, ...
						  'timeout'             ,cc.timeout, ...
						  'link'                ,cc);
  
case 4,  % bitfield (-> memoryobj)
    symtab = ccs.bitfield( 'name'               ,si.name, ...
                           'address'            ,si.address, ... 
                           'endianness'         ,si.dspendian, ...
                           'location'           ,si.bitinfo, ...
                           'size'               ,1, ...
                           'procsubfamily'      ,si.procsubfamily, ...
                           'timeout'            ,cc.timeout, ...
                           'link'               ,cc);
	convert(symtab,si.type);

case 5,  % string (-> numeric -> memoryobj )
    symtab = ccs.string(  'name'                ,si.name, ...
						  'address'             ,si.address, ...
						  'size'                ,si.size, ...  
						  'bitsperstorageunit'  ,bitspersu, ...  
						  'endianness'          ,si.dspendian, ...  
                          'procsubfamily'       ,si.procsubfamily, ...
						  'timeout'             ,cc.timeout, ...
						  'link'                ,cc);
	convert(symtab,si.type);
                      
% REGISTER OBJECTS -------------------------------------------------

case 6, % rnumeric (->registerobj)
    symtab = ccs.rnumeric( ...
                           'link'               ,cc, ...
                           'procsubfamily'      ,si.procsubfamily, ...
                           'bitsperstorageunit' ,r_bitspersu, ...  
                           'name'               ,si.name, ...
                           'reginfo'            ,si.location, ...
                           'size'               ,si.size, ...  
                           'endianness'         ,si.dspendian, ...  
                           'timeout'            ,cc.timeout ...  
                       );

    if strcmp(si.procsubfamily,'C55x') && symtab.wordsize<=16,
        cast_C55x(symtab,si.type,1);
    else
        convert(symtab,si.type);
    end
    AssignRegisterNameAndId(symtab,si);
                      
case 7, % rpointer (->rnumeric->registerobj)
    si = PreprocessInputs('rpointer',si);
    symtab = ccs.rpointer( ...
                           'link'                ,cc, ...
                           'reginfo'             ,si.location,  ...
                           'procsubfamily'       ,si.procsubfamily, ...
                           'name'                ,si.name,      ...
                           'endianness'          ,si.dspendian, ...
                           'bitsperstorageunit'  ,r_bitspersu,  ...
                           'size'                ,si.size,      ...
                           'storageunitspervalue',1,            ...       
                           'timeout'             ,cc.timeout,   ...
                           'reftype'             ,si.type, ...
                           'isrecursive'         ,si.member_pts_to_same_struct, ...
                           'objectdata'          ,si.objectdata, ...
                           'referent'            ,si.referent ...
                        );
    AssignRegisterNameAndId(symtab,si);
    
case 8, % renum (->rnumeric->registerobj)
    symtab = ccs.renum(   ...
                          'link'                ,cc, ...
                          'name'                ,si.name, ...
                          'label'               ,si.label, ...
						  'value'               ,si.value, ...
						  'size'                ,si.size, ...  
						  'bitsperstorageunit'  ,r_bitspersu, ...  
						  'endianness'          ,si.dspendian, ...  
                          'reginfo'             ,si.location, ...
                           'procsubfamily'      ,si.procsubfamily, ...
                          'storageunitspervalue',1, ...
                          'timeout'             ,cc.timeout ...
                    );
    AssignRegisterNameAndId(symtab,si);

case 9, % rbitfield
	error('Register bit field is not supported. ');

case 10, % rstring (-> rnumeric -> registerobj )
    symtab = ccs.rstring(  ... 
                           'link'               ,cc,                ...
                           'name'               ,si.name,           ...
                           'reginfo'            ,si.location,       ...
                           'size'               ,si.size,           ...  
                           'bitsperstorageunit' ,r_bitspersu,       ... 
                           'endianness'         ,si.dspendian,      ...  
                           'timeout'            ,cc.timeout,        ...  
                           'procsubfamily'      ,si.procsubfamily   ...
                       );
    AssignRegisterNameAndId(symtab,si);
  	convert(symtab,si.type);

% STRUCTURE OBJECT ---------------------------------------
                     
case {11,12},  % struct/union (Container Class)
    % First create containerobj class for all struct/union inputs
    container = ccs.containerobj(   'containerobj_address'      ,si.address, ...
                                    'containerobj_membinfo'     ,si.members, ...
                                    'containerobj_link'         ,cc);                            
    % Create structure class, assign 'container' to 'member'
    symtab = ccs.structure( ...
                        'name'                  ,si.name, ...
                        'address'               ,si.address, ...  
                        'size'                  ,si.size, ...  
                        'storageunitspervalue'  ,si.sizeof, ...  
                        'member'                ,container, ...
                        'link'                  ,cc);

% FUNCTION OBJECT ---------------------------------------

case 13,  % function
    if si.islibfunc,
        if ~isfield(si,'funcdecl')
            si.funcdecl = '';
        end
        if ~isfield(si,'filename')
            si.filename = '';
        end
        si = initialize_stackallocation(si);
        symtab = ccs.function( ...
                          'procsubfamily',si.procsubfamily, ...
                          'name'         ,si.name, ...
                          'uclass'       ,si.uclass, ...
                          'islibfunc'    ,si.islibfunc, ...
                          'filename'     ,si.filename, ...
                          'stackallocation', si.stackallocation, ...
                          'funcdecl'     ,si.funcdecl, ...
                          'timeout'      ,cc.timeout, ...
                          'link'         ,cc, ...
                          'funcinfo'     ,si.funcinfo);

		AssignOtherProps(symtab,si);
  else
        if ~isfield(si,'funcdecl') || isempty(si.funcdecl)
        si.funcdecl = p_extract_funcdecl(cc,si.filename,si.linepos(1));
        end
        si = initialize_stackallocation(si);
        si.address = struct('start',si.address.start,'end',si.address.end);
        symtab = createFunctionClass(cc.ccsversion,cc,si);
    end    

    % note: 'funcinfo' is deliberately placed at the end of constructor to 
    % ensure no error (constructor uses funcinfo together with 'islibfunc' & 'link' properties
                         
% ------------------------------------------------------------

case 14, % reference
    error('Reference is not supported. ');
    
otherwise,
    error(['Symbol type:''' symi.uclass ''' is not supported']);
end

% ------------------------------------------------------------
function si = checkIfRecursivePointer(si)
if ~isempty(strmatch(si.uclass,{'pointer','rpointer'},'exact'))
    if ~isfield(si,'member_pts_to_same_struct')
        si.member_pts_to_same_struct = 0;
    end
    return;
elseif ~strcmp(si.uclass,'structure'),
    return;
end
member_names = cell( fieldnames(si.members)' );
for name = member_names,
    if strcmp(si.members.(name{1}).uclass,'pointer') & si.members.(name{1}).member_pts_to_same_struct>0,
        ptr_indicator = si.members.(name{1}).member_pts_to_same_struct;
        if ptr_indicator==1, % members points to same struct
            si.members.(name{1}).referent = si;
        elseif ptr_indicator==2, % members is a ptr to a ptr to same struct (eg. struct **)
            ref = struct(   ...
                'name','',...
                'size',1,...
                'location',[],...
                'address',[],...
                'uclass','pointer',...
                'type',si.members.(name{1}).reftype,...
                'bitsize',si.members.(name{1}).bitsize,...
                'reftype',GetRefType(si.members.(name{1}).reftype),...
                'referent',si,...
                'member_pts_to_same_struct',1 );
            si.members.(name{1}).referent = ref;         
        else
            % do nothing
        end
    end
end

%-----------------------------------
function reftype = GetRefType(type)
astx = findstr('*',type);
if ~isempty(astx)
    reftype = p_deblank( type(1:astx(end)-1) );
end
%--------------------------------------
function [uci,si] = CheckIfChar(uci,si)
if uci==1 && any(findstr(lower(si.type),'char')), % numeric
    uci = 5;
    si.uclass = 'string';
elseif uci==6 && any(findstr(lower(si.type),'char')), % rnumeric
    uci = 10;
    si.uclass = 'rstring';
end
%----------------------------------------
function [si,bitspersu,r_bitspersu,storeunitperval] = SetProcSpecificValues(cc,si)
ccinfo = info(cc);
family      = ccinfo.family;
subfamily   = ccinfo.subfamily;
revfamily   = ccinfo.revfamily;

errid = generateccsmsgid('ProcNotSupported');
if family == 470  %ARM Processor (R1x or R2x)
    procsubfamily = 'Rxx';
    if strcmp(si.uclass,'function')
        error(errid,['Creating objects for ' procsubfamily ' embedded functions is not supported.']);
    end
    if subfamily == 1
        si.procsubfamily   = 'R1x';
        bitspersu       = 8;
        r_bitspersu     = 32;
        storeunitperval = 4;
    elseif subfamily == 2
        si.procsubfamily   = 'R2x';
        bitspersu       = 8;
        r_bitspersu     = 32;
        storeunitperval = 4;
    else
        error(errid,['Creating objects for ' procsubfamily ' embedded symbols is not supported.']);
    end       
else % the 320 family
    if subfamily>=112,
        procsubfamily = ['C' dec2hex(subfamily) 'x'];
        error(['Processor ' procsubfamily 'x is not supported.']);
    elseif subfamily>=96, % C6xx
        si.procsubfamily   = 'C6x';
        bitspersu       = 8;
        r_bitspersu     = 32;
        storeunitperval = 4;
    elseif subfamily==84, % C54x
        si.procsubfamily  = 'C54x';
        bitspersu       = 16;
        r_bitspersu     = 16;
        storeunitperval = 1;
    elseif subfamily==85, % C55x
        if strcmp(si.uclass,'function')
            error(errid,'Creating objects for C55x embedded functions is not supported.');
        end
        si.procsubfamily  = 'C55x';
        bitspersu       = 16;
        r_bitspersu     = 16;
        storeunitperval = 1;
    elseif subfamily==40, % C28x
        si.procsubfamily  = 'C28x';
        bitspersu       = 16;
        r_bitspersu     = 16;
        storeunitperval = 1;
    else
        procsubfamily = ['C' dec2hex(subfamily) 'x'];
        error(errid,['Creating objects for ' procsubfamily ' embedded symbols is not supported.']);
    end
end

%----------------------------------------
function si = SetEndianValue(ti_endian,si)
if ti_endian.isbigendian,
    si.dspendian = 'big';
else                
    si.dspendian = 'little';
end
%-----------------------------------------
function si = SetEmptyName(si)
if isempty(strmatch('name',fieldnames(si),'exact')),
    si(1).('name') = '';
end
%-----------------------
function si = GetSymbolInformation(cc,sname,opt,args)
errid = generateccsmsgid('InvalidInput');
if strcmp(opt,'local'),
    symbolinfo = list(cc,'variable-complete',sname);
    if ~isempty(args)
        error(errid,'Too many input arguments.');
    end
elseif strcmp(opt,'global') || strcmp(opt,'static'),
    symbolinfo = list(cc,'globalvar-complete',sname);
    if ~isempty(args)
        error(errid,'Too many input arguments.');
    end
elseif strcmp(opt,'function'),
    symbolinfo = list(cc,'function-complete',sname);
    symbolinfo = CheckFunctionInputs(cc,symbolinfo,args);
else
    error(errid,'Third parameter must be ''global'', ''local'', ''static'' or ''function''. ');
end
sname = char( fieldnames(symbolinfo) );
si = symbolinfo.(sname); % set structure info to SNAME
%--------------------------------
function AssignRegisterNameAndId(symtab,si)
fnames = fieldnames(si);
if ~isempty(strmatch('regname',fnames,'exact'))
    setprop(symtab,'regname',si.regname);
end
if ~isempty(strmatch('regid',fnames,'exact'))
    setprop(symtab,'regid',si.regid);
end

%---------------------------------------------
function AssignOtherProps(symtab,si)
fnames = fieldnames(si);
other_fnames = { 'address','filename','variables' };
for i=1:length(other_fnames)
    if ~isempty(strmatch(other_fnames{i},fnames,'exact'))
        setprop(symtab,other_fnames{i},si.(other_fnames{i}));
    end
end

%--------------------------------------------
function si = initialize_stackallocation(si) 
if ~isfield(si,'stackallocation') 
    si.stackallocation.vars = {}; 
    si.stackallocation.varnames = {}; 
end 
si.stackallocation.spvalue = []; 
si.stackallocation.space = 0; 

%-------------------------------------------- 
function symbolinfo = CheckFunctionInputs(cc,symbolinfo,args)
if isempty(args)
    return;
end
fname = char(fieldnames(symbolinfo));
% Add the missing fields to library functions - needed by dispatch()
if symbolinfo.(fname).islibfunc
    symbolinfo.(fname).('filename') ='';
    symbolinfo.(fname).('funcdecl') ='';
end

nargs = length(args);
symbolinfo.(fname).stackallocation.varnames = {};

if(mod(nargs,2)~=0)
    error(generateccsmsgid('InvalidInputPairs'),'Additional input parameters must be given in input-value pairs.');
end

for i = 1:2:nargs
    prop = lower(args{i});
    val  = args{i+1};
    switch prop
        case {'funcdecl', 'filename'} % Populate fields
            symbolinfo.(fname).(args{i}) = args{i+1};
        case 'allocate'
            if ~iscell(val) || mod(length(val),2)~=0
                error(generateccsmsgid('InvalidInput'),sprintf(['To allocate a variable(s), '...
                        'specify the variable name(s) and size(s)\ninside the cell array.']));
            end
            if ~iscellstr({val{1:2:end}})
                error(generateccsmsgid('InvalidInput'),sprintf(['Allocate: The input name must '...
                    'be a string.']));
            elseif ~isnumeric([val{2:2:end}])
                error(generateccsmsgid('InvalidInput'),sprintf(['Allocate: The input size must '...
                    'be numeric.']));
            end
            for i=1:length(val)/2
                valpair = {val{i*2-1:i*2}};
                symbolinfo.(fname).stackallocation.vars.(valpair{1}).name = valpair{1};            
                symbolinfo.(fname).stackallocation.vars.(valpair{1}).size = valpair{2}; 
                symbolinfo.(fname).stackallocation.vars.(valpair{1}).bpsu = []; %initialization            
                symbolinfo.(fname).stackallocation.vars.(valpair{1}).address = []; %initialization 
                symbolinfo.(fname).stackallocation.varnames(end+1) = valpair(1);      
            end
        otherwise
            error(generateccsmsgid('InvalidInput'),sprintf('%s ''%s'' %s','Input parameter',args{i},...
                'cannot be recognized.'))
    end
end

%-------------------------------------------
function si = PreprocessInputs(uclass,si)
switch uclass
    case {'pointer','rpointer'}
        if ~isempty(strmatch('bitsize',fieldnames(si),'exact'))
            si(end).objectdata = struct('bitsize',si.bitsize);
        else
            si(end).objectdata = [];
        end
    otherwise
        si = [];
end

%-------------------------------------------
function C28xBugCheck(si)
if isfield(si,'c28xbugcheck') && strcmp(si.procsubfamily,'C28x') && strcmp(si.uclass(1),'r'),
    error(generateccsmsgid('FeatureIsDisabled'),...
        'Cannot create an object for a C28x register variable. This feature is currently disabled.');
end

%-------------------------------------------
function C55xBugCheck(symbobj)
% Some C55x non-16-bit register variables are assigned by the compiler/API
% to a 16-bit register. This creates an invalid object.
objclass = class(symbobj);
if ~strcmpi(objclass(1:5),'ccs.r')
    return
end
try
    proc = getprop(symbobj,'procsubfamily');
catch
    % try-catch is only necessary bec. some classes do not have a
    % 'procsubfamily' property
    if findstr(lasterr,'There is no ''procsubfamily'' property')
        return
    end
end
if strcmp(proc,'C55x') && symbobj.wordsize>16 && length(symbobj.regname)==1,
    error(generateccsmsgid('ObjectNotCreated'),...
        ['Unable to create a valid register object for the C55x variable ''' symbobj.name '''.']);
end

% [EOF] CREATEOBJ.M