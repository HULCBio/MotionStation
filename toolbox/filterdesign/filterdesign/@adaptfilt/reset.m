%RESET Reset adaptive filter.
%   RESET(H) resets all the properties of the adaptive filter H that are
%   updated when filtering to the value specified at construction. If no
%   value was specified at construction for a particular property, the
%   property is reset to the default value.
%
%   Example: Denoise a sinusoid and reset the object.
%       h = adaptfilt.lms(5,.05,1,[0.5,0.5,0.5,0.5,0.5]);
%       n = filter(1,[1 1/2 1/3],.2*randn(1,2000)); 
%       d = sin((0:1999)*2*pi*0.005) + n; % Noisy sinusoid
%       x = n;
%       [y,e]= filter(h,x,d);             % e has denoised signal
%       disp(h)
%       reset(h); % Coefficients, States, and NumSamplesProcessed are reset
%       disp(h)     
%
%   See also ADAPTFILT/FILTER.

%   Author: R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/31 19:02:01 $
