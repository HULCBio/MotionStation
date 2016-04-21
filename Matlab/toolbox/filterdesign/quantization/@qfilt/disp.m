function disp(Hq)
%DISP   Display QFILT object. 
%   DISP(Hq) displays a QFILT object in the same way as leaving off the
%   semicolon, except that the variable name is not displayed.
%
%   If the MATLAB workspace display format is HEX, then the coefficients are
%   displayed in hexadecimal format.
%
%   If the MATLAB workspace display format is RAT, then the coefficients are
%   displayed in rational format. 
%
%   Example:
%     [b,a] = butter(4,.5);
%     Hq = qfilt('ref',{b,a});
%     format hex
%     disp(Hq)
% 
%     format rat
%     disp(Hq)
%
%     format
%     disp(Hq)
%
%   See also QFILT, QFILT/NUM2BIN, QFILT/NUM2HEX.

%   Thomas A. Bryan, 9 August 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.20 $  $Date: 2002/04/14 15:29:25 $

disp(dispstr(Hq))
