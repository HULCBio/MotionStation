function z = amdemod(y, Fc, Fs, ini_phase, varargin)
%ADEMOD Amplitude demodulation.
%   Z = AMDEMOD(Y,Fc,Fs) demodulates the amplitude modulated signal Y from
%   the carrier frequency Fc (Hz). Y and Fc have sample frequency Fs (Hz).
%   The modulated signal Y has zero initial phase, and zero carrier
%   amplitude, for suppressed carrier modulation. A lowpass filter is used
%   in the demodulation.  The default filter is: [NUM,DEN] =
%   butter(5,Fc*2/Fs).
%   
%   Z = AMDEMOD(Y,Fc,Fs,INI_PHASE) specifies the initial phase (rad) of the
%   modulated signal.
%
%   Z = AMDEMOD(Y,Fc,Fs,INI_PHASE,CARRAMP) specifies the carrier amplitude
%   of the modulated signal for transmitted carrier modulation.
%
%   Z = AMDEMOD(Y,Fc,Fs,INI_PHASE,CARRAMP,NUM,DEN) specifies the filter to
%   be used in the demodulation. 
%
%   See also AMMOD, SSBDEMOD, FMDEMOD, PMDEMOD.

%    Copyright 1996-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:00:21 $ 

% Number of arguments check
if(nargin > 7)
    error('comm:amdemod:tooManyInp','Too many input arguments.');
end

%Check y,Fc, Fs, ini_phase, numerator and denominator.
if(~isreal(y)|| ~isnumeric(y))
    error('comm:amdemod:Yreal','Y must be real.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 || ~isnumeric(Fc))
    error('comm:amdemod:FcReal','Fc must be a real, positive scalar.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 || ~isnumeric(Fs) )
    error('comm:amdemod:FsReal','Fs must be a real, positive scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<=2*Fc)
    error('comm:amdemod:FsReal','Fs must be at least 2*Fc.');
end


if(nargin<4 || isempty(ini_phase) )
    ini_phase = 0;
elseif(~isreal(ini_phase) || ~isscalar(ini_phase) ||  ~isnumeric(ini_phase) )
    error('comm:amdemod:ini_phaseReal','INI_PHASE must be a real scalar.');
end

carr_amp = 0;
% check the carrier amplitude
if(nargin>=5)
    carr_amp = varargin{1};
    if(isempty(carr_amp)) 
        carr_amp = 0;
    elseif(~isreal(carr_amp) || ~isscalar(carr_amp)|| ~isnumeric(carr_amp))
        error('comm:amdemod:carrAmpReal','CARRAMP must be a real scalar.')
    end 
end


if(isempty(varargin)|| nargin == 5)
    [num,den] = butter(5,Fc*2/Fs);
    
    % check that the numerator and denominator are valid, and come in a pair
elseif( (nargin == 6) )
    error('comm:amdemod:numDenPair','Numerator and Denominator must be a pair.');
    
    
    % check to make sure that both num and den have values.
elseif( xor( isempty(varargin{2}), isempty(varargin{3})))
    error('comm:amdemod:numDenPair','Numerator and Denominator must be a pair.');
elseif(  isempty(varargin{2}) && isempty(varargin{3}) )
    [num,den] = butter(5,Fc*2/Fs);
else 
    num = varargin{2};
    den = varargin{3};
end

% --- Assure that Y, if one dimensional, has the correct orientation --- %
wid = size(y,1);
if(wid ==1)
    y = y(:);
end

t = (0 : 1/Fs :(size(y,1)-1)/Fs)';
t = t(:, ones(1, size(y, 2)));
z = y .* cos(2*pi * Fc * t + ini_phase);
for i = 1 : size(y, 2)
    z(:, i) = filtfilt(num, den, z(:, i)) * 2;
end

z = z - carr_amp;

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    z = z';
end


% --- EOF --- %
