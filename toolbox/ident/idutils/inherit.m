function sys = inherit(sys,pre)
%INHERIT  Lets a new IDMODEL object inherit the properties of another one.
% Except ParameterVector, CovarianceMatrix and NoiseVariance.
%
%   SYS = INHERIT(SYS,OLDSYS)

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/01/21 09:38:51 $


%% Inherit everything but parameter vector and covariancematrix
idm = pvget(pre,'idmodel');
par = pvget(sys,'ParameterVector');
cov = pvget(sys,'CovarianceMatrix');
noisev = pvget(sys,'NoiseVariance');
%noi = pvget(sys,'NoiseVariance');
idm = pvset(idm,'ParameterVector',par,'CovarianceMatrix',cov,...
   'NoiseVariance',noisev);
sys = pvset(sys,'idmodel',idm);
