function Group = groupcat(Group,NewGroup,inew)
%GROUPCAT  Concatenates two I/O groups.  
%
%   GROUP = GROUPCAT(GROUP,NEWGROUP,INEW) inserts the new 
%   groups NEWGROUP into an existing group list GROUP as 
%   part of one of the operations:  
%      *  SYS = [SYS , NEWSYS] 
%      *  SYS = [SYS ; NEWSYS]
%      *  SYS(:,indices) = NEWSYS
%      *  SYS(indices,:) = NEWSYS
%   INEW is the index vector such that SYS(:,INEW) = NEWSYS
%   or SYS(INEW,:) = NEWSYS.

%       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:39 $

CellFlag = isCellGroup(Group,NewGroup);
Group = getgroup(Group);
NewGroup = getgroup(NewGroup);
f = fieldnames(Group);
fnew = fieldnames(NewGroup);

% Look for shared group names and merge corresponding index sets
[is1,is2] = NameIntersect(char(f),char(fnew));
for ct=1:length(is1),
   chold = Group.(f{is1(ct)});
   chnew = NewGroup.(fnew{is2(ct)});
   % Delete reassigned channels that do not appear in new group
   jdel = inew;
   jdel(chnew) = [];  % reassigned channels not in new group
   [junk,j1,j2] = intersect(chold,jdel);
   chold(:,j1) = [];
   % Append new channels that were not among old ones
   jnew = inew(chnew);
   [junk,j1,j2] = intersect(jnew,chold);
   jnew(:,j1) = [];
   Group.(f{is1(ct)}) = [chold , jnew];
end

% Append new groups 
fnew(is2) = [];
for ct=1:length(fnew)
   Group.(fnew{ct}) = inew(NewGroup.(fnew{ct}));
end
Group = setgroup(Group,CellFlag);


% Subfunction NameIntersect
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ia,ib] = NameIntersect(a,b)
%NAMEINTERSECT  Looks for matching strings in CHAR arrays A and B
%
%  Output:  A(IA)=B(IB) are the shared names

if isempty(a) | isempty(b),
   ia = []; ib = [];  return
end

% Adjust number of columns in A and B
space = ' ';
[ra,ca] = size(a);
[rb,cb] = size(b);
a = [a , space(ones(1,ra),ones(1,cb-ca))];
b = [b , space(ones(1,rb),ones(1,ca-cb))];

% Find matching entries (discarding '' names)
[c,ndx] = sortrows([a;b]);
d = find(all(c(1:end-1,:)==c(2:end,:),2) & any(c(1:end-1,:)~=' ',2));

% Derive indices
ndx = ndx([d;d+1]);
boo = (ndx<=ra);
ia = ndx(boo);
ib = ndx(~boo)-ra;

