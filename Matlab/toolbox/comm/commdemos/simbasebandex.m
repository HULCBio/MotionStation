function [ratio, errors] = simbasebandex(EbNo)
% Baseband QPSK simulation example
%
%   [RATIO, ERRORS] = SIMBASEBANDEX(EbNo) demonstrates how to simulate
%   modulation using a complex baseband equivalent representation of the
%   signal modulated on a carrier. It also demonstrates demodulation and
%   detection of the signal in the presence of additive white Gaussian
%   noise for quaternary phase shift keying (QPSK). EbNo is a vector that
%   contains the signal to noise ratios per bit of the channels for the
%   simulation. This file runs a simulation at each of the EbNo's listed.
%   Each simulation runs until both the minimum simulation iterations have
%   been completed and the number of errors equals or exceeds 'expSymErrs'
%   (60 symbols). SIMBASEBANDEX then plots the theoretical curves for QPSK
%   along with the simulation results as they are generated.
%
%   SIMBASEBANDEX can be changed to simulate binary PSK (BPSK) by changing
%   M from 4 to 2. Changes to other modulations (i.e. modulation type and
%   alphabet) will require changes to the equations that generate expected
%   results.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.5 $ $Date: 2004/04/12 23:01:31 $

% Define alphabet (quaternary), EsNo
% Change M to 2 for BPSK instead of QPSK
M = 4; k = log2(M); EsNo = EbNo + 10*log10(k);

% Set number of symbols per iteration, number of iterations,
% and expected number of symbol error count
symbPerIter = 4096; iters = 3; expSymErrs = 60;

% Set random number seeds for uniform and Gaussian noise
rand('state', 123456789);  randn('state', 987654321);

% Calculate expected results only for QPSK for plotting later on
expBER = berawgn(EbNo, 'psk', 4, 'nondiff');
expSER = 1 - (1 - expBER) .^ k;

% Plot the theoretical results for SER and BER.
semilogy(EbNo(:), expSER, 'g-', EbNo(:), expBER, 'm-');
legend('Theoretical SER','Theoretical BER',0);  grid on;
title('Performance of Baseband QPSK');
xlabel('EbNo (dB)');
ylabel('SER and BER');
hold on;
drawnow;

% Create Gray encoding and decoding arrays
grayencod = bitxor(0:M-1, floor((0:M-1)/2));
[dummy graydecod] = sort(grayencod); graydecod = graydecod - 1;

% Drive the simulation for each of the SNR values calculated above
for idx2 = 1:length(EsNo)
    % Exit loop only when minimum number of iterations have completed and the
    % number of errors exceeds 'expSymErrs'
    idx = 1;
    while ((idx <= iters) || (sum(errSym) <= expSymErrs))

        % Generate random numbers from in the range [0, M-1]
        msg_orig = randsrc(symbPerIter, 1, 0:M-1);

        % Gray encode symbols
        msg_gr_orig = grayencod(msg_orig+1)';

        % Digitally modulate the signal
        msg_tx = pskmod(msg_gr_orig, M);

        % Add Gaussian noise to the signal. The noise is calibrated using
        % the 'measured' option.
        msg_rx  = awgn(msg_tx, EsNo(idx2), 'measured', [], 'dB');

        % Demodulate the signal
        msg_gr_demod = pskdemod(msg_rx, M);

        % Gray decode message
        msg_demod = graydecod(msg_gr_demod+1)';

        % Calculate bit error count, BER, symbol error count and SER,
        % for this iteration.
        [errBit(idx) ratBit(idx)] = biterr(msg_orig, msg_demod, k);
        [errSym(idx) ratSym(idx)] = symerr(msg_orig, msg_demod);

        % Increment for next iteration
        idx = idx + 1;
    end

    % average the errors and error ratios for the iterations.
    errors(idx2, :) = [sum(errBit),  sum(errSym)];
    ratio(idx2, :)  = [mean(ratBit), mean(ratSym)];

    % Plot the simulated results for SER and BER.
    semilogy(EbNo(1:size(ratio(:,2),1)), ratio(:,2), 'bo', ...
             EbNo(1:size(ratio(:,1),1)), ratio(:,1), 'ro');
    legend('Theoretical SER','Theoretical BER','Simulated SER','Simulated BER',0);
    drawnow;
end
hold off;
