function nn = createmember(memb,name,sobj)
% Private.
%ADDMEMBER - add a member to structure class
%  ADDMEMBER(ST,NAME,HANDLE)- appends the specifed member to
%  the 'ST' structure class.  NAME is used to identify the
%  member, which is used to specify an entry in the member
%  structure of ST.  
%
%  See Also READ, WRITE, DELMEMBER.

% 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $ $Date: 2003/11/30 23:07:48 $

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

membname    = fieldnames(memb.containerobj_membinfo);
memb.(name) = sobj;

% [EOF] createmember.m
