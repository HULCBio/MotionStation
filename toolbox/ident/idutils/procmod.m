function [A,B,C,D,K,X0,xnr,levnr]=procmod(par,T,aux)
%PROCMOD Function for defining IDPROC objects.
%
%   [A,B,C,D,K,X0] = PROCMOD(PAR, T, AUX)
%
%   PROCMOD is the MfileName property of the underlying IDGREY
%   object in IDPROC. PAR is the parameter vector, T is the
%   sampling interval and AUX is the FileArgument property of the
%   IDGREY object. AUX{1} contains the Model Type property of the
%   IDPROC object and AUX{2} contains the sampling instruction,
%   'zoh' or 'foh'.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $ $Date: 2004/04/10 23:20:23 $

typec = aux{1}; %Model type
samp = aux{2}; % should be a cell containing zoh or foh

dist = aux{3}; % disturbance model
parnr = aux{5};
%parnr = pardistnr{1};
%distnr = pardistnr{2};
try
    ulev = aux{8};
catch
    ulev = cell(1,length(typec));
end

% Parameter order K, TP1 TP2 TW ZETA TP3 TD TZ  D1 D2 C1 C2
if ~iscell(typec),typec={typec};end
nu = length(typec);
if ~iscell(samp),samp={samp};end
if length(samp)<nu
    samp = repmat(samp,1,nu);
end
param = zeros(8*nu+4,1);
param(parnr) = par(1:length(parnr));
A=[];B=[];C=[];D=[];
levnr = zeros(1,nu); % statenumber that holds InputLevels
for ku = 1:nu
    type = typec{ku};
    n = eval(type(2));
    if any(type=='I')
        n = n+1;
    end
    parku = param((ku-1)*8+1:ku*8); 
    TD = 0;
    if any(type=='D')
        TD = parku(7);
    end
    if any(type=='U')
        a = parku(4)*parku(4);
        b = parku(4)*2*parku(5);
    else
        a = parku(2)*parku(3);
        b = parku(2)+parku(3);
    end
    den = [a*parku(6) a+parku(6)*b b+parku(6) 1];
    if any(type=='I')
        den = [den 0];
    end
    den = den(end-n:end);
    num = zeros(1,n+1);
    if n>0
        num(end-1:end) = [parku(1)*parku(8) parku(1)]/den(1);
        den = den/den(1);
    else
        num = parku(1);
    end
    
    Dp = num(1);
    num = num(2:end)-den(2:end)*num(1);
    F = [-den(2:end);[eye(n-1),zeros(n-1,1)]];
    if n>0
        G = [1;zeros(n-1,1)];
    else
        G = zeros(0,1);
    end
    Cp = num;
    
    if any(strcmp(ulev.status{ku},{'estimate','fixed'}))
        F = [[F,-G];zeros(1,length(F)+1)];%%%%
        G = [G;0];%%%%
        Cp = [Cp,0];
        if ku==1
            levnr(ku) = length(F);
        else
            levnr(ku) = xnr(ku-1)+length(F);
        end
        %xlev(ku) = ulev.value(ku);
    end
    %Kp =[Kp;0];
    if T>0 
        modsa = lower(samp{ku});
        switch modsa(1)
            case 'z'
                Kp = zeros(size(F,1),0);
                [A1,B1,C1,D1] = idsample(F,G,Cp,Dp,Kp,T,'zoh',1,TD);
                
            case 'f'
                %tau=TD;
                %n=floor(tau/T);
                %tau1=tau/T-n;
                Ktemp = zeros(size(F,1),size(Cp,1));
                Cc = Cp;Dd=Dp;
                [A1,B1,C1,D1]=idsample(F,G,Cp,Dp,Ktemp,T,'foh',1,TD);
                
        end            
        K1=zeros(size(C1))';
        
        
    else
        B1 = G; A1 = F; C1 = Cp;D1 = Dp;
        K1=zeros(size(C1))';
        
    end
    
    n = length(A1);nn=length(A);
    if length(D)>0
        A = [[A,zeros(nn,n)];[zeros(n,nn),A1]];
        B = [[B;zeros(n,size(B,2))],[zeros(nn,1);B1]];
        C = [C C1];
        D = [D D1];
        K = [K;K1];
    else
        A = A1;
        B = B1;
        C = C1;
        D = D1;
        K = K1;
    end
    xnr(ku) = length(A);
end % ku
if strcmp(dist,'Fixed')
    pard = aux{4};
    if length(pard)==4
        dist = 'ARMA2';
    else
        dist = 'ARMA1';
    end
    %par = [par;pard(:)];
else
    pard = par(length(parnr)+1:end);
end
switch dist 
    case 'ARMA1'
        d1 = pard(1);
        c1 = pard(2);
        a = -d1;
        b = c1-d1;
         if any([d1,c1]<0) % unstable noise model or inverse noise model
            a = NaN;
            b = NaN;
        else
        if T>0
            [a,b]=idsample(a,b,[],[],zeros(size(b)),T,'zoh');
            if abs(a-b)>1 % unstable predictor
                b = ssssaux('kric',a,1,b^2,1,b);
            end
        end
    end
        A=[[A,zeros(size(A,1),1)];[zeros(1,size(A,2)),a]];K=[zeros(size(B,1),1);b];
        B=[B;zeros(1,size(B,2))];
        C=[C,1];   
    case 'ARMA2'
        d1 = pard(1);
        d2 = pard(2);
        c1=pard(3);
        c2 = pard(4);
        a = [-d1 1;-d2 0]; 
        b = [c1-d1;c2-d2];
        if any([d1,d2,c1,c2]<0) % unstable noise model or inverse noise model
            a = NaN*eye(2);
            b = NaN*[1;1];
        else
        if T>0
            [a,b]=idsample(a,b,[],[],zeros(size(b)),T,'zoh');
            if max(abs(eig(a-b*[1 0])))>1 % unstable predictor
                b = ssssaux('kric',a,[1 0],b*b',1,b);
            end
        end
    end
        A=[[A,zeros(length(A),2)];[zeros(2,length(A)),a]];
        K = [zeros(length(B),1);b];
        B = [B;zeros(2,size(B,2))];
        C = [C,1,0];
end
X0=zeros(size(A,1),1);
for ku=1:nu
    if levnr(ku)~=0
        if ~isnan(ulev.value(ku))
            X0(levnr(ku))=ulev.value(ku);
        end
    end
end


