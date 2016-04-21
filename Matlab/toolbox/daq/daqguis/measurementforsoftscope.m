function out = measurementforsoftscope(fcn, data, object);
%MEASUREMENTFORSOFTSCOPE Helper function used by Data Acquisition Toolbox oscilloscope.
%
%   MEASUREMENTFORSOFTSCOPE helper function used by Data Acquisition Toolbox 
%   oscilloscope. MEASUREMENTFORSOFTSCOPE is used by the oscilloscope to calculate
%   the measurement values.
%  
%   This function should not be called directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 10-03-01
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.5.2.3 $  $Date: 2003/08/29 04:44:37 $

% Evaluate the measurement with the given data. fcn is the Measurement Type.
% data contains the data from the Measurement Channel.
if any(strcmp(fcn, {'frequency', 'period'})) 
    out = {feval(fcn, data, object)};
elseif (any(strcmp(fcn, {'max', 'min'})))
    [val, ind] = feval(fcn, data); 
    out = {val ind};
else
    out = {feval(fcn, data)};
end

% ---------------------------------------------------------------------
% Calculate the frequency of the waveform.
function out = frequency(data, object)

if isempty(object)
    out = [];
    return;
end

xfft = abs(fft(data));
[ymax, idx] = max(xfft);
N=length(xfft);
Fs = get(object, 'SampleRate');
freq=[0:Fs/N:Fs-1/N];
out = freq(idx);

% ---------------------------------------------------------------------
% Calculate the peak to peak value of the waveform.
function out = peak2peak(data)

out =  max(data)-min(data);

% ---------------------------------------------------------------------
% Calculate the period of the waveform.
function out = period(data, object)

freq = frequency(data, object);
if isempty(freq)
    out = [];
else
    out = 1/freq;
end

% ---------------------------------------------------------------------
% Calculate the rms value of the waveform.
function out = rms(data)

out = sqrt(mean(data .* data));
