function  [ber, varargout] = semianalytic(txSig, rxSig, modType, M, Nsamp, ...
                             varargin)
%SEMIANALYTIC Use the semianalytic technique to calculate BER performance.
%   BER = SEMIANALYTIC(TXSIG, RXSIG, MODTYPE, M, Nsamp) returns the BER of a
%   system that transmits the complex baseband vector signal TXSIG and receives
%   the noiseless complex baseband vector signal RXSIG.  It is assumed that
%   RXSIG is received after the point where the noise would be introduced, but
%   prior to the receiver filter.  MODTYPE is the modulation type of the signal,
%   and can have the values 'psk', 'qam', 'dpsk', 'oqpsk', 'msk/diff', or
%   'msk/nondiff'.  The 'diff' and 'nondiff' options for MSK refer to
%   differentially encoded, coherently demodulated systems.  M is the order of
%   the modulation, the value of which is dependent on MODTYPE as follows:
%
%                    MODTYPE                        M
%                 -------------    ----------------------------------------
%                 'psk/diff'       2, 4
%                 'psk/nondiff'    2, 4, 8, 16, 32, or 64 
%                 'qam'            4, 8, 16, 32, 64, 128, 256, 512, or 1024 
%                 'dpsk'           2 or 4 
%                 'oqpsk'          4
%                 'msk/diff'       2
%                 'msk/nondiff'    2
%
%   Nsamp is the number of samples per symbol of TXSIG and RXSIG.  Nsamp must be
%   an integer, and is also the sample frequency, in Hz, of TXSIG and RXSIG.
%   For this calling sequence, SEMIANALYTIC filters the received signal RXSIG
%   with an ideal integrator.  It calculates BERs for Eb/No values in the range
%   of [0:20] dB. In doing so, SEMIANALYTIC assumes that symbols are Gray coded.
%
%   SEMIANALYTIC returns an upper bound on the BER of a DQPSK system.
%
%   BER = SEMIANALYTIC(TXSIG, RXSIG, MODTYPE, M, Nsamp, NUM, DEN) filters
%   the signal RXSIG with a receiver filter with a transfer function given in
%   ascending powers of z^(-1) by the vectors NUM and DEN.  
%
%   BER = SEMIANALYTIC(TXSIG, RXSIG, MODTYPE, M, Nsamp, EbNo) returns BER
%   values over the Eb/No range specified in dB by the vector EbNo.
%
%   BER = SEMIANALYTIC(TXSIG, RXSIG, MODTYPE, M, Nsamp, NUM, DEN, EbNo)
%   combines the functionality of the above two calling sequences.
%
%   [BER, AVGAMPL, AVGPOWER] = SEMIANALYTIC(. . .) returns the mean complex
%   signal amplitude and power of the signal RXSIG after it has been filtered by
%   the receiver filter and sampled at the symbol rate.
%
%
%   Example:  To determine the BER of a 16QAM system with square pulse shaping,
%   a slight phase offset, and an integrate and dump receiver filter:
%
%   % Initialize variables and generate message sequence.
%   M = 16; Nsamp = 16; msg = [0:M-1 0];
%
%   % Modulate the message with 16QAM and pulse shape.
%   modsig = qammod(msg,M);
%   txsig = rectpulse(modsig,Nsamp);
%
%   % Run txsig through a noiseless channel and add one degree of phase offset.
%   rxsig = txsig*exp(j*pi/180);
%
%   % Specify the receiver filter and calculate BER over an Eb/No range.
%   num = ones(Nsamp,1)/Nsamp; den = 1; EbNo = [0:20];
%   ber = semianalytic(txsig,rxsig,'qam',M,Nsamp,num,den,EbNo);
%
%
%   See also DFILT/CASCADE, NOISEBW, QFUNC.

%   Copyright 1996-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.6 $  $Date: 2003/12/01 18:58:05 $
%
%   References:   M. Jeruchim, P. Balaban, and K.S. Shanmugan, Simulation of
%   Communication Systems, 2nd ed., 2000.  
%   S. Pasupathy, "MSK: A Spectrally Efficient Modulation", IEEE Communications
%   Magazine, July 1979.

% Error checking ----------------------------------
% Number of input arguments
if (nargin < 5 || nargin > 8)
    error('comm:semianalytic:InputArgs',...
          'SEMIANALYTIC requires between 5 and 8 arguments.');
end

% txSig
if (isreal(txSig) || ~isnumeric(txSig) || ismatrix(txSig))
    error('comm:semianalytic:complexVector',...
          'TXSIG must be a complex vector.');
end

% rxSig
if (isreal(rxSig) || ~isnumeric(rxSig) || ismatrix(rxSig))
    error('comm:semianalytic:complexVector',...
          'RXSIG must be a complex vector.');
end

% txSig and rxSig
if (size(rxSig) ~= size(txSig))
    error('comm:semianalytic:sameDims',...
          'TXSIG and RXSIG must be the same dimensions.');
end

% modType
modType = lower(modType);
valModType = {'psk/diff' 'psk/nondiff' 'qam' 'dpsk' 'oqpsk' 'msk/diff' ...
              'msk/nondiff'};
if(~any(strcmp(modType, valModType)))
    error('comm:semianalytic:invalidModtype', 'Invalid MODTYPE specified');
end

if (ismember(modType, {'msk/diff' 'msk/nondiff'}) && length(rxSig)/Nsamp<4)
    error('comm:semianalytic:invalidLength', ...
          'For MSK modulation, the signals must be at least 4 symbols long.');
end

% M
switch modType
    case 'psk/diff'
        valM = [2 4];
        if (all(M~=valM))
            error('comm:semianalytic:invalidM', ...
                  ['For PSK modulation with differential encoding, ' ...
                   'M must be 2 or 4.']);
        end
        
    case 'psk/nondiff'
        valM = [2 4 8 16 32 64];
        if (all(M~=valM))
            error('comm:semianalytic:invalidM',...
                  ['For PSK modulation with nondifferential encoding, ' ...
                  'M must be 2, 4, 8, 16, 32, or 64.']);
        end
        
    case 'qam'
        valM = [4 8 16 32 64 128 256 512 1024];
        if (all(M~=valM))
            error('comm:semianalytic:invalidM',...
                  ['For QAM modulation, M must be an integer power of 2 ', ...
                   'between 4 and 1024, inclusive.']);
        end
        
    case 'dpsk'
        if (M~=2 && M~=4)
            error('comm:semianalytic:invalidM',...
                  'For DPSK modulation, M must be 2 or 4.');
        end
        
    case 'oqpsk'
        if (M~=4)
            error('comm:semianalytic:invalidM',...
                  'For OQPSK modulation, M must be 4.');
        end
        
    case {'msk/diff' 'msk/nondiff'}
        if (M~=2)
            error('comm:semianalytic:invalidM',...
                  'For MSK modulation, M must be 2.');
        end
end

% Nsamp
if (~isreal(Nsamp) || ~isnumeric(Nsamp) || ~isscalar(Nsamp) || ...
    ~isinteger(Nsamp) || Nsamp<=0)
    error('comm:semianalytic:invalidNsamp',...
          'Nsamp must be a real, positive integer scalar.');
end
Fs = Nsamp;     % With Fs==Nsamp, we assume that the symbol rate = 1 sps


% If varargin is empty, populate NUM, DEN, and EbNo
switch length(varargin)
    case 0          % empty varargin -- populate NUM, DEN, and EbNo
        switch modType
            case {'psk/diff' 'psk/nondiff' 'qam' 'dpsk'}
                num = ones(Nsamp,1) / Nsamp;
            otherwise
                num = ones(2*Nsamp,1) / (2*Nsamp);
        end
        den = 1;
        EbNo = 0:20;
        
    case 1          % EbNo is being specified
        EbNo = varargin{1};  
        if (~isreal(EbNo) || ~isnumeric(EbNo) || length(size(EbNo))>2 || ...
            all(size(EbNo)>1))
            error('comm:semianalytic:invalidEbNo', ...
                  'EbNo must be a real vector.');
        end
        switch modType
            case {'psk/diff' 'psk/nondiff' 'qam' 'dpsk'}
                num = ones(Nsamp,1) / Nsamp;
            otherwise
                num = ones(2*Nsamp,1) / (2*Nsamp);
        end
        den = 1;
        
    case 2          % NUM and DEN are being specified
        num = varargin{1};
        if (~isnumeric(num) || length(size(num))>2 || all(size(num)>1))
            error('comm:semianalytic:invalidNUM',...
                  'NUM must be a numeric vector.');
        end
        den = varargin{2};
        if (~isnumeric(den) || length(size(den))>2 || all(size(den)>1))
            error('comm:semianalytic:invalidDEN',...
                  'DEN must be a numeric vector.');
        end
        EbNo = 0:20;
        
    case 3          % NUM, DEN, and EbNo are being specified
        num = varargin{1};
        if (~isnumeric(num) || length(size(num))>2 || all(size(num)>1))
            error('comm:semianalytic:invalidNUM',...
                  'NUM must be a numeric vector.');
        end
        den = varargin{2};
        if (~isnumeric(den) || length(size(den))>2 || all(size(den)>1))
            error('comm:semianalytic:invalidDEN',...
                  'DEN must be a numeric vector.');
        end
        EbNo = varargin{3};  
        if (~isreal(EbNo) || ~isnumeric(EbNo) || length(size(EbNo))>2 || ...
            all(size(EbNo)>1))
            error('comm:semianalytic:invalidEbNo',...
                  'EbNo must be a real vector.');
        end
end

% Number of output arguments
if (nargout > 3)
    error('comm:semianalytic:OutputArgs',...
          'Too many output arguments.');
end
if (nargout == 2)
    error('comm:semianalytic:OutputArgs',...
          'SEMIANALYTIC allows 1 or 3 output arguments.');
end
% End of error checking ------------------------------

% Perform initial receiver processing.  For all modulation types except MSK,
% simply filter the received signal with the filter described by NUM and DEN.
% For MSK, perform the processing described by Pasupathy, "MSK: A Spectrally
% Efficient Modulation", IEEE Comms Mag., July 1979.
valMSKmodType = {'msk/diff' 'msk/nondiff'};
if (~ismember(modType, valMSKmodType))
    filtSig = filter(num, den, rxSig);
else
    % Multiply the received MSK signal by cos(pi*(t-tau)/2T) and
    % sin(pi*(t-tau)/2T), where tau is the delay (in sec) between txSig and
    % rxSig, and T is the symbol time (in sec).  See Pasupathy for a fuller
    % discussion on T. These cos() and sin() multipliers are matched to the I
    % and Q pulse shapes, respectively. Then perform receiver filtering.
    
    % Get delay, in sec
    [maxVal, index] = max(abs(xcorr(rxSig, txSig)));
    sigLength = length(txSig);
    delay = index - sigLength;      % in samples
    tau = delay / Fs;               % in sec
    
    % Define the other time variables
    t = (0 : 1/Fs : length(rxSig)/Fs - 1/Fs)';
    Tsym = Nsamp / Fs;
    
    % Perform the multiplication
    multI = sqrt(2) * cos(pi*(t-tau)/(2*Tsym));
    multQ = sqrt(2) * sin(pi*(t-tau)/(2*Tsym));
    realMultSig = multI .* real(rxSig(:));
    imagMultSig = multQ .* imag(rxSig(:));
    multSig = complex(realMultSig, imagMultSig);
    filtSig = filter(num, den, multSig);
end

% Determine the proper symbol timing and return a vector of symbol-spaced
% samples
sampledSig = symtiming(txSig, rxSig, filtSig, modType, M, Nsamp, num, den);

% Calculate the noise bandwidth of the receive filter
numSamp = max([length(num) length(den) length(rxSig)]);
Bn = noisebw(num, den, numSamp, Fs);

% Calculate BERs over the entire signal vector
ber = bercalc(sampledSig, EbNo, modType, M, Nsamp, Fs, Bn);

% Calculate mean and power of sampled signal, if necessary
if (nargout == 3)
    varargout{1} = mean(sampledSig);
    varargout{2} = mean(sampledSig .* conj(sampledSig));
end

return;

% ------------------------------------------------------------------------------
function  sampledSig = symtiming(txSig, rxSig, filtSig, modType, M, Nsamp, ...
                                 num, den)
%SYMTIMING Sample a received digital signal to minimize BER
%   SAMPLEDSIG = SYMTIMING(TXSIG, RXSIG, FILTSIG, MODTYPE, M, Nsamp, NUM, DEN)
%   returns a decimated digital signal, sampled such that its average distance
%   to the ideal signaling points is minimized.  It finds the sampling instant
%   by initially finding the delay induced by the system on the received signal
%   FILTSIG. (NUM and DEN are used to find the delay induced by the receiver
%   filter when the MODTYPE is MSK.)  It then subdivides FILTSIG into Nsamp
%   vectors by decimating FILTSIG by a factor of Nsamp (the number of samples
%   per symbol), with each subvector having a different timing offset. The
%   function then calculates the distance from the ideal signaling point to the
%   received subvector.  The index at which the mean distance is minimized is
%   the index at which to sample the signal.

% Find the delay through the system.  For all modulation types besides MSK,
% simply correlate the transmitter output with the receiver filter output.  For
% MSK, correlate the transmitter output with the *input* to the receiver filter.
% Then find the peak of the impulse response of the receiver filter, and add
% that to the computed delay.
valMSKmodType = {'msk/diff' 'msk/nondiff'};
if (~ismember(modType, valMSKmodType))
    [maxVal, index] = max(abs(xcorr(filtSig, txSig)));
    sigLength = length(txSig);
    delay = index - sigLength;
else
    [maxVal, index] = max(abs(xcorr(rxSig, txSig)));
    sigLength = length(txSig);
    chnlDelay = index - sigLength;      % delay prior to receive filter
    
    impulse = [1; zeros(length(txSig)-1,1)];
    impResp = filter(num, den, impulse);
    [maxVal, delIndex1] = max(impResp);
    
    % Account for the ideal windowed integrator case, in which case the delay is
    % the length of the integrator
    if (all(impResp(1) == impResp))
        rxDelay = length(impResp);       % for ideal windowed integrator
    else
        rxDelay = delIndex1;
    end
    delay = chnlDelay + rxDelay;
end
    
% Create the decimated subvectors
switch modType    
    case {'msk/diff' 'msk/nondiff' 'oqpsk'}       % align I and Q over 2Tsym
        decSig = complex(real(filtSig(1:end-Nsamp)), imag(filtSig(1+Nsamp:end)));
        decSig = decSig(max([delay 1])+Nsamp:end);             % discard transient response
        decSig = decSig(1:end-mod(length(decSig), 2*Nsamp));   % prepare decSig for reshape
        decSig = reshape(decSig, 2*Nsamp, length(decSig)/(2*Nsamp)).';
    
    otherwise
        decSig = filtSig(max([delay 1]):end);                  % discard transient response
        decSig = decSig(1:end-mod(length(decSig), Nsamp));     % prepare decSig for reshape
        decSig = reshape(decSig, Nsamp, length(decSig)/Nsamp).';
end

% Find the index where the average distance from the ideal signaling point(s) to
% the received signal subvector is minimized.
switch modType
    case {'psk/diff' 'psk/nondiff' 'dpsk'}
        % Rotate all points so that they are nominally on the positive I-axis.
        % This operation assumes that the first PSK constellation point actually
        % is on the positive I-axis, instead of rotated by pi/M
        posSig = abs(real(decSig)) + j*abs(imag(decSig));
        if (M == 4)
            posSig = max(real(posSig), imag(posSig)) + j*min(real(posSig), imag(posSig));
        elseif (M > 4)
            posSig = posSig .* exp(j*pi/M);
            mag = abs(posSig);
            newSigAngle = mod(angle(posSig), pi/(M/2)) - pi/M;
            posSig = mag .* exp(j*newSigAngle);
        end
        
        % Find the distance to (1,0)
        dist = abs(posSig - 1);             % mod(length(decSig, Nsamp)) X Nsamp
        
    case 'oqpsk'
        % Rotate all the points so that they are nominally on the positive
        % I-axis. This operation assumes that the OQPSK constellation has an
        % offset of pi/4 radians.
        posSig = abs(real(decSig)) + j*abs(imag(decSig));   % to first quadrant
        posSig = posSig .* exp(-j*pi/4);                    % to positive I-axis
        
        % Find the distance to (1,0)
        dist = abs(posSig - 1);             % mod(length(decSig, Nsamp)) X Nsamp       
    
    case {'msk/diff' 'msk/nondiff'}
        % Rotate all points to the first quadrant
        mag = abs(decSig);
        newSigAngle = mod(angle(decSig), pi/2);
        rotateSig = mag .* exp(j*newSigAngle);
        
        % Find the distance to (cos(pi/M, sin(pi/M))
        idealPoint = (1+j) / sqrt(2);
        dist = abs(rotateSig - idealPoint);    % mod(length(decSig, Nsamp)) X Nsamp
        
    case 'qam'
        % Create ideal constellations for each QAM type.  These constellations
        % exist only in the first quadrant, since the signal will be rotated
        % there anyway
        constellation = idealQAMConst(M);
        
        % Collapse the signal into the first quadrant and find the minimum
        % distance from each received signal point to an ideal point
        collapseSig = complex(abs(real(decSig)), abs(imag(decSig)));
        for iRow = 1 : size(collapseSig, 1)
            for iCol = 1 : size(collapseSig, 2)
                dist(iRow, iCol) = min(abs(collapseSig(iRow, iCol) - constellation));
            end
        end

end
meanDist = mean(dist, 1);           % 1 X Nsamp
[minDist, minIndex] = min(meanDist);
sampledSig = decSig(:, minIndex);   % perform the actual signal sampling

return;

% -----------------------------------------------------------------------------------
function  ber = bercalc(rxSig, EbNo, modType, M, Nsamp, Fs, Bn)
%BERCALC Calculate BER values over a range of EbNo values
%   BER = BERCALC(RXSIG, EBNO, MODTYPE, M, Nsamp, Fs, Bn) returns the BER values
%   over a range of EbNo values, in dB, for the received signal RXSIG.  The
%   received signal has a modulation type of MODTYPE, of order M.  MODTYPE can
%   be either 'psk',  'qam', 'dpsk', 'oqpsk', or 'msk'.  The system under test
%   has a two-sided noise bandwidth Bn, in Hz. The signal has a symbol rate of
%   Fs/Nsamp, in symbols per second.

ber = [];

% Set the signal power
sigPower = sum(abs(rxSig).^2) / length(rxSig);

% Set the bit rate.  Treat OQPSK like MSK by setting the bit rate equal to the
% symbol rate, as does Pasupathy.
symRate = Fs / Nsamp;
bitRate = symRate * log2(M);
if (strcmpi(modType, 'oqpsk'))
    bitRate = symRate;
end

% Loop over the EbNo vector
for EbNoindex = 1:length(EbNo)
    % Find the standard deviation of the noise, in V
    EbNoAbs = 10.^(EbNo(EbNoindex)./10);
    noiseStdDev = sqrt((Bn/2) * (1/EbNoAbs) * (sigPower/bitRate));
    noiseVar = noiseStdDev.^2;
    
    % Calculate the BER vector on a per-modulation basis
    switch lower(modType)
        case 'psk/diff'
            if (M == 2)
                % Use consecutive symbols to calculate the error.  The BER is
                % the probability that one symbol is in error and the next one
                % is correct.
                arg1 = abs(real(rxSig(1:end-1))) ./ noiseStdDev;
                arg2 = abs(real(rxSig(2:end))) ./ noiseStdDev;
                berVec = 2*qfunc(arg1).*(1-qfunc(arg2));
                ber(EbNoindex) = sum(berVec) / (length(rxSig)-1);
                
            elseif (M == 4)
                % Rotate the signal constellation so that Q functions can be
                % independently calculated for the I and Q rails.  (The rotated
                % constellation has symbols at +/-0.707 +/-j*0.707.)
                newRxSig = abs(real(rxSig)) + j*abs(imag(rxSig));
                newRxSig = max(real(newRxSig), imag(newRxSig)) + ...
                               j*min(real(newRxSig), imag(newRxSig));
                newRxSig = newRxSig * exp(j*pi/4);
                
                % Use consecutive symbols to calculate the error.  The BER is
                % the probability that one symbol is correct and the next one is
                % in error.
                realArg1 = abs(real(newRxSig(1:end-1))) ./ noiseStdDev;
                imagArg1 = abs(imag(newRxSig(1:end-1))) ./ noiseStdDev;
                realArg2 = abs(real(newRxSig(2:end))) ./ noiseStdDev;
                imagArg2 = abs(imag(newRxSig(2:end))) ./ noiseStdDev;
                
                % Get the prob that the first symbol is correct
                PcorrI1 = 1 - qfunc(realArg1);
                PcorrQ1 = 1 - qfunc(imagArg1);
                PcorrSym1 = PcorrI1 .* PcorrQ1;
                
                % Get the prob that the next symbol is in error
                PerrI2 = qfunc(realArg2);
                PerrQ2 = qfunc(imagArg2);
                PerrSym2 = PerrI2 + PerrQ2 - PerrI2 .* PerrQ2;
                
                % Get the prob of a symbol error.  Account for the factor of 2
                % because of differential encoding.
                PsymErr = 2 * PcorrSym1 .* PerrSym2;
                
                % Get the BER. Divide by 2 because of the assumption of Gray
                % coding for QPSK.
                ber(EbNoindex) = sum(PsymErr) / (2*(length(rxSig)-1));
                
            end
            
        case 'psk/nondiff'
            if (M == 2)
                ber(EbNoindex) = mean(qfunc(abs(real(rxSig)) ./ noiseStdDev));
                
            elseif (M == 4)
                % Rotate the signal constellation so that Q functions can be
                % independently calculated for the I and Q rails.  (The rotated
                % constellation has symbols at +/-0.707 +/-j*0.707.)
                newRxSig = abs(real(rxSig)) + j*abs(imag(rxSig));
                newRxSig = max(real(newRxSig), imag(newRxSig)) + j*min(real(newRxSig), imag(newRxSig));
                newRxSig = newRxSig * exp(j*pi/4);
                
                berI = mean(qfunc(abs(real(newRxSig)) ./ noiseStdDev));
                berQ = mean(qfunc(abs(imag(newRxSig)) ./ noiseStdDev));
                ber(EbNoindex) = 0.5*(berI + berQ);  % We assume an orthogonal I and Q
                
            elseif (M > 4)
                
                % The AWGN in I and Q create a composite noise vector that is
                % uniformly distributed in phase, and Rayleigh distributed in
                % amplitude.  Using the Rayleigh amplitude distribution, find
                % the total SER as an average of SERs conditioned on the phase
                % of the noise.  Then calculate BER by assuming Gray coding.
                
                % First rotate each sampled signal point such that it nominally
                % sits on the positive I-axis.  Assume that the ideal PSK
                % constellation contains signal points on the I and Q axes.
                newRxSig = rxSig .* exp(j*pi/M);
                mag = abs(rxSig);
                newSigAngle = mod(angle(newRxSig), pi/(M/2)) - pi/M;
                newRxSig = mag .* exp(j*newSigAngle);
                
                % Set overall angle limits over which BERs will be calculated
                thetaMin = (pi/M) + pi/180;         % 1 degree above "numerical trouble" limit
                thetaMax = ((2*M-1)*pi/M) - pi/180; % 1 degree below "numerical trouble" limit
                alpha    = angle(newRxSig);
                
                numCalcBER = 60;       % # of BERs to calculate per signal point per Eb/No
                serPerSig = zeros(length(newRxSig),1);  % Pre-allocating memory
                
                for sigIndx = 1:length(newRxSig)
                    
                    % Create a vector of distances from each signal point to the
                    % decision boundary with the positive slope.  Create the
                    % signal point, then the angles over which to extend to the
                    % decision boundary, then the points of intersection, then
                    % the distances.
                    Ival = real(newRxSig(sigIndx));
                    Qval = imag(newRxSig(sigIndx));
                    thetaPos = (thetaMin : pi/(numCalcBER/2) : pi + alpha(sigIndx));
                    thetaNeg = (pi + alpha(sigIndx) : pi/(numCalcBER/2) : thetaMax);
                    xAtBdry = (Qval - Ival .* tan(thetaPos)) ./ (tan(pi/M) - tan(thetaPos));
                    yAtBdry = tan(pi/M) .* xAtBdry;
                    distPos = sqrt((xAtBdry-Ival).^2 + (yAtBdry-Qval).^2);
                    
                    % Create a vector of distances from each signal point to the
                    % decision boundary with the negative slope
                    xAtBdry = (Ival .* tan(thetaNeg - pi) - Qval) ./ (tan(pi/M) + tan(thetaNeg - pi));
                    yAtBdry = -tan(pi/M) * xAtBdry;
                    distNeg = sqrt((xAtBdry-Ival).^2 + (yAtBdry-Qval).^2);
                    
                    distance = [distPos distNeg];
                    
                    % Determine the number of "distance vectors" for which the
                    % BER is 0 because they never intersect a decision boundary
                    numZeroBER = numCalcBER - length(distance);
                    
                    % Use 1 minus the Rayleigh CDF to get the BER at all the
                    % possible phase offsets of the noise, then average the
                    % result over all phase offsets
                    serPerSig(sigIndx) = sum(exp(-distance.^2 / (2*noiseVar))) ./ numCalcBER;
                end
                
                % Average over all signals to get the SER at this Eb/No, then
                % assume Gray coding to get BER from SER
                serPerEbNo = mean(serPerSig);
                ber(EbNoindex) = serPerEbNo / log2(M);
            end
            
        case 'dpsk'
            if (M == 2)
                if (EbNoindex == 1)
                    % Demodulate by performing a delay and multiply.  The
                    % conjugate operation performs a phase differencing between
                    % the two signals, and the real part is the projection of
                    % the second signal on the first signal.  Define an initial
                    % condition so that the demodulated signal is the same
                    % length as the received signal
                    rxSigInit = 1;
                    demodSig(1) = real(rxSigInit .* conj(rxSig(1)));
                    demodSig2 = real(rxSig(1:end-1) .* conj(rxSig(2:end)));
                    demodSig2 = demodSig2(:);       % Convert to a column vector for appending
                    demodSig = [demodSig(1); demodSig2];
                end
            
                arg = -(abs(demodSig) ./ (2*noiseVar));          % arg is a modified SNR
                ber(EbNoindex) = mean(0.5 * exp(arg));
                
            elseif (M == 4)
                % Use an upper bound on performance.  Assume that the squared
                % noise term of the decision variable is negligible.  Taken from
                % Sklar, 2nd ed., ch. 4.9.
                sigAmpl = abs(rxSig);
                arg = (sigAmpl ./ noiseStdDev) * sin(pi/(4*sqrt(2)));
                ber(EbNoindex) = mean(qfunc(arg));
            end
            
        case 'oqpsk'
            % Rotate the signal constellation so that Q functions can be
            % independently calculated for the I and Q rails.  (The rotated
            % constellation has symbols at 0.707 +j*0.707.)
            newRxSig = abs(real(rxSig)) + j*abs(imag(rxSig));

            berI = mean(qfunc(abs(real(newRxSig)) ./ noiseStdDev));
            berQ = mean(qfunc(abs(imag(newRxSig)) ./ noiseStdDev));
            ber(EbNoindex) = 0.5*(berI + berQ);  % We assume an orthogonal I and Q

        case 'msk/diff'
            % At a given time index, the I and Q channels of rxSig represent
            % consecutive data bits.  I represents bits 1, 3, 5, etc., and Q
            % represents bits 2, 4, 6, etc.  Two consecutive bits are needed for
            % the BER computation.  First use the I and Q bits at each time
            % instant for comparisons between bits 1-2, 3-4, etc.  Then slide Q
            % relative to I for comparisons between bits 2-3, 4-5, etc.
            realArg1 = abs(real(rxSig)) ./ noiseStdDev;
            imagArg1 = abs(imag(rxSig)) ./ noiseStdDev;
            ber1 = 2*qfunc(realArg1).*(1-qfunc(imagArg1));
            
            shiftRxSig = complex(real(rxSig(2:end)), imag(rxSig(1:end-1)));
            realArg2 = abs(real(shiftRxSig)) ./ noiseStdDev;
            imagArg2 = abs(imag(shiftRxSig)) ./ noiseStdDev;
            ber2 = 2*qfunc(realArg2).*(1-qfunc(imagArg2));
            
            ber(EbNoindex) = (sum(ber1)+sum(ber2)) / (2*length(rxSig)-1);
            
        case 'msk/nondiff'
            berI = mean(qfunc(abs(real(rxSig)) ./ noiseStdDev));
            berQ = mean(qfunc(abs(imag(rxSig)) ./ noiseStdDev));
            ber(EbNoindex) = 0.5*(berI + berQ);  % We assume an orthogonal I and Q
            
        case 'qam'
            % Create ideal decision boundaries for all rectangular QAM
            % constellation sets up to 1024QAM
            [decBdryI decBdryQ] = idealQAMBdry(M);
            
            % Collapse the signal into the first quadrant
            rxSigI = abs(real(rxSig));
            rxSigQ = abs(imag(rxSig));
            
            % Initialize the I and Q decision boundaries
            sigLength = length(rxSig);
            sigBdryI  = zeros(sigLength,2);
            sigBdryQ  = zeros(sigLength,2);
            
            % Find the decision boundaries surrounding each signal point
            for sigIndx = 1:sigLength
                minIndxI = max(find(decBdryI < rxSigI(sigIndx)));
                sigBdryI(sigIndx, 1) = decBdryI(minIndxI);
                sigBdryI(sigIndx, 2) = decBdryI(minIndxI+1);
                
                minIndxQ = max(find(decBdryQ < rxSigQ(sigIndx)));
                sigBdryQ(sigIndx, 1) = decBdryQ(minIndxQ);
                sigBdryQ(sigIndx, 2) = decBdryQ(minIndxQ+1);
            end    
            
            % Find the probability that the I and Q channels are correct
            PcI = 1 - qfunc((rxSigI - sigBdryI(:,1)) ./ noiseStdDev) - ...
                qfunc((sigBdryI(:,2) - rxSigI) ./ noiseStdDev);
            PcQ = 1 - qfunc((rxSigQ - sigBdryQ(:,1)) ./ noiseStdDev) - ...
                qfunc((sigBdryQ(:,2)-rxSigQ) ./ noiseStdDev);
            
            % Find the probability of a symbol error, then assume Gray coding to get the BER
            PeSym = 1 - PcI .* PcQ;
            ber(EbNoindex) = (sum(PeSym) ./ sigLength) ./ log2(M);
            
    end
end

return;

% -----------------------------------------------------------------------------------
function [decBdryI, decBdryQ] = idealQAMBdry(M)
%IDEALDECBDRY Find ideal decision boundary thresholds for M-ary QAM
%   [DECBDRYI DECBDRYQ] = IDEALQAMBDRY(M) returns vectors or matrices of ideal
%   decision thresholds for rectangular QAM modulation with an alphabet size of
%   M up to 1024.  The decision thresholds are approximate (i.e. rectangular for
%   all signal points) for non-square constellations (i.e. M=8, 32, 128, and
%   512), since they do not account for the "cross" characteristics of these
%   modulation types. The function assumes the the I and Q QAM signalling points
%   are 1, 3, 5, etc., because the received QAM signal is collapsed into the
%   first quadrant. The computed decision boundaries include a very large
%   maximum threshold to maintain the same form of BER equation for all input
%   signal types.  

if ((round(sqrt(M))^2) == (sqrt(M))^2)    % Square QAM
    decBdryI = [0:2:sqrt(M)-2 1e5];
    decBdryQ = decBdryI;
elseif (M==8)
    decBdryI = [0 2 1e5];
    decBdryQ = [0 1e5];
else              % Cross constellation
    % Find the parameters of the cross constellation.  bigLen is the number of
    % signal points along an I or Q axis of a square constellation that
    % encompasses the cross constellation, and smallLen is the number of signal
    % points along an I or Q axis of the "square" of signal points that is
    % removed from the large square constellation to make the cross
    smallLen = 1;
    for bigLen = ceil(sqrt(M)) : floor(sqrt(2*M))
        while (bigLen > sqrt(M + 4*smallLen.^2))
            smallLen = smallLen + 1;
        end
        if (bigLen == sqrt(M + 4*smallLen.^2))
            break;
        else          % bigLen < target
            bigLen = bigLen + 1;
            smallLen = 1;
        end
    end
    
    decBdryI = [0:2:bigLen-2 1e5];
    decBdryQ = decBdryI;
end

return;

% EOF -- semianalytic.m