function nn = delmember(st,name)
%DELMEMBER - deletes a member of the structure class
%  DELMEMBER(ST,NAME) removes the specifed member from
%  the 'ST' structure class.  NAME identifies the
%  member that is to be removed.  
%
%  See Also READ, WRITE, ADDMEMBER.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2004/04/08 20:47:07 $

error(nargchk(2,2,nargin));

if ~ischar(name),
    error('member NAME must be a string');
end
if name(1) == '_',
    fullname = ['Q' name];
else
    fullname = name;
end
memnam = st.membname;
imnam = strmatch(fullname, memnam);
if ~isempty(imnam),
    memnam(imnam) = [];
    st.membname = memnam;
else
    error(['Specified structure member: ''' name ''' not found']);
end
st.member = rmfield(st.member,fullname);
set(st,'membnumber',length(st.membname));

% [EOF] delmember.m
 