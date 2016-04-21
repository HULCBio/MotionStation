function Y = goertzel(X,I,DIM)
%GOERTZEL 2��Goertzel�A���S���Y��
%   GOERTZEL(X,I) �́A2����Goertzel�A���S���Y�����g�p���āA�x�N�g��I��
%   �܂܂��C���f�b�N�X�ŁAX �̗��UFourier�ϊ�(DFT)���v�Z���܂��B
%   
%   �C���f�b�N�X�́A1 ����N �܂ł̐����l�ł���K�v������܂��B
%   �����ŁAN �́A�ŏ��̃V���O���g���łȂ������̒����ł��B  
%   �󂠂邢�́A�ȗ��̏ꍇ�AI �́A1:N�ł���Ɖ��肳��܂��B
%
%   GOERTZEL(X,[],DIM) ���邢�� GOERTZEL(X,I,DIM) �́A����DIM�ɏ]����
%   DFT���v�Z���܂��B 
%
%   ��ʂɁA�\�Ȃ�����DFT�C���f�b�N�X���v�Z����ꍇ�AGOERTZEL�́A
%   FFT�����A���x���Ȃ�܂��B�������AX �������x�N�g���ł���A
%   DFT�̏ꍇ�A�ł��L���ł��B 
% 
%   �v�Z�́A log2(length(X))���Z���C���f�b�N�X�̃T�u�Z�b�g�݂̂�
%   �΂��ĕK�v�ł��B
%   �C���f�b�N�X 1:length(X) �́A���g���͈�[0, 2*pi)���W�A����
%   �������܂��B
%
%   �Q�l FFT, FFT2.

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
