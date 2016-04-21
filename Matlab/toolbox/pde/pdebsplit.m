function cc=pdebsplit(c)
%PDEBSPLIT Splits space separated string into separate rows.
%
%       CC=PDEBSPLIT(C) splits the string C into its space separated
%       components. A maximum of four space separated string components
%       is allowed. The separated string components are returned as
%       rows in a string matrix.

%       Magnus Ringh 9-12-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:08 $

if ~ischar(c),
  error('PDE:pdebsplit:InputNotString', 'Entry must be a string.')
end
if size(c,1)~=1,
  error('PDE:pdebsplit:StringNot1Line', 'String contains more than one line.')
end
c=[fliplr(deblank(fliplr(deblank(c)))), ' '];
whites=find(isspace(c));
c(whites(find(diff(whites)==1)+1))=[];
whites=find(isspace(c));
nc=length(whites);
if nc>4,
  error('PDE:pdebsplit:TooManyStrings', 'A maximum of four strings is allowed.')
end
if nc==1,
  cc=c(1:whites-1);
else
  cc=c(1:whites(1)-1);
  for k=1:nc-1,
    cc=str2mat(cc,c(whites(k)+1:whites(k+1)-1));
  end
end

