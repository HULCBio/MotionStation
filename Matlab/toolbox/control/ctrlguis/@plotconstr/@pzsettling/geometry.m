function p = geometry(Constr)
%GEOMETRY  Computes parameters defining constraint geometry.
%
%   Continuous time: returns X such that constraint equivalent to Re(s)<X
%   Discrete time: returns RHO such that constraint equivalent to |z|<RHO

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:08:46 $

TbxPrefs = cstprefs.tbxprefs;
alpha = log(TbxPrefs.SettlingTimeThreshold)/Constr.SettlingTime;  % Re(p)<alpha

if Constr.Ts
    p = exp(alpha*Constr.Ts);
else
    p = alpha;
end
