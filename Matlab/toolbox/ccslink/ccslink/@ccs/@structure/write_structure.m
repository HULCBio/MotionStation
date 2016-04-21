function write_structure(st,args)
% WRITE Store a value to the location pointed to by a STRUCTURE object.
% 
% 	WRITE(st,val,member) - writes the value VAL to the STRUCTURE member specified by MEMBER.
%     
% 	WRITE(st,val,member,varargin) - writes the value VAL to the STRUCTURE member specified 
% 	by member, where VARARGIN are extra WRITE options. See WRITE options of MEMBER.
% 
% 	WRITE(st,index,val,member) - writes the value VAL to the STRUCTURE member of the STRUCTURE 
%     element INDEX.
%     
% 	WRITE(st,index,val,member,varargin) - writes the value VAL to the STRUCTURE member of the STRUCTURE 
%     element INDEX, where VARARGIN are extra WRITE options. See WRITE options of MEMBER.
% 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2003/11/30 23:13:51 $


error(nargchk(2,2,nargin));
if ~ishandle(st),
    error(generateccsmsgid('InvalidHandle'),...
        'First Parameter must be a valid STRUCTURE handle.');
end

nargs = length(args);
if isempty(args),
    error(generateccsmsgid('NotEnoughInputs'),'Not enough input arguments.');
elseif ischar(args{1}),
    if nargs<2,
        error(generateccsmsgid('NotEnoughInputs'),'Incorrect number of inputs, please specify the member name. ');
    end
    struct_idx = ones(1,length(st.size));
    extra_args = args;
elseif isnumeric(args{1}),
    nargs = nargs-1;
    if nargs<2,
        error(generateccsmsgid('NotEnoughInputs'),'Incorrect number of inputs, please include the value. ');
    end
    if any(round(args{1})<=0),  
        error(generateccsmsgid('InvalidInput'),['Invalid STRUCTURE index: [' num2str(args{1}) '] ']);
    elseif isempty(args{1}),    
        struct_idx = ones(1,length(st.size));
    else                    
        struct_idx = args{1};
    end
    extra_args = {args{2:end}};
else
    error(generateccsmsgid('InvalidInput'),'Second Parameter must be a STRUCTURE index or a STRUCTURE membername.');
end

if mod(nargs,2)~=0
    error(generateccsmsgid('InvalidInput'),['WRITE requires member name and value arguments to be specified in pairs.']);
end
if ~iscellstr({extra_args{1:2:nargs-1}})
    error(generateccsmsgid('InvalidInput'),['WRITE requires member name and value arguments to be specified in pairs.']);
end

for i=1:2:nargs-1
    name  = extra_args{i};
    value = extra_args{i+1};
    membobj = getmember(st,struct_idx,name);
    try 
        write(membobj,value);
    catch
        errId = generateccsmsgid('InvalidMemberWrite');
        error(errId, sprintf(['Problem writing to structure member ''' name ,...
                ''' (member class: '  strrep(class(membobj),'ccs.','') '):\n' lasterr]));
    end
end

% [EOF] write_structure.m