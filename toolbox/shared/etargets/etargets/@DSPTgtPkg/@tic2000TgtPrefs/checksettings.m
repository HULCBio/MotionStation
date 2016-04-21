function ret = checksettings(h)
%CHECKSETTINGS  Make sure all tic2000TgtPrefs settings are valid
%               Return 1 if settings are correct and 0 if they are not

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:29 $

ret = 1;

if (h.DSPBoard.DSPChip.eCAN.BitRatePrescaler<1 || h.DSPBoard.DSPChip.eCAN.BitRatePrescaler>256)
    errordlg ('BitRatePrescaler must be between 1 and 256','BitRatePrescaler settings error');
    ret = 0;
end
if (str2num (h.DSPBoard.DSPChip.eCAN.TSEG1) < str2num(h.DSPBoard.DSPChip.eCAN.TSEG2))
    errordlg ('TSEG1 must not be less than TSEG2','eCAN settings error');
    ret = 0;
end



