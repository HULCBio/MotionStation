function [Ncap,d]=getncap(th)
%GETNCAP Gets the number of data points and the number of parameters for a model.
%   OBSOLETE function. Use field 'DataLength' in MODEL property 'EstimationInfo' instead.
%
%   [Ncap,D]=getncap(TH);
%
%   TH: The model, defined i any IDMODEL format.
%   Ncap: The number of data points (samples) that were used to estimate TH
%      (If the model is not estimated, Ncap is returned as [])
%   D: The number of estimated parameters in the model structure

%   L. Ljung 10-2-90,9-9-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:38 $

if nargin < 1
   disp('Usage: [NUMBER_OF_DATA,NUMBER_OF_PARS] = GETNCAP(TH)')
   return
end

Ncap=[];
es = get(th,'EstimationInfo');
try
   Ncap = es.DataLength;
   d = length(th.ParameterVector);
catch
end

 
