function datr = unwrap(dat)
%IDDATA/UNWRAP Unwrap phases of complex IDDATA signals.
%
%   DATU = UNWRAP(DAT) is the same as applying UNWRAP to each
%   signals in DAT.
  
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2001/12/14 11:42:24 $  
  
  
datr = dat;
 y = dat.OutputData;
u = dat.InputData;
for kexp = 1:length(y)
	y{kexp} =unwrap(angle(y{kexp}));
	u{kexp} = unwrap(angle(u{kexp}));
end
yna = dat.OutputName;
una = dat.InputName;
for ky = 1:length(yna)
	yna{ky} = ['angle(',yna{ky},')'];
end

for ku = 1:length(una)
	una{ku} = ['angle(',una{ku},')'];
end

datr.OutputData = y;
datr.InputData = u;
datr.InputName = una;
datr.OutputName = yna;
