function datr = abs(dat)
%IDDATA/ABS Take absolute value of complex IDDATA signals.
%
%   DATA = ABS(DAT) is the same as applying ABS to all
%   signals in DAT.
  
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2001/12/14 11:42:00 $  
  
datr = dat;
 y = dat.OutputData;
u = dat.InputData;
for kexp = 1:length(y)
	y{kexp} =abs(y{kexp});
	u{kexp} = abs(u{kexp});
end
yna = dat.OutputName;
una = dat.InputName;
for ky = 1:length(yna)
	yna{ky} = ['abs(',yna{ky},')'];
end

for ku = 1:length(una)
	una{ku} = ['abs(',una{ku},')'];
end

datr.OutputData = y;
datr.InputData = u;
datr.InputName = una;
datr.OutputName = yna;
