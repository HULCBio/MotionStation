%% Using a Convolutional Code
% This example, described in the Getting Started chapter of the
% Communications Toolbox documentation, aims to solve the following
% problem:
%
% Modify the filtering example (COMMDOC_RRC) so that it
% includes convolutional coding and decoding, given the
% constraint lengths and generator polynomials of the
% convolutional code.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/03/30 13:01:48 $

%% Setup
% Define parameters.
M = 16; % Size of signal constellation
k = log2(M); % Number of bits per symbol
n = 5e5; % Number of bits to process
nsamp = 4; % Oversampling rate

%% Signal Source
% Create a binary data stream as a column vector.
x = randint(n,1); % Random binary data stream

% Plot first 40 bits in a stem plot.
stem(x(1:40),'filled');
title('Random Bits');
xlabel('Bit Index'); ylabel('Binary Value');

%% Encoder
% Define a convolutional coding trellis and use it
% to encode the binary data.
t = poly2trellis([5 4],[23 35 0; 0 5 13]); % Trellis
code = convenc(x,t); % Encode.
coderate = 2/3;

%% Bit-to-Symbol Mapping
% Convert the bits in x into k-bit symbols, using
% Gray coding.

% A. Define a vector for mapping bits to symbols using
% Gray coding. The vector is specific to the arrangement
% of points in a 16-QAM constellation.
mapping = [0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10].';

% B. Do ordinary binary-to-decimal mapping.
xsym = bi2de(reshape(code,k,length(code)/k).','left-msb');

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

%% Filter Definition
% Define filter-related parameters.
filtorder = 40; % Filter order
delay = filtorder/(nsamp*2); % Group delay (# of input samples)
rolloff = 0.25; % Rolloff factor of filter

% Create a square root raised cosine filter.
rrcfilter = rcosine(1,nsamp,'fir/sqrt',rolloff,delay);

% Plot impulse response.
figure; impz(rrcfilter,1);

%% Transmitted Signal
% Upsample and apply square root raised cosine filter.
ytx = rcosflt(y,1,nsamp,'filter',rrcfilter);

% Create eye diagram for part of filtered signal.
eyediagram(ytx(1:2000),nsamp*2);

%% Channel
% Send signal over an AWGN channel.
EbNo = 10; % In dB
snr = EbNo + 10*log10(k*coderate)-10*log10(nsamp);
ynoisy = awgn(ytx,snr,'measured');

%% Received Signal
% Filter received signal using square root raised cosine filter.
yrx = rcosflt(ynoisy,1,nsamp,'Fs/filter',rrcfilter);
yrx = downsample(yrx,nsamp); % Downsample.
yrx = yrx(2*delay+1:end-2*delay); % Account for delay.

%% Scatter Plot
% Create scatter plot of received signal before and
% after filtering.
h = scatterplot(sqrt(nsamp)*ynoisy(1:nsamp*5e3),nsamp,0,'g.');
hold on;
scatterplot(yrx(1:5e3),1,0,'kx',h);
title('Received Signal, Before and After Filtering');
legend('Before Filtering','After Filtering');
axis([-5 5 -5 5]); % Set axis ranges.

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

%% Decoder
% Decode the convolutional code.
tb = 16; % Traceback length for decoding
z = vitdec(z,t,tb,'cont','hard'); % Decode.

%% BER Computation
% Compare x and z to obtain the number of errors and
% the bit error rate. Take the decoding delay into account.
decdelay = 2*tb; % Decoder delay, in bits
[number_of_errors,bit_error_rate] = ...
   biterr(x(1:end-decdelay),z(decdelay+1:end))
