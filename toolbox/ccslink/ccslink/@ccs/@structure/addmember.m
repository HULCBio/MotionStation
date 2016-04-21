function nn = addmember(st,name,sobj)
%ADDMEMBER - add a member to structure class
%  ADDMEMBER(ST,NAME,HANDLE)- appends the specifed member to
%  the 'ST' structure class.  NAME is used to identify the
%  member, which is used to specify an entry in the member
%  structure of ST.  
%
%  See Also READ, WRITE, DELMEMBER.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.2 $ $Date: 2004/04/08 20:47:05 $

% Limited to the following handle types:
%  numeric, string, ....
%
error(nargchk(3,3,nargin));

if ~ischar(name),
    error('member NAME must be a string');
elseif name(1) == '_',
    warning(['Member: ' name ' does not start with an alphanumeric characters.  Q was added to the member name']);
    name = ['Q' name];
    ismangled = true;  % Eventually this should be noted in class
end

if ~ishandle(sobj),
    error('New members must be defined with an UDD object class');
end
% p = schema.prop(st,name,'handle');

memb = get(st,'member');
membname = fieldnames(memb);
if ~isempty(strmatch(name,membname)),
    error(['The new member: ' name ' already exists as a member']);
end
memb(1).(name)  = sobj;
membname{end+1} = name;
set(st,'member',memb);
set(st,'membname',membname);
set(st,'membnumber',length(membname));

i = st.membnumber; 
if i==1
    st.memboffset = horzcat(st.memboffset, 0);
else
    st.memboffset = horzcat(st.memboffset, st.memboffset(end) + st.member.(membname{i}).address(1) - st.member.(membname{i-1}).address(1));
end
 
% handle.listener(st,st.member.(name),'PropertyPreGet', @fetchobj);
% 
% % This avoid the (slow) call to create the object until necessary
% function fetchobj(h, eventData)
% if isempty(h.(get(eventData.Source, 'Name'))),
%     set(h, get(eventData.Source, 'Name'), 'link');
% end

% [EOF] addmember.m
