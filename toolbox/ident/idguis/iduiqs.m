function iduiqs
%IDUIQS Quickstart operation for ident.
%      For the current Estimation data set, the impulse response(s)
%      are calculated using correlation analysis. Then
%      the frequency response(s) are calculated using spectral
%      analysis. The delay in the different channels are
%      estimated by picking the first value where the impulse
%      response estimate exceeds 0.5*the estimated standard
%      deviation. Then a fourth order ARX-model is computed
%      with these delays. The step responses, the frequency
%      responses and a compare view are opened for the resulting
%      models

%   L. Ljung 4-4-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/10 23:19:55 $

Xsum = findobj(get(0,'children'),'flat','tag','sitb16');
XID = get(Xsum,'Userdata');
dat =iduigetd('e');
[Ncap,ny,nu] = sizedat(dat);
if isa(dat,'idfrd')
    dom='f';
elseif strcmp(get(dat,'Domain'),'Frequency')
    dom='f';
else
    dom = 't';
end
    
if nu>0
    was = warning;
    warning off
    IR=iduinpar('cra');
    warning(was)
    if isempty(IR)
        return
    end
    [IR1,Tim,sdIR] = impulse(IR);
    Ts = pvget(IR,'Ts');
    %IR1 = IR.ir;
    for ky=1:ny
        for ku=1:nu
            ir = squeeze(IR1(:,ky,ku));
            lev = squeeze(sdIR(:,ky,ku));
            kdum=find(abs(ir)-lev*2.58>0);
            if isempty(kdum)
                nk(ky,ku)=0;
            else
                nk(ky,ku)=floor(max(0,Tim(kdum(1))/Ts));  
            end
        end
    end
    set(XID.plotw(5,2),'value',1),iduipw(5);
end
iduinpar('spa');
if nu>0,
    wino=2;
else
    wino=7;
end
set(XID.plotw(wino,2),'value',1),iduipw(wino);
iduistat('Computing a 4th order ARX model...');
if nu==0,nk=zeros(ny,nu);end
iduiarx('estimate',[4*ones(ny,ny),4*ones(ny,nu),nk],'arxqs');
dv = iduigetd('v','me'); domv = lower(pvget(dv,'Domain'));
if ~(nu==0&strcmp(domv,'frequency'))
set(XID.plotw(3,2),'value',1),iduipw(3);
end
if ~(nu==0&dom=='f')
   
    if Ncap>(ceil(10/ny+1)+ceil((10-ny+1)/(nu+ny)))*(1+nu+ny)
        %if Ncap>19*ny+30*(nu+1)
        iduistat('Computing a default order state space model using N4SID...');
        iduiss('qsestimate');
    else
        iduistat('Too few data points for default order N4SID model.')
    end
else
    iduistat('No N4SID model for frequency domain data with no input.')
end