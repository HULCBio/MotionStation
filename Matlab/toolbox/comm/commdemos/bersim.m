function [ber numBits] = bersim(EbNo, maxNumErrs, maxNumBits)
%BERSIM Baseband QPSK simulation example for BERTool
%
%   BERSIM demonstrates how to simulate modulation using a complex baseband
%   equivalent representation of the signal modulated on a carrier. It also
%   shows demodulation and detection of the signal in the presence of
%   additive white Gaussian noise for quaternary phase shift keying (QPSK).
%   EbNo is a scalar that represents the bit energy to noise power spectral
%   density ratio (in dB) of the channel. The simulation runs until either
%   the number of errors equals or exceeds 'maxNumErrs', or the simulated
%   number of bits reaches 'maxNumBits'. The function returns the bit error
%   rate and the actual number of bits simulated.
%
%   BERSIM serves as a simple example of how to write a MATLAB simulation
%   function for BERTool.
%
%   See also SIMBASEBANDEX

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/24 20:32:32 $

% Import Java class for BERTool
import com.mathworks.toolbox.comm.BERTool;

% Change M to 2 for BPSK simulation
M = 4;
k = log2(M);
EsNo = EbNo + 10*log10(k);

% Number of symbols to simulate per iteration
symsPerIter = 4096;

numBits = 0;
bitErrs = 0;

% Create Gray encoding and decoding arrays
grayCode = bitxor(0:M-1, floor((0:M-1)/2)).';

idx = 1;
while ((sum(bitErrs) < maxNumErrs) && (numBits < maxNumBits))

    % Check if the user has clicked the Stop button of BERTool
    if (BERTool.getSimulationStop)
        break;
    end

    % Generate message sequence
    msg = randsrc(symsPerIter, 1, 0:M-1);

    % Gray encode symbols
    msgGray = grayCode(msg+1);

    % Digitally modulate the signal
    txSig = pskmod(msgGray, M);

    % Add Gaussian noise to the signal. The noise is calibrated using
    % the 'measured' option.
    rxSig = awgn(txSig, EsNo, 'measured', [], 'dB');

    % Demodulate the signal
    msgGrayDemod = pskdemod(rxSig, M);

    % Gray decode message
    msgDemod = grayCode(msgGrayDemod+1);

    % Calculate number of bit errors and BER for this iteration
    [bitErrs(idx) bers(idx)] = biterr(msg, msgDemod, k);

    % Count number of bits simulated
    numBits = numBits + symsPerIter * k;

    % Incrementing index
    idx = idx + 1;
end

% Calculate BER
ber = sum(bitErrs) / numBits;
