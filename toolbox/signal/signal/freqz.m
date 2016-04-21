function [hh,w,s,options] = freqz(b,a,varargin)
%FREQZ Digital filter frequency response.
%   [H,W] = FREQZ(B,A,N) returns the N-point complex frequency response
%   vector H and the N-point frequency vector W in radians/sample of
%   the filter:
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
%   given numerator and denominator coefficients in vectors B and A. The
%   frequency response is evaluated at N points equally spaced around the
%   upper half of the unit circle. If N isn't specified, it defaults to
%   512.
%
%   [H,W] = FREQZ(B,A,N,'whole') uses N points around the whole unit circle.
%
%   H = FREQZ(B,A,W) returns the frequency response at frequencies 
%   designated in vector W, in radians/sample (normally between 0 and pi).
%
%   [H,F] = FREQZ(B,A,N,Fs) and [H,F] = FREQZ(B,A,N,'whole',Fs) return 
%   frequency vector F (in Hz), where Fs is the sampling frequency (in Hz).
%   
%   H = FREQZ(B,A,F,Fs) returns the complex frequency response at the 
%   frequencies designated in vector F (in Hz), where Fs is the sampling 
%   frequency (in Hz).
%
%   FREQZ(B,A,...) with no output arguments plots the magnitude and
%   unwrapped phase of the filter in the current figure window.
%
%   See also FILTER, FFT, INVFREQZ, FVTOOL, and FREQS.

%   Author(s): R. Losada and P. Pacheco
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.43 $  $Date: 2002/04/15 01:18:41 $ 

error(nargchk(1,5,nargin));

if nargin == 1, 
   a = 1; % Assume FIR
end

if nargin <= 2,
   varargin = {};
end

[options,msg] = freqz_options(varargin{:});
error(msg);

% Make b and a rows
b = b(:).';
a = a(:).';

nb = length(b);
na = length(a);
a  = [a zeros(1,nb-na)];  % Make a and b of the same length
b  = [b zeros(1,na-nb)];
n  = length(a); % This will be the new length of both num and den

w      = options.w;   
Fs     = options.Fs;
nfft   = options.nfft;
fvflag = options.fvflag;

% Actual Frequency Response Computation 
if fvflag,
   %   Frequency vector specified.  Use Horner's method of polynomial
   %   evaluation at the frequency points and divide the numerator
   %   by the denominator.
   %
   %   Note: we use positive i here because of the relationship
   %            polyval(a,exp(i*w)) = fft(a).*exp(i*w*(length(a)-1))
   %               ( assuming w = 2*pi*(0:length(a)-1)/length(a) )
   %        
   if ~isempty(Fs), % Fs was specified, freq. vector is in Hz
      digw = 2.*pi.*w./Fs; % Convert from Hz to rad/sample for computational purposes
   else
      digw = w;
   end
       
   s = exp(i*digw); % Digital frequency must be used for this calculation
   h = polyval(b,s) ./ polyval(a,s);   
else   
   % freqvector not specified, use nfft and RANGE in calculation
   s = strmatch(lower(options.range),{'twosided','onesided'});
         
   if s.*nfft < n,
      % Data is larger than FFT points, wrap modulo s*nfft      
      b = datawrap(b,s.*nfft);   
      a = datawrap(a,s.*nfft);
   end  
         
   % dividenowarn temporarily shuts off warnings to avoid "Divide by zero"
   h = dividenowarn(fft(b,s.*nfft),fft(a,s.*nfft)).';
   % When RANGE = 'half', we computed a 2*nfft point FFT, now we take half the result
   h = h(1:nfft);
   h = h(:); % Make it a column only when nfft is given (backwards comp.)
   w = freqz_freqvec(nfft, Fs, s);
   w = w(:); % Make it a column only when nfft is given (backwards comp.)
end

% Generate the default structure to pass to freqzplot
s.plot = 'both';
s.fvflag = fvflag;
s.yunits = 'db';
s.xunits = 'rad/sample';
s.Fs     = Fs; % If rad/sample, Fs is empty
if ~isempty(Fs),
   s.xunits = 'Hz';
end

if nargout == 0, % Plot when no output arguments are given   
   phi = phasez(b,a,varargin{:});
   data(:,:,1) = h;
   data(:,:,2) = phi;
   freqzplot(data,w,s,'magphase');
else
   hh = h;
end

%-------------------------------------------------------------------------------
function [options,msg] = freqz_options(varargin)
%FREQZ_OPTIONS   Parse the optional arguments to FREQZ.
%   FREQZ_OPTIONS returns a structure with the following fields:
%   options.nfft         - number of freq. points to be used in the computation
%   options.fvflag       - Flag indicating whether nfft was specified or a vector was given
%   options.w            - frequency vector (empty if nfft is specified)
%   options.Fs           - Sampling frequency (empty if no Fs specified)
%   options.range        - 'half' = [0, Nyquist); 'whole' = [0, 2*Nyquist)


% Set up defaults
options.nfft   = 512;
options.Fs     = [];
options.w      = [];
options.range  = 'onesided';
options.fvflag = 0;
msg            = '';
isreal_x       = []; % Not applicable to freqz

[options,msg] = psdoptions(isreal_x,options,varargin{:});

if any(size(options.nfft)>1), 
   % frequency vector given, may be linear or angular frequency
   options.w = options.nfft;
   options.fvflag = 1;
end

% [EOF] freqz.m


