function datr = imag(dat)
%IDDATA/IMAG Take imaginary part of complex IDDATA signals.
%
%   DATI = IMAG(DAT) is the same as applying IMAG to all
%   signals in DAT.
  
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2001/12/14 11:42:11 $  
  
datr = dat;
 y = dat.OutputData;
u = dat.InputData;
for kexp = 1:length(y)
	y{kexp} =imag(y{kexp});
	u{kexp} = imag(u{kexp});
end
yna = dat.OutputName;
una = dat.InputName;
for ky = 1:length(yna)
	yna{ky} = ['imag(',yna{ky},')'];
end

for ku = 1:length(una)
	una{ku} = ['imag(',una{ku},')'];
end

datr.OutputData = y;
datr.InputData = u;
datr.InputName = una;
datr.OutputName = yna;

