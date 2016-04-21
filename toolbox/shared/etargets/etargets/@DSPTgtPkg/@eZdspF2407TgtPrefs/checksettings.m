function ret = checksettings(h)
%CHECKSETTINGS  Make sure all tic2400TgtPrefs settings are valid
%               Return 1 if settings are correct and 0 if they are not

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:17 $

ret = 1;

IPT = ceil (3 / h.DSPBoard.DSPChip.CAN.BitRatePrescaler);

if (h.DSPBoard.DSPChip.CAN.BitRatePrescaler<1 || h.DSPBoard.DSPChip.CAN.BitRatePrescaler>256)
    errordlg ('BitRatePrescaler must be between 1 and 256','CAN settings error');
    ret = 0;
    return
end
if (str2num (h.DSPBoard.DSPChip.CAN.TSEG1) < str2num(h.DSPBoard.DSPChip.CAN.TSEG2))
    errordlg ('TSEG1 must not be less than TSEG2','CAN settings error');
    ret = 0;
    return
end
if (str2num (h.DSPBoard.DSPChip.CAN.TSEG2) < IPT)
    errordlg ('TSEG2 must not be less than information processing time (IPT)','CAN settings error');
    ret = 0;
    return
end
if (strcmp(h.DSPBoard.DSPChip.CAN.SAM,'Sample_three_times') && h.DSPBoard.DSPChip.CAN.BitRatePrescaler<=4)
    errordlg ('SAM can be set to Sample_three_times only if BitRatePrescaler is greater than 4','CAN settings error');
    ret = 0;
    return
end
if (str2num (h.DSPBoard.DSPChip.CAN.SJW) > str2num(h.DSPBoard.DSPChip.CAN.TSEG2))
    errordlg ('SJW must be less than TSEG2','CAN settings error');
    ret = 0;
    return
end

