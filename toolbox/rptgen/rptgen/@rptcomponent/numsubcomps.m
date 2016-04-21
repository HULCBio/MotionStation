function nsc=numsubcomps(c)
%NUMSUBCOMPS returns the number of subcomponents C has.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:11 $

ID=subsref(c,substruct('.','ref','.','ID'));
if isa(ID,'rptcp')
   nsc=numsubcomps(ID);
else
   nsc=0;
end
