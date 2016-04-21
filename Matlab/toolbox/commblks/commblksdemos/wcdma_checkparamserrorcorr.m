% WCDMA_CHECKPARAMSERRORCORR Checks mask parameters for 
% Wcdma Error Correction block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:06 $

% Check number of Transport Channels
len=[length(trBlkSize) length(trBlkSetSize) length(tti) length(crcSize)...
        length(errorCorr) length(RMAttribute)];
if(any(len~=mean(len)))
    errordlg('Number of elements of the parameters on the mask must have the same size.');
end

% Check for Transport Block and Transport Set Size
if(any(floor(trBlkSize) ~= trBlkSize) | any(trBlkSize<1) | any(trBlkSize>6400))
    errordlg('Transport block size must be a vector of positive integer values between 1 and 6400 bits.');
end

if(any(floor(trBlkSetSize) ~= trBlkSetSize) | any(trBlkSetSize<1) | any(trBlkSetSize>6400))
    errordlg('Transport block size must be a vector of positive integer values between 1 and 6400 bits.');
end

if(any((trBlkSetSize-trBlkSize)<0))
    errordlg('Transport block set size parameter corresponding to a given channel must be equal or greater than the Transport block size for the same channel.');
end 

% Check TTI
if(not(all((tti==10)+(tti==20)+(tti==40)+(tti==80)))),
    errordlg('Transmission Time Interval (TTI) must be one of the specified values: 10, 20, 40 or 80 ms.');
end

% Check CRC Size
if(not(all((crcSize==0)+(crcSize==8)+(crcSize==12)+(crcSize==16)+(crcSize==24)))),
    errordlg('Cyclic Redundancy Check (CRC) Size must be one of the specified values: 0, 8, 12 or 24.');
end

% Check type or Error Correction
if(any(errorCorr>4) | any(errorCorr<0) | floor(errorCorr) ~= errorCorr)
    errordlg('Type of error correction must be 0 for No-Coding, 1 for Convolutional Coding (rate=1/2) and 2 for Convolutional Coding (rate=1/3) or 3 for Turbo Coding.');
elseif(any(errorCorr==3))
    errordlg('Turbo Coding scheme is not currently supported.');
end

% Check for Rate Matching attribute 
if(any(floor(RMAttribute) ~= RMAttribute) | any(RMAttribute<1))
    errordlg('Rate matching attribute must be a vector of positive integers.');
end

% Check for Transport Channel Position
if(sum(size(posTrCh))>2 | ~isreal(posTrCh) | floor(posTrCh) ~= posTrCh | posTrCh<0 | posTrCh>1)
    errordlg('Position in Transport channel must be a scalar equal to 0 for Fixed position or 1 for Flexible position.');
    
elseif(posTrCh==1)
    errordlg('Flexible position in transport channel is not currently supported.');
end

% Check for Number of Physical Channels
if(sum(size(numPhCH))>2 | ~isreal(numPhCH) | floor(numPhCH) ~= numPhCH | numPhCH<=0 | numPhCH>3)
    errordlg('Number of physical channels must be an integer number from 1 to 3.');
elseif(numPhCH ~= 1)
    errordlg('Only 1 Physical Channel is currently supported');
end

% Check Slot Format Parameter
if(sum(size(slotFormat))>2 | ~isreal(slotFormat) | floor(slotFormat) ~= slotFormat | slotFormat >16 | slotFormat<0),
    errordlg('The Slot format parameter must be an integer between 0 and 16.');
end