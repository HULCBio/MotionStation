function datr = phase(dat)
%IDDATA/PHASE Compute phase (in radians) for complex IDDATA signals.
%
%   DATP = PHASE(DAT) is the same as applying PHASE to all
%   signals in DAT.
  
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2001/12/14 11:42:13 $ 
  
datr = dat;
y = dat.OutputData;
u = dat.InputData;
for kexp = 1:length(y)
  for ky=1:size(y{kexp},2)
	y{kexp}(:,ky) =phase(y{kexp}(:,ky).').';
  end
  for ku = 1:size(u{kexp},2)
	u{kexp}(:,ku) = phase(u{kexp}(:,ku).').';
  end
  
end
yna = dat.OutputName;
una = dat.InputName;
for ky = 1:length(yna)
	yna{ky} = ['phase(',yna{ky},')'];
end

for ku = 1:length(una)
	una{ku} = ['phase(',una{ku},')'];
end

datr.OutputData = y;
datr.InputData = u;
datr.InputName = una;
datr.OutputName = yna;

