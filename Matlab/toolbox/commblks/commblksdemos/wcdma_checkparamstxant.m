% WCDMA_CHECKPARAMSTXANT Checks mask parameters for the
% Wcdma Tx Antenna block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:07 $

load wcdma_slotformattable;
% Second Column of wcdma_slotformattable corresponds to SF
sprdFactor = wcdma_slotformattable(slotFormat+1,2);

% Check Slot Format Parameter
if(sum(size(slotFormat))>2 | ~isreal(slotFormat) | floor(slotFormat) ~= slotFormat | slotFormat >16 | slotFormat<0),
    errordlg('The Slot format parameter must be an integer between 0 and 16.');
end

% Check DCPH Code Number
if(sum(size(dpchCode))>2 | ~isreal(dpchCode) | floor(dpchCode) ~= dpchCode | dpchCode>=sprdFactor),
    errordlg('The DPCH code number must be an integer between 0 and the value of the Spreading Factor minus 1.');
end

% Check for Scrambling Code
if(length(scrCode)~=2)
    errordlg('The Scrambling code parameter must be a 2-element vector containing the Scrambling Code Group and the Primary Code.');
end

if(sum(size(scrCode(1)))>2 | ~isreal(scrCode(1)) | floor(scrCode(1)) ~= scrCode(1) | scrCode(1)<0 | scrCode(1)>63)
    errordlg('The first element of the Scrambling Code (Scrambling Code Group) must be an integer between 0 to 63.');
end

if(sum(size(scrCode(2)))>2  | ~isreal(scrCode(2)) | floor(scrCode(2)) ~= scrCode(2) | scrCode(2)<0 | scrCode(2)>8)
    errordlg('The second element of the Scrambling Code (Primary Code) must be an integer between 0 to 7.');
end

% Check for Power Settings Vector
if(length(powerVector) ~=5)
    errordlg('Power Vector must be a 5-element vector containing the Ec/Ior (in dB) as defined by the standard for the following channels: DPCH, P-CPICH, PICH, P-CCPCH, SCH.');
end

% Check for Number of Tap filter for RRC
if(sum(size(numTapsRRC))>2 | ~isreal(numTapsRRC) | floor(numTapsRRC)~=numTapsRRC ) %| numTapsRRC<overSampling*2
    errordlg('The number of coefficients of the Root Raised Cosine filter must be a positive integer multiple of 2 times the oversampling factor of the filter.');
end

% Check for Oversampling Factor
if(sum(size(overSampling))>2 | ~isreal(overSampling) | floor(overSampling)~=overSampling | overSampling<0 | 2*overSampling>numTapsRRC)
    errordlg('The oversampling factor has to be an integer greater than 0.');
end

% Not currently supported
if(powerVector(4)~= powerVector(5))
    errordlg('In the current version, power settings for the P-CCPCH and SCH must be the same.');
end