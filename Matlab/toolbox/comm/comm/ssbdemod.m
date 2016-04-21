function z = ssbdemod(y, Fc, Fs, ini_phase,varargin)
% SSBDEMOD Single sideband amplitude demodulation.
%   Z = SSBDEMOD(Y,Fc,Fs) demodulates the single sideband amplitude
%   modulated signal Y from the carrier frequency Fc (Hz). Y and Fc have
%   sample frequency Fs (Hz). The modulated signal has zero initial phase.
%   The modulated signal can be an upper or lower sideband signal. A
%   lowpass filter is used in the demodulation.  The default filter is:
%   [NUM,DEN] = butter(5,Fc*2/Fs).
% 
%   Z = SSBDEMOD(Y,Fc,Fs,INI_PHASE) specifies the initial phase (rad) of
%   the modulated signal.
% 
%   Z = SSBDEMOD(Y,Fc,Fs,INI_PHASE,NUM,DEN) specifies the numerator and
%   denominator of the lowpass filter to be used in the demodulation.
%
%   Fs must satisfy Fs >2*(Fc + BW), where BW is the bandwidth of the
%   modulating signal.
% 
%   See also SSBMOD, AMDEMOD.

%    Copyright 1996-2003 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:01:25 $ 

% Number of arguments check
if(nargin > 6)
    error('comm:ssbdemod:TooManyInp','Too many input arguments.');
end

%Check y,Fc, Fs, ini_phase.
if(~isreal(y)|| ~isnumeric(y) )
    error('comm:ssbdemod:Yreal','Y must be real.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 || ~isnumeric(Fc) )
    error('comm:ssbdemod:FcReal','Fc must be a real, positive scalar.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 || ~isnumeric(Fs) )
    error('comm:ssbdemod:FsReal','Fs must be a real, positive scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<=2*Fc)
    error('comm:ssbdemod:Fs2Fc','Fs must be at least 2*Fc.');
end

if(nargin<4 || isempty(ini_phase) )
    ini_phase = 0;
elseif(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
    error('comm:ssbdemod:iniphaseReal','INI_PHASE must be a real scalar.');
end

if(isempty(varargin))
    [num,den] = butter(5,Fc*2/Fs);
    
% check that the numerator and denominator are valid, and come in a pair
elseif( (nargin == 5) )
    error('comm:ssbdemod:NumDenPair','Numerator and Denominator must be a pair.');

% check to make sure that both num and den have values.
elseif( xor( isempty(varargin{1}), isempty(varargin{2})))
    error('comm:ssbdemod:NumDenPair','Numerator and Denominator must be a pair.');
elseif(  isempty(varargin{1}) && isempty(varargin{2}) )
        [num,den] = butter(5,Fc*2/Fs);
else 
    num = varargin{1};
    den = varargin{2};
end

% --- End Parameter checks --- %

% --- Assure that Y, if one dimensional, has the correct orientation --- %
wid = size(y,1);
if(wid ==1)
    y = y(:);
end

t = (0 : 1/Fs :(size(y,1)-1)/Fs)';
t = t(:, ones(1, size(y, 2)));
z = y .* cos(2*pi * Fc * t + ini_phase);
for i = 1 : size(z, 2)
    z(:, i) = filtfilt(num, den, z(:, i)) * 2;
end;

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    z = z';
end

% --- EOF --- %
