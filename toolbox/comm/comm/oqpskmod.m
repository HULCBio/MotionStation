function y = oqpskmod(x,varargin);
% OQPSKMOD Offset quadrature phase shift keying modulation.
%   Y = OQPSKMOD(X) outputs the complex envelope of the modulation of the
%   message signal X using OQPSK modulation. The message signal must
%   consist of integers between 0 and 3. For two-dimensional signals, the
%   function treats each column as 1 channel. This function implicitly
%   upsamples by a factor of 2, because an odd number of samples per symbol
%   is not allowed for OQPSK.
%   
%   Y = OQPSKMOD(X,INI_PHASE) specifies the phase offset (rad) of the
%   modulated signal Y.
%
%   See also OQPSKDEMOD, PSKMOD, PSKDEMOD, QAMMOD, QAMDEMOD, MODNORM.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/02/14 20:50:37 $ 

% error checks
if(nargin>2)
    error('comm:oqpskmod:numarg','Too many input arguments.');
end

%Check x, phase
if ( ~isreal(x) || any(any(ceil(x)~=x)) || ~isnumeric(x) ) 
    error('comm:oqpskmod:xreal','Elements of input X must be integers in [0, 3].');
end

M = 4; Nsamp = 2;

% check that X are all integers within range.
if (min(min(x)) < 0)  || (max(max(x)) > (M-1))
    error('comm:oqpskmod:xreal','Elements of input X must be integers in [0, 3].');
end

if(nargin==2)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    elseif(~isreal(ini_phase) || ~isscalar(ini_phase) )
        error('comm:oqpskmod:ini_phaseReal','INI_PHASE must be a real scalar.');
    end
else 
    ini_phase = 0;
end

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if(wid ==1)
    x = x(:);
end

% create the modmap
modmap = zeros(1,4);
modmap(1) = cos(ini_phase + pi/4) + j* sin(ini_phase + pi/4);
modmap(2) = cos(ini_phase + 7*pi/4) + j * sin(ini_phase + 7*pi/4);
modmap(3) = cos(ini_phase + 3*pi/4) + j * sin(ini_phase + 3*pi/4);
modmap(4) = cos(ini_phase + 5*pi/4) + j * sin(ini_phase + 5*pi/4);

% upsample
yy = [];
for i = 1 : size(x, 2)
    tmp = x(:, ones(1, Nsamp)*i)';
    yy = [yy tmp(:)];
end
x = yy;


% modulate 
y = genqammod(x,modmap);

% separate the signal into I and Q
yI = real(y);
yQ = imag(y);

% introduce the timing offset in the quadrature channel.

yQ = [zeros(1,size(y,2)); yQ(1:end,:) ];
yI = [yI;zeros(1,size(y,2))];
y = yI + j*yQ;

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y.';
end

% --- EOF --- %
