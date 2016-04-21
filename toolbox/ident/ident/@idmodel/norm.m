function [n,fpeak] = norm(sys,varargin)
%NORM  IDMODEL norms.
%   Requires the Control Systems Toolbox.
%
%   NORM(MOD) is the root-mean-squares of the impulse response of 
%   the IDMODEL object MOD, or equivalently the H2 norm of MOD.
%
%   NORM(MOD,2) is the same as NORM(MOD).
%
%   NORM(MOD,inf) is the infinity norm of MOD, i.e., the peak gain
%   of its frequency response (as measured by the largest singular 
%   value in the MIMO case).
%
%   NORM(MOD,inf,TOL) specifies a relative accuracy TOL for the 
%   computed infinity norm (TOL=1e-2 by default).
%       
%   [NINF,FPEAK] = NORM(MOD,inf) also returns the frequency FPEAK
%   where the gain achieves its peak value NINF.
%
%   By default, only the measured inputs in MOD are used for this
%   calculation. To include also effects from the noise inputs,
%   first convert these using NOISECNV.
%  
%
%   See also SIGMA, FREQRESP.

%   Copyright 1986-2001 The MathWorks, Inc.
%	 $Revision: 1.3 $  $Date: 2001/04/06 14:22:16 $

sys.CovarianceMatrix = [];
try
sys1 = ss(sys('m'));
 
catch
  error(lasterr)
end
if nargin == 1
  varargin{1} = 2;
end

