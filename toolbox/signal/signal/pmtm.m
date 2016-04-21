function varargout = pmtm(x,varargin);
%PMTM   Power Spectral Density (PSD) estimate via the Thomson multitaper 
%   method (MTM).
%   Pxx = PMTM(X) returns the PSD of a discrete-time signal vector X in 
%   the vector Pxx.  Pxx is the distribution of power per unit frequency.
%   The frequency is expressed in units of radians/sample.  PMTM uses a 
%   default FFT length equal to the greater of 256 and the next power of
%   2 greater than the length of X.  The FFT length determines the length
%   of Pxx.
%
%   For real signals, PMTM returns the one-sided PSD by default; for 
%   complex signals, it returns the two-sided PSD.  Note that a one-sided 
%   PSD contains the total power of the input signal.
%
%   Pxx = PMTM(X,NW) specifies NW as the "time-bandwidth product" for the
%   discrete prolate spheroidal sequences (or Slepian sequences) used as 
%   data windows.  Typical choices for NW are 2, 5/2, 3, 7/2, or 4.  The 
%   number of sequences used to form Pxx is 2*NW-1.  If empty or omitted,
%   NW defaults to 4.
%   
%   Pxx = PMTM(X,NW,NFFT) specifies the FFT length used to calculate 
%   the PSD estimates.  For real X, Pxx has length (NFFT/2+1) if NFFT is 
%   even, and (NFFT+1)/2 if NFFT is odd.  For complex X, Pxx always has 
%   length NFFT.  If empty, NFFT defaults to the greater of 256
%   and the next power of 2 greater than the length of X.
%
%   [Pxx,W] = PMTM(...) returns the vector of normalized angular 
%   frequencies, W, at which the PSD is estimated.  W has units of 
%   radians/sample.  For real signals, W spans the interval [0,Pi] when
%   NFFT is even and [0,Pi) when NFFT is odd.  For complex signals, W 
%   always spans the interval [0,2*Pi).
%
%   [Pxx,F] = PMTM(...,Fs) specifies a sampling frequency Fs in Hz and
%   returns the power spectral density in units of power per Hz.  F is a
%   vector of frequencies, in Hz, at which the PSD is estimated.  For real 
%   signals, F spans the interval [0,Fs/2] when NFFT is even and [0,Fs/2)
%   when NFFT is odd.  For complex signals, F always spans the interval 
%   [0,Fs).  If Fs is empty, [], the sampling frequency defaults to 1 Hz.  
%
%   [Pxx,F] = PMTM(...,Fs,method) uses the algorithm specified in method 
%   for combining the individual spectral estimates:
%      'adapt'  - Thomson's adaptive non-linear combination (default).
%      'unity'  - linear combination with unity weights.
%      'eigen'  - linear combination with eigenvalue weights.
%
%   [Pxx,Pxxc,F] = PMTM(...,Fs,method) returns the 95% confidence interval
%   Pxxc for Pxx.  
% 
%   [Pxx,Pxxc,F] = PMTM(...,Fs,method,P) where P is a scalar between 0 and
%   1, returns the P*100% confidence interval for Pxx.  Confidence 
%   intervals are computed using a chi-squared approach.  Pxxc(:,1) is the 
%   lower bound of the confidence interval, Pxxc(:,2) is the upper bound.
%   If left empty or omitted, P defaults to .95.
%
%   [Pxx,Pxxc,F] = PMTM(X,E,V,NFFT,Fs,method,P) is the PSD estimate,
%   confidence interval, and frequency vector from the data tapers in E
%   and their concentrations V.  Type HELP DPSS for a description of the 
%   matrix E and the vector V.
%
%   [Pxx,Pxxc,F] = PMTM(X,DPSS_PARAMS,NFFT,Fs,method,P) uses the cell 
%   array DPSS_PARAMS containing the input arguments to DPSS (listed in
%   order, but excluding the first argument) to compute the data tapers. 
%   For example, PMTM(x,{3.5,'trace'},512,1000) calculates the prolate 
%   spheroidal sequences for NW=3.5, NFFT=512, and Fs=1000, and displays
%   the method that DPSS uses for this calculation. Type HELP DPSS for 
%   other options.
%
%   [...] = PMTM(...,'twosided') returns a two-sided PSD of a real signal
%   X.  In this case, Pxx will have length NFFT and will be computed  over
%   the interval [0,2*Pi) if Fs is not specified and over the interval
%   [0,Fs) if Fs is specified.  Alternatively, the string 'twosided' can be
%   replaced with the string 'onesided' for a real signal X.  This would
%   result in the default behavior.  
%
%   The string input arguments may be placed in any position in the input
%   argument list after the second input argument, unless E and V are 
%   specified, in which case the strings may be placed in any position
%   after the third input argument.
%
%   PMTM(...) with no output arguments plots the PSD in the current figure
%   window, with confidence intervals.
%
%   EXAMPLE:
%      Fs = 1000;   t = 0:1/Fs:.3;  
%      x = cos(2*pi*t*200)+randn(size(t)); % A cosine of 200Hz plus noise
%      pmtm(x,3.5,[],Fs);                  % Uses the default NFFT.
%
%   See also DPSS, PWELCH, PERIODOGRAM, PMUSIC, PBURG, PYULEAR, PCOV,
%   PMCOV, PEIG, SPECTRUM/MTM, DSPDATA/PSD.

%   References: 
%     [1] Thomson, D.J."Spectrum estimation and harmonic analysis."
%         In Proceedings of the IEEE. Vol. 10 (1982). Pgs 1055-1096.
%     [2] Percival, D.B. and Walden, A.T., "Spectral Analysis For Physical
%         Applications", Cambridge University Press, 1993, pp. 368-370. 

%   Author: Eric Breitenberger, version date 10/1/95.
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.17.4.6 $   $Date: 2004/04/13 00:18:15 $

error(nargchk(1,8,nargin));

% Parse the inputs, set up default values, and return any error messages.
[params,err_msg] = parseinputs(x,varargin{:});
error(err_msg);

% Compute the two-sided power spectrum via MTM.
[S,k] = mtm_spectrum(x,params);

% Generate the freq vector in [rad/sample] at which Pxx will be computed.
% If Fs is not empty, w will be converted to Hz in computepsd below.
nfft = params.nfft;
w = psdfreqvec(nfft); 

% Compute the 1- or 2-sided PSD [Power/freq] and the corresponding power 
% spectrum, Sxx, [Power]. Also, compute the frequencies at which the psd 
% is computed and the corresponding frequency units.  (Sxx is not used.)
[Pxx,f,units] = computepsd(S,w,params.range,params.nfft,params.Fs,'psd');  

% Calculate confidence limits ONLY when needed, since it can take a while.
if nargout==0 | nargout>=3,
   Pxxc=Pxx*chi2conf(params.ConfInt,k);
end

% Output
switch nargout,
case 0,
   % If no output arguments are specified plot the PSD w/ conf intervals.
   f = {f};
   if strcmpi(units,'Hz'), f = {f{:},'Fs',params.Fs}; end
   hpsd = dspdata.psd([Pxx Pxxc],f{:},'SpectrumType',params.range);

   % Create a spectrum object to store in the PSD object's metadata.
   hspec = spectrum.mtm(params.E,params.V,params.MTMethod);
   hpsd.Metadata.setsourcespectrum(hspec);

   plot(hpsd);

case 1, varargout = {Pxx};
case 2, varargout = {Pxx,f};
case 3, varargout = {Pxx,Pxxc,f};
case 4, varargout = {Pxx,Pxxc,f,Sxx};
end

%----------------------------------------------------------------------
function [S,k] = mtm_spectrum(x,params);
%MTM_SPECTRUM Compute the power spectrum via MTM.
%
% Inputs:
%   x      - Input data vector.
%   params - Structure containing pmtm's input parameter list, except for
%            the input data sequence, x; it contains the following fields:
%      nfft     - Number of frequency points to evaluate the PSD at; 
%                 the default is max(256,2^nextpow2(N)).
%      Fs       - The sampling frequency; default is 1.
%      range    - default is 'onesided' or real signals and 'twosided' for 
%               - complex signals.
%      ConfInt  - Confidence interval; default is .95.
%      MTMethod - Algorithm used in MTM; default is 'adapt'.
%      E        - Matrix containing the discrete prolate spheroidal 
%                 sequences (dpss).
%      V        - Vector containing the concentration of the dpss.
%      NW       - Time-bandwidth product; default is 4.
%
% Outputs:
%   S      - Power spectrum computed via MTM.
%   k      - Number of sequences used to form Pxx.

% Extract some parameters from the input structure for convenience.
nfft = params.nfft ;
Fs = params.Fs;
E  = params.E;
V  = params.V;
NW = params.NW;

N = length(x);
x = x(:);
k = min(round(2*NW),N); % By convention, the first 2*NW 
                        % eigenvalues/vectors are stored 
k = max(k-1,1);
V = V(1:k);

% Compute the windowed DFTs.
if N<=nfft
   Sk=abs(fft(E(:,1:k).*x(:,ones(1,k)),nfft)).^2;
else  % Wrap the data modulo nfft if N > nfft
   % use CZT to compute DFT on nfft evenly spaced samples around the 
   % unit circle:
   Sk=abs(czt(E(:,1:k).*x(:,ones(1,k)),nfft)).^2; 
end

% Compute the MTM spectral estimates, compute the whole spectrum 0:nfft.
switch params.MTMethod,
   
case 'adapt'
   % Set up the iteration to determine the adaptive weights: 
   
   sig2=x'*x/N;              % Power
   S=(Sk(:,1)+Sk(:,2))/2;    % Initial spectrum estimate
   Stemp=zeros(nfft,1);
   S1=zeros(nfft,1);
   
   % The algorithm converges so fast that results are
   % usually 'indistinguishable' after about three iterations.
   
   % This version uses the equations from [2] (P&W pp 368-370).
   
   % Set tolerance for acceptance of spectral estimate:
   tol=.0005*sig2/nfft;
   i=0;
   a=sig2*(1-V);
   
   % Do the iteration:
   while sum(abs(S-S1)/nfft)>tol
      i=i+1;
      % calculate weights
      b=(S*ones(1,k))./(S*V'+ones(nfft,1)*a'); 
      % calculate new spectral estimate
      wk=(b.^2).*(ones(nfft,1)*V');
      S1=sum(wk'.*Sk')./ sum(wk');
      S1=S1';
      Stemp=S1; S1=S; S=Stemp;  % swap S and S1
   end
   
case {'unity','eigen'}
   % Compute the averaged estimate: simple arithmetic averaging is used. 
   % The Sk can also be weighted by the eigenvalues, as in Park et al. 
   % Eqn. 9.; note that that eqn. apparently has a typo; as the weights
   % should be V and not 1/V.
   if strcmp(params.MTMethod,'eigen')
      wt = V(:);    % Park estimate
   else
      wt = ones(k,1);
   end
   S = Sk*wt/k;
end

%----------------------------------------------------------------------
function [params,err_msg] = parseinputs(x,varargin);
%PARSEINPUTS Parse the inputs passed to pmtm.m and return a structure
%            containing all the parameters passed to PMTM set to either
%            default values or user defined values.
%
% Inputs:
%   x        - Input data vector.
%   varargin - Input parameter list passed to pmtm, except for x.
%
% Outputs:
%   params   - Structure containing pmtm's input parameter list, except for
%              the input data sequence, x; it contains the following fields:
%      nfft     - Number of frequency points to evaluate the PSD at; 
%                 the default is max(256,2^nextpow2(N)).
%      Fs       - The sampling frequency; default is .
%      range    - default is 'onesided' or real signals and 'twosided' for 
%               - complex signals.
%      ConfInt  - Confidence interval; default is .95.
%      MTMethod - Algorithm used in MTM; default is 'adapt'.
%      E        - Matrix containing the discrete prolate spheroidal 
%                 sequences.
%      V        - Vector containing the concentration of the dpss.
%      NW       - Time-bandwidth product; default is 4.
%
%   err_msg  - String containing an error message if an error occurred.

% Set default parameter values.
N = length(x);
params  = [];
err_msg = '';

if isreal(x), 
   range = 'onesided';
else
   range = 'twosided'; 
end

% Parse the input arguments up to NFFT (exclusive). 
% If E and V are not specified, calculate them.
[E,V,NW,indx,err_msg] = getEV(N,varargin{:});
if err_msg, return; end

% NOTE: The psdoptions function REQUIRES a structure with the following 
%       fields.  Any changes to the structure, such as adding/removing 
%       fields, should be done after the call to psdoptions.
params.nfft    = max(256,2^nextpow2(N));
params.Fs      = [];
params.range   = range;
params.ConfInt = .95;
params.MTMethod= 'adapt';

% Call psdoptions to handle the remaining input arg list starting with NFFT.
% Overwrite default options with user specified options (if specified).
if length(varargin) > 1, 
   [params,err_msg] = psdoptions(isreal(x),params,varargin{indx:end});
   if err_msg, return, end;
end

% Add remaining fields to the return structure.
params.E  = E;
params.V  = V;
params.NW = NW;

%----------------------------------------------------------------------
function [E,V,NW,indx,err_msg] = getEV(N,varargin);
% GETEV  Parse the input arguments up to, but not including, Nfft and 
%        calculate E and V if not specified.
%
% Inputs:
%   N        - Length of the input data sequence, x.
%   varargin - Input parameter list passed to pmtm, except for x.
%
% Outputs:
%   E        - Matrix containing the discrete prolate spheroidal 
%              sequences (dpss).
%   V        - Vector containing the concentration of the dpss.
%   NW       - Time-bandwidth product; default is 4.
%   indx     - Index indicating starting location of options in pmtm's 
%              input argument list.
%   err_msg  - String containing an error message if an error occurred.

% Define defaults & intialize output variables (in case of early return).
E       = [];
V       = [];
NW      = 4;
indx    = 2;  % Index where the options begin in the input arg list
err_msg = '';

% The 2nd input arg to pmtm can be a
%    1. (X,NW,...)            scalar
%    2. (X,E,V,...)           matrix E, hence, 3rd input must be a vector (V) 
%    3. (X,{dpss_params},...) cell containing the input argument list to dpss 

if length(varargin)>0,
   if length(varargin{1})>0,
      NW = varargin{1};
   end
   if iscell(NW),           % NW is a cell array
      [E,V] = dpss(N,NW{:});
      NW = NW{1};
   elseif length(NW)>1,     % NW is the matrix E (==>V must be specified)
      E = NW;
      if length(varargin)<2,
         err_msg = 'Must provide V with E matrix.';
         return;
      else
         V = varargin{2};
      end
      indx = 3; % Update index of begining of options in the input arg list
      if size(E,2)~=length(V)
         err_msg = 'Number of columns of E and length of V do not match.';
         return;
      end
      NW = size(E,2)/2;  % only used for computation of # of tapers k
   else                     % NW is a scalar
      % Get the dpss, one way or another:
      [E,V] = dpss(N,NW);
   end
else
   % Get the dpss, one way or another:
   [E,V] = dpss(N,NW);
end

% [EOF] pmtm.m

