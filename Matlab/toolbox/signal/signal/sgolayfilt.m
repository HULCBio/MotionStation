function y=sgolayfilt(x,k,F,W,DIM)
%SGOLAYFILT Savitzky-Golay Filtering.
%   SGOLAYFILT(X,K,F) smoothes the signal X using a Savitzky-Golay 
%   (polynomial) smoothing filter.  The polynomial order, K, must
%   be less than the frame size, F, and F must be odd.  The length 
%   of the input X must be >= F.  If X is a matrix, the filtering
%   is done on the columns of X.
%
%   Note that if the polynomial order K equals F-1, no smoothing
%   will occur.
%
%   SGOLAYFILT(X,K,F,W) specifies a weighting vector W with length F
%   containing real, positive valued weights employed during the
%   least-squares minimization. If not specified, or if specified as
%   empty, W defaults to an identity matrix.
%
%   SGOLAYFILT(X,K,F,[],DIM) or SGOLAYFILT(X,K,F,W,DIM) operates along
%   the dimension DIM.
%
%   See also SGOLAY, MEDFILT1, FILTER

%   References:
%     [1] Sophocles J. Orfanidis, INTRODUCTION TO SIGNAL PROCESSING,
%              Prentice-Hall, 1995, Chapter 8.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/15 01:13:55 $

error(nargchk(3,5,nargin));

% Check if the input arguments are valid
if round(F) ~= F, error('Frame length must be an integer.'), end
if rem(F,2) ~= 1, error('Frame length must be odd.'), end
if round(k) ~= k, error('Polynomial degree must be an integer.'), end
if k > F-1, error('The degree must be less than the frame length.'), end

if nargin < 4 | isempty(W),
   % No weighting matrix, make W an identity
   W = ones(F,1);
else
   % Check for right length of W
   if length(W) ~= F, error('The weight vector must be of the same length as the frame length.'),end
   % Check to see if all elements are positive
   if min(W) <= 0, error('All the elements of the weight vector must be greater than zero.'), end
end

if nargin < 5, DIM = []; end

% Compute the projection matrix B
B = sgolay(k,F,W);

if ~isempty(DIM) & DIM > ndims(x)
	error('Dimension specified exceeds the dimensions of X.')
end

% Reshape X into the right dimension.
if isempty(DIM)
	% Work along the first non-singleton dimension
	[x, nshifts] = shiftdim(x);
else
	% Put DIM in the first dimension (this matches the order 
	% that the built-in filter function uses)
	perm = [DIM,1:DIM-1,DIM+1:ndims(x)];
	x = permute(x,perm);
end

if size(x,1) < F, error('The length of the input must be >= frame length.'), end

% Preallocate output
y = zeros(size(x));

% Compute the transient on
y(1:(F+1)./2-1,:) = flipud(B((F-1)./2+2:end,:))*flipud(x(1:F,:));

% Compute the steady state output
ytemp = filter(B((F-1)./2+1,:),1,x);
y((F+1)/2:end-(F+1)/2+1,:) = ytemp(F:end,:);

% Compute the transient off
y(end-(F+1)./2+2:end,:) = flipud(B(1:(F-1)./2,:))*flipud(x(end-(F-1):end,:));

% Convert Y to the original shape of X
if isempty(DIM)
	y = shiftdim(y, -nshifts);
else
	y = ipermute(y,perm);
end

