function g = dcgain(sys)
%DCGAIN  DC gain of LTI models.
%
%   K = DCGAIN(SYS) computes the steady-state (D.C. or low frequency)
%   gain of the LTI model SYS.
%
%   If SYS is an array of LTI models with dimensions [NY NU S1 ... Sp],
%   DCGAIN returns an array K with the same dimensions such that
%      K(:,:,j1,...,jp) = DCGAIN(SYS(:,:,j1,...,jp)) .  
%
%   See also NORM, EVALFR, FREQRESP, LTIMODELS.

%   Author(s): S. Almy
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.6 $  $Date: 2002/04/10 06:18:09 $

error('DCGAIN is not supported for Frequency Response Data objects.')