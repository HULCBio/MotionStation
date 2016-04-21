function [w,amp,phas,sdamp,sdphas] = getff(g,nu,ny)
%GETFF  Selects the frequency function (for own plotting).
%   OBSOLETE function. Use BODE instead.
%
%   [W,AMP,PHAS] = GETFF(G,NU,NY)
%
%   W: The frequency scale in radians/second
%   AMP: The amplitude function
%   PHAS: The phase function (in degrees)
%   G: The frequency function in the IDFRD format. See also IDFRD.
%
%   NU: The input number (noise input is counted as input # 0)
%       (Default 1. If G contains all spectra, then default is 0)
%   NY: The output number (default 1)
%
%   If several entries in G correspond to the same input-output relation
%   W, AMP and PHAS will have the corresponding number of columns.
%
%   The standard deviation of the amplitude and the standard deviation of
%   the phase are obtained by
%
%   [W,AMP,PHAS,SD_AMP,SD_PHAS] = GETFF(G,NU,NY)

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.10 $ $Date: 2001/04/06 14:21:38 $

if nargin < 1
   disp('Usage: [FREQs,AMPLITUDE,PHASE] = GETFF(G)')
   disp('       [FREQs,AMP,PHASE,SDamp,SDphase] = GETFF(G,INPUT_no,OUTPUT_no)')
   return
end
if nargin<3, ny=1;end
if isempty(ny), ny=1;end
if nargin<2, nu=1;end, if isempty(nu), nu=1;end
%%LL%% Think about the noise nu==0
[amp,phas,w,sdamp,sdphas] = boderesp(g(ny,nu));
if isempty(amp);
   return
end

amp=squeeze(amp(1,1,:));
if ~isempty(sdamp)
sdamp=squeeze(sdamp(1,1,:));
end
phas=squeeze(phas(1,1,:));
if ~isempty(sdphas)
sdphas=squeeze(sdphas(1,1,:));
end
w = w(:);
return
 
