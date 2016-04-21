function [z,k] = iozero(sys)
%IOZERO   Get zeros and gains for each I/O transfer.
%
%  Single model, low-level utility.

%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.3 $ $Date: 2002/04/10 06:08:34 $
[ny,nu] = size(sys.num);
z = cell(ny,nu);
k = zeros(ny,nu);
for ct=1:ny*nu
   num = sys.num{ct};
   den = sys.den{ct};
   % zeros = roots of numerator
   z{ct} = roots(num);
   % gain = num(1)/den(1)
   num = num(num~=0);
   den = den(den~=0);
   if ~isempty(num)
      k(ct) = num(1)/den(1);
   end
end