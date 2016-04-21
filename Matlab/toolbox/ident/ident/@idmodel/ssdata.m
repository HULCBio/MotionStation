function  ssdata(th);
%IDMODEL/SSDATA  Returns state-space matrices for IDMODEL models.
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
%   M is any IDMODEL  object, like IDPOLY, IDARX, IDSS and IDGREY.
%   The output are the matrices of the state-space model
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%  in continuous or discrete time, depending on the model's sampling
%  time Ts.
%
%  [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M)
%
%  returns also the model uncertainties (standard deviations) dA
%  etc.
%
%  If M is a time series (no input), B and D will be returned as
%  empty matrices. Note that the noise source e is the innovations
%  of the output. To convert the noise source to a regular input
%  use M = NOISECNV(M,noise) with an option to normalize it to unit
%  variance.
%
%  See also NOISECNV, TFDATA, ZPKDATA.

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/10 23:17:44 $
  
   