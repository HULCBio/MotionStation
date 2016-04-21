% WCDMA_CHECKPARAMSPHCHMAP Checks mask parameters for 
% Wcdma Physical Channel Mapping block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:48:43 $

if(sum(size(numPhCH))>2 | ~isreal(numPhCH) | floor(numPhCH) ~= numPhCH | numPhCH<=0 | numPhCH>3)
    errordlg('Number of physical channels must be an integer number between 1 and 3.');
elseif(numPhCH ~= 1)
    errordlg('Only 1 Physical Channel is currently supported');
end

% Check for Number of bits in CCTrCh
if(any(floor(numBitsRF) ~= numBitsRF) | numBitsRF<1 | ~isreal(numBitsRF))
    errordlg('Number of bits per CCTrCH must be a positive integer number.');
end

% Check Slot Format Parameter
if(sum(size(slotFormat))>2 | ~isreal(slotFormat) | floor(slotFormat) ~= slotFormat | slotFormat >16 | slotFormat<0),
    errordlg('The Slot format parameter must be an integer between 0 and 16.');
end