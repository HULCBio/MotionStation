function dydx = twoode(x,y)
%TWOODE  Evaluate the differential equations for TWOBVP. 
% 
%   See also TWOBC, TWOBVP. 

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.5 $  $Date: 2002/04/15 03:37:29 $ 

dydx = [ y(2); -abs(y(1)) ];