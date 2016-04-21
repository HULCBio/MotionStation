function win32audiodevs
%WIN32AUDIODEVS Populate audio device popup menus for From Wave Device 
% and To Wave Device Blocks in Signal Processing Blockset.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:07:53 $

try
    inputDevs = listaudiodevs(1);
    inputDev = audiodevinfo(1,0);
    outputDevs = listaudiodevs(0);
    outputDev = audiodevinfo(0,0);
catch
    % audiodevinfo won't work on this platform, meaning
    % from/to wave device blocks also won't work on this
    % platform 
    return;
end

% From Wave Device
% populate menu of input devices
[blockName, errMsg] = sprintf('dspwin32/From Wave%cDevice', sprintf('\n'));
inputStyleString = get_param(blockName, 'MaskStyleString');
inputStyleString = strrep(inputStyleString, 'INPUTDEVS', inputDevs);
set_param(blockName, 'MaskStyleString', inputStyleString);

%select first input device as default
inputValueString = get_param(blockName, 'MaskValueString');
inputValueString = strrep(inputValueString, 'INPUTDEV', inputDev);
set_param(blockName, 'MaskValueString', inputValueString);


% To Wave Device
% populate menu of output devices
[blockName, errMsg] = sprintf('dspwin32/To Wave%cDevice', sprintf('\n'));
outputStyleString = get_param(blockName, 'MaskStyleString');
outputStyleString = strrep(outputStyleString, 'OUTPUTDEVS', outputDevs);
set_param(blockName, 'MaskStyleString', outputStyleString);

%select first output device as default
outputValueString = get_param(blockName, 'MaskValueString');
outputValueString = strrep(outputValueString, 'OUTPUTDEV', outputDev);
set_param(blockName, 'MaskValueString', outputValueString);

% end of win32audiodevs()


% ------------------------------------------------------------------------
% Local functions:
% ------------------------------------------------------------------------
function devs = listaudiodevs(inputOrOutput)

if inputOrOutput ~= 0 & inputOrOutput ~= 1,
    error('Parameter to LISTAUDIODEVS must be 1 (input) or 0 (output)');
end

numDevs = audiodevinfo(inputOrOutput);
devs = '';

for i=0:(numDevs-1),
    name = audiodevinfo(inputOrOutput, i);
    if i ~= 0,
        name = strcat('|', name);
    end
    devs = strcat(devs, name);
end
return

% [EOF] win32audiodevs.m