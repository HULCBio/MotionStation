function Y = goertzel(X,I,DIM)
%GOERTZEL 2次Goertzelアルゴリズム
%   GOERTZEL(X,I) は、2次のGoertzelアルゴリズムを使用して、ベクトルIに
%   含まれるインデックスで、X の離散Fourier変換(DFT)を計算します。
%   
%   インデックスは、1 からN までの整数値である必要があります。
%   ここで、N は、最初のシングルトンでない次元の長さです。  
%   空あるいは、省略の場合、I は、1:Nであると仮定されます。
%
%   GOERTZEL(X,[],DIM) あるいは GOERTZEL(X,I,DIM) は、次元DIMに従って
%   DFTを計算します。 
%
%   一般に、可能なあらゆるDFTインデックスを計算する場合、GOERTZELは、
%   FFTよりも、より遅くなります。しかし、X が長いベクトルであり、
%   DFTの場合、最も有効です。 
% 
%   計算は、 log2(length(X))より短いインデックスのサブセットのみに
%   対して必要です。
%   インデックス 1:length(X) は、周波数範囲[0, 2*pi)ラジアンに
%   相当します。
%
%   参考 FFT, FFT2.

%   Author: P. Costa

%   Reference:
%     C.S.Burrus and T.W.Parks, DFT/FFT and Convolution Algorithms, 
%     John Wiley & Sons, 1985

if ~(exist('goertzelmex') == 3), 
	error('Unable to find goertzelmex executable');
end

error(nargchk(1,3,nargin));
if nargin < 2, I = []; end
if nargin < 3, DIM = []; end

% Inputs should all be of class 'double'
error(checkdatatype('goertzel','double',X,I,DIM));

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

% Verify that the indices in I are valid.
siz = size(X);
if isempty(I),
	I = 1:siz(1); % siz(1) is the number of rows of X
else
	I = I(:);
	if max(I) > siz(1),
		error('Maximum Index exceeds the dimensions of X.');
	elseif min(I) < 1
		error('Index must greater than one.');
	elseif all(I-fix(I))
		error('Indices must be integer values.');
	end
end

% Initialize Y with the correct dimension
Y = zeros([length(I),siz(2:end)]); 

% Call goertzelmex 
for k = 1:prod(siz(2:end)),
	Y(:,k) = goertzelmex(X(:,k),I);
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


%   Copyright 1988-2002 The MathWorks, Inc.
