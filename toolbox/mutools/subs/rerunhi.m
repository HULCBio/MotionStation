% function again = rerunhi(tmp)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function again = rerunhi(tmp)

   go = 1;
   while go
    yns = input('RERUN H_inf with DIFFERENT bounds/tolerances? (y/n): ','s');
    if strcmp(yns,'y') | strcmp(yns,'''y''')
       again = 1;
       go = 0;
     elseif strcmp(yns,'n') | strcmp(yns,'''n''')
       again = 0;
       go = 0;
     else
       disp('Please enter y or n');
     end
   end