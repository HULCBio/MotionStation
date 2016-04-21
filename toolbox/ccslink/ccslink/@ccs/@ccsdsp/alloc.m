function memobj = alloc(varargin)
% ALLOC(Private) Allocate data on a pre-defined scratch area in memory.
%  SYMOBJ=ALLOC(CC,DATA,DATATYPE) Returns an object that points to an block
%  of data on the stack that is defined through CREATEMEM. The data stored
%  in this memory area is defined by DATA and DATATYPE. DATA is the value(s)
%  to be stored in memory and DATATTYPE is the data type. The size of memory
%  block allocated is denoted by DATA's size.
%
%  SYMOBJ=ALLOC(CC,DATA,DATATYPE,SIZE) Same as above but the size of the
%  memory block allocated is specified by SIZE. If a conflict between the
%  SIZE and the size of DATA occurs, then SIZE takes higher precedence.
%
%  SYMOBJ=ALLOC(CC,DATA,DATATYPE,SIZE,TIMEOUT) Same as above except a time
%  out value is specified.
% 
%  DATA is a vector of data. If DATA=[], block of data is not initialized.
%  
%  DATATYPE is any Code Composer supported data type. If DATATYPE is of
%   type 'struct', DATA must be [].
%  SIZE is the size of the memory block to allocate. If SIZE is not
%   specified, SIZE is equal to the size of the data being passed.
%   Example:
%       alloc(cc,ones(2,3))         % size is equal to [2 3]
%       alloc(cc,ones(2,3),[2 3])   % size is equal to [2 2]
%  TIMEOUT can be passed in when pushing huge data blocks. This can also be
%   specified through CC's 'timeout' property, i.e. cc.timeout.
%
%  Signatures allowed:
%   alloc(cc, data, datatype, size, timeout)
%   alloc(cc, data, datatype, size) - initialized
%   alloc(cc, [], datatype, size) - uninitialized
%   alloc(cc, data, datatype)
%
%  See also DEALLOC, CREATEMEM.

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:06:47 $

error(nargchk(2,5,nargin));

cc = varargin{1};

% does not support multi-proc
p_errorif_ccarray(cc);

% Do not allow using this method if memory is not allocated
if isempty(cc.stack.startaddress)
    error('Before using ''alloc'', use ''createmem'' to specify the memory block you want to use for allocation.');
end

% Parse arguments
% outputing si for consequent use, effeciency, and speed
[data, datatype, siz, timeout, si] = ParseArgs(varargin{:});

% find bitsize and storageunit of object to be created
[storageunits,bitsize] = getstorageinfo(cc, datatype, siz, si);

CheckIfThereIsEnoughAvailableSpace(cc.stack,siz,storageunits);

% Align SP, and compute object address
[objaddr,totalsu] = computeobjaddr(cc, storageunits, siz);

% Point SP to top object on stack
if cc.stack.growsToLowAddr
    % Compute new topofstack value - this is the next available space for
    % allocation
    topofstack = [objaddr(1)-1,objaddr(2)];
    % Before proceeding, check again if within boundaries. Somtimes,
    % alignment can increase allocation space
    if topofstack(1)<cc.stack.startaddress(1)
        error('There is not enough space to allocate this data.');
    end
    set(cc.stack,'topofstack', topofstack);
    % Compute remaining storage units left
    cc.stack.storageUnitsLeft = cc.stack.topofstack(1) - cc.stack.startaddress(1) + 1;
else
    % Compute new topofstack value - this is the next available space for
    % allocation
    topofstack = [objaddr(1)+totalsu,objaddr(2)];
    % Before proceeding, check again if within boundaries. Somtimes,
    % alignment can increase allocation space
    if topofstack(1)>cc.stack.endaddress(1)
        error('There is not enough space to allocate this data.');
    end
    % Compute remaining storage units left
    set(cc.stack,'topofstack', topofstack);
    cc.stack.storageUnitsLeft = cc.stack.endaddress(1) - cc.stack.topofstack(1) + 1;
end

% object creation
memobj = creatememobj(cc, objaddr, bitsize, datatype, siz, si);

% write data if available
if any(data)
    write(memobj, data);
end

% save object and SP on stack list
p_push(cc, memobj);

%-------------------------------------------------
function memobj = creatememobj(cc, addr, bitsize, datatype ,siz, si)
if ~isempty(si) && any(findstr('struct',si.type))
    % Create STRUCT info structure
    memobj = createStructInfo(cc, addr, datatype, siz, si);
else % Create numeric struct
    memobj = createNumericInfo(cc, addr, bitsize, datatype ,siz);
end
%-------------------------------------------------
function memobj = createNumericInfo(cc, addr, bitsize, datatype ,siz)
% create a name for object being pushed
stk = cc.stack;
label = stk.numofstackobjs + 1;
stkobjname  = ['user_'  datatype num2str(label) ];

% Create NUMERIC info structure
si = struct(...
    'name',     stkobjname,...
    'isglobal', [],...
    'address',  addr,...
    'location', [],...
    'size',     siz,...
    'uclass',   'numeric',...
    'bitsize',  bitsize,...
    'type',     datatype);

% Call object's class constructor using info structure 
memobj = createobj(cc,si);

% currently awaiting a bug fix
% if ~strcmp(si.uclass,'structure')
%     symtab.timeout = timeout;
% end

%-------------------------------------------------
function [data, datatype, siz, timeout, si] = ParseArgs(varargin);
cc = varargin{1};
si = [];

if (nargin == 1 || nargin == 2)
    error('Not enough input arguments.');
elseif nargin == 3  
    data = varargin{2};
    % push(cc, data, datatype) 
    % allow push(cc,[],datatype), only if datatype is struct,enum,...
    if isempty(data)
        try
            si = checktypeinfo(cc,varargin{3});
            if strcmpi(si.uclass,'structure') % push(cc, [], 'struct')
                siz = si.size; 
                timeout = cc.timeout;
                datatype = varargin{3};
            end
        catch
            error('Data type is not recognized, or size parameter is not passed.');
        end
    else
        if ischar(varargin{3}) %push(cc, data, datatype)
            datatype = varargin{3}; 
            siz = size(data);
            timeout = cc.timeout;
        else  
            error('TIMEOUT parameter must be a scalar positive numeric value.');
        end
    end
elseif nargin == 4
    data = varargin{2};
    if isempty(data) % push(cc, [], datatype, size) or push(cc, [], 'struct ', size)
        try
            si = checktypeinfo(cc,varargin{3});
            if strcmpi(si.uclass,'structure')  %push(cc, [], 'struct ', size)
                siz = varargin{4}; 
                timeout = cc.timeout;
                datatype = varargin{3};
            end
        catch  % push(cc, [], datatype, size) 
            datatype = varargin{3};
            siz = varargin{4};
            timeout = cc.timeout;
        end
    else
        try
            si = checktypeinfo(cc,varargin{3});
            if strcmpi(si.uclass,'structure') % push(cc, data, 'struct', size)
                error(sprintf(['Initializing a struct/union data type through ''alloc'' is not supported.\n',...
                    'Use ''[]'' for the data field instead and then initialize by using ''write''.']));
            end
        catch % push(cc, data, datatype, size)
            ErrorOutIfDataEmpty(data);
            datatype = varargin{3};
            siz = varargin{4};
            timeout = cc.timeout;
        end
    end
end

if iscell(datatype) || ~ischar(datatype)
    error('Parameter type must be a valid data type string.');
end

if ~isnumeric(timeout) || length(timeout) ~= 1 || timeout < 0,
    error('TIMEOUT parameter must be a scalar positive numeric value.');
end

%-------------------------------------------------
function SPaligned = alignSP_C54x(cc, SP, storageunits)

if cc.stack.numofstackobjs == 0
    SPaligned = cc.stack.topofstack(1) - rem(cc.stack.topofstack(1),4);
else
    sobjsfields = fieldnames(get(cc.stack,'stackobjects'));
    lastobj = getfield(cc.stack.stackobjects, sobjsfields{end});
    lastobjstorageunit = lastobj.storageunit;
    SPaligned =  SP ;
    if storageunits == 4 %int,float
            dif = rem(SP,4);
            SPaligned = SP - dif;
    end
end

%-------------------------------------------------
function SPaligned = alignSP_C6x(cc, SP, storageunits)

if cc.stack.numofstackobjs == 0
    SPaligned = cc.stack.topofstack(1) - rem(cc.stack.topofstack(1),4);
else
    sobjsfields = fieldnames(get(cc.stack,'stackobjects'));
    lastobj = getfield(cc.stack.stackobjects, sobjsfields{end});
    lastobjstorageunit = lastobj.storageunit;
    SPaligned =  SP ;
    switch(storageunits)
        case 1 %char
            SPaligned =  SP ; %No alignment needed
        case 2
            dif = rem(SP,2);
            SPaligned = SP - dif;

        case 4 %int,float
            dif = rem(SP,4);
            SPaligned = SP - dif;

        case 8 %double,long double,long
            dif = rem(SP,4);
            SPaligned = SP - dif;
    end
end

%-------------------------------------------------
function [addr,TotalObjStorage] = computeobjaddr(cc, storageunits, siz)

% find object total storage units
TotalObjStorage = storageunits * prod(siz) ;
SPoffset = TotalObjStorage;

% find SP value and check boundary
stk = cc.stack;
if stk.growsToLowAddr
    SPvalue = stk.topofstack(1) - SPoffset + 1;
    SPaligned = SPvalue; % alignSP_C54x(cc,SPvalue,storageunits);
    SPvalue = SPaligned;
else
    SPaligned = stk.topofstack(1); % TO DO: THIS SHOULD BE ALIGNED
%     SPvalue = SPaligned + SPoffset;
    SPvalue = SPaligned;
end

% NewMemTopBoundary = SPaligned + SPvalue(1);
% 
% if NewMemTopBoundary <  stk.startaddress(1)
%     error(sprintf(['There is not enough memory space available to allocate this data.\n',...
%         'Please use ''deallocate'' or ''packdata'' to free memory space.']));
% end

% find address
addr(1) = SPvalue;
addr(2) = stk.topofstack(2);

%-------------------------------------------------
function  p_push(cc, pobj)

stk = cc.stack;
sobjname = pobj.name;
sobj = get(stk,'stackobjects');

% append object to stack
sobj(1).(sobjname) = pobj;
set(stk,'stackobjects',sobj);

% update number of stack objects
stackobjsize = get(stk,'numofstackobjs');
set(stk,'numofstackobjs',stackobjsize + 1);

% append SP to the list
stk.toslist(end + 1) = cc.stack.topofstack(1);
stk.stacksplist(end + 1) = sobj(1).(sobjname).address(1);

%-------------------------------------------------
function [storageunits,bitsize] =  getstorageinfo(cc, datatype, siz, si);
bitsize = [];
storageunits = [];
if isempty(si) % not a structure
ts = p_IsNativeCType(cc.type,datatype);
bitsize      = ts.typeprop.bitsize;
storageunits = ts.typeprop.storageunitspervalue;
else
    storageunits = siz*(si.sizeof);
end

%-------------------------------------------------
function sinfo = checktypeinfo(cc, utype)
s = list(cc,'type',utype);
sinfo = getfield(s,utype);

%-------------------------------------------------
function ErrorOutIfDataEmpty(data)
if isempty(data)
    error('Data cannot be an empty vector. If data is not available, specify the size and data type.');
end

%-------------------------------------------------
function stinfo = createStructInfo(cc,address,type,siz,si)
stinfo = si;

stinfo.address = address;
members         = fieldnames(stinfo.members);
for i=1:length(members)
    memb          = stinfo.members.(members{i});
    memb.address  = [stinfo.address(1)+memb.offset, stinfo.address(2)];
    memb.location = [];
end

% Create STRUCT object depending on the given information
switch lower(args{1})
    
case 'structinfo',
    stinfo = args{2};
    stinfo.isglobal = 0;
    stinfo.location = [];
    stinfo.address  = address;
    stinfo.size   = siz;

case 'members',
	stinfo = struct('isglobal', 0, ...
                    'name', [], ...
                    'address', address, ...
                    'location',[], ...
                    'size',siz, ...
                    'uclass','structure', ...
                    'sizeof', [], ...
                    'type', type, ...
                    'members',struct([]));

	% Get field/type pairs from argument list
    for i=2:nargs,
	
        % limit member uclass to NUMERIC; just CONVERT afterwards
        memberinfo = struct('offset' ,[],         'address' ,[], 'size' ,[], ...
                            'uclass' ,'numeric',  'bitsize' ,[], 'type'   ,[], ...
                            'storageunitspervalue'  ,[]);
                        
        % Important: STORAGEUNITSPERVALUE here is not the same as the STORAGEUNITSPERVALUE property of a memory object.
        % This STORAGEUNITSPERVALUE is the number of addressable units plus padding that TI follows when 
        % storing/arranging members in a structure. See Mary Ann's documentation.
        
        membprops = args{i};
        numprops = length(membprops);
        
        % 1st property - name of struct member
        membname = membprops{1};
        if ~ischar(membname) & ~(iscellstr(membname))
            error('MEMBER name must be a string entry.');
        end

        % defaults - 2nd and 3rd properties
        memberinfo.type = 'uint32';
        memberinfo.size = 1;
        % TYPE
        if isempty(membprops{2})
            memberinfo.type = 'uint32';
        elseif ischar(membprops{2})
            memberinfo.type = membprops{2};
		else
            error('TYPE must be a string entry.')
		end
        % size
        if numprops==3,
           val = membprops{3};
           if isnumeric(val) & ~isempty(val)
                memberinfo.size = val;
            elseif isnumeric(val) & isempty(val)
                memberinfo.size = 1;
            end
        end
        
        % BITSIZE
        switch lower(memberinfo.type)
        case {'int32','uint32','int','unsigned int','float'}
            memberinfo.bitsize = 32;
            memberinfo.storageunitspervalue = 4;  % storage units in a word = 32/aubits
        case {'short','unsigned short','int16','uint16'}
            memberinfo.bitsize = 16;    
            memberinfo.storageunitspervalue = 2;
        case {'char','unsigned char','int8','uint8'}
            memberinfo.bitsize = 8;    
            memberinfo.storageunitspervalue = 2;
        case {'double','long int','long double','unsigned long','long'}
            memberinfo.bitsize = 64;    
            memberinfo.storageunitspervalue = 8;
        otherwise
            warning('The TYPE entered is not supported. MEMBER will be set to UNSINGED INT.');
            memberinfo.bitsize = 16;
            memberinfo.storageunitspervalue = 2;
        end
        
        % OFFSET - compute offset for next member
        if i==2,
			memberinfo.offset = 0;
			next = memberinfo.size * memberinfo.storageunitspervalue;
        else
          [memberinfo.offset,next] = computeNextOffset(memberinfo,next);
		end
        
        % ADDRESS = base address plus member offset
        memberinfo.address = [address(1)+memberinfo.offset, address(2)];
        
        % ADD THIS MEMBER TO THE STRUCTURE
        stinfo.members(1).(membname) = memberinfo;
	end
	stinfo.sizeof = next; % initialize last stinfo property
    
otherwise,
    error(['FIELD ''' args{1} ''' not supported.']);
end

%--------------------------------------------------------------------
function [offset,nextoffset] = computeNextOffset(member,nextoffset)

numberofstorageunits = prod(member.size) * member.storageunitspervalue;

extra = rem(nextoffset,4);
if member.bitsize>=32,   % storageunitspervalue >= 4
	offset = nextoffset - extra + 4*(extra~=0);
else    % storageunitspervalue = 2
	extra  = rem(extra,2);
	offset = nextoffset - extra + 2*(extra~=0);
end

nextoffset = offset + numberofstorageunits;

%----------------------------------------------------------
function CheckIfThereIsEnoughAvailableSpace(ccstack,siz,storageunits)

totalspace2ballocated = prod(siz) * storageunits;
if ccstack.size<totalspace2ballocated
    error('The data you are allocating does not fit into the memory block you have defined.');
elseif ccstack.storageUnitsLeft<totalspace2ballocated
    error('The data you are allocating does not fit into the memory block you have defined.');
end

% [EOF] alloc.m