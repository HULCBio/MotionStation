function [ber, numBits] = commdoc_bertool(EbNo, maxNumErrs, maxNumBits)
%COMMDOC_BERTOOL BERTool example in Getting Started documentation.
%   This example, described in the Getting Started chapter of the
%   Communications Toolbox documentation, aims to solve the following
%   problem:
%
%   Modify the modulation example in Incorporating Gray Coding
%   (COMMDOC_GRAY) so that it computes the BER for integer values
%   of EbNo between 0 and 7. Plot the BER as a function of EbNo
%   using a logarithmic scale for the vertical axis.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/03/30 13:01:47 $

% Import Java class for BERTool.
import com.mathworks.toolbox.comm.BERTool;

% Initialize variables related to exit criteria.
totErr = 0;  % Number of errors observed
numBits = 0; % Number of bits processed

% Setup
% Define parameters.
M = 16; % Size of signal constellation
k = log2(M); % Number of bits per symbol
n = 1000; % Number of bits to process
nsamp = 1; % Oversampling rate

% Simulate until number of errors exceeds maxNumErrs
% or number of bits processed exceeds maxNumBits.
while((totErr < maxNumErrs) && (numBits < maxNumBits))

   % Check if the user clicked the Stop button of BERTool.
   if (BERTool.getSimulationStop)
      break;
   end

   % --- Proceed with simulation.

   %% Signal Source
   % Create a binary data stream as a column vector.
   x = randint(n,1); % Random binary data stream

   %% Bit-to-Symbol Mapping
   % Convert the bits in x into k-bit symbols, using
   % Gray coding.

   % A. Define a vector for mapping bits to symbols using
   % Gray coding. The vector is specific to the arrangement
   % of points in a 16-QAM constellation.
   mapping = [0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10].';

   % B. Do ordinary binary-to-decimal mapping.
   xsym = bi2de(reshape(x,k,length(x)/k).','left-msb');

   % C. Map from binary coding to Gray coding.
   xsym = mapping(xsym+1);

   %% Modulation
   % Modulate using 16-QAM.
   y = qammod(xsym,M);

   %% Transmitted Signal
   ytx = y;

   %% Channel
   % Send signal over an AWGN channel.
   %EbNo = 10; % In dB % COMMENT OUT FOR BERTOOL
   snr = EbNo + 10*log10(k) - 10*log10(nsamp);
   ynoisy = awgn(ytx,snr,'measured');

   %% Received Signal
   yrx = ynoisy;

   %% Demodulation
   % Demodulate signal using 16-QAM.
   zsym = qamdemod(yrx,M);

   %% Symbol-to-Bit Mapping
   % Undo the bit-to-symbol mapping performed earlier.

   % A. Define a vector that inverts the mapping operation.
   [dummy demapping] = sort(mapping);
   % Initially, demapping has values between 1 and M.
   % Subtract 1 to obtain values between 0 and M-1.
   demapping = demapping - 1;

   % B. Map between Gray and binary coding.
   zsym = demapping(zsym+1);

   % C. Do ordinary decimal-to-binary mapping.
   z = de2bi(zsym,'left-msb');
   % Convert z from a matrix to a vector.
   z = reshape(z.',prod(size(z)),1);

   %% BER Computation
   % Compare x and z to obtain the number of errors and
   % the bit error rate.
   [number_of_errors,bit_error_rate] = biterr(x,z);

   %% Update totErr and numBits.
   totErr = totErr + number_of_errors;
   numBits = numBits + n;

end % End of loop

% Compute the BER.
ber = totErr/numBits;
