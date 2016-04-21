function [ratio, errors] = simpassbandex(SNRpBit)
% Passband QPSK simulation example
%
%   [RATIO, ERRORS] = SIMPASSBANDEX(SNRPBIT) is an example that demonstrates how
%   to simulate modulation to a carrier frequency and demodulation back to
%   baseband in the presence of additive white Gaussian noise for quaternary
%   phase shift keying (QPSK). SNRPBIT is a vector that contains the Signal to
%   Noise ratios per bit of the channels for the simulation run.  This file runs
%   a simulation at each of the SNRBBITs listed.  Each simulation runs until
%   both the minimum simulation iterations have been completed and the number of
%   errors equals 'expSymErrs' (60 symbols).  SIMPASSBANDEX then plots the
%   theoretical curves for QPSK along with the simulation results as they are
%   generated.
%
%   SIMPASSBANDEX can be changed to simulate binary PSK (BPSK) by changing M
%   from 4 to 2.  Changes to other modulations (i.e. modulation type and
%   alphabet) will require changes to the equations that generate expected
%   results.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:01:54 $

% Initalize sampling times, oversampling rate, modulation.
Fd = 1; Fc = 4; Fs = 16; N = Fs/Fd;
modulation = 'psk';

% Define alphabet (quaternary). Signal to Noise ratio (SNR).
% Change M to 2 to get results for BPSK instead of QPSK
M = 4; k = log2(M); SNR = SNRpBit + 10*log10(k);

% Set number of symbols per iteration and number of iterations
% Expected number of symbol error count
symbPerIter = 2048; iters = 3; expSymErrs = 60;
numSymbTot = symbPerIter * iters;

% Set random number seeds for uniform and Gaussian noise
rand('state', 56789*10^10);  randn('state', 98765*10^5);

% Calculate expected results for plotting (QPSK, BPSK only)
% expBER = 0.5.*erfc(sqrt(10.^(SNRpBit(:).*0.1)) );
expBER = berawgn(SNRpBit, 'psk', 4);
expSER = 1 - (1 - expBER) .^ k;

% Plot the theoretical results for SER and BER.
semilogy(SNRpBit(:), expSER, 'g-', ...
         SNRpBit(:), expBER, 'm-');
legend('Theoretical SER','Theoretical BER',0);  grid on;
title('Performance of Passband QPSK');
xlabel('SNR/bit (dB)');
ylabel('SER and BER');
hold on;

% Create Gray encoding and decoding arrays
grayencod	= bitxor([0:M-1],floor([0:M-1]/2));
[dummy graydecod] = sort(grayencod);  graydecod = graydecod - 1;

% Drive the simulation for each of the SNR values calculated above
for(idx2 = [1:length(SNR)])
    % Exit loop only when minimum number of iterations have completed and the
    % number of errors exceeds 'expSymErrs'
    idx = 1;
    while ((idx <= iters) | (sum(errSym) <= expSymErrs))

        % Generate random numbers from in the range [0,M-1]
        msg_orig = randsrc(symbPerIter,1,[0:M-1]);

        % Gray encode symbols
        msg_gr_orig = grayencod(msg_orig+1)';

        % Digitally modulate and upsample the signal
        msg_tx  = dmod(msg_gr_orig, Fc, Fd, Fs, modulation, M);

        % Add Gaussian noise to the signal.  The noise signal is calibrated using
        % the 'measured' option.  The noise power is scaled for oversampling.
        % In addition, the noise power is halved because this is a passband signal.
        msg_rx  = awgn(msg_tx, SNR(idx2)-10*log10(0.5.*N), 'measured', [], 'dB');

        % Demodulate, detect, and downsample the signal
        msg_gr_demod = ddemod(msg_rx, Fc, Fd, Fs, modulation, M);

        % Gray decode message
        msg_demod = graydecod(msg_gr_demod+1)';

        % calculate bit error count, BER, symbol error count and SER, for this iteration.
        [errBit(idx) ratBit(idx)] = biterr(msg_orig, msg_demod, k);
        [errSym(idx) ratSym(idx)] = symerr(msg_orig, msg_demod);

        % Increment for next iteration, pause to allow <ctrl-C> break
        idx = idx + 1;  pause(.1);
    end

    % average the errors and error ratios for the iterations.
    errors(idx2,:) = [sum(errBit),  sum(errSym)];
    ratio(idx2,:)  = [mean(ratBit), mean(ratSym)];

    % Plot the simulated results for SER and BER.
    semilogy(SNRpBit([1:size(ratio(:,2),1)]),ratio(:,2),'bo', ...
             SNRpBit([1:size(ratio(:,1),1)]),ratio(:,1),'ro');
    legend('Theoretical SER','Theoretical BER','Simulated SER','Simulated BER',0);
    pause(.1);
end
hold off;
