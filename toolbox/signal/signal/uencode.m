function y = uencode(varargin)
%UENCODE Uniform quantization and encoding of the input into N-bits.
%   Y = UENCODE(U,N) uniformly quantizes and encodes the data in array U, 
%   saturating the input values at +/- 1. The output is in the range [0 2^N-1]. 
%   Output datatype is either a 8, 16, or 32-bit unsigned integer, based 
%   on the least number of bits needed.
%
%   Y = UENCODE(U,N,V) saturates the inputs at +/- peak value, V. 
%
%   Y = UENCODE(U,N,V,'unsigned') outputs unsigned integers in the 
%   range [0 2^N-1]. 
%
%   Y = UENCODE(U,N,V,'signed') outputs signed integers in the 
%   range [-2^(N-1) 2^(N-1)-1].
%
%   See also UDECODE, SIGN, FIX, FLOOR, CEIL, ROUND.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/04/15 01:16:07 $

% Input checking:
[u, Nbits, V, isUnsigned, msg] = uencodeParseParams(varargin{:});
error(msg);

% Quantize and encode input: 
if (~isreal(u)), x = FloatTo32Cplx(u, Nbits, V, isUnsigned);
else,            x = FloatTo32Real(u, Nbits, V, isUnsigned);
end
y = copyInt32ToIntN(x, Nbits, isUnsigned);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Local Functions      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------------------------------------------------
function [u, Nbits, V, isUnsigned, msg] = uencodeParseParams(varargin)
%uencodeParseParams Parse input parameters and define defaults.

u = []; Nbits = []; V = []; isUnsigned = [];

msg = nargchk(2,4,nargin);
if ~isempty(msg)
   return
end

u = varargin{1};
Nbits = varargin{2};

% Allow empty for parameters
if (nargin > 3) & ~isempty(varargin{4})
   signstr = varargin{4};
else
   signstr = 'unsigned';
end

if (nargin > 2) & ~isempty(varargin{3})
   V = varargin{3};
else
   V = 1;
end

% Input value:
if ~isa(u,'double'),
   msg = 'Input value must be a double.';
   return;
end

% Number of bits:
if ( (~isa(Nbits,'double')) | (length(Nbits) ~= 1)    ... 
                            | (Nbits ~= floor(Nbits)) ...
                            | ((Nbits<2)|(Nbits>32))  ... 
                            | ~isreal(Nbits)),
   msg = 'Number of output bits must be an integer from 2 to 32.';
   return;
end

% Peak value:
if ( (~isa(V,'double')) | (length(V) ~= 1) | (V <= 0) | ~isreal(V)),
   msg = 'Peak input value must be a positive real scalar.';
   return;
end

% Sign string:
signidx = strmatch(lower(signstr),{'signed','unsigned'});

if (isempty(signidx) | (length(signidx)>1))
   msg = 'Sign string must be either ''unsigned'' or ''signed''.';
   return;
end

% Determine sign flag:
isUnsigned = (signidx == 2);


%---------------------------------------------
function x = FloatTo32Real(u, Nbits, V, isUnsigned)
% FloatTo32Real Execute the main body of the quantizer.
%    Saturate values at limits and return the (u)int32 value.

UnSignMax= 2^Nbits-1;
SignMax = 2^(Nbits-1)-1;
SignMin = -(1+SignMax);

Q = 2^Nbits-1;         
T = (Q+1)/(2*V);
u = (u+V)*T;

if isUnsigned,
   u(u < 0) = 0;
   u(u > Q) = Q;
   x = uint32(floor(u)); 
else,
   u = u+SignMin;
   u(u < SignMin) = SignMin;
   u(u > SignMax) = SignMax ;
   x = int32(floor(u)); 
end

%---------------------------------------------
function x = FloatTo32Cplx(u, Nbits, V, isUnsigned)
% FloatTo32Cplx Complex inputs are passed to main
%    body of the quantizer in real and imaginary 
%    components.

xre = FloatTo32Real(real(u), Nbits, V, isUnsigned);
xim = FloatTo32Real(imag(u), Nbits, V, isUnsigned);
x = complex(xre,xim);


%------------------------------------------
function y = copyInt32ToIntN(x, Nbits, isUnsigned);
% copyInt32ToIntN Copy (u)int32 to an 8, 16, or 32 bit integer.

if isUnsigned,
   if     (Nbits <= 8),  y = uint8(x);
   elseif (Nbits <= 16), y = uint16(x);
   else                  y = uint32(x);
   end
else
   if     (Nbits <= 8),  y = int8(x);
   elseif (Nbits <= 16), y = int16(x);
   else                  y = int32(x);
   end
end

% [EOF] uencode.m
