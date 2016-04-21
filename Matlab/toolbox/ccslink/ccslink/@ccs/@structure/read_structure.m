function resp = read_structure(st,args)
% READ Read values stored in the location pointed to by a STRUCTURE object.
% 
% 	O = READ(st) - reads the values of each member in the STRUCTURE object ST. This returns a MATLAB
%     structure having the member names as fields.
%     
% 	O = READ(st,member) - reads the value of the STRUCTURE object's member specified by MEMBER.
%     
% 	O = READ(st,member,varargin) - reads the value of the STRUCTURE member specified by MEMBER,
% 	where VARARGIN are extra 'read' options. See 'read' options for MEMBER's class.
% 
% 	O = READ(st,index,member) - reads the value of the member of the STRUCTURE element INDEX.
%     
% 	O = READ(st,index,member,varargin) - reads the value of the member of the STRUCTURE 
%     element INDEX, where VARARGIN are extra 'read' options. See 'read' options for MEMBER's class.
%
%   The output O is not in MATLAB structure format when reading a particular member value.
% 
%   Copyright 2002-2003 The MathWorks, Inc.

error(nargchk(2,2,nargin));
if ~ishandle(st),
    error(generateccsmsgid('InvalidHandle'),'First parameter must be a valid STRUCTURE handle.');
end

index     = [1:prod(st.size)];
membidx   = [1:length(st.membname)];
nargs = length(args) + 1;

allWarnings = {};
if nargs==1 || (nargs==2 && isempty(args{1})),
    next = 1;
    all_index = 1;
    descr = 'structure';
    % Create an array of structures
    emptySt = struct([]);
    emptySt(prod(st.size)).('dummy') = [];
    if length(st.size)==1,  emptySt = reshape(emptySt,1,st.size);
    else                    emptySt = reshape(emptySt,st.size); 
    end
    SendWarning(st,{'largestruct','mangle'});
    
elseif nargs>=2,
    % If 2nd argument is index, READ(st,1,...) or READ(st,1,'memb',...)
    if isnumeric(args{1}) && ~isempty(args{1}),
        index = round(args{1});
        if any(index<=0) || any(index>st.size)
            error(generateccsmsgid('InvalidInput'),['Invalid STRUCTURE index: ' num2str(args{1})] );
        end
        if length(args)==1, % read one index only
            next = 1;
            all_index = 0;
            descr = 'indexed_structure';
            emptySt = CreateEmptyStruct(st);
            resp = emptySt;
            SendWarning(st,{'mangle'});
        else
            next = 2;
            if nargs>2
                membidx = strmatch(args{2},st.membname,'exact');
                CheckIfNotAMember(membidx,args{2});
                next = 3;
            end
            all_index = 0;
            descr = 'indexed_member';
        end
    % If 2nd argument is struct member, READ(st,'memb',...)
	elseif isempty(args{1}) || (ischar(args{1}) && strmatch(args{1},st.membname,'exact')), 
        if isempty(args{1})
            args = {args{2}};
        end
        membidx = strmatch(args{1},st.membname,'exact');
        CheckIfNotAMember(membidx,args{1});
        next = 2;
        all_index = 1;
        descr = 'all_members';
        resp = CreateArrayForAllElementOutput(st,membidx);
    else
        error(generateccsmsgid('InvalidInput'),'Second input must be a STRUCTURE index or member name.');
    end
end

stOrigAddr = st.address; % original address of object
membobjlist = cell(1,membidx(end)); % create a cell array of member objects - index corresponds to member order (1-based)
for i=membidx, membobjlist{i} = my_getmember(st,i);  end
memboffset = getprop(st.member,'containerobj_memboffset'); % get all member offsets


i=1;
if strcmp(descr,'structure'), % separate loop - for faster read operation
    for idx=index,
		temp = struct([]);
        mangledmembname = getprop(st.member,'containerobj_mangledmembname');
		for memid=membidx,
            % sname = st.member.containerobj_membname{memid};
            sname = mangledmembname{memid};
            % adjust member address
            membtemp = membobjlist{memid};
            membtemp.address = [stOrigAddr(1)+memboffset(memid)+st.storageunitspervalue*(idx-1), membtemp.address(2)];
            % call regular READ on each member
            temp(1).(sname) = read(membtemp);
        end
        resp(i) = temp;
        i = i+1;
	end
    
else
    % Compute linear memory index from index and array-order info
	if strcmp(descr,'indexed_structure') || strcmp(descr,'indexed_member'),
        index = ComputeLinearIndex(st,index);
    end

    withExtraArgs = 0;
	for idx=index,
		temp = struct([]);
        mangledmembname = getprop(st.member,'containerobj_mangledmembname');
		for memid=membidx,
            % sname = st.member.containerobj_membname{memid};
            sname = mangledmembname{memid};
            % adjust member address
            membtemp = membobjlist{memid};
            membtemp.address = [stOrigAddr(1)+memboffset(memid)+st.storageunitspervalue*(idx-1), membtemp.address(2)];
            % call regular READ on each member
            if strcmp(descr,'indexed_structure') || isempty([args{next:end}]), % or 'structure'
                temp(1).(sname) = read(membtemp);
            else
                withExtraArgs = 1;
                % extra arguments
                num_extra_args = length(args)-next+1;
                if num_extra_args==1
                    temp(1).(sname) = read(membtemp,args{next});
                elseif num_extra_args==2
                    temp(1).(sname) = read(membtemp,args{next},args{next+1});
                else
                    eval(call_arbitrary_args(num_extra_args));
                end
            end
            
        end
	
		if strcmp(descr,'indexed_structure')
            resp = temp;
		elseif strcmp(descr,'indexed_member')
            resp = temp.(sname);
		elseif strcmp(descr,'all_members')
            if iscell(resp),            resp{i} = temp.(sname);
            elseif isnumeric(resp),     resp(i,:) = temp.(sname);
            else                        resp(i) = temp.(sname);
            end
        end
        i = i+1;
	end
end

% Rearrange output data according to array-order property
if strcmp(descr,'all_members') || strcmp(descr,'structure')
	if length(st.size) > 1,  % Non-indexed, arrange according to 'arrayorder' prop
        if strcmp(st.arrayorder,'row-major'),
            resp = resp( GetMatlabIndex(st) );
        end
        resp = reshape(resp,st.size); 
    end
end
ReturnOrignalMemberAddress(st,membidx,stOrigAddr);

%-------------------------------------------
function str = call_arbitrary_args(num_args)
str = 'temp(1).(sname) = read(membtemp,args{next},args{next+1},';
for i=2:num_args-1
    str = horzcat(str,['args{next+' num2str(i) '},']);
end
str(end) = ')';
str = horzcat(str,';');

%-------------------------------------------
function emptySt = CreateEmptyStruct(st)
emptySt = struct([]);
for memb=st.membname
    m_memb = p_manglename(st,memb{1},'off');
    emptySt(1).(m_memb) = [];
end

%-------------------------------------------
function emptySt = CreateEmptyStructFromInfo(m_info)
emptySt = struct([]);
m_names = fieldnames(m_info);
for i = 1:length(m_names)
    memb = m_names{i};
    emptySt(1).(memb) = [];
end

%------------------------------------------
function resp = CreateArrayForAllElementOutput(st,membidx)

membinfo = getprop(st.member,'containerobj_membinfo');
% m_membname = st.member.containerobj_mangledmembname{membidx};

minfo_membname = fieldnames(membinfo)';
minfo_membname = minfo_membname{membidx};
memberinfo = membinfo.(minfo_membname);

isStructScalar = (length(st.size)==1);

if ~isempty(strmatch(memberinfo.uclass,{'string','rstring','enum','renum'},'exact')) % character output
	if isStructScalar,    resp = cell(1,st.size);
    else            resp = cell(st.size);
	end        
elseif strcmp(memberinfo.uclass,'structure') % structure output
    emptySt(prod(st.size)) = CreateEmptyStructFromInfo(memberinfo.members);
	if isStructScalar,    resp = reshape(emptySt,1,st.size);
    else            resp = repmat(emptySt,st.size);
	end        
else % numeric output
    if strcmp(memberinfo.uclass,'bitfield')
        memberinfo.size = 1;
    end
	if isStructScalar,      resp = zeros(1,memberinfo.size);
	else                    resp = zeros(st.size,memberinfo.size);
	end        
end

%--------------------------------------------
function dummy = ReturnOrignalMemberAddress(st,membidx,baseAddr)
for membid = membidx
    mangledmembname = getprop(st.member,'containerobj_mangledmembname');
	obj = st.member.(mangledmembname{membid});
    containerobj_memboffset = getprop(st.member,'containerobj_memboffset');
	origAddr = [baseAddr(1)+containerobj_memboffset(membid),baseAddr(2)]; 
	set(obj,'address',origAddr);
end

%--------------------------------------------
function resp = my_getmember1(str,membid,structidx)
mangledmembname = getprop(str.member,'containerobj_mangledmembname');
resp = str.member.(mangledmembname{membid});
resp.address = [resp.address(1)+str.storageunitspervalue*(structidx-1), resp.address(2)];

%--------------------------------------------
function resp = my_getmember(str,membid)
mangledmembname = getprop(str.member,'containerobj_mangledmembname');
resp = str.member.(mangledmembname{membid});

%--------------------------------------------
function linearindex = getLinearIndex(str,subs)
try    
    index_shaped = round(reshape(subs,length(str.size),[])');
catch  
    error(['Index Array must be an (N x '  num2str(length(st.size)) ') array of indices' ]);
end
for subscript = index_shaped',
    if any(subscript < 1) || any(subscript' > str.size),
      error(['INDEX has an entry: [' num2str(subscript') '], which exceeds the defined size of object ']);
    end
end
addrange = index2addr(str,index_shaped);
uidata   = read_memoryobj(str,addrange',dtimeout);
uidata   = reshape(uidata,str.storageunitspervalue,[]);
nvalues  = size(uidata);
nvalues  = nvalues(2);

%-----------------------------------------
function linearindex = GetMatlabIndex(nn)
nsize = nn.size;
subsc = [];
totalnumel = prod(nsize);
len = length(nsize);
subsc = p_ind2sub(nn,nsize,[1:totalnumel],'col-major'); % index in a) C if row-major b) MATLAB if col-major
linearindex = p_sub2ind(nn,nsize,subsc,'row-major'); % map indices to native MATLAB array order
if ~isequal(unique(linearindex),sort(linearindex))
    error(generateccsmsgid('InvalidOperation'),'Error generating linear index. Please report this error to The MathWorks.');
end

%-----------------------------------------
function linearindex = ComputeLinearIndex(nn,index)
if ~isequal(length(index),length(nn.size)) && length(index)
    error(['Index must be a (1 x '  num2str(length(nn.size)) ') array ' ]);
end
if length(nn.size)>1,
    linearindex = p_sub2ind(nn,nn.size,index,nn.arrayorder);
else
    linearindex = index;
end

%----------------------------------------------
function SendWarning(st,warnlist)
for i=1:length(warnlist),
    switch warnlist{i}
    case 'largestruct'
		if prod(st.size)*(st.storageunitspervalue)>150,
            warning(generateccsmsgid('ReadingLargeStruct'),'You are reading a large structure, this may take a while... ');
        end
    case 'mangle'
        mangledmembname = getprop(st.member,'containerobj_mangledmembname');
        if ~isequal(st.membname,mangledmembname),
            warning(generateccsmsgid('MemberRenamed'),'One or more member names have been renamed to become valid MATLAB structure fieldnames.');
		end
    otherwise
    end
end

%------------------------------
function CheckIfNotAMember(membidx,membname)
if isempty(membidx)
    errid =generateccsmsgid('NotAStructMember');
    error(errid,['Invalid STRUCTURE member ''' membname '''.']);
end

% [EOF] read_structure.m