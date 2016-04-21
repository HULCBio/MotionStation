function mname = p_manglename(st,iname,warnstat)
% (Private) Mangle (rename) given name.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2003/11/30 23:13:42 $

error(nargchk(2,3,nargin));
if ~ishandle(st),
    error('First Parameter must be a valid STRUCTURE handle ');
end
if ~ischar(iname)
    error('Second Parameter must be a string ');
end
if nargin==3
	if ~ischar(warnstat)
        error('Third Parameter must be a string ');
    elseif isempty(strmatch(lower(warnstat),{'on','off'},'exact'))
        error('Third Parameter must be [on] or [off] only ');
    end
end

origname = iname;

if strcmp(iname(1),'_')
    if nargin===3 && strcmpi(warnstat,'off')
        warning(['''' origname ''' starts with an invalid character ''_'',  ''Q'' is attached (Q' iname ') ']);
        iname = ['Q' iname];
    end
end

if strfind(iname,'$')
    if nargin===3 && strcmpi(warnstat,'off')
        warning(['''' origname ''' contains the invalid character ''$'', it is replaced with ''DOLLAR''']);    
        iname = strrep(iname,'$','DOLLAR');
    end
end

if strfind(iname,'.')
    if nargin===3 && strcmpi(warnstat,'off')
        warning(['''' origname ''' contains the invalid character ''.'', it is replaced with ''PERIOD''']);    
        iname = strrep(iname,'.','PERIOD');
    end
end

mname = iname;

% [EOF] p_manglename.m