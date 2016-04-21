function y = pskmod(x,M,varargin)
%PSKMOD Phase shift keying modulation
%   Y = PSKMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X, using the phase shift keying modulation. M is the
%   alphabet size and must be an integer power or 2. The message signal X
%   must consist of integers between 0 and M-1. For two-dimensional
%   signals, the function treats each column as 1 channel.
%
%   Y = PSKMOD(X,M,INI_PHASE) specifies the desired initial phase in
%   INI_PHASE. The default value of INI_PHASE is 0.
%
%   See also PSKDEMOD, PAMMOD, PAMDEMOD, QAMMOD, QAMDEMOD, MODNORM.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/05/20 11:43:28 $ 


% Error checks
if (nargin > 3)
    error('comm:pskmod:numarg', 'Too many input arguments. ');
end

% Check that x is a positive integer
if (~isreal(x) || any(any(ceil(x) ~= x)) || ~isnumeric(x))
    error('comm:pskmod:xreal', 'Elements of input X must be integers in [0, M-1].');
end

% Check that M is a positive integer
if (~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M))
    error('comm:pskmod:Mreal', 'M must be a positive integer. ');
end

% Check that M is of the form 2^K
if(~isnumeric(M) || (ceil(log2(M)) ~= log2(M)))
    error('comm:pskmod:Mpow2', 'M must be in the form of M = 2^K, where K is an integer. ');
end

% Check that x is within range
if ((min(min(x)) < 0) || (max(max(x)) > (M-1)))
    error('comm:pskmod:xreal', 'Elements of input X must be integers in [0, M-1].');
end

% Determine initial phase. The default value is 0
if (nargin == 3)
    ini_phase = varargin{1};
    if (isempty(ini_phase))
        ini_phase = 0;
    elseif (~isreal(ini_phase) || ~isscalar(ini_phase))
        error('comm:pskmod:ini_phaseReal', 'INI_PHASE must be a real scalar. ');
    end
else
    ini_phase = 0;
end

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if (wid == 1)
    x = x(:);
end

% Evaluate the phase angle based on M and the input value. The phase angle
% lies between 0 - 2*pi. 
theta = 2*pi*x/M;

% The complex envelope is (cos(theta) + j*sin(theta)). This can be
% expressed as exp(j*theta). If there is an initial phase, it is added
% to the existing phase angle
y = exp(j*(theta + ini_phase));

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y.';
end

% EOF
