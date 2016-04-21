function [par,P,lam]=th2par(th);
%TH2PAR converts the theta-format to parameters and covariance matrix.
%   OBSOLETE function. Use model properties 'ParmeterVector', 'CovarianceMatrix'
%   and 'NoiseVariance' instead. See IDPROPS IDMODEL.
%
%   [PAR,P,LAM] = TH2PAR(TH)
%
%   TH: The model defined in the THETA-format (see also THETA).
%
%   PAR: The parameter vector in THETA (nominal or estimated
%        values of the free parameters)
%   P:   The covariance matrix of the estimated parameters
%   LAM: The variance (covariance matrix) of the innovations

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:41 $

if nargin<1
  disp('Usage: [PARs,PAR_COV_MATRIX,NOISE_COV_MATRIX] = TH2PAR(TH)')
  return
end
par = get(th,'ParameterVector');
P = get(th,'CovarianceMatrix');
lam = get(th,'NoiseVariance');

