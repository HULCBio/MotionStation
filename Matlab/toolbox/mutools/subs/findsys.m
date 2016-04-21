%function [iloc,err] = findsys(names,namelen,sysname)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [iloc,err] = findsys(names,namelen,sysname)
   err = 0;
   lend = length(sysname);
   places = find(namelen==lend);
   if length(places) == 0
     err = 1;
   else
     iloc = 0;
     i = 1;
     nomatch = 1;
     while i <= length(places) & nomatch == 1
       if sysname == names(places(i),1:lend)
         iloc = places(i);
         nomatch = 0;
       else
         i = i + 1;
       end
     end
     if iloc == 0
       err = 1;
     end
   end

%
%