function kk=isempty(m)

%   $Revision: 1.5.4.1 $ $Date: 2004/04/10 23:17:58 $
%   Copyright 1986-2003 The MathWorks, Inc.

kk=false;
%return
if size(m.Ds)==[0,0]
    kk = true;
end
if isempty(m.Bs)&norm(pvget(m,'NoiseVariance')) == 0
    kk = true;
end

