%% Getting Started with Multirate Filter (MFILT) Objects
% This demonstrates how to use the new multirate filter (MFILT) objects
% available in the Filter Design Toolbox.
%  

% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.1.4.3 $ $Date: 2004/04/20 23:17:22 $

%% Getting Help 
% Typing "helpwin mfilt" in the command window gives you a list of
% structures supported by the Filter Design Toolbox as well as methods
% operating on MFILT objects. For further information about a particular
% structure or method, type "helpwin mfilt/<structure or method>" or "help
% mfilt/<structure or method>". For example:
help mfilt/firinterp % Help on the FIRINTERP structure
%%
help mfilt/polyphase % Help on the POLYPHASE method

%% Creating Multirate Filters
% To create a multirate filter (MFILT) object, you need to select the
% structure to be used. Most constructors take the coefficients of the
% filter as an optional last input argument. If the coefficients are not
% specified, a default filter is designed according to the interpolation
% and/or decimation factor(s).

L = 3; % Interpolation factor
M = 2; % Decimation factor
%%
% Direct-Form FIR Polyphase Interpolator. The default design is a Nyquist
% filter with a cutoff frequency of pi/L and a gain of L. 
h1 = mfilt.firinterp(L);
%%
% Direct-Form Transposed FIR Polyphase Decimator. The default design is a Nyquist
% filter with a cutoff frequency of pi/M and a gain of 1. 
h2 = mfilt.firtdecim(M);
%%

%% Getting and Setting the Filter Coefficients
% To manipulate the coefficients of a filter as a regular MATLAB vector,
% you can always get them from the object. To modify the coefficients of an
% existing MFILT object, you can set new ones. Direct-form FIR structures
% only have numerator coefficients; these are also known as the filter
% weights.
h2
%%
b = get(h2,'Numerator');   % Assign the coefficients to vector b
bmod = firnyquist(8,M,kaiser(9,0.1102*(80-8.71)));
set(h2,'Numerator',bmod); % Set the modified coefficients

%% Analyzing Multirate Filters
% The analysis of multirate filter (MFILT) objects is similar to that of
% discrete-time filter (DFILT) objects. In  particular, the Filter
% Visualization Tool (FVTool) can be used to perform  most of the analysis.
h = fvtool(h1,h2);
set(h,'MagnitudeDisplay','Magnitude')
legend(h, 'FIR Interpolator (L=3)', 'FIR Transposed Decimator (M=2)', 'Location', 'NorthEast')
set(h, 'Color', [1 1 1])

%%
% Additionaly MFILT objects provides analysis of the polyphase components.
% Calling the polyphase method without output arguments launches an FVTool
% session with all the polyphase subfilters. 
polyphase(h1)


%% Filtering with Multirate Filters
% By default, the states of the filter, stored in the 'States' property,
% are each initialized to zero. Furthermore the 'ResetBeforeFiltering'
% property is 'on' which means that the object is reset before the filter
% is run. This allows to filter the same sequence twice and produce the
% same output. For example:
x = 1:6;
y1 = filter(h2,x) % First run
%%
% At this point, we verify that the object holds non-zero final conditions.
zf1 = h2.States 

%%
y2 = filter(h2,x) % Second run
%%
zf2 = h2.States
%%
% Notice that after the second run, the states of the object are the same
% as after the first run. Because the 'ResetBeforeFiltering' property was 'on', 
% the states were reinitialized to zeros before the second run.

%% Specifying Initial Conditions to the Filter
% The user can specify initial conditions by turning the
% 'ResetBeforeFiltering' property 'off' and setting the 'States' property.
% If a scalar is specified, it will be expanded to the correct number of
% states. If a vector is specified, its length must be equal to the number
% of states. For example:
h2.ResetBeforeFiltering='off';
h2.States = zf1;
y3 = filter(h2,x) % Run the filter with final states of first run
%%
zf3 = h2.States

%%
% As expected, both the output of the filter and the states are
% different than in the first run. 

%% Streaming Data to the Filter
% Setting the 'ResetBeforeFiltering' property 'off' is a convenient feature
% for streaming data to the filter. Breaking up a signal and filtering in a
% loop is equivalent to filtering the entire signal at once. We will
% emulate streaming data by using the filter in a loop:
reset(h2); % Clear history of the filter
xsec = reshape(x(:),2,3);    % Breaking the signal in 3 sections
yloop = zeros(1,3);          % Pre-allocate memory
for i=1:3,
    yloop(i)=filter(h2,xsec(:,i));
end
yloop
%%
% We verify that yloop(signal filtered by sections) is equal to y1 (entire signal filtered at once).

%% Filtering Multi-Channel Signals
% If the input signal x is a matrix, each column of x is seen by the filter
% as an independent channel.
reset(h2);
x = randn(10,3); % 3-channels signal
y = filter(h2,x)
%%
zf = h2.States
%%
% Notice that the object stores the final conditions of the filter for each
% channel, each colum of the 'States' property corresponding to one
% channel.

%% Generating Simulink Models
% When the Signal Processing Blockset is installed, you can generate a
% Simulink block of the MFILT filter object if the structure is supported
% by Signal Processing Blockset. For example, the Direct-Form FIR Polyphase
% Interpolator:
block(h1); 
