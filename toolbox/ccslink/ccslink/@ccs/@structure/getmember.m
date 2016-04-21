function resp = getmember(str,structidx,membername)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/11/30 23:13:39 $

error(nargchk(2,3,nargin));
if ~ishandle(str),
    error('First parameter must be a STRUCTURE handle');
end
if nargin==2,
    if ~ischar(structidx)
        error('Second Parameter must be a string when using GETMEMBER with two inputs ');
    end
    struct_offset = 0; % struct address offset from str.address
    membername = structidx;
else
    if ~isnumeric(structidx),
        error('Second Parameter must be a numeric when using GETMEMBER with two inputs ');
    end
    if isempty(structidx)
        structidx = ones(1,length(str.size));
    elseif length(structidx)~=length(str.size)
        error(['Structure size is [' num2str(str.size) '], index must be a (1 x '  num2str(length(str.size)) ') array ' ]);
    else
        if any(structidx<0) | any(structidx>str.size)>0
            error('Invalid value for STRUCTURE index');
        end
    end
    linearindex = getLinearIndex(str,round(structidx)); % linearindex is 1-based
    struct_offset = linearindex-1; % convert to zero-based
end
% Check if membername is a valid member of STR
memb_idx = strmatch(membername,str.membname,'exact');
if isempty(memb_idx)
    error(['Invalid STRUCTURE member ''' membername '''. ']);
end
% Make a copy of the member
mangledmembname = getprop(str.member,'containerobj_mangledmembname');
resp = copy( str.member.(mangledmembname{memb_idx}) );
% Adjust the address value such that it points to the correct member
resp.address = [resp.address(1)+str.storageunitspervalue*struct_offset, resp.address(2)];

%------------------------------
function linearindex = getLinearIndex(str,structidx)
if str.size==1,     
    linearindex = structidx;
else
    linearindex = p_sub2ind(str,str.size,structidx,str.arrayorder);
end

% [EOF] getmember.m