function varargout = pmusic( x, p, varargin )
%PMUSIC  Frequency estimate via the MUSIC eigenvector method.
%   S = PMUSIC(X,P) returns the pseudospectrum of a discrete-time signal
%   vector X in the vector S. P is the number of complex sinusoids in
%   the signal X.  If X is a data matrix, each row is interpreted as
%   a separate sensor measurement or trial.  You can use the function
%   CORRMTX to generate data matrices to be used here.
%
%   S = PMUSIC(R,P,'corr') returns the pseudospectrum of a discrete-time
%   signal whose correlation matrix estimate is given by the positive
%   definite matrix R. Exact conjugate-symmetry of R is ensured by forming
%   (R+R')/2 inside the function.
%
%   If P is a two element vector, P(2) is used as a cutoff for signal and
%   noise subspace separation.  All eigenvalues greater than P(2) times
%   the smallest eigenvalue are designated as signal eigenvalues.  In 
%   this case, the signal subspace dimension is at most P(1).
%
%   For real signals, PMUSIC returns half the pseudospectrum by default;
%   for complex signals, it returns the whole pseudospectrum.  To return
%   the whole pseudospectrum for real signals use PMUSIC(X,P,'whole').
%   Note that the strings 'whole' and 'corr' can be specified at any
%   position after P.
%
%   S = PMUSIC(X,P,NFFT) specifies the FFT length used to calculate the
%   pseudospectrum.  For real X, S has length (NFFT/2+1) if NFFT is even,
%   and (NFFT+1)/2 if NFFT is odd.  For complex X, S always has length 
%   NFFT.  If empty, the default NFFT is 256.
%
%   [S,W] = PMUSIC(...) returns the vector of normalized angular 
%   frequencies, W, at which the pseudospectrum is evaluated.  W has
%   units of rad/sample.  For real signals, W spans the interval [0,Pi]
%   when NFFT is even and [0,Pi) when NFFT is odd.  For complex signals,
%   W always spans the interval [0,2*Pi).
%
%   [S,F] = PMUSIC(...,Fs) specifies a sampling frequency Fs in Hz and
%   returns the pseudospectrum as a function of frequency in Hz.  F is a
%   vector of frequencies, in Hz, at which the pseudospectrum is computed.
%   For real signals, F spans the interval [0,Fs/2] when NFFT is even and
%   [0,Fs/2) when NFFT is odd.  For complex signals, F always spans the
%   interval [0,Fs).  If Fs is empty, [], the sampling frequency defaults
%   to 1 Hz.  
%
%   [S,F] = PMUSIC(...,NW,NOVERLAP) divides the signal vector, X, into
%   sections of length NW which overlap by NOVERLAP samples.  The sections 
%   are concatenated as the rows of a matrix that multiplied times its
%   transposed results in an estimate of the NW by NW correlation matrix of
%   X.  If NW is a scalar, it is ignored if X is already a matrix. NOVERLAP
%   is also ignored in this case. If NW is a vector, the rows of the data
%   matrix are windowed with NW.  The window length must equal the number
%   of columns in the data matrix.  If empty or omitted, NW = 2*P, and
%   NOVERLAP = NW-1.
%
%   [S,W,V,E] = PMUSIC(...) returns a matrix V whose columns are the
%   eigenvectors corresponding to the noise subspace and a vector E with
%   all eigenvalues. This syntax is useful to determine the frequencies
%   and powers of the sinusoids.
%
%   PMUSIC(...) with no output arguments plots the pseudospectrum in the
%   current figure window.
%
%   EXAMPLES:
%      randn('state',1); n=0:99;   
%      s=exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      X=corrmtx(s,12,'mod');   % Estimate the correlation matrix using
%                               % the modified covariance method.
%      pmusic(X,3,'whole')      % Uses the default NFFT of 256.
%
%      n=0:99; figure;
%      s2=sin(pi/3*n)+2*sin(pi/4*n)+randn(1,100);
%      X2=corrmtx(s2,20,'cov'); % Estimate the correlation matrix using
%                               % the covariance method.            
%      pmusic(X2,4,'whole')     % Use twice the signal space dimension
%                               % for real sinusoids.
%   
%   See also ROOTMUSIC, PEIG, PMTM, PCOV, PMCOV, PBURG, PYULEAR, PWELCH,
%   CORRMTX, SPECTRUM/MUSIC, SPECTRUM/POWEREST, DSPDATA/PS.

%   References:
%     [1] Petre Stoica and Randolph Moses, Introduction To Spectral
%         Analysis, Prentice-Hall, 1997, pg. 15
%     [2] S. J. Orfanidis, Optimum Signal Processing. An Introduction. 
%         2nd Ed., Macmillan, 1988.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.8 $  $Date: 2004/04/13 00:18:16 $

error(nargchk(2,9,nargin));

[md,msg] = music(x,p,varargin{:});
error(msg);

% compute the pseudospectrum
range = 'half';
if strcmpi(md.range,'twosided'), range = 'whole'; end
[Sxx,w] = pseudospectrum(md.noise_eigenvects,md.eigenvals,md.nfft,md.Fs,...
    range,md.EVFlag);

% Assign outputs
switch nargout
case 0,
    titlestring = 'Pseudospectrum Estimate via ';
    if md.EVFlag,   titlestring = [titlestring, 'Eigenvector Method'];
    else            titlestring = [titlestring, 'MUSIC'];
    end

    w = {w};
    if ~isempty(md.Fs), w = {w{:},'Fs',md.Fs}; end
    hps = dspdata.pseudospectrum(Sxx,w{:},'SpectrumRange',range);
    %plot(hps);

    % Create sigresp object in order to be able to set the title string.
    hresp = sigresp.pseudopowerresp(hps);
    set(hresp, 'Name', titlestring);
    plot(hresp);

case 1, varargout = {Sxx};
case 2, varargout = {Sxx,w};
case 3, varargout = {Sxx,w,md.noise_eigenvects};
case 4, varargout = {Sxx,w,md.noise_eigenvects,md.eigenvals};
end
           
%---------------------------------------------------------------------------------------------
function [Sxx,w] = pseudospectrum(noise_eigenvects,eigenvals,nfft,Fs,range,EVFlag)

% compute weights
if EVFlag,
   % Eigenvector method, use eigenvalues as weights
   weights = eigenvals(end-size(noise_eigenvects,2)+1:end); % Use the noise subspace eigenvalues
else
   weights = ones(1,size(noise_eigenvects,2));
end

% Compute the freq. response of each noise subspace eigenfilter via freqz
den = 0;
for n = 1:size(noise_eigenvects,2),
   [h,w] = freqz(noise_eigenvects(:,n),1,nfft,'whole');
   den = den + abs(h).^2./weights(n);
end
s = 1./den; % This is the pseudospectrum

% Convert the frequency vector from rad/sample to Hz.
if ~isempty(Fs),
   w = w.*Fs./(2.*pi); 
end

% Calculate the spectrum over the frequency range requested by the user.
[Sxx,w] = computespectrumrange(s,w,range,nfft);

%--------------------------------------------------------------------------
function [Sxx,w] = computespectrumrange(Sxx,w,range,nfft)
%Return the correct spectrum range based on the user input argument RANGE.

% Convert input row vectors to columns (if not a matrix).
if any(size(Sxx)==1),   Sxx = Sxx(:); end
w = w(:); 

if strcmpi(range,'half'),
   if rem(nfft,2),   select = 1:(nfft+1)/2;  % ODD
   else              select = 1:nfft/2+1;    % EVEN
   end
   Sxx = Sxx(select,:); % Take only [0,pi] or [0,pi)
   w = w(select);
end

% [EOF] pmusic.m

