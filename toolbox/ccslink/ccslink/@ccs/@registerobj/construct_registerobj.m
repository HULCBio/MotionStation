function rr = construct_registerobj(rr,args)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2003/11/30 23:10:34 $

nargs = length(args);

if( nargin < 2 | ~ishandle(rr) ),
    error('A memory object can only be created from a valid link object, see REGISTER');
end

if(mod(nargs,2)~=0)
    error(['REGISTER constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
end

% Get property / value pairs from argument list

for i = 1:2:nargs,
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error('PROPERTY must be a string entry');
    end
    if ~isempty( strmatch(prop,{'procsubfamily','name','bitsperstorageunit','timeout','numberofstorageunits',...
                'objectdata','regname', 'regid'},'exact')),
        rr.(prop) = val;
       
    elseif strcmp(prop,'link'),
        rr.(prop) = val;
       
    elseif strcmp(prop,'reginfo'),
        reginfo    = val;
        if ~isempty(reginfo)
            rr.regid   = getregid(reginfo); % parse out register ID from this string
            rr.regname = registerNameLookup(rr); % 'type'-assumed to have been initialized
                                                 %  by derived class (ex numeric)
        end
    else
        error(['Unknown property ''' prop ''' specified for REGISTER object.'])
    end
    
end            

%--------------------------------------
function id = getregid(reginfo)
% Parse out register ID from reginfo string
index = strfind(reginfo,'Register:');
start = index + 9; % length('Register:') = 9
openparindex = findstr('(',reginfo(start:end)); % find first open parenthesis after 'Register:';
last = start + openparindex(1) - 2;             
idstr = p_deblank(reginfo(start:last));
id = str2num(idstr);% this marks the end of the register ID string

%-------------------------------------------
function name = registerNameLookup(rr)
% Determine which register this ID points to

[regnameList,regidList] = p_registerlist(rr);
index = find(rr.regid==regidList);
name = { regnameList{index} };
% idcheck = regidlookup(name{1});
switch (rr.link.family)
case 320,
	if ( (rr.link.subfamily>=96 && rr.link.subfamily<=112) && rr.wordsize>16 ) | ...
       ( (rr.link.subfamily==84) && rr.wordsize>16 ),
        % For C6x & C54x, concatenate register names when wordsize does not
        % fit in 1 register unit
        name = horzcat(name,{regnameList{index+1}});
    elseif (rr.link.subfamily==85), % C5500 
        if strcmpi(name,'AC0'),
            name = {'AC0L','AC0H'};
        elseif strcmpi(name,'AC1'),
            name = {'AC1L','AC1H'};
        elseif strcmpi(name,'AC2'),
            name = {'AC2L','AC2H'};
        elseif strcmpi(name,'AC2'),
            name = {'AC3L','AC3H'};
        end
	end
case 470,
otherwise,
    error('Processor family not supported.');
end


%-------------------------------------------
function id = regidlookup(name)
lookuptable = [];
lookuptable = setfield(lookuptable,{1},'PC'  ,0);

lookuptable = setfield(lookuptable,{1},'A0'  ,9);
lookuptable = setfield(lookuptable,{1},'A1'  ,10);
lookuptable = setfield(lookuptable,{1},'A2'  ,11);
lookuptable = setfield(lookuptable,{1},'A3'  ,12);
lookuptable = setfield(lookuptable,{1},'A4'  ,13);
lookuptable = setfield(lookuptable,{1},'A5'  ,14);
lookuptable = setfield(lookuptable,{1},'A6'  ,15);
lookuptable = setfield(lookuptable,{1},'A7'  ,16);
lookuptable = setfield(lookuptable,{1},'A8'  ,17);
lookuptable = setfield(lookuptable,{1},'A9'  ,18);
lookuptable = setfield(lookuptable,{1},'A10' ,19);
lookuptable = setfield(lookuptable,{1},'A11' ,20);
lookuptable = setfield(lookuptable,{1},'A12' ,21);
lookuptable = setfield(lookuptable,{1},'A13' ,22);
lookuptable = setfield(lookuptable,{1},'A14' ,23);
lookuptable = setfield(lookuptable,{1},'A15' ,24);

lookuptable = setfield(lookuptable,{1},'B0'  ,25);
lookuptable = setfield(lookuptable,{1},'B1'  ,26);
lookuptable = setfield(lookuptable,{1},'B2'  ,27);
lookuptable = setfield(lookuptable,{1},'B3'  ,28);
lookuptable = setfield(lookuptable,{1},'B4'  ,29);
lookuptable = setfield(lookuptable,{1},'B5'  ,30);
lookuptable = setfield(lookuptable,{1},'B6'  ,31);
lookuptable = setfield(lookuptable,{1},'B7'  ,32);
lookuptable = setfield(lookuptable,{1},'B8'  ,33);
lookuptable = setfield(lookuptable,{1},'B9'  ,34);
lookuptable = setfield(lookuptable,{1},'B10' ,35);
lookuptable = setfield(lookuptable,{1},'B11' ,36);
lookuptable = setfield(lookuptable,{1},'B12' ,37);
lookuptable = setfield(lookuptable,{1},'B13' ,38);
lookuptable = setfield(lookuptable,{1},'B14' ,38);
lookuptable = setfield(lookuptable,{1},'B15' ,40);
% lookuptable = setfield(lookuptable,{1},'SP'  ,40);
% lookuptable = setfield(lookuptable,{1},'FP'  ,40);
id = lookuptable.(name);

% [EOF] construct_register.m
    


