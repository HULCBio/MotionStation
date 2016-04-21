function ms = llset(m,field,value)
%LLSET  obsolete function

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:16:59 $

ms=m;
for kk=1:length(field)
 eval(['ms.',field{kk},'=','value{kk};']);
end

