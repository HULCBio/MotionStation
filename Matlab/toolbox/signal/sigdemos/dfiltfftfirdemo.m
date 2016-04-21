%% Overlap-add FIR Block filter object
% This demonstrates illustrates the DFILT.FFTFIR object.
%  
% DFILT.FFTFIR implements overlap-add block filtering. This algorithm is
% fast for filtering large chunks of data, and it is well suited for
% streaming data.
% 
% Author(s): R. Losada
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.1.4.2 $ $Date: 2004/04/12 23:51:43 $

%% Constructing a DFILT.FFTFIR object
% To create an FFTFIR object, one specifies the vector of filter
% coefficients and the block length (as with all DFILT objects, these
% values can be changed at any point using SET).

b = fir1(250,.4);        % 250th-order linear-phase FIR filter
BL = 250;                % Block length
Hd = dfilt.fftfir(b,BL); % Construct the object


%%
% The FFT of the filter coefficients is computed "off-line" to speed up
% computation. If needed they can be returned from the object using the
% FFTCOEFFS method.

BFFT = fftcoeffs(Hd);    % Return the frequency-domain coefficients

%%
% The number of FFT points is given by BL+length(NUM)-1. It may be
% advantageous to choose BL such that the number of FFT points is a power
% of two.

%% Filtering with DFILT.FFTFIR objects
% As with all DFILT objects, the FILTER method is used to perform the
% filtering.

x = randn(1000,1);
y = filter(Hd,x);

%%
% The final "tail" of the overlap-add method is saved in the STATES
% property of the object. This way we can pick-up where we left off and
% continue filtering. This is a way handling large data in chunks.

x1 = x(1:500);
x2 = x(501:1000);
y1 = filter(Hd,x1);
Hd.ResetBeforeFiltering = 'off'; % Same as set(Hd,'ResetBeforeFiltering','off');
y2 = filter(Hd,x2); % [y1;y2] should be the same as y

%% Analysis of the filter
% Analysis of the filter is the same as other DFILT objects

h = fvtool(Hd);    % Launches filter visualization tool
islinphase(Hd) % Checks for linear-phase
isstable(Hd)   % Checks for stability
order(Hd)      % Returns filter order


%% Generating Simulink models
% When the DSP Blockset is installed, you can generate Simulink block of
% the filter object.

block(Hd); 

%% 

close(h);

