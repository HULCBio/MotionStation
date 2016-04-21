function sys = setnoime(sys1)
% SETNOIME
% Help function to SUBSREF
% All channels in sys1 are converted to measured channels
% but no scaling of the noise takes place, in contrast to 'all'

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $ $Date: 2004/04/10 23:17:39 $

[Ny,Nu]=size(sys1);
ynam = sys1.OutputName;
if norm(sys1.NoiseVariance) == 0
    sys = sys1;
    return
end
sys1.NoiseVariance = eye(Ny);
sys1.EstimationInfo.DataLength = inf;
ut = sys1.Utility;
try
    pm = ut.Pmodel;
catch
    pm = [];
end
if ~isempty(pm)
    pm.NoiseVariance = eye(Ny);
    pm.EstimationInfo.DataLength = inf;
    ut.Pmodel = pm;
    sys1.Utility = ut;
end
  
sys = sys1(:,'allx9');
ut = sys.Utility;
for kk = 1:Ny
   sys.InputName{kk+Nu} = [noiprefi('e'),ynam{kk}];
end

try
    sys3 = ut.Pmodel;
catch
    sys3 = [];
end
if ~isempty(sys3)
sys3.InputName = sys.InputName;
ut.Pmodel = sys3;
sys.Utility = ut;
end