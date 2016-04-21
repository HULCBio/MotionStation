function y = udecode(varargin)
%UDECODE Uniform decoding of the input.
%   Y = UDECODE(U,N) decodes the data in array U, with peak value at +/- 1.  
%   Input datatype is signed or unsigned integers in the range of [0 2^N-1].
%   Output datatype is double. Saturates input if overflow occurs.
%
%   Y = UDECODE(U,N,V) decodes the data with peak value at +/- V. 
%
%   Y = UDECODE(U,N,V,'wrap') wrap the input if overflow occurs. 
%
%   See also UENCODE, SIGN, FIX, FLOOR, CEIL, ROUND.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/04/15 01:16:10 $

%Check and prepare parameters for decoding:
[u, N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd, msg] = udecodeParseParams(varargin{:});
error(msg);

% Decode input: 
if (~isreal(u)), y = DecodeCplx(u, N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd);
else,            y = DecodeReal(u, N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Local Functions      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------
function [u, N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd, msg] = udecodeParseParams(varargin)
%udecodeParseParams Parse input parameters and define defaults.

% Initialize parameters:
u = []; 
N = []; V = []; T = []; W = []; 
isSaturate = []; isSigned = [];
UpperBnd = []; LowerBnd = [];

msg = nargchk(2,4,nargin);
if ~isempty(msg)
   return;
end

u = varargin{1};
N = varargin{2};

% Allow empty for parameters
if (nargin > 2) & (~isempty(varargin{3}))
   V = varargin{3};
else
   V = 1;
end
if (nargin > 3) & (~isempty(varargin{4}))
   OverFlowStr = varargin{4};
else
   OverFlowStr = 'saturate';
end


% Input value:
if (~isa(u,'int8') & ~isa(u,'int16') & ~isa(u,'int32') & ~isa(u,'uint8') & ~isa(u,'uint16') & ~isa(u,'uint32')),
   msg = 'Input value must be a signed or unsigned integer.';
   return;
end

% Number of bits:
if ( (~isa(N,'double')) | (length(N) ~= 1)    ... 
                            | (N ~= floor(N)) ...
                            | ((N<2)|(N>32))  ... 
                            | ~isreal(N)),
   msg = 'Number of output bits must be an integer from 2 to 32.';
   return;
end

% Peak value:
if ( (~isa(V,'double')) | (length(V) ~= 1) | (V <= 0) | ~isreal(V)),
   msg = 'Peak input value must be a positive real scalar.';
   return;
end

% Determine input datatype sign:
if (isa(u,'int8') | isa(u,'int16') | isa(u,'int32')),
   W = 2^(N-1);
   isSigned = 1;
else
   W = 0;
   isSigned = 0;
end

% Overflow mode
oflowidx = strmatch(lower(OverFlowStr),{'saturate','wrap'});
if (isempty(oflowidx) | (length(oflowidx)>1)),
   msg = 'Overflow mode string must be either ''saturate'' or ''wrap''.';
   return;
end
isSaturate = (oflowidx == 1);

% Determine additional parameters:
T = pow2(V,1-N);

if (isSigned), UpperBnd = pow2(N-1) - 1;    LowerBnd = -pow2(N-1);
else           UpperBnd = pow2(N) - 1;      LowerBnd = 0;
end

%Convert input to a double:
u = double(u);

%---------------------------------------------
function y = DecodeCplx(u, N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd)
% DecodeCplx Execute the main body for each component 
%    of complex input.
yre = DecodeReal(real(u), N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd);
yim = DecodeReal(imag(u), N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd);
y = complex(yre,yim);

%---------------------------------------------
function y = DecodeReal(u, N, V, T, W, isSaturate, isSigned, UpperBnd, LowerBnd)
% DecodeReal Execute the main body of the decoder.

if (isSaturate)  u = Saturate(u, UpperBnd, LowerBnd);
else             u = Wrap(u, N, isSigned, LowerBnd);
end
y = (u+W)*T - V;

%---------------------------------------------
function u = Saturate(u, UpperBnd, LowerBnd)

u(find(u > UpperBnd)) = UpperBnd;
u(find(u < LowerBnd)) = LowerBnd;

%---------------------------------------------
function u = Wrap(u, N, isSigned, LowerBnd)

if (isSigned)   u = mod((u-LowerBnd),pow2(N)) + LowerBnd; 
else            u = mod(u,pow2(N));
end
