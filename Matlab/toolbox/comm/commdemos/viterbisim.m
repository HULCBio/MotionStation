function [ber, numBits] = viterbisim(EbNo, maxNumErrs, maxNumBits)
%VITERBISIM Viterbi decoder simulation example for BERTool.
%
%   VITERBISIM is a simulation of a Quaternary Phase Shift Keying (QPSK) or
%   Binary PSK (BPSK) over an additive white Gaussian channel (AWGN) using
%   convolutional encoding and the Viterbi decoding algorithm with hard
%   decision decoding. It demonstrates how to write a MATLAB simulation
%   function for BERTool, and cannot run without BERTool. BERTool provides
%   3 variables to this function: EbNo, maxNumErrs (number of bit errors to
%   collect before stopping the simulation), and maxNumBits (maximum number
%   of bits to simulate). The function returns the bit error rate in BER,
%   and the actual number of bits simulated in NUMBITS.
%
%   VITERBISIM illustrates how to use the convolutional trellis generator
%   (POLY2TRELLIS), encoder (CONVENC), and decoder (VITDEC). It also shows
%   the use of other functions: PSKMOD, PSKDEMOD, BITERR, BERCODING,
%   RANDINT, and AWGN.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/03/24 20:33:14 $

% Import Java class of BERTool
import com.mathworks.toolbox.comm.BERTool;

% Define number of bits per symbol (k).
M = 4;  % or 2
k = log2(M);

% Code properties
codeRate = 1/2;
constlen = 7;
codegen = [171 133];
tblen = 32;     % traceback length
trellis = poly2trellis(constlen, codegen);

% number of bits per iteration
bitsPerIter = 1e4;

% maximum number of iterations (at least 1)
maxNumIters = max(1, maxNumBits / bitsPerIter);

% Adjust SNR for coded bits and multi-bit symbols.
adjSNR = EbNo - 10*log10(1/codeRate) + 10*log10(k);

% Create Gray encoding and decoding array
grayCode = bitxor(0:M-1, floor((0:M-1)/2));

% Initialize the leftover vector with all zeros to create a decoder
% 'prehistory' of 0's.
msg_orig_lo = zeros(tblen, 1);

% Reset the encoder/decoder states and persistent data
stateEnc = [];
metric = [];
stateDec = [];
in = [];

% Initialize the bit error rate and error counters.
totErr = 0;
numBits = 0;
initCompIdx = 1;
iter = 1;

% Exit loop when either the number of bit errors exceeds 'maxNumErrs'
% or the maximum number of iterations have completed
while ((totErr < maxNumErrs) && (iter < maxNumIters))

    % Check if the user has clicked the Stop button of BERTool
    if (BERTool.getSimulationStop)
        break;
    end

    % Generate binary random numbers
    msg_orig = randint(bitsPerIter, 1);

    % Convolutionally encode the message, saving encoder state between iterations
    [msg_enc_bi, stateEnc] = convenc(msg_orig, trellis, stateEnc);

    % Change binary symbols to quaternary symbols, and gray encode to ensure
    % one bit transition per symbol
    msg_enc = bi2de(reshape(msg_enc_bi, k, length(msg_enc_bi) / k)');
    msg_gr_enc = grayCode(msg_enc+1);

    % Digitally modulate the signal.
    msg_tx = pskmod(msg_gr_enc, M);

    % Add Gaussian noise to the signal.
    msg_rx = awgn(msg_tx, adjSNR, 'measured', [], 'dB');

    % Demodulate and detect the signal
    msg_gr_demod = pskdemod(msg_rx, M);

    % Gray decode and change demodulated symbols to bits
    msg_demod = grayCode(msg_gr_demod+1);
    msg_demod_bi = de2bi(msg_demod, k)';

    % Use the Viterbi algorithm to decode the received signal.  Save the
    % trellis and metric states from iteration to iteration in
    % 'metric', 'stateDec', and 'in'.
    [msg_dec, metric, stateDec, in] = vitdec(msg_demod_bi(:), trellis, ...
        tblen, 'cont', 'hard', metric, stateDec, in);

    % Add leftover symbols from last iteration to those from this iteration
    msg_orig_w_lo = [msg_orig_lo; msg_orig];

    % Compare the input and outputs to determine BER and error count
    size_msg_dec = length(msg_dec) - initCompIdx + 1;
    [errBitInfo, ratBitInfo] = ...
        biterr(msg_dec(initCompIdx:end), msg_orig_w_lo(initCompIdx:length(msg_dec)));

    % Accumulate bit count and bit error statistics after each iteration
    totErr = totErr + errBitInfo;
    numBits = numBits + size_msg_dec;

    % Save leftover bits from this iteration for the next iteration
    msg_orig_lo = msg_orig_w_lo(end-tblen+1:end);

    % Increment iteration index, and set the initial index for comparison
    % in next iteration
    iter = iter + 1;
    initCompIdx = tblen + 1;
end

% Compute the BER for all the iterations together
ber = totErr / numBits;
