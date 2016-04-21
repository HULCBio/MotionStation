function bb = construct_containerobj(bb,args)
% (Private) Set Containerobj properties.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2003/11/30 23:07:46 $

bb.containerobj_mangledmembname = {};
nargs = length(args);

if nargin<=1,
    return; % Use defaults
end

if(mod(nargs,2)~=0)
    error(generateccsmsgid('PropValuePairsRequired'),['CONTAINEROBJ constructor requires property and value arguments to be specified in pairs.']);
end

% Get property / value pairs from argument list
for i = 1:2:nargs,
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error(generateccsmsgid('InvalidInput'),'Property Name must be a string entry');
    end
    
    % Assign property values
    if ~isempty( strmatch(prop,{'containerobj_address','containerobj_link'},'exact'))
        bb.(prop) = val;
        args{i}   = [];
        args{i+1} = [];
        
    elseif ~isempty( strmatch(prop,'containerobj_membinfo','exact'))
        bb.(prop) = val;
        args{i}   = [];
        args{i+1} = [];
        SetStructureProperties(bb,val);
        
    else
        error(generateccsmsgid('InvalidInput'),['Unknown property ''' prop ''' specified for STRUCTURE object.'])
    end
   
end           

%---------------------------------------------------
function SetStructureProperties(bb,val)
% Note: 
% *membnames - real C names of members
% *mangled_membinfo_names - fieldnames in membinfo (result from
%   switchyard), some of names are already mangled here, specifically
%   those that start with underscore; 
%   these names are also used to access member info from containerobj_membinfo
% *mangledmembnames - result of further renaming/mangling (includes those
%   that has double names -> str.member is case sensitive;
%   this is used to access member objects directly -> str.member.(mangledmembnames{i})

mangled_membinfo_names = fieldnames(bb.containerobj_membinfo)'; % get membinfo member names - some might be mangled already
len = length(mangled_membinfo_names); % number of members

memtab{len} = ''; % get real C member names
for i=1:len, memtab{i} = val.(mangled_membinfo_names{i}).name;  end
bb.containerobj_membname = memtab;

bb.containerobj_isInstantiated = zeros(1,length(bb.containerobj_membname)); % initialize to 0, members not yet instantiated

for mi = 1:len,

    membername        = memtab{mi};
    mangledmembername = mangled_membinfo_names{mi};
    
    % check for multiple names - note: member names with leading underscores is
    % taken cared of in the switchyard
    if mi>1,
        mangledmembername = MangleDuplicateNames(membername,mangledmembername,{memtab{1:mi-1}});
    end

    bb.containerobj_mangledmembname = horzcat(bb.containerobj_mangledmembname,{mangledmembername}); % final mangled member name
   
    % create property for struct/union member
	p = schema.prop(bb, mangledmembername, 'handle');
	p.AccessFlags.PublicSet = 'on';

	createmember(bb,mangledmembername,[]);  % add empty member object to structure object
	memblistener(mi) = handle.listener(bb, findprop(bb, mangledmembername), 'PropertyPreGet', {@creatememberobj mi}); % set a listener for creating/accessing member object
    bb.containerobj_memboffset = horzcat(bb.containerobj_memboffset, bb.containerobj_membinfo.(mangled_membinfo_names{mi}).offset); % compute address offset of member

    % if bitfield, add 'baseaddress'
    if strmatch(bb.containerobj_membinfo.(mangled_membinfo_names{mi}).uclass,'bitfield')
        bb.containerobj_membinfo.(mangled_membinfo_names{mi}).baseaddress = bb.containerobj_address;
    end

end
set(memblistener, 'CallbackTarget', bb);
set(bb, 'Containerobj_PreGetListeners', memblistener);

%-----------------------------------------------------
function mangledmembername = MangleDuplicateNames(membername,mangledmembername,rest_of_membnames)
% check for multiple names 
% note: member names with leading underscores is taken cared of in the switchyard

i = strmatch( lower(membername), lower(rest_of_membnames) ); % check if it contains double names
if i,
	prefix = 'Q'; % prefix for double names
	mangledmembername = [prefix*ones(1,length(i)) mangledmembername]; % further mangle if necessary
	warning(generateccsmsgid('StructMemberRenamed'), ...
        sprintf(['MEMBER is not case-sensitive and therefore cannot have more than 1 entry for \n', ...
        '''' membername ''' (No.' num2str(length(i)+1) ' occurrence). ' ,...
        'This Structure member is renamed to ''' mangledmembername '''.']));
end

% [EOF] construct_containerobj.m 