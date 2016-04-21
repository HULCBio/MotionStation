function [w,idx] = iddefw(sys,type)
%IDDEFW Sets default frequency vectors
%   
%   W = IDDEFW(SYS,TYPE)
%   
%   SYS: any IDMODEL or LTI Model
%   W: Suitable frequency vector for this model.
%   If TYPE == 'Nyquist' the freqeuncies are suited for Nyquist plots
%   while TYPE == 'BODE' gives frequencies for Bode plots.

%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.2.4.1 $  $Date: 2004/04/10 23:18:34 $

if nargin<2
    type = 'n';%Nyquist
end
type = lower(type(1));
idx = [];
T = pvget(sys,'Ts');
[z,p] = zpkdata(sys);
inpd = pvget(sys,'InputDelay');
try
w = freqpick(z,p,T,inpd,1,'d'); %% The below for BODE
catch
    if T>0
        w = [1:128]/128*pi/T;
    else
        w = logspace(0.01,100,100);
    end
end
try
if type=='b'
    sys1 = pvset(sys,'InputDelay',zeros(size(inpd)));
    h = permute(freqresp(sys1,w),[3 1 2]);
    FocusInfo = freqfocus(w,h,z,p,T);
    [wdef,idx] = roundfocus('freq',FocusInfo.Range(3,:),w,[],[]);
    %end
   % if type=='b'
        w = w(idx);
    end
end
