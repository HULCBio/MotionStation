function displaycoefficients(Hq)
%DISPLAYCOEFFICIENTS  Display coefficients of quantized filter.
%   DISPLAYCOEFFICIENTS(Hq) displays the coefficients of QFILT object Hq.
%
%   See also QFILT, QFILT/DISP, QFILT/DISPLAY.

%   Thomas A. Bryan, 9 August 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:30:55 $

disp(coeffstr(Hq))
