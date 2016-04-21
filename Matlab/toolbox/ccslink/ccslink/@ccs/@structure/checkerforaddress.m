function sv = checkerforaddress(mm,usersSV)
%CHECKERFORADDRESS - private function to verify operations on property MAXADDRESS
% Force Address to have both address+page
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.2 $  $Date: 2003/11/30 23:13:30 $

if ~isnumeric(usersSV) || length(usersSV)>2, % ignore 
    error('Property ''address'' must be a (1x2) numeric vector : [offset,page].');
end
if isempty(usersSV)
    usersSV = mm.address;
elseif any(mod(usersSV,1)~=0)
    error('Property ''address'' components must be integers.')
end
% check offset
usersAddr = round(usersSV(1));
if usersAddr<0,
    error('Property ''address'' must not be negative.');
end
% check page
if length(usersSV)>1,
    usersPage = round(usersSV(2));
else
    usersPage = mm.address(2);
end
if usersPage < 0,
    error('Property ''address(2)'', i.e. page, must not be negative.');
end

% check address versus maximum address 
cc = mm.link;
% Ask Mary Ann about this:

if ~isempty(cc)
    %    if any(strcmp(mm.procsubfamily,{'C6x','R1x','R2x'})) 
    if cc.subfamily==84, % C54x
        maxaddress = (2^23)-1;
    elseif cc.subfamily==85, % C55x
        maxaddress = (2^24)-1;
    elseif cc.subfamily==40, % C28x
        maxaddress = (2^22)-1;
    else % C6x,R1x,R2x
        maxaddress = (2^32)-1;
    end
    if usersAddr > maxaddress
        error('ADDRESS parameter exceeds available address space.');
    end
end

sv = [usersAddr usersPage];

if ~isempty(mm.member)
    setprop(mm.member,'containerobj_address',sv);
    temp = getprop(mm.member,'containerobj_membinfo');
    for i=1:length(mm.membname)
        m_membname = getprop(mm.member,'containerobj_mangledmembname');
        m_membname = m_membname{i};
        struct_addr = getprop(mm.member,'containerobj_address');
        temp.(m_membname).address = [struct_addr(1)+mm.memboffset(i),struct_addr(2)];
        setprop(mm.member,'containerobj_membinfo',temp);
    end
end

% [EOF] checkerforaddress.m