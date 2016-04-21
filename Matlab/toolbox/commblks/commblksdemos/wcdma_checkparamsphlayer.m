% WCDMA_CHECKPARAMSPHLAYER Checks mask parameters for 
% Wcdmaphlayer model included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:48:45 $

% Check number of Transport Channels
len=[length(trBlkSize) length(trBlkSetSize) length(tti) length(crcSize)...
        length(errorCorr) length(RMAttribute)];
if(any(len~=mean(len)))
    msg='All parameters in the mask must have the same number of elements.';
end

% Check for Transport Block and Transport Set Size
if(any(floor(trBlkSize) ~= trBlkSize) | any(trBlkSize<1) | any(trBlkSize>6400))
    msg='Transport block size must be a vector of positive integer values between 1 and 6400 bits.';
end

if(any(floor(trBlkSetSize) ~= trBlkSetSize) | any(trBlkSetSize<1) | any(trBlkSetSize>6400))
    msg='Transport block size must be a vector of positive integer values between 1 and 6400 bits.';
end

if(any((trBlkSetSize-trBlkSize)<0))
    msg='Transport block set size parameter corresponding to a given channel must be equal to or greater than the Transport block size for the same channel.';
end 

% Check TTI
if(not(all((tti==10)+(tti==20)+(tti==40)+(tti==80)))),
    msg='Transmission Time Interval (TTI) must be one of the specified values: 10, 20, 40 or 80 ms.';
end

% Check CRC Size
if(not(all((crcSize==0)+(crcSize==8)+(crcSize==12)+(crcSize==16)+(crcSize==24)))),
    msg='Cyclic Redundancy Check (CRC) Size must be one of the specified values: 0, 8, 12 or 24.';
end

% Check type or Error Correction
if(any(errorCorr>4) | any(errorCorr<0) | floor(errorCorr) ~= errorCorr)
    msg='Type of error correction must be 0 for No coding, 1 for convolutional coding (rate=1/2) and 2 for convolutional coding (rate=1/3) or 3 for turbo coding.';
elseif(any(errorCorr==3))
    msg='Turbo Coding scheme is not currently supported.';
end

if (any(errorCorrMask==3))
    msg_warn='Error Correction has been automatically changed to Convolutional Encoder rate=1/3 since Turbo coding is not currently supported.';
end

% Check for Rate Matching attribute 
if(any(floor(RMAttribute) ~= RMAttribute) | any(RMAttribute<1))
    msg='Rate matching attribute must be a vector of positive integers.';
end

% Check for Transport Channel Position
if(sum(size(posTrCh))>2 | ~isreal(posTrCh) | floor(posTrCh) ~= posTrCh | posTrCh<0 | posTrCh>1)
    msg='Position in Transport channel must be a scalar equal to 0 for Fixed position or 1 for Flexible position.';
    
elseif(posTrCh==1)
    msg='Flexible position in transport channel is not currently supported.';
end

% Check for Number of Physical Channels
if(sum(size(numPhCH))>2 | ~isreal(numPhCH) | floor(numPhCH) ~= numPhCH | numPhCH<=0 | numPhCH>3)
    msg='Number of physical channels must be an integer number between 1 and 3.';
elseif(numPhCH ~= 1)
    msg='Only 1 Physical Channel is currently supported';
end

% Check Slot Format Parameter
if(sum(size(slotFormat))>2 | ~isreal(slotFormat) | floor(slotFormat) ~= slotFormat | slotFormat >16 | slotFormat<0),
    msg='The Slot format parameter must be an integer between 0 and 16.';
end


% Check DCPH Code Number
if(sum(size(dpchCode))>2 | ~isreal(dpchCode) | floor(dpchCode) ~= dpchCode | dpchCode>=sprdFactor),
    msg='The DPCH code number must be an integer between 0 and the value of the Spreading Factor minus 1.';
end

% Check for Scrambling Code
if(length(scrCode)~=2)
    msg='The Scrambling code parameter must be a 2-element vector containing the Scrambling Code Group and the Primary Code.';
    
else
    
    if(sum(size(scrCode(1)))>2 | ~isreal(scrCode(1)) | floor(scrCode(1)) ~= scrCode(1) | scrCode(1)<0 | scrCode(1)>63)
        msg='The first element of the Scrambling Code (Scrambling Code Group) must be an integer between 0 to 63.';
    end
    
    if(sum(size(scrCode(2)))>2 | ~isreal(scrCode(2)) | floor(scrCode(2)) ~= scrCode(2) | scrCode(2)<0 | scrCode(2)>8)
        msg='The second element of the Scrambling Code (Primary Code) must be an integer between 0 to 7.';
    end
    
end
% Check for Power Settings Vector
if(length(powerVector) ~=5)
    msg='Power Vector must be a 5-element vector containing the Ec/Ior (in dB) as defined by the standard for the following channels: DPCH, P-CPICH, PICH, P-CCPCH, SCH.';
end

% Check for Number of Tap filter for RRC
if( sum(size(numTapsRRC))>2 | ~isreal(numTapsRRC) | floor(numTapsRRC)~=numTapsRRC ) %| numTapsRRC<overSampling*2
    msg='The number of coefficients of the Root Raised Cosine filter must be a positive integer multiple of 2 times the oversampling factor of the filter.';
end

% Check for Oversampling Factor
if(sum(size(overSampling))>2 | ~isreal(overSampling) | floor(overSampling)~=overSampling | overSampling<0 | 2*overSampling>numTapsRRC)
    msg='The oversampling factor has to be an integer greater than 0.';
end
% Check for SNR 
if(sum(size(snrdB))>2 | ~isreal(snrdB))
    msg='The Signal to Noise Ratio, expressed in dB, must be a real number.';
end

% Check for Finger Enables and Finger Phases
if(length(fingerEnables)<length(fingerPhases) | length(fingerEnables) ~=4)
    msg='The length of the Finger enables vector and the length of the Finger phases vector must be the same and equal to the number of fingers in the RAKE receiver.';
end

if (~all((fingerEnables==1)+(fingerEnables==0)))
    msg='Finger Enables parameter must be a vector of binary numbers where 1 enables the finger and 0 disables finger.';
end
    
if (any(fingerPhases<0))
    msg='Finger Phases must be a vector of real numbers greater than or equal to 0.';
end

if(sum(size(numTapsChEst))>2 | ~isreal(numTapsChEst) | floor(numTapsChEst)~=numTapsChEst | mod(numTapsChEst,2)==0 | numTapsChEst <= 1)
    msg='The number of coefficients of the Channel estimator filter must be an odd positive integer greater than 1.';
end

% Not currently supported
if(powerVector(4)~= powerVector(5))
    msg='In the current version, power settings for the P-CCPCH and SCH must be the same.';
end