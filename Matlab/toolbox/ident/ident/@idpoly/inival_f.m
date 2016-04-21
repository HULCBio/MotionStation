function ms = inival_f(z,mi,initflag,realflag)
%INIVAL_F
%
%   M = INIVAL_F(DATA,Mi,T,initflag)
%
%

%	L. Ljung 10-1-02
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.8.4.1 $  $Date: 2004/04/10 23:16:35 $

% This version is for OE strutures only

if nargin <3
    initflag = 0;
end
T = pvget(z,'Ts'); 
T = T{1};
nf = mi.nf;
nb = mi.nb;
nk = mi.nk;
nu = size(nb,2);
if T==0
    nk = zeros(1,nu);
end
maxsize = pvget(mi,'MaxSize');% maxsize is not used in this version
if isempty(maxsize)|ischar(maxsize)
    maxsize = idmsize(min(size(z,'N')));
end

if initflag % then the last input already has nf = sum(nf(1:end-1))
    naf = max(nf);
    nbf = nb + naf - nf;
    nbf(end) = nb(end);
else
    naf = sum(nf);
    nbf = nb +naf - nf;
end
[a,b] = arx_f(z,naf,nbf,nk,T,maxsize,realflag);
was = warning;
warning off % To avoid warnings about no white noise for Ts = 0;
mi = pvset(mi,'a',a,'b',b,'Ts',T,'InputName',pvget(z,'InputName'),'OutputName',...
    pvget(z,'OutputName'));
YHd = sim(mi,z);
%lastwarn('')
warning(was)

[a,b] = ivx_f(z,YHd,naf,nbf,nk,T,maxsize,realflag);
bi = b(end,:);
f = [];
b = [];
if initflag
    nu1 = nu-1;
else
    nu1 = nu;
end
for ku = 1:nu1
    Uk = z(:,[],ku);
    lsub.type='()';
    lsub.subs = {[1],ku};
    mis= subsref(mi,lsub);
    was = warning;
    warning off
    Y1 = sim(mis,Uk);
    %lastwarn('')
    warning(was)
    [ff,bb] = arx_f([Y1,Uk],nf(ku),nb(ku),nk(ku),T,maxsize,realflag);
    %ff = fstab(ff,T);
    f = idextmat(f,ff,T);
    b = idextmat(b,bb,T);
end
if initflag
   % a = fstab(a,T);
    f = idextmat(f,a,T);
    b = idextmat(b,bi,T);
end

ms = pvset(mi,'b',b,'a',1,'f',f,'Ts',T);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b] = arx_f(data,na,nb,nk,T,maxsize,realflag)
%realflag = realdata(data);
nm = max([na,nb+nk-1]);
nu = length(nb);
n1 = na + sum(nb);
Yc = pvget(data,'OutputData');
Uc = pvget(data,'InputData');
Wc = pvget(data,'Radfreqs');
R1=zeros(0,n1+1);
    M = floor(maxsize/(nm+1));

for kexp = 1:length(Yc)
    Y1 =Yc{kexp};
    U1 = Uc{kexp};
    w1 = Wc{kexp};
    N = size(Y1,1);
    for kM = 1:M:N
        jj = [kM:min(N,kM-1+M)];
        w = w1(jj,:);
        Y = Y1(jj,:);
        U = U1(jj,:);
    if T>0,
        OM=exp(-i*[0:nm]'*w'*T);
        inda = 2:na+1;
        YY = Y;
    else 
        OM=ones(1,length(w));
        for kom=1:nm
            OM=[OM;(i*w').^kom];
        end
        inda = na:-1:1;
        YY = Y.*OM(na+1,:).';
    end
    D = (OM(inda,:).').*(-Y*ones(1,na));
    for ku = 1:nu
        if T>0, 
            ind=nk(ku)+1:nk(ku)+nb(ku);
        else 
            ind=nb(ku):-1:1;
        end	
        temp=(OM(ind,:).').*(U(:,ku)*ones(1,nb(ku)));
        D=[D temp]; 
    end
    if realflag
        R1=triu(qr([R1;[[real(D);imag(D)],[real(YY);imag(YY)]]]));
    else
        R1 = triu(qr([R1;[D,YY]]));
    end
    [nRr,nRc]=size(R1);
    R1=R1(1:min(nRr,nRc),:);
end
end
R=R1(1:n1,1:n1);Re=R1(1:n1,n1+1);
t = pinv(R)*Re;
a = [1 t(1:na).'];
b = [];
ind = na;
for ku = 1:nu
    b = idextmat(b,[zeros(1,nk(ku)),t(ind+1:ind+nb(ku)).'],T);
    ind = ind + nb(ku);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b] = ivx_f(data,YHd,na,nb,nk,T,maxsize,realflag)
%realflag = realdata(data);
nm = max([na,nb+nk-1]);
nu = length(nb);
n1 = na + sum(nb);
Yc = pvget(data,'OutputData');
Uc = pvget(data,'InputData');
Wc = pvget(data,'Radfreqs');
YHc = pvget(YHd,'OutputData');
R=0;Re=0;
M = floor(maxsize/(nm+1));
for kexp = 1:length(Yc)
    Y1 =Yc{kexp};
    YH1 = YHc{kexp};
    U1 = Uc{kexp};
    w1 = Wc{kexp};
    N = size(Y1,1);
    for kM = 1:M:N
        jj = [kM:min(N,kM-1+M)];
        Y = Y1(jj,:);
        U = U1(jj,:);
        YH = YH1(jj,:);
        w = w1(jj);
    if T>0,
        OM=exp(-i*[0:nm]'*w'*T);
        
        inda = 2:na+1;
        YY = Y;
    else 
        OM=ones(1,length(w));
        for kom=1:nm
            OM=[OM;(i*w').^kom];
        end
        inda = na:-1:1;
        YY = Y.*OM(na+1,:).';
    end
    DH = (OM(inda,:).').*(-YH*ones(1,na));
    D = (OM(inda,:).').*(-Y*ones(1,na));
    Db = [];
    
    for ku = 1:nu
        if T>0, 
            ind=nk(ku)+1:nk(ku)+nb(ku);
        else 
            ind=nb(ku):-1:1;
        end	
        temp=(OM(ind,:).').*(U(:,ku)*ones(1,nb(ku)));
        Db=[Db temp]; 
    end
    if realflag
        R = R + real([DH Db]'*[D Db]);
        Re = Re + real([DH Db]'*YY);
    else
        R = R + [DH Db]'*[D Db];
        Re = Re + [DH Db]'*YY;
    end
end
end
t = pinv(R)*Re;
a = [1 t(1:na).'];
b = [];
ind = na;
for ku = 1:nu
    b = idextmat(b,[zeros(1,nk(ku)),t(ind+1:ind+nb(ku)).'],T);
    ind  = ind+nb(ku);
end
