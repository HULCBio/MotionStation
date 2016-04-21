function sys = real(sys);
%REAL  Real part of frequency response for FRD models.
%
%   REALFRD = REAL(SYS) computes the real part of the frequency 
%   response contained in the FRD model SYS, including the 
%   contribution of input, output, and I/O delays.  The output 
%   REALFRD is an FRD object containing the values of the real 
%   part across frequencies.
%
%   See also IMAG, ABS.

%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2003/12/04 01:25:55 $

% Absorb time delays
if hasdelay(sys)
   sys = delay2z(sys);
end

sys.ResponseData = real(sys.ResponseData);