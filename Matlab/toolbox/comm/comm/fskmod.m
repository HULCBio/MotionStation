function y = fskmod(x,M,freq_sep,nSamp,varargin)
%FSKMOD Frequency shift keying modulation
%   Y = FSKMOD(X,M,FREQ_SEP,NSAMP) outputs the complex envelope of the
%   modulation of the message signal X using frequency shift keying modulation. M
%   is the alphabet size and must be an integer power of two.  The message
%   signal must consist of integers between 0 and M-1.  FREQ_SEP is the desired
%   separation between successive frequencies, in Hz.  NSAMP denotes the number
%   of samples per symbol and must be an integer greater than 1.  For two
%   dimensional signals, the function treats each column as one channel.
%
%   Y = FSKMOD(X,M,FREQ_SEP,NSAMP,FS) specifies the sampling frequency (Hz).
%   The default sampling frequency is 1.
%
%   Y = FSKMOD(X,M,FREQ_SEP,NSAMP,FS,PHASE_CONT) specifies the phase continuity
%   across FSK symbols.  PHASE_CONT can be either 'cont' for continuous phase, 
%   or 'discont' for discontinuous phase.  The default is 'cont'.
%
%   See also FSKDEMOD, PSKMOD, PSKDEMOD.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2004/04/12 23:00:40 $ 


% Error checks -----------------------------------------------------------------
if (nargin > 6)
    error('comm:fskmod:numarg', 'Too many input arguments. ');
end

% Check X
if (~isreal(x) || any(any(ceil(x) ~= x)) || ~isnumeric(x))
    error('comm:fskmod:xreal', ...
        'Elements of input X must be integers in [0, M-1].');
end

% Check that M is a positive integer
if (~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M))
    error('comm:fskmod:Mreal', 'M must be a positive integer. ');
end

% Check that M is of the form 2^K
if(~isnumeric(M) || (ceil(log2(M)) ~= log2(M)))
    error('comm:fskmod:Mpow2', 'M must be a power of 2. ');
end

%Check that all X are integers within [0,M-1]
if ((min(min(x)) < 0) || (max(max(x)) > (M-1)))
    error('comm:fskmod:xreal', ...
        'Elements of input X must be integers in [0, M-1].');
end

% Check that the FREQ_SEP is greater than 0
if( ~isnumeric(freq_sep) || ~isscalar(freq_sep) || freq_sep<=0 )
    error('comm:fskmod:freqSep', 'FREQ_SEP must be a scalar greater than 0.');
end

% Check that NSAMP is an integer greater than 1
if((~isnumeric(nSamp) || (ceil(nSamp) ~= nSamp)) || (nSamp <= 1))
    error('comm:fskmod:nSampPos', 'NSAMP must be an integer greater than 1.');
end

% Check Fs
if (nargin >= 5)
Fs = varargin{1};
    if (isempty(Fs))
        Fs = 1;
    elseif (~isreal(Fs) || ~isscalar(Fs) || ~isnumeric(Fs) || Fs<=0)
        error('comm:fskmod:FsReal', 'FS must be a real, positive scalar. ');
    end
else
    Fs = 1;
end
samptime = 1/Fs;

% Check that the maximum transmitted frequency does not exceed Fs/2
maxFreq = ((M-1)/2) * freq_sep;
if (maxFreq > Fs/2)
    error('comm:fskmod:maxFreq', ...
          'The maximum frequency must be less than or equal to Fs/2.');
end

% Check if the phase is continuous or discontinuous
if (nargin == 6)
    phase_type = varargin{2};
    %check the phase_type string
    if ~( strcmpi(phase_type,'cont') ||  strcmpi(phase_type,'discont') )
        error('comm:fskmod:phaseCont', ...
              'PHASE_CONT must be ''cont'' or ''discont''.');
    end

else
    phase_type = 'cont';
end

if (strcmpi(phase_type, 'cont'))
    phase_cont = 1;
else
    phase_cont = 0;
end

% End of error checks ----------------------------------------------------------


% Assure that X, if one dimensional, has the correct orientation
wid = size(x,1);
if (wid == 1)
    x = x(:);
end

% Obtain the total number of channels
[nRows, nChan] = size(x);

% Initialize the phase increments and the oscillator phase for modulator with 
% discontinous phase.  phaseIncr is the incremental phase over one symbol,
% across all M tones.  phIncrSamp is the incremental phase over one sample,
% across all M tones.
phaseIncr = [0:nSamp-1]'*[-(M-1):2:(M-1)]*pi*freq_sep*samptime;
phIncrSym = phaseIncr(end,:);
phIncrSamp = phaseIncr(2,:);    % recall that phaseIncr(1:0) = 0
OscPhase = zeros(nChan, M);
prevPhase = 0;

% phase = nSamp*# of symbols x # of channels
Phase = zeros(nSamp*nRows, nChan);

for iChan = 1 : nChan

    for iSym = 1:length(x)
        
        % Get the initial phase for the current symbol
        if (phase_cont)
            ph1 = prevPhase;
        else
            ph1 = OscPhase(x(iSym,iChan)+1);
        end

        % Compute the phase of the current symbol by summing the initial phase
        % with the per-symbol phase trajectory associated with the given M-ary
        % data element.
        Phase(nSamp*(iSym-1)+1:nSamp*iSym,iChan) = ...
            ph1*ones(nSamp,1) + phaseIncr(:,x(iSym,iChan)+1);

        % Update the oscillator for a modulator with discontinuous phase.
        % Calculate the phase modulo 2*pi so that the phase doesn't grow too
        % large.
        if (~phase_cont)
            OscPhase(iChan,:) = ...
            rem(OscPhase(iChan,:) + phIncrSym + phIncrSamp, 2*pi);
        end

        % If in continuous mode, the starting phase for the next symbol is the
        % ending phase of the current symbol plus the phase increment over one
        % sample.
        prevPhase = Phase(nSamp*iSym,iChan) + phIncrSamp(x(iSym,iChan)+1);
    end
end

y = exp(j*Phase);

% Restore the output signal to the original orientation
if(wid == 1)
    y = y.';
end

% EOF --- fskmod.m
