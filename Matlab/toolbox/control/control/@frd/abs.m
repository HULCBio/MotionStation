function sys = abs(sys);
%ABS  Frequency response magnitude for FRD models.
%
%   ABSFRD = ABS(SYS) computes the magnitude of the frequency 
%   response contained in the FRD model SYS.  For MIMO models,
%   the magnitude is computed for each entry.  The output ABSFRD
%   is an FRD object containing the magnitude data across 
%   frequencies.
%
%   See also BODEMAG, SIGMA, REAL, IMAG, FNORM.

%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2003/12/04 01:25:51 $


sys.ResponseData = abs(sys.ResponseData);

sizeSys = size(sys.ResponseData);

% Set I/O delays to zero
sys.lti = pvset(sys.lti,'InputDelay',zeros(sizeSys(2),1),...
   'OutputDelay',zeros(sizeSys(1),1),...
   'ioDelay',zeros(sizeSys(1:2)));
