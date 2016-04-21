function scale = modnorm(const,powType, power)
% MODNORM Scaling factor for normalizing modulation output.
%   SCALE = MODNORM(CONST,'AVPOW', AVPOW) returns a scale factor SCALE for
%   normalizing a PAM or QAM modulator output such that its average power
%   is AVPOW (watts). CONST is a one dimensional array specifying the
%   reference constellation  used to generate the scale factor. MODNORM
%   assumes that the signal to be normalized has a minimum distance of 2.
% 
%   SCALE = MODNORM(CONST,'PEAKPOW', PEAKPOW) returns a scale factor SCALE
%   for normalizing a PAM or QAM modulator output such that its peak power
%   is PEAKPOW (watts).
%
%   Example:
%     M = 4;                                % M-ary number.
%     const = pammod([0:M-1],M);            % Generate a constellation.
%     s = randint(1,100,[0 M-1]);           % Random signal
%     Scale = modnorm(const,'avpow',1);     % Compute scale factor for an
%                                           % average power of 1 watt.
%     Tx = Scale * pammod(s,M);             % Modulate and scale.
%     Average_Pow = mean(abs(Tx).^2)        % Compute the average power.
%     Tx = Tx/Scale;                        % Unscale
%     Rx = pamdemod(Tx,M);                  % Demodulate.
%
%     isequal(s,Rx)
%
%   See also PAMMOD, PAMDEMOD, QAMMOD, QAMDEMOD.

%    Copyright 1996-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:00:51 $ 

%error checks

% check that const is a 1-D vector
if(~isvector(const) || ~isnumeric(const) )
    error('comm:modnorm:const1D','CONST must be a one dimensional vector.');
end

% check the string 
if( ~strcmpi(powType,'avpow') && ~strcmpi(powType,'peakpow') )
    error('comm:modnorm:powString','Power type must be ''avpow'' or ''peakpow''. ')
end

%check that the power is a scalar
if( ~isscalar(power) || ~isnumeric(power) || ~isreal(power) || power <= 0 )
    if(strcmpi(powType,'avpow'))
        error('comm:modnorm:powSalar','AVPOW must be a real, positive scalar.');
    else
        error('comm:modnorm:powScalar','PEAKPOW must be a real, positive scalar.');
    end
end

% average power normalization
if(strcmpi(powType,'avpow'))
    constPow = mean(abs(const).^2);
end

% peak power normalization
if(strcmpi(powType,'peakpow'))
     constPow = max(abs(const).^2);
end

 scale = sqrt(power/constPow);
 
% EOF