function [propseg, pseg1, pseg2, presdiv, sample] = ...
    can_bit_timing(fsys,bitrate,nq,sample_point)
%CAN_BIT_TIMING calculates bit timing values for the TouCAN module
% of a board in the Motorola MPC555 family.
%
%   This function takes the arguments
%     fsys           -  oscillator frequency
%     bitrate        -  the desired bit rate
%     nq             -  the number of segments in the bit
%     sample_point   -  the desired sample_point   0 < sample_point < 1
%
%   and returns
%     propseg        -  the number of propagation quanta
%     pseg1          -  phase segment 1 quanta
%     pseg2          -  phase segment 2 quanta
%     presdiv        -  prescaler divide to calculate oscillator freq
%     sample         -  the achieved sample point
%
% Example
%
%     [propseg,pseg1,pseg2,presdiv,sample] = can_bit_timing(20e6,500e3,20,0.81)

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:21:40 $

presdiv =  fsys / (nq * bitrate);

%
% Check that the required pre-scaler is a whole number
%
if(fix(presdiv) ~= presdiv)
  error(['System_Frequency / ( Number_Of_Quanta * CAN_Bit_Rate ) must equal a whole number,'...
	 sprintf('\n') ...
	 'but, the current settings for these values give: '...
	 sprintf('\n') ...
	 '  (' num2str(fsys) ' / ( ' num2str(nq) ' * ' num2str(bitrate) ' ) = ' num2str(presdiv) ...
	 sprintf('\n') ...
	 'You must change one or more of Number_Of_Quanta, CAN_Bit_Rate and System_Frequency' ...
	 sprintf('\n') ...
	 'such that the result is a whole number.']);
end

%
% Check that the sample point is in the required range
%
if ( sample_point <= 0 | sample_point >= 1 )
  error(['Sample_Point must be greater than 0 and less than 1. You must select bit timing parameters'...
	 sprintf('\n') ...
	 'such that the sample point is in the required range. For details of bit timing parameters,'...
	 sprintf('\n') ...
	 'see any reference documentation on Controller Area Network.']);
end

% Candidate values for tseg1
TSEG1 = 2:(min(nq-1,16));

% Candidate values for sample
SAMPLE = (1 + TSEG1) / nq;

% Choose the best values for tseg1 and sample
[tmp,idx] = min(abs(SAMPLE - sample_point));
sample = SAMPLE(idx);
tseg1 = TSEG1(idx);

% Calculate remaining output arguments
propseg = floor(tseg1/2);
pseg1 = tseg1 - propseg;
pseg2 = nq -1 - propseg - pseg1;
 
   



   
  
