function res = twobc(ya,yb)
%TWOBC  Evaluate the residual in the boundary conditions for TWOBVP. 
% 
%   See also TWOODE, TWOBVP. 

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.5 $  $Date: 2002/04/15 03:37:33 $ 

res = [ ya(1); yb(1) + 2 ];
