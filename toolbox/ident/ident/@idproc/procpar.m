function [Kp,TP1,TP2,TR,ZETA,TP3,TD,TZ,DMpar] = procpar(sys) 
%PROCPAR Computes the parameters of an IDPROC object.
%
%   [Kp,Tp1,Tp2,Tres,Zeta,Tp3,Td,Tz] = PROCPAR(MOD)
%   
%   MOD is an IDPROC model and the returned parameters are the
%   basic model parameters extracted from MOD.ParameterVector.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $ $Date: 2004/04/10 23:18:04 $


par = pvget(sys.idgrey,'ParameterVector');
typec = i2type(sys);%sys.Type;
if ~iscell(typec),typec={typec};end
nu = length(typec);
TP1=NaN*ones(nu,1);TP2 =TP1; TZ = TP1; TD = TP1; TP3 = TP1;TR = TP1;ZETA =TP1;Kp=TP1;
DMpar = []; %disturbance model par
for ku=1:nu
    type =typec{ku};
%     par = parc((ku-1)*8+1:ku*8);
    Kp(ku,1)=par(1); %  Static gain

n = eval(type(2));
if n==0
    stnr = 1;
elseif n==1
    TP1(ku,1)=par(2); % time constant
    stnr = 2;
     if any(type=='U')
         error('Underdamped poles are not possible for firts order models.')
     end
elseif n>=2
    if any(type=='U');
        TR(ku,1) = par(2);
        ZETA(ku,1) = par(3);
    else
        TP1(ku,1) = par(2);
        TP2(ku,1) = par(3);
    end
    if n==3
        TP3(ku,1) = par(4);
        stnr = 4;
    else
        stnr = 3;
    end    
end
pend = stnr;
if any(type=='D') 
    TD(ku,1) = par(stnr+1);
    pend = stnr+1;
    if any(type=='Z')
        TZ(ku,1) = par(stnr+2);
    pend =stnr+2;    
    end
elseif any(type=='Z')
    TZ(ku,1) = par(stnr+1);
    pend=stnr+1;
end
par = par(pend+1:end);
end
fa = pvget(sys.idgrey,'FileArgument');

switch fa{3}
case 'ARMA1'
    DMpar = par(end-1:end);
case 'ARMA2'
    DMpar = par(end-3:end);
end