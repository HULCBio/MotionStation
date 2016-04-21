function setContents(this,s,Vars)
%SETCONTENTS  Sets values of all variable and link.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:29:27 $
if nargin==2
   Vars = [getvars(this); getlinks(this)];
end
for ct=1:length(Vars)
   vn = Vars(ct).Name;
   this.(vn) = s.(vn);
end