function ret = checksettings(h)
%CHECKSETTINGS  Make sure all tic2000TgtPrefs settings are valid
%               Return 1 if settings are correct and 0 if they are not

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 21:07:24 $

ret = 1;

IPT = ceil (3 / h.DSPBoard.DSPChip.eCAN.BitRatePrescaler);

if (h.DSPBoard.DSPChip.eCAN.BitRatePrescaler<1 || h.DSPBoard.DSPChip.eCAN.BitRatePrescaler>256)
    errordlg ('BitRatePrescaler must be between 1 and 256','eCAN settings error');
    ret = 0;
    return
end
if (str2num (h.DSPBoard.DSPChip.eCAN.TSEG1) < str2num(h.DSPBoard.DSPChip.eCAN.TSEG2))
    errordlg ('TSEG1 must not be less than TSEG2','eCAN settings error');
    ret = 0;
    return
end
if (str2num (h.DSPBoard.DSPChip.eCAN.TSEG2) < IPT)
    errordlg ('TSEG2 must not be less than information processing time (IPT)','eCAN settings error');
    ret = 0;
    return
end
if (strcmp(h.DSPBoard.DSPChip.eCAN.SAM,'Sample_three_times') && h.DSPBoard.DSPChip.eCAN.BitRatePrescaler<=4)
    errordlg ('SAM can be set to Sample_three_times only if BitRatePrescaler is greater than 4','eCAN settings error');
    ret = 0;
    return
end
if (str2num (h.DSPBoard.DSPChip.eCAN.SJW) > str2num(h.DSPBoard.DSPChip.eCAN.TSEG2))
    errordlg ('SJW must be less than TSEG2','eCAN settings error');
    ret = 0;
    return
end
if (strcmp (h.DSPBoard.DSPChip.eCAN.SBG,'Both_falling_and_rising_edges'))
    errordlg ('Due to a silicon bug, SBG cannot be set to Both_falling_and_rising_edges','eCAN settings error');
    ret = 0;
    return
end