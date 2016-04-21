%% Incorporating Gray Coding
% This example, described in the Getting Started chapter of the
% Communications Toolbox documentation, aims to solve the following
% problem:
%
% Modify the modulation example (COMMDOC_MOD) so that it uses
% a Gray-coded signal constellation.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/03/30 13:01:49 $

%% Setup
% Define parameters.
M = 16; % Size of signal constellation
k = log2(M); % Number of bits per symbol
n = 3e4; % Number of bits to process
nsamp = 1; % Oversampling rate

%% Signal Source
% Create a binary data stream as a column vector.
x = randint(n,1); % Random binary data stream

% Plot first 40 bits in a stem plot.
stem(x(1:40),'filled');
title('Random Bits');
xlabel('Bit Index'); ylabel('Binary Value');

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

%% Stem Plot of Symbols 
% Plot first 10 symbols in a stem plot.
figure; % Create new figure window.
stem(xsym(1:10));
title('Random Symbols');
xlabel('Symbol Index'); ylabel('Integer Value');

%% Modulation
% Modulate using 16-QAM.
y = qammod(xsym,M);

%% Transmitted Signal
ytx = y;

%% Channel
% Send signal over an AWGN channel.
EbNo = 10; % In dB
snr = EbNo + 10*log10(k) - 10*log10(nsamp);
ynoisy = awgn(ytx,snr,'measured');

%% Received Signal
yrx = ynoisy;

%% Scatter Plot
% Create scatter plot of noisy signal and transmitted
% signal on the same axes.
h = scatterplot(yrx(1:nsamp*5e3),nsamp,0,'g.');
hold on;
scatterplot(ytx(1:5e3),1,0,'k*',h);
title('Received Signal');
legend('Received Signal','Signal Constellation');
axis([-5 5 -5 5]); % Set axis ranges.
hold off;

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
[number_of_errors,bit_error_rate] = biterr(x,z)
