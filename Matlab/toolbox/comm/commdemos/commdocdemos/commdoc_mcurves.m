%% Varying Parameters and Managing a Set of Simulations
% This jexample, described in the Getting Started chapter of the
% Communications Toolbox documentation, aims to solve the following
% problem:
%
% Modify the modulation example in Modulating a Random Signal
% (COMMDOC_MOD) so that it computes the BER for alphabet sizes (M)
% of 4, 8, 16, and 32 and for integer values of EbNo between
% 0 and 7. For each value of M, plot the BER as a function of
% EbNo using a logarithmic scale for the vertical axis.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/01/09 17:35:30 $

%% Ranges of Variables
Mvec = [4 8 16 32]; % Values of M to consider
EbNovec = [0:7]; % Values of EbNo to consider

%% Preallocate space for results.
number_of_errors = zeros(length(Mvec),length(EbNovec));
bit_error_rate   = zeros(length(Mvec),length(EbNovec));

%% Simulation loops
for idxM = 1:length(Mvec)
   for idxEbNo = 1:length(EbNovec)

      %% Setup
      % Define parameters.
      M = Mvec(idxM); % Size of signal constellation
      k = log2(M); % Number of bits per symbol
      n = 3e4; % Number of bits to process
      nsamp = 1; % Oversampling rate

      %% Signal Source
      % Create a binary data stream as a column vector.
      x = randint(n,1); % Random binary data stream

      %% Bit-to-Symbol Mapping
      % Convert the bits in x into k-bit symbols.
      xsym = bi2de(reshape(x,k,length(x)/k).','left-msb');

      %% Modulation
      % Modulate using 16-QAM.
      y = qammod(xsym,M);

      %% Transmitted Signal
      ytx = y;

      %% Channel
      % Send signal over an AWGN channel.
      EbNo = EbNovec(idxEbNo); % In dB
      snr = EbNo + 10*log10(k) - 10*log10(nsamp);
      ynoisy = awgn(ytx,snr,'measured');

      %% Received Signal
      yrx = ynoisy;

      %% Demodulation
      % Demodulate signal using 16-QAM.
      zsym = qamdemod(yrx,M);

      %% Symbol-to-Bit Mapping
      % Undo the bit-to-symbol mapping performed earlier.
      z = de2bi(zsym,'left-msb'); % Convert integers to bits.
      z = reshape(z.',prod(size(z)),1); % Convert z from matrix to vector.

      %% BER Computation
      % Compare x and z to obtain the number of errors and
      % the bit error rate.
      [number_of_errors(idxM,idxEbNo),bit_error_rate(idxM,idxEbNo)] = ...
         biterr(x,z);

   end % End of loop over EbNo values
   
   %% Plot a Curve.
   markerchoice = '.xo*';
   plotsym = [markerchoice(idxM) '-']; % Plotting style for this curve
   semilogy(EbNovec,bit_error_rate(idxM,:),plotsym); % Plot one curve.
   drawnow; % Update the plot instead of waiting until the end.
   hold on; % Make sure next iteration does not remove this curve.

end % End of loop over M values

%% Complete the plot.
title('Performance of M-QAM for Varying M');
xlabel('EbNo (dB)'); ylabel('BER');
legend('M = 4','M = 8','M = 16','M = 32',...
   'Location','SouthWest');
