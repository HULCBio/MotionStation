function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:29 $

switch c.att.LinkType;
case 'Ulink'
   lName= 'URL link';
case 'Xref'
   lName='Cross reference';
otherwise
   lName=c.att.LinkType;
end

if isempty(c.att.LinkID)
   lID='<No ID>';
else
   lID=c.att.LinkID;
end

strout=[xlate(lName) ' - ' xlate(lID)];