function y = ammod(x, Fc, Fs, varargin)
%AMMOD Amplitude modulation.
%   Y = AMMOD(X, Fc, Fs) uses the message signal X to modulate the carrier
%   frequency Fc(Hz) using amplitude modulation. X and Fc have sample
%   frequency Fs (Hz). The modulated signal has zero initial phase. The
%   default carrier amplitude is zero, so the function implement suppressed
%   carrier modulation.
%
%   Y = AMMOD(X,Fc,Fs,INI_PHASE) specifies the initial phase (rad) in the
%   modulated signal, Y.
%
%   Y = AMMOD(X,Fc,Fs,INI_PHASE,CARRAMP) implements transmitted carrier
%   modulation with carrier amplitude CARRAMP.
%
%   Fs must satisfy Fs >2*(Fc + BW), where BW is the bandwidth of the
%   modulating signal, X.
%
%   See also AMDEMOD, SSBMOD, FMMOD, PMMOD.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:39:35 $ 

% Number of arguments check
if(nargin > 5)
    error('comm:ammod:tooManyInp','Too many input arguments.');
end

%Check x,Fc, Fs, ini_phase
if(~isreal(x)|| ~isnumeric(x))
    error('comm:ammod:Xreal','X must be real.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 || ~isnumeric(Fc) )
    error('comm:ammod:FcReal','Fc must be a real, positive scalar.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 || ~isnumeric(Fs))
    error('comm:ammod:FsReal','Fs must be a real, positive scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<2*Fc)
    error('comm:ammod:Fs2Fc','Fs must be at least 2*Fc');
end

%check the ini_phase
if(nargin>=4)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    elseif(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:ammod:ini_phaseReal','INI_PHASE must be a real scalar.');
    end
else 
    ini_phase = 0;
end

% check the carrier amplitude
if(nargin==5)
    carr_amp = varargin{2};
    if(~isreal(carr_amp) || ~isscalar(carr_amp)|| ~isnumeric(carr_amp))
        error('comm:ammod:carrAmpreal','CARRAMP must be a real scalar.')
    end
else
    carr_amp = 0;
end


% --- End Parameter checks --- %

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if(wid ==1)
    x = x(:);
end

% Do the modulation
t = (0:1/Fs:((size(x, 1)-1)/Fs))';
t = t(:, ones(1, size(x, 2)));
y = (x + carr_amp) .* cos(2 * pi * Fc * t + ini_phase);

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y';
end
    
% --- EOF --- %
