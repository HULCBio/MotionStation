function oList=getobjects(c,isVerify)
%GETOBJECTS returns a list of objects to include in report

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:25 $

currContext=getparentloop(c);
switch currContext
case 'Block'
   loopArgs={
      c.att.isBlockIncoming
      c.att.isBlockOutgoing
   };
case 'System';
   loopArgs={
      c.att.isSystemIncoming
      c.att.isSystemOutgoing
      c.att.isSystemInternal
   };
otherwise
   loopArgs={};
end

oList=loopsignal(c,c.att.SortBy,currContext,loopArgs{:});


