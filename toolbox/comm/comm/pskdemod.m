function z = pskdemod(y,M,varargin)
%PSKDEMOD Phase shift keying demodulation
%   Z = PSKDEMOD(Y,M) demodulates the complex envelope Y of a signal
%   modulated using the phase shift key method. M is the alphabet size and
%   must be an integer power of 2. For two-dimensional signals, the
%   function treats each column as 1 channel.
%
%   Z = PSKDEMOD(Y,M,INI_PHASE) specifies the initial phase which was used
%   to modulate the original signal. The default value of INI_PHASE is 0.
% 
%   See also PSKMOD, QAMDEMOD, QAMMOD, MODNORM.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.2 $  $Date: 2003/07/30 02:47:40 $ 

% Error checks 
if (nargin > 3)
    error('comm:pskdemod:numarg', 'Too many input arguments. ');
end

%Check y, m
if( ~isnumeric(y))
    error('comm:pskdemod:Ynum','Y must be numeric.');
end

% Checks that M is positive integer
if (~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M))
    error('comm:pskdemod:Mreal', 'M must be a positive integer. ');
end

% Checks that M is in of the form 2^K
if(~isnumeric(M) || (ceil(log2(M)) ~= log2(M)))
    error('comm:pskdemod:Mpow2', 'M must be in the form of M = 2^K, where K is an integer. ');
end

% Determine INI_PHASE. The default value is 0
if (nargin == 3)
    ini_phase = varargin{1};
    if (isempty(ini_phase))
        ini_phase = 0;
    elseif (~isreal(ini_phase) || ~isscalar(ini_phase))
        error('comm:pskdemod:Ini_phaseReal', 'INI_PHASE must be a real scalar. ');
    end
else
    ini_phase = 0;
end

% generate a constellation
const = pskmod(0:M-1,M, ini_phase);

%demodulate.
z = genqamdemod(y,const);

% EOF

