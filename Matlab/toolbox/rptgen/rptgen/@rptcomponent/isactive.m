function active=isactive(c)
%ISACTIVE     True if the component is active

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:08 $

c=struct(c);

active=logical(0);
if isfield(c,'comp')
   if isfield(c.comp,'Active')
      active=logical(c.comp.Active);
   end
end