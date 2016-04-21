function this = dspopts
%DSPOPTS   DSP options object.
%   OPTS = DSPOPTS.OPTSOBJECT returns a DSP options object, OPTS, of
%   type OPTSOBJECT. You must specify an options object with DSPOPTS. DSP
%   options objects usually don't take any inputs. Instead, they are
%   constructed via methods on other objects. See help on a specific DSP
%   options object for more details.
%  
%   Once an object is created, its properties may be changed with
%   SET(OPTS,'PARAMNAME',PARAMVAL) or OPTS.PARAMNAME = PARAMVAL.
%  
%   DSPOPTS.OPTSOBJECT can be one of the following (type help
%   DSPOPTS/OPTSOBJECT to get help on a specific data object - e.g. help
%   dspopts/spectrum):
%  
%   dspopts.spectrum       - Options object for PSD method, MSSPECTRUM
%                            method and others.
%   dspopts.pseudospectrum - Options object for PSEUDOSPECTRUM method.
%
%   EXAMPLE: Create a DSPOPTS.SPECTRUM object for a SPECTRUM.WELCH object
%   s = spectrum.welch; 
%   n = 0:199;
%   Fs = 48e3;
%   x = sin(2*pi*n*10e3/Fs)+2*sin(2*pi*n*20e3/Fs)+randn(1,200);
%   opts = psdopts(s,x);
%   opts.Fs = Fs;  % Sets opts.NormalizedFrequency to false
%   d = psd(s,x,opts);
%
%   For more information, enter doc dspopts at the MATLAB command line.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:07:09 $

% Help for the DSPOPTS package.

% [EOF]
