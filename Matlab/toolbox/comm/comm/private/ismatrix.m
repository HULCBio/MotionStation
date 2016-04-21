function ecode = ismatrix(Vec)
% ISMATRIX - returns 1 for matrix inputs.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/27 00:14:24 $

   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = 1; % Matrix
      else
         ecode = 0;
      end;
   else
      ecode = 1;
   end;
return;
