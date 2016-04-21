function y = qammod(x,M, varargin)
%QAMMOD Quadrature amplitude modulation
%   Y = QAMMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X using quadrature amplitude modulation. M is the
%   alphabet size and must be an integer power of two. The message signal
%   must consist of integers between 0 and M-1. The signal constellation is
%   a rectangular constellation. For two-dimensional signals, the function
%   treats each column as 1 channel.
%
%   Y = QAMMOD(X,M,INI_PHASE) specifies a phase offset (rad).
%
%   See also QAMDEMOD, GENQAMMOD, GENQAMDEMOD, PAMMOD, PAMDEMOD, MODNORM.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/02/14 20:51:06 $ 

% error checks
if(nargin>3)
    error('comm:qammod:numarg','Too many input arguments.');
end

%Check x, ini_phase
if ( ~isreal(x) || any(any(ceil(x)~=x)) || ~isnumeric(x) ) 
    error('comm:qammod:xreal','Elements of input X must be integers in [0, M-1].');
end

if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:qammod:Mreal','M must be a positive integer.');
end

if( ~isnumeric(M) || ceil(log2(M)) ~= log2(M))
    error('comm:qammod:Mpow2','M must be in the form of M = 2^K, where K is an integer. ');
end

% check that X are all integers within range.
if (min(min(x)) < 0)  || (max(max(x)) > (M-1))
    error('comm:qammod:xreal','Elements of input X must be integers in [0, M-1].');
end

if(nargin==3)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    elseif(~isreal(ini_phase) || ~isscalar(ini_phase) )
        error('comm:qammod:ini_phaseReal','INI_PHASE must be a real scalar.');
    end
else 
    ini_phase = 0;
end

const = squareqamconst(M,ini_phase);
y = genqammod(x,const);

% --- EOF --- %
