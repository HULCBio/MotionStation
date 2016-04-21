function y = ssbmod(x, Fc, Fs, varargin)
% SSBMOD Single sideband amplitude modulation.
%   Y = SSBMOD(X, Fc, Fs) uses the message signal X to modulate the carrier
%   frequency Fc (Hz) using single sideband amplitude modulation. X and Fc
%   have sample frequency Fs (Hz). The modulated signal has zero initial
%   phase, and the default sideband modulated is the lower sideband.
%   
%   Y = SSBMOD(X,Fc,Fs,INI_PHASE) specifies the initial phase(rad) of
%   the modulated signal.
%
%   Y = SSBMOD(X,Fc,Fs,INI_PHASE,'upper') uses the upper
%   sideband.
%
%   Fs must satisfy Fs >2*(Fc + BW), where BW is the bandwidth of the
%   modulating signal, X.
%
%   See also SSBDEMOD, AMMOD.

%    Copyright 1996-2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/01/26 18:40:22 $ 

% Number of arguments check
if(nargin > 5)
    error('comm:ssbmod:TooManyInp','Too many input arguments.');
end

%Check x,Fc, Fs, ini_phase
if(~isreal(x)|| ~isnumeric(x))
    error('comm:ssbmod:Xreal','X must be real.');
end

if(~isreal(Fc) || ~isscalar(Fc) || Fc<=0 || ~isnumeric(Fc) )
    error('comm:ssbmod:FcReal','Fc must be a real, positive scalar.');
end

if(~isreal(Fs) || ~isscalar(Fs) || Fs<=0 || ~isnumeric(Fs) )
    error('comm:ssbmod:FsReal','Fs must be a real, positive scalar.');
end

% check that Fs must be greater than 2*Fc
if(Fs<=2*Fc)
    error('comm:ssbmod:Fs2Fc','Fs must be at least 2*Fc');
end

if(nargin>=4)
    ini_phase = varargin{1};
    if(isempty(ini_phase))
        ini_phase = 0;
    elseif(~isreal(ini_phase) || ~isscalar(ini_phase)|| ~isnumeric(ini_phase) )
        error('comm:ssbmod:IniPhaseReal','INI_PHASE must be a real scalar.');
    end
else 
    ini_phase = 0;
end

Method = '';
if(nargin==5)
    Method = varargin{2};
    if(~strcmpi(Method,'upper'))
        error('comm:ssbmod:InvStr','String argument must be ''upper''.');
    end
end

% --- End Parameter checks --- %

% --- Assure that X, if one dimensional, has the correct orientation --- %
wid = size(x,1);
if(wid ==1)
    x = x(:);
end
t = (0:1/Fs:((size(x,1)-1)/Fs))';
t = t(:, ones(1, size(x, 2)));

if findstr(Method, 'up')
    y = x .* cos(2 * pi * Fc * t + ini_phase) - ...
        imag(hilbert(x)) .* sin(2 * pi * Fc * t + ini_phase);    
else
    y = x .* cos(2 * pi * Fc * t + ini_phase) + ...
        imag(hilbert(x)) .* sin(2 * pi * Fc * t + ini_phase);    
end; 

% --- restore the output signal to the original orientation --- %
if(wid == 1)
    y = y';
end

% --- EOF --- %
