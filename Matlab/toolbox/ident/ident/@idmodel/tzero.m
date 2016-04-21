function [z,gain] = tzero(mod)
%TZERO  Transmission zeros of IDMODEL. Requires the Control System Toolbox
%  
%   Z = TZERO(M) returns the transmission zeros of the IDMODEL M. 
% 
%   [Z,GAIN] = TZERO(M) also returns the transfer function 
%   gain if the system is SISO.
%   
%   By default only the transmission zeros from the measured inputs are
%   computed. To obtain also the zeros from the noise inputs, first convert
%   these using NOISECNV.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2001/04/06 14:22:17 $

mods = ss(mod('m'));
if nargout < 2
   z = tzero(mods);
else
   [z,gain] = tzero(mods),
end
