function boo = isCellGroup(Group1,Group2)
%ISCELLGROUP  Determine group format in binary ops

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/01/07 19:32:25 $
isCell1 = isa(Group1,'cell');
isCell2 = isa(Group2,'cell');
boo = (isCell1 && isCell2) || ...
   (isCell1 && isempty(fieldnames(Group2))) || ...
   (isCell2 && isempty(fieldnames(Group1)));