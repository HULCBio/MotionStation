function ecode = ismatrix(Vec)
% ISMATRIX - returns 1 for matrix inputs.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2002/10/20 12:43:07 $

   if(ndims(Vec) == 2)
      if(all([size(Vec,1)>1 size(Vec,2)>1]))
         ecode = logical(1); % Matrix
      else
         ecode = logical(0);
      end;
   else
      ecode = logical(1);
   end;
return;