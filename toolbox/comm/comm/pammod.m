function y = pammod(x,M, varargin)
%PAMMOD Pulse amplitude modulation
%   Y = PAMMOD(X,M) outputs the complex envelope of the modulation of the
%   message signal X using pulse amplitude modulation. M is the alphabet
%   size and must be an integer. The message signal must consist of
%   integers between 0 and M-1. The modulated signal Y has a minimum
%   Euclidean distance of 2. For two-dimensional signals, the function
%   treats each column as 1 channel.
%
%   Y = PAMMOD(X,M,INI_PHASE) specifies the initial phase of the modulated
%   signal in radians. The default value of INI_PHASE is 0.
%
%   See also PAMDEMOD, QAMMOD, QAMDEMOD, PSKMOD, PSKDEMOD, MODNORM.

%    Copyright 1996-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.5 $  $Date: 2004/04/12 23:00:54 $ 

if(nargin>3)
    error('comm:pammod:toomanyinp','Too many input arguments.');
end

%Check x, ini_phase
if ( ~isreal(x) || any(any(ceil(x)~=x)) || ~isnumeric(x) ) 
    error('comm:pammod:Xreal','Elements of input X must be real integers in [0, M-1].');
end

if(~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:pammod:Mreal','M must be a positive integer.');
end

% check that X are all integers within range.
if (min(min(x)) < 0)  || (max(max(x)) > (M-1))
    error('comm:pammod:Xreal','Elements of input X must be real integers in [0, M-1].');
end

if(nargin==2 || isempty(varargin{1}) )    
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:pammod:ini_phaseReal','INI_PHASE must be a real scalar.');    
    end
end


% --- End Parameter checks --- %

% create constellation
const = (-(M-1):2:(M-1)).*exp(j*ini_phase);
% modualte
y = genqammod(x,const);

% EOF
