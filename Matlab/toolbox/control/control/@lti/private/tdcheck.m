function Td = tdcheck(Td)
%TDCHECK  Collapses the I/O delay matrix TD into 2D array
%         when all model have identical delays

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 05:53:26 $

if ndims(Td)>2,
   dvar = diff(Td(:,:,:),1,3);
   if ~any(dvar(:)),
      Td = Td(:,:,1);
   end
end
