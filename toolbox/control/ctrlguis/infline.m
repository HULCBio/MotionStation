function x = infline(a,b)
%INFLINE  Generate data for infinite HG line.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 04:43:55 $
x = 10.^(0:3:100);
if a==0
   x = [1./fliplr(x(2:end)) , x];
elseif b==0
   x = [-fliplr(x) -1./x(2:end)];
else
   x = [-fliplr(x) , 0 , x];
   if isfinite(a)
      x = [a x(x>a)];
   end
   if isfinite(b)
      x = [x(x<b) b];
   end
end