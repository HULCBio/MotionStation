function Y = goertzel(X,INDVEC,DIM)
%GOERTZEL Second-order Goertzel algorithm.  
%   GOERTZEL(X,INDVEC) computes the discrete Fourier transform (DFT)
%   of X at indices contained in the vector INDVEC, using the
%   second-order Goertzel algorithm.  The indices must be integer values
%   from 1 to N where N is the length of the first non-singleton dimension.
%   If empty or omitted, INDVEC is assumed to be 1:N.
%
%   GOERTZEL(X,[],DIM) or GOERTZEL(X,INDVEC,DIM) computes the DFT along 
%   the dimension DIM.
%
%   In general, GOERTZEL is slower than FFT when computing all the possible
%   DFT indices, but is most useful when X is a long vector and the DFT 
%   computation is required for only a subset of indices less than
%   log2(length(X)).  Indices 1:length(X) correspond to the frequency span
%   [0, 2*pi) radians.
%
%   EXAMPLE:
%      % Resolve the 1.24 kHz and 1.26 kHz components in the following
%      % noisy cosine which also has a 10 kHz component.
%      Fs = 32e3;   t = 0:1/Fs:2.96;
%      x  = cos(2*pi*t*10e3)+cos(2*pi*t*1.24e3)+cos(2*pi*t*1.26e3)...
%           + randn(size(t));
%
%      N = (length(x)+1)/2;
%      f = (Fs/2)/N*(0:N-1);              % Generate frequency vector
%      indxs = find(f>1.2e3 & f<1.3e3);   % Find frequencies of interest
%      X = goertzel(x,indxs);
%      
%      hms = dspdata.msspectrum((abs(X)/length(X)).^2,f(indxs),'Fs',Fs);
%      plot(hms);                          % Plot the mean-square spectrum.
%
%   See also FFT, FFT2.

%   Author: P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $  $Date: 2004/04/13 00:18:00 $

%   Reference:
%     C.S.Burrus and T.W.Parks, DFT/FFT and Convolution Algorithms, 
%     John Wiley & Sons, 1985

if ~(exist('goertzelmex') == 3), 
	error('Unable to find goertzelmex executable');
end

error(nargchk(1,3,nargin));
if nargin < 2, INDVEC = []; end
if nargin < 3, DIM = []; end

% Inputs should all be of class 'double'
error(checkdatatype('goertzel','double',X,INDVEC,DIM));

if ~isempty(DIM) & DIM > ndims(X)
	error('Dimension specified exceeds the dimensions of X.')
end

% Reshape X into the right dimension.
if isempty(DIM)
	% Work along the first non-singleton dimension
	[X, nshifts] = shiftdim(X);
else
	% Put DIM in the first dimension (this matches the order 
	% that the built-in filter function uses)
	perm = [DIM,1:DIM-1,DIM+1:ndims(X)];
	X = permute(X,perm);
end

% Verify that the indices in INDVEC are valid.
siz = size(X);
if isempty(INDVEC),
	INDVEC = 1:siz(1); % siz(1) is the number of rows of X
else
	INDVEC = INDVEC(:);
	if max(INDVEC) > siz(1),
		error('Maximum Index exceeds the dimensions of X.');
	elseif min(INDVEC) < 1
		error('Index must greater than zero.');
	elseif all(INDVEC-fix(INDVEC))
		error('Indices must be integer values.');
	end
end

% Initialize Y with the correct dimension
Y = zeros([length(INDVEC),siz(2:end)]); 

% Call goertzelmex 
for k = 1:prod(siz(2:end)),
	Y(:,k) = goertzelmex(X(:,k),INDVEC);
end

% Convert Y to the original shape of X
if isempty(DIM)
	Y = shiftdim(Y, -nshifts);
else
	Y = ipermute(Y,perm);
end


%-------------------------------------------------------------------
%                       Utility Function
%-------------------------------------------------------------------
function msg = checkdatatype(fname,cname,varargin)
%CHECKDATATYPE Check data type class
%   Checks for exact match on class, subclasses don't count.  i.e.,
%   sparse will not be a double, even though isa(sparse(2),'double')
%   evaluates to true.
%
% Inputs:
%   fname    - Function name
%   cname    - Class name
%   varargin - Inputs to check

msg = '';
for k=1:length(varargin),
  if ~strcmpi(class(varargin{k}),cname)
    msg = ['Function ''',fname,...
          ''' is not defined for variables of class ''',...
          class(varargin{k}),''''];
    break;
  end
end

% [EOF] goertzel.m
