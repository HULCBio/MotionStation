function datr = real(dat)
%IDDATA/REAL Take real part of complex IDDATA signals.
%
%   DATR = REAL(DAT) is the same as applying REAL to all
%   signals in DAT.
  
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2001/12/14 11:42:21 $  
  
datr = dat;
if isreal(dat)
	return
end
y = dat.OutputData;
u = dat.InputData;
for kexp = 1:length(y)
	y{kexp} =real(y{kexp});
	u{kexp} = real(u{kexp});
end
yna = dat.OutputName;
una = dat.InputName;
for ky = 1:length(yna)
	yna{ky} = ['real(',yna{ky},')'];
end

for ku = 1:length(una)
	una{ku} = ['real(',una{ku},')'];
end

datr.OutputData = y;
datr.InputData = u;
datr.InputName = una;
datr.OutputName = yna;

