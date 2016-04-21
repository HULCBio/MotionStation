function z = pamdemod(y,M,varargin)
%PAMDEMMOD Pulse amplitude demodulation.
%   Z = PAMDEMOD(Y,M) demodulates the complex envelope Y of a pulse
%   amplitude modulated signal. M is the alphabet size and must be an
%   integer. The ideal modulated signal Y should have a minimum Euclidean
%   distance of 2. For two-dimensional signals, the function treats each
%   column as 1 channel.
%
%   Z = PAMDEMOD(Y,M,INI_PHASE) specifies the initial phase of the
%   modulated signal in radians. The default value of INI_PHASE is 0.
% 
%   See also PAMMOD, QAMDEMOD, QAMMOD, PSKDEMOD, PSKMOD, MODNORM.

%    Copyright 1996-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.5 $  $Date: 2004/04/12 23:00:53 $ 

%Check y, m
if( ~isnumeric(y))
    error('comm:pamdemod:Ynum','Y must be numeric.');
end

if(~isreal(M) || ~isscalar(M) ||  M<=0 || (ceil(M)~=M) || ~isnumeric(M) )
    error('comm:pamdemod:Mreal','M must be a positive integer.');
end

if(nargin==2 || isempty(varargin{1}) )    
    ini_phase = 0;
else
    ini_phase = varargin{1};
    if(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:pamdemod:ini_phaseReal','INI_PHASE must be a real scalar.');    
    end
end

% --- Assure that Y, if one dimensional, has the correct orientation --- %
wid = size(y,1);
if(wid ==1)
    y = y(:);
end

% create constellation
const = (-(M-1):2:(M-1)).*exp(j*ini_phase);
% demodulate
z = genqamdemod(y,const);

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    z = z';
end

