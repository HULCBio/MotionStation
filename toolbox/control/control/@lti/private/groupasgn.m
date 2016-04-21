function Group = groupasgn(Group,indices,Grhs)
%GROUPASGN  Reassignment of an I/O group portion
%
%   GROUP = GROUPASGN(GROUP,INDICES,GRHS) propagates I/O group
%   information in the assignments  SYS(:,INDICES) = RHS  and
%   SYS(INDICES,:) = RHS.  If RHS has I/O groups, this grouping
%   information is inherited by the reassigned channels of GROUP.
%
%   Used by LTI/SUBSASGN.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/01/07 19:32:22 $

% Keep existing groups if RHS group is empty
if isempty(fieldnames(getgroup(Grhs))),
   return
end
Group = groupcat(Group,Grhs,indices);
