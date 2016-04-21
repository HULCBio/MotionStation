function sys = imag(sys);
%IMAG  Imaginary part of frequency response for FRD models.
%
%   IMAGFRD = IMAG(SYS) computes the imaginary part of the frequency 
%   response contained in the FRD model SYS, including the 
%   contribution of input, output, and I/O delays.  The output 
%   IMAGFRD is an FRD object containing the values of the real 
%   part across frequencies.
%
%   See also REAL, ABS.

%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2003/12/04 01:25:53 $

% Absorb time delays
if hasdelay(sys)
   sys = delay2z(sys);
end

sys.ResponseData = imag(sys.ResponseData);