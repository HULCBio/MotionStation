function y = chirp(t,f0,t1,f1,method,phi,quadtype)
%CHIRP  Swept-frequency cosine generator.
%   Y = CHIRP(T,F0,T1,F1) generates samples of a linear swept-frequency
%   signal at the time instances defined in array T.  The instantaneous
%   frequency at time 0 is F0 Hertz.  The instantaneous frequency F1
%   is achieved at time T1.  By default, F0=0, T1=1, and F1=100.
%
%   Y = CHIRP(T,F0,T1,F1,method) specifies alternate sweep methods.
%   Available methods are 'linear','quadratic', and 'logarithmic'; the
%   default is 'linear'.  Note that for a log-sweep, F1>F0 is required.
%
%   Y = CHIRP(T,F0,T1,F1,method, PHI) allows an initial phase PHI to
%   be specified in degrees.  By default, PHI=0.
%
%   Y = CHIRP(T,FO,T1,F1,'quadratic',PHI,'concave') generates samples of
%   a quadratic swept-frequency signal whose spectrogram is a parabola with
%   its concavity in the positive frequency axis.
%
%   Y = CHIRP(T,FO,T1,F1,'quadratic',PHI,'convex') generates samples of
%   a quadratic swept-frequency signal whose spectrogram is a parabola with
%   its convexity in the positive frequency axis.
%
%   Default values are substituted for empty or omitted trailing input
%   arguments.
%
%   EXAMPLE 1: Compute the spectrogram of a linear chirp.
%     t=0:0.001:2;                 % 2 secs @ 1kHz sample rate
%     y=chirp(t,0,1,150);          % Start @ DC, cross 150Hz at t=1sec 
%     specgram(y,256,1E3,256,250); % Display the spectrogram
%
%   EXAMPLE 2: Compute the spectrogram of a quadratic chirp.
%     t=-2:0.001:2;                % +/-2 secs @ 1kHz sample rate
%     y=chirp(t,100,1,200,'q');  % Start @ 100Hz, cross 200Hz at t=1sec 
%     specgram(y,128,1E3,128,120); % Display the spectrogram
%
%   EXAMPLE 3: Compute the spectrogram of a "convex" quadratic chirp
%     t= 0:0.001:1;                % 1 second @ 1kHz sample rate
%     fo=25;f1=100;                % Start at 25Hz, go up to 100Hz
%     y=chirp(t,fo,1,f1,'q',[],'convex');
%     specgram(y,256,1000)         % Display the spectrogram.
%
%   EXAMPLE 4: Compute the spectrogram of a "concave" quadratic chirp
%     t= 0:0.001:1;                % 1 second @ 1kHz sample rate
%     fo=100;f1=25;                % Start at 100Hz, go down to 25Hz
%     y=chirp(t,fo,1,f1,'q',[],'concave');
%     specgram(y,256,1000)         % Display the spectrogram.

%   See also GAUSPULS, SAWTOOTH, SINC, SQUARE.

%   Author(s): D. Orofino, T. Krauss, 3/96
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/13 00:17:38 $

% Parse inputs, and substitute for defaults:
error(nargchk(1,7,nargin));

if nargin<7 quadtype=[]; end
if nargin<6, phi=[]; end
if nargin<5, method=[]; end
if nargin<4, f1=[]; end
if nargin<3, t1=[]; end
if nargin<2, f0=[]; end
if isempty(phi), phi=0; end
if isempty(method), method='linear'; end
if isempty(f1), f1=100; end
if isempty(t1), t1=1; end
if isempty(f0), f0=0; end


% Parse the method string:
if length(f0)>1,
   %   Y = CHIRP(T,P) specifies a polynomial vector P for the
   %   instantaneous frequency trajectory of the chirp. 
   warnStr = 'Specifying a polynomial sweep vector as the second input argument will not be supported in future releases.';
   warning(generatemsgid('syntaxObselete'),warnStr)

   method='polynomial';
else
   % Set p=1 for linear, 2 for quadratic, 3 for logarithmic
   strs = {'linear','quadratic','logarithmic'};
   p = strmatch(lower(method),strs);
   if isempty(p),
      error('Unknown method selected.');
   elseif length(p)>1,
      error('Ambiguous method selected.');
   end
   method = strs{p};
end

% Parse the  quadtype string and display an error message
% if quadtype is used with a sweep mode besides quadratic.
if ~isempty(quadtype) & ~strcmpi(method,'quadratic')
    errmsg=['The "' quadtype '" mode is not defined for the '...
            method ' sweep method'];
     error(errmsg);
end


% Compute beta, phase and the output.

switch method
case 'polynomial'
    % Polynomial chirp
    y = cos( 2*pi * polyval(polyint(f0),t) );
    
case {'linear'},
    % Polynomial chirp: p is the polynomial order
    y = calculateChirp(f0,f1,t1,p,t,phi);
    
case {'quadratic'},
    
    % Determine the shape of the quadratic sweep - concave or convex
    if isempty(quadtype) & f1>f0
        quadtype = 'concave'; % Default for upsweep
    elseif isempty(quadtype) & f1<f0
        quadtype = 'convex'; % Default for downsweep.
    end
    
    % Polynomial chirp: p is the polynomial order
    % Compute the quadratic chirp output based on quadtype
    y = computequadchirp(f0,f1,t1,p,t,phi,quadtype);
    
    
case 'logarithmic',
    % Logarithmic chirp:
    if f1<f0, error('F1>F0 is required for a log-sweep.'); end
    beta = log10(f1-f0)/t1;
    y = cos(2*pi * ( (10.^(beta.*t)-1)./(beta.*log(10)) + f0.*t + phi/360));
    
end

%---------------------------------------------------------------------------
function yvalue = calculateChirp(f0,f1,t1,p,t,phi)
% General function to compute beta and y for both 
% linear and quadratic modes.
  
beta   = (f1-f0).*(t1.^(-p));
yvalue = cos(2*pi * ( beta./(1+p).*(t.^(1+p)) + f0.*t + phi/360));

%---------------------------------------------------------------------------
function y=computequadchirp(f0,f1,t1,p,t,phi,quadtype)
% Compute the quadratic chirp (upsweep or downsweep) for
% complex or concave modes.

% For the default 'concave-upsweep' and 'convex=downsweep' modes
% call calculateChirp without any changes to the input parameters.
% For the forced 'convex-upsweep' and 'concave-downsweep' call
% calculateChirp with f0 and f1 swapped and t= fliplr(-t)

% For 'convex-upsweep' and 'concave-downsweep' modes
if ((f0<f1) & strcmpi(quadtype,'convex')) | ((f0>f1) &...
    strcmpi(quadtype,'concave'))
    t = fliplr(-t);
    ftemp=f0; f0 = f1; f1 = ftemp;
end

y = calculateChirp(f0,f1,t1,p,t,phi);

%----------------------------------------------------------------------------

% [EOF] chirp.m

