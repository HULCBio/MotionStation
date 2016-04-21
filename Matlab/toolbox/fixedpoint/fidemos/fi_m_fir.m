function [y,z] = fi_m_fir(b, x, z, y)
% Copyright 2004 The MathWorks, Inc.

for k=1:length(x);
  z = [x(k);z(1:end-1)];
  y(k) = b*z;
end
