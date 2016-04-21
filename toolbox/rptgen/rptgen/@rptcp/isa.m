function tf=isa(p,type)
%ISA true if component is of given class

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:43 $

if strcmp(type,'rptcp')
   tf=logical(1);
else
   tf=isa(get(p.h,'UserData'),type);
end