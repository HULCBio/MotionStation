function [w_i,powers] = rootmusic(x,p,varargin)
%ROOTMUSIC   Computes the frequencies and powers of sinusoids via the
%            Root MUSIC algorithm.
%   W = ROOTMUSIC(X,P) returns the vector of frequencies W of the complex
%   sinusoids contained in signal vector X.  W is in units of rad/sample.
%   P is the number of complex sinusoids in X. If X is a data matrix,
%   each row is interpreted as a separate sensor measurement or trial.
%   In this case, X must have a number of columns larger than P.  You can
%   use the function CORRMTX to generate data matrices to be used here.  
%
%   W = ROOTMUSIC(R,P,'corr') returns the vector of frequencies W, for a
%   signal whose correlation matrix estimate is given by the positive
%   definite matrix R. Exact conjugate-symmetry of R is ensured by forming
%   (R+R')/2 inside the function. The number of rows or columns of R must
%   be greater than P.
%
%   If P is a two element vector, P(2) is used as a cutoff for signal and
%   noise subspace separation.  All eigenvalues greater than P(2) times
%   the smallest eigenvalue are designated as signal eigenvalues.  In 
%   this case, the signal subspace dimension is at most P(1).
%
%   F = ROOTMUSIC(...,Fs) uses the sampling frequency Fs in the computation
%   and returns the vector of frequencies, F, in Hz.
%
%   [W,POW] = ROOTMUSIC(...) returns in addition a vector POW containing the
%   estimates of the powers of the sinusoids in X.
%
%   EXAMPLES:
%      randn('state',1); n=0:99;   
%      s=exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%      X=corrmtx(s,12,'mod'); % Estimate the correlation matrix using
%                             % the modified covariance method.
%      [W,P] = rootmusic(X,3);         
%   
%   See also ROOTEIG, PMUSIC, PEIG, PMTM, PBURG, PWELCH, CORRMTX,
%   SPECTRUM/MUSIC, SPECTRUM/POWEREST.

%   Reference: Stoica, P. and R. Moses, INTRODUCTION TO SPECTRAL ANALYSIS,
%              Prentice-Hall, 1997.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2004/04/13 00:19:04 $

error(nargchk(2,5,nargin));

xIsReal = isreal(x);

% Check for an even number of complex sinusoids if data is real
if xIsReal & rem(p,2),
	error('Real signals require an even number p of complex sinusoids.');
end

nfft = []; % Root Music doesn't use nfft, but the parser needs it
varargin = {nfft,varargin{:}};

[md,msg] = music(x,p,varargin{:});
error(msg);


% Find the Complex Sinusoid Frequencies
w_i = compute_freqs(md.noise_eigenvects,md.p_eff,md.EVFlag,md.eigenvals);

% Estimate the noise variance as the average of the noise subspace eigenvalues
sigma_w = sum(md.eigenvals(md.p_eff+1:end))./size(md.noise_eigenvects,2);

% Estimate the power of the sinusoids
powers = compute_power(md.signal_eigenvects,md.eigenvals,w_i,md.p_eff,sigma_w,xIsReal);

% Convert the estimated frequencies to Hz if Fs was specified
if ~isempty(md.Fs),
   w_i = w_i*md.Fs./(2*pi);
end

%---------------------------------------------------------------------------------------------
function w_i = compute_freqs(noise_eigenvects,p_eff,EVFlag,eigenvals)
%Compute the frequencies via the roots of the polynomial formed with the noise eigenvectors
%
%   Inputs:
%
%     noise_eigenvects - a matrix whose columns are the noise subspace eigenvectors
%     p_eff            - signal subspace dimension
%     EVFlag           - a flag indicating of the eigenvector methos should be used
%     eigenvals        - a vector with all the correlation matrix eigenvalues. 
%                        However, we use only the noise eigenvalues as weights 
%                        in the eigenvector method.
%
%   Outputs:
%
%     w_i - frequencies of the complex sinusoids


% compute weights
if EVFlag,
   % Eigenvector method, use eigenvalues as weights
   weights = eigenvals(end-size(noise_eigenvects,2)+1:end); % Use the noise subspace eigenvalues
else
   weights = ones(1,size(noise_eigenvects,2));
end

% Form a polynomial D, consisting of a sum of polynomials given by the product of
% the noise subspace eigenvectors and the reversed and conjugated version.
D = 0;
for i = 1:length(weights),
   D = D + conv(noise_eigenvects(:,i),conj(flipud(noise_eigenvects(:,i))))./weights(i);
end

roots_D = roots(D);
% Because D is formed from the product of a polynomial and its conjugated and reversed version,
% every root of D inside the unit circle, will have a "reflected" version outside the unit circle.
% We choose to use the ones inside the unit circle, because the distance from them to the unit
% circle will be smaller than the corresponding distance for the "reflected" root.
roots_D1 = roots_D(abs(roots_D) < 1);

% Sort the roots from closest to furthest from the unit circle
[not_used,indx] = sort(abs(abs(roots_D1)-1));
sorted_roots = roots_D1(indx);

% Use the first p_eff roots to determine the frequencies
w_i = angle(sorted_roots(1:p_eff));

%-----------------------------------------------------------------------------------------------
function powers = compute_power(signal_eigenvects,eigenvals,w_i,p_eff,sigma_w,xIsReal)
%COMPUTE_POWER   Solves the system of linear eqs. to calculate the power of the sinusoids.
%
%   Inputs:
%
%     signal_eigenvects - the matrix whose columns are the signal subspace eigenvectors
%     eigenvals         - a vector containing all eigenvalues of the correlation matrix
%     w_i               - a vector of frequency estimates of the sinusoids
%     p_eff             - the dimension of the signal subspace
%     sigma_w           - the estimate of the variance of the white noise
%     xIsReal           - a flag indicating wether we have real or complex sinusoids
%
%   Outputs:
%
%     powers - a vector that contains the power of each sinusoid

%This is just the solution of a linear system of eqs, Ax=b

% For real sinusoids, the system of eqs. has half the number of unknowns
if xIsReal,
   w_i = reshape(w_i,2,length(w_i)./2);
   w_i = w_i(1,:); % Use only the positive freqs.
   w_i = w_i(:);
   p_eff = p_eff./2;
end

% Form the A matrix
if length(w_i) == 1,
   % FREQZ does not compute the gain at a single frequency, handle this separately
   A = polyval(signal_eigenvects,exp(i*w_i));
else
   for n = 1:p_eff,
      A(:,n) = freqz(signal_eigenvects(:,n),1,w_i);
   end
end

A = abs(A.').^2;

% Form the b vector
b = eigenvals(1:p_eff) - sigma_w;

% The powers are simply the solution to the set of eqs.
powers = A\b;

% [EOF] rootmusic.m

