function [fit,Tz] = findzero(tau,mt,p1z,K)
% Finds one zero to a continous version of m, given that the static gain is
% K

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:24 $
nf = pvget(mt,'nf');
F = pvget(mt,'f');
bd = pvget(mt,'b');

bd = bd.';
Ts = pvget(mt,'Ts');
nb = pvget(mt,'nb');
int = mt.es.DataInterSample;
int = int{1,1};
%nf = pvget(mt,'nf');
nk = pvget(mt,'nk'); 

int = lower(int(1));
if nb~=nf+1
    %  error('wrong structure')
end
af=diag(ones(nf-1,1),1);
af(:,1)=-F(2:end).';
ac = real(logm(af)/Ts); % The continuous time A-matrix
acp = poly(ac); %observer can form
kcomp = acp(end);
Kp = K*kcomp; % constant term in numerator
ac = diag(ones(nf-1,1),1);
ac(:,1)=-acp(2:end)';
c = [1,zeros(1,nf-1)];
d = 0;
nxc = length(ac);
%case 1 D is non-zero (1st order model with zero)
if p1z==1 % first order with zero
    [f1,g1,c1,d1] = idsample(ac,1,c,0,zeros(nf,1),Ts,int,1,tau);
    m1 = idpoly(idss(f1,g1,c1,d1));
    b = m1.b;
    if length(b)>length(bd)
        b=b(2:end);
    end
    der(:,2) = b.';
    [f1,g1,c1,d1] = idsample(ac,0,c,1,zeros(nf,1),Ts,int,1,tau);
    m1 = idpoly(idss(f1,g1,c1,d1));
    b = m1.b;
    if length(b)>length(bd)
        b=b(2:end);
    end
    der(:,1) = b.';
    if length(bd)>size(der,1)
        bd= bd(2:end);
    end
    dd=-kcomp*der(:,2)+der(:,1);
    a= inv(dd'*dd)*dd'*(bd-der(:,2)*Kp);
    Tz = a/Kp;
    fit = norm(bd-dd*a-Kp*der(:,2));
    elseif p1z==2 % just Td no Tz
    bb=zeros(nxc,1);
    bb(end)=Kp;
    [f1,g1,c1,d1]=idsample(ac,bb,c,0,zeros(nf,1),Ts,int,1,tau);
    m1 = idpoly(idss(f1,g1,c1,d1));
    b = m1.b(end-2:end); %% fix size
    fit = norm(b-bd(end-2:end)');
    Tz = 0;

else % estimate Tz and td
    
    %case 2 nf>nb
    for kk=[1 2];
        bb = zeros(nxc,1);
        bb(end+1-kk,1)=1; % this is the coefficient for s
        [f1,g1,c1,d1]=idsample(ac,bb,c,0,zeros(nf,1),Ts,int,1,tau);
        m1 = idpoly(idss(f1,g1,c1,d1));
        
        b = m1.b; 
        if kk>1&length(b)>size(der,1), b = [b 0];end % andra fall
        der(:,kk) = b.';
    end
    if length(bd)>size(der,1)
        bd=bd(2:end);
    end
    b2=inv(der(:,end)'*der(:,end))*der(:,end)'*(bd-der(:,end-1)*Kp); 
    Tz = b2/Kp;
    fit = norm(der*[Kp;b2]-bd);
end


