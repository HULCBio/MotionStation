function datamod = nyqcut(data)
%NYQCUT Cuts way data above the Nyquist frequency


%   L. Ljung 03-06-05
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/06/05 19:32:44 $


fre = data.Frequency;
if strcmp(lower(data.Units),'hz')
    picorr = 2*pi;
else
    picorr = 1;
end
if data.Ts > 0 & any(fre>pi/picorr/data.Ts+1e4*eps)
    warning('Frequency points above the Nyquist frequency have been removed')
    datamod = fselect(data,find(fre<=pi/picorr/data.Ts+1e4*eps));
else
    datamod = data;
end