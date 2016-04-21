function p = iopole(sys)
%IOPOLE   Get poles for each I/O transfer.
%
%  Single model, low-level utility.

%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.2 $ $Date: 2002/04/10 06:08:37 $
[ny,nu] = size(sys.den);
p = cell(ny,nu);
for ct=1:ny*nu
   p{ct} = roots(sys.den{ct});
end