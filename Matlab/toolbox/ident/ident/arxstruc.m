function V=arxstruc(z,zv,nn,maxsize);
%ARXSTRUC Computes loss functions for families of ARX-models.
%   V = ARXSTRUC(ZE,ZV,NN)
%
%   V: The first row of V is returned as the loss functions of the
%   structures defined by the rows of NN. The remaining rows are
%   returned as NN'. The last column of V contains the number of
%   data points in Z.
%
%   ZE : the output-input data as an IDDATA object (See Help IDDATA) 
%   Only Single-Output data are handled by this routine.
%    
%   ZV: the input-output data on which the validation is performed.
%   (could equal ZE).  Also an IDDATA object.
%
%   NN: Each row of NN is of the format [na nb nk], the orders and delays
%   of the corresponding ARX model.(See also ARX and STRUC.)
%
%   For a time series, each row of NN equals na only.
%
%   See also SELSTRUC for analysis of V.
%
%   Some parameters associated with the algorithm are accessed by
%   V = ARXSTRUC(Z,ZV,NN,maxsize)
%   See also AUXVAR for an explanation of maxsize, and IVSTRUC for
%   an alternative approach.

%   L. Ljung 4-12-87, 9-26-1993
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.1 $  $Date: 2004/04/10 23:18:53 $

if nargin < 3
    disp('Usage: V = ARXSTRUC(EST_DATA,VAL_DATA,ORDERS)')
    disp('       V = ARXSTRUC(EST_DATA,VAL_DATA,ORDERS,MAXSIZE)')
    return
end
init = 'z'; %normally no initial states
if isa(z,'frd'), z = idfrd(z);end
if isa(zv,'fdr'), zv = idfrd(zv);end
if isa(zv,'idfrd'), zv = iddata(zv);end
if isa(z,'idfrd'), z = iddata(z);end
if isa(z,'iddata')
    dom = pvget(z,'Domain');
    if lower(dom(1))=='f'
        fd = 1;
        z = complex(z);
        init='e';
        try
            ut = pvget(z,'Utility');
            if ut.idfrd, init = 'z';end
        end
    else
        fd = 0;
    end
    if fd & init=='e' % then insert an extra input for the initial conditions
        [Nc,Ny,nuorig,Nexp] = size(z);
        Uc = pvget(z,'InputData');
        Wc = pvget(z,'Radfreqs');
        Tsdat = pvget(z,'Ts');
        %      nb = [nb,na*ones(1,Nexp)]; %%LL order max(na,nb+nk)??
        %     nk = [nk,ones(1,Nexp)];
        for kexp = 1:Nexp
            Uc{kexp} = [Uc{kexp},zeros(size(Uc{kexp},1),Nexp)];
            Uc{kexp}(:,nuorig+kexp) = exp(i*Wc{kexp}*Tsdat{kexp});
        end
        nunew = size(Uc{kexp},2);
        z = pvset(z,'InputData',Uc,'InputName',defnum([],'u',nunew));
        %z = pvset(z,'InputData',Uc,'InputName',{'d','g'});
    end
    [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(z,0,inputname(1));
    error(errflag)
    if ny>1
        error('ARXSTRUC only works for single output data.')
    end
    nz = 1+nu;
    
else
    [Ncaps,nz] = size(z);
    nu = nz-1;
    ze ={z};
    Ne = 1;
    fd = 0;
end
if isa(zv,'iddata') % check domain here too
    dom = pvget(zv,'Domain');
    if lower(dom(1))=='f'
        fdv = 1;
        zv = complex(zv);
    else
        fdv = 0;
    end
    if fd~=fdv
        error('Z and ZV should have the same domain (time or frequency).')
    end
    if fd & init=='e' % then insert an extra input for the initial conditions
        [Ncv,Nyv,nuorig,Nexpv] = size(zv);
        Uc = pvget(zv,'InputData');
        Wc = pvget(zv,'Radfreqs');
        Tsdatv = pvget(zv,'Ts');
        %      nb = [nb,na*ones(1,Nexp)]; %%LL order max(na,nb+nk)??
        %     nk = [nk,ones(1,Nexp)];
        for kexp = 1:Nexpv
            Uc{kexp} = [Uc{kexp},zeros(size(Uc{kexp},1),Nexp)];
            Uc{kexp}(:,nuorig+kexp) = exp(i*Wc{kexp}*Tsdat{kexp});
        end
        nunew = size(Uc{kexp},2);
        zv = pvset(zv,'InputData',Uc,'InputName',defnum([],'u',nunew));
    end
    [zev,Nev,ny,nuv,Ts,Name,Ncapsv,errflag]=idprep(zv,0,inputname(1));
    error(errflag)
    if ny>1
        error('ARXSTRUC only works for single output data.')
    end
    nzv = nuv +1;
else
    [Ncapsv,nzv] = size(zv); 
    zev ={zv};
    Nev = 1; 
end
[nm,nl] = size(nn);
if nu>1 & nm==1,
    error('For just one model, use ARX instead!')
end
if nz>Ncaps(1),
    error(' Data should be organized in column vectors!'),
end
% fix the orders for frequency domain data with the extra "initial" inputs
nnorig = nn;
[nmorig,nlorig]=size(nnorig);
if init=='e'
    for kn = 1:nm
        nbtemp = nn(kn,2:nuorig+1);
        nktemp = nn(kn,nuorig+2:end);
        nnnew(kn,:) = [nn(kn,1),nbtemp,max([nn(kn,1) nbtemp+nktemp])*ones(1,Nexp),...
                nktemp,ones(1,Nexp)]; % problem om olika antal exp i Z och Zv!
    end
    nn = nnnew;
    [nm,nl]=size(nn);
end
if nl~=1+2*(nz-1)
    error(sprintf(['Incorrect number of orders specified.',...
    '\nFor an AR-model nn=na',...
    '\nFor an ARX-model, nn=[na nb nk].']))
end
if nzv~=nz
    error(' ZV-set should have the same number of inputs as Z!')
end
if nz>1, 
    na=nn(:,1);nb=nn(:,2:1+nu);nk=nn(:,2+nu:1+2*nu);
else 
    na=nn(:,1); nb=zeros(nm,1);nk=zeros(nm,1);
end
% %%LLom Ts==0 skall alla nk sättas till 1: påverkar ej skattningen.
nma=max(na);nbkm=max(nb+nk)-ones(1,nu);nkm=min(nk);
n=nma+sum((nbkm-nkm))+nu;
%nmm=max(na,max(nb+nk));
if nn==0,return,end
vz = 1;
if Ne==Nev
    vz = 0;
    for kexp = 1:Ne
        if any(size(ze{kexp})~=size(zev{kexp}))
            vz = 1;
        elseif norm(ze{kexp}-zev{kexp})>eps,
            vz = 1;
        end
        
    end 
end

% *** Set up default values **
maxsdef=idmsize(max(Ncaps),n);

if nargin<4, maxsize=maxsdef;end
if isempty(maxsize),maxsize=maxsdef;end
if maxsize<0, maxsize=maxsdef; end

% *** construct regression matrix ***

nmax=max(max([na+ones(nm,1) nb+nk]'))-1;
M=floor(maxsize/n);
R=zeros(n);F=zeros(n,1);
v1 = 0;
if vz,
    Rv=zeros(n);Fv=zeros(n,1);
end
if fd
    Wc = pvget(z,'Radfreqs');
    Yc = pvget(z,'OutputData');
    Uc = pvget(z,'InputData');
    Tsdat = pvget(z,'Ts');
    if vz
        Wcv = pvget(zv,'Radfreqs');
        Ycv = pvget(zv,'OutputData');
        Ucv = pvget(zv,'InputData');
        Tsdatv = pvget(zv,'Ts');
    end
end


for kexp = 1:max(Ne,Nev)
    if fd
        Y = Yc{kexp};
        U = Uc{kexp};
        w = Wc{kexp};
        if vz
            Yv = Ycv{kexp};
            Uv = Ucv{kexp};
            wv = Wcv{kexp};
        end
        if Tsdat{kexp}>0,
            OM=exp(-i*[0:nmax]'*w'*Tsdat{kexp});
            inda = 2:nma+1;
            YY = Y;
        else 
            OM=ones(1,length(w));
            for kom=1:nmax
                OM=[OM;(i*w').^kom];
            end
            inda = nma:-1:1;
            %  indb=nb(ku):-1:1;
            YY = Y.*OM(na+1,:).';
        end
        if vz
            if Tsdatv{kexp}>0,
                OMv=exp(-i*[0:nmax]'*wv'*Tsdatv{kexp});
                indav = 2:nma+1;
                YYv = Yv;
            else 
                OMv=ones(1,length(wv));
                for kom=1:nmax
                    OM=[OM;(i*wv').^kom];
                end
                indav = nma:-1:1;
                % indbv=nb(ku):-1:1;
                YYv = Yv.*OMv(na+1,:).';
            end
        end
    end
    if kexp>Ne
        nez = 0;
        Ncap = Ncapsv{kexp};
    else
        z = ze{kexp};
        Ncap = Ncaps(kexp);
        nez = 1;
    end
    if kexp > Nev
        nezv = 0;
        Ncapv = Ncaps(kexp);
    else
        zv = zev{kexp};
        Ncapv = Ncapsv(kexp);
        nezv = 1;
    end
    if fd 
        nnm=0;
    else
        nnm = nmax;
    end
    for k=nnm:M:max(Ncap,Ncapv)
        if min(Ncap,k+M)<k+1
            ntz=0;
        else ntz=1;
        end
        if min(Ncapv,k+M)<k+1,
            ntzv=0;
        else 
            ntzv=1;
        end
        if ntz&nez
            jj=(k+1:min(Ncap,k+M));
            phi=zeros(length(jj),n);
        end
        if vz & ntzv,
            jjv=(k+1:min(Ncapv,k+M));
            phiv=zeros(length(jjv),n);
        end
        %if fd
        
        for kl=1:nma,
            if ntz&nez
                if ~fd
                    phi(:,kl)=-z(jj-kl,1);
                else
                    phi(:,kl)= (OM(inda(kl),jj).').*(-Y(jj)); %kolonnnr för Ts==0
                end
            end
            if vz & ntzv & nezv
                if ~fd
                    phiv(:,kl)=-zv(jjv-kl,1);
                else
                    phiv(:,kl)= (OMv(indav(kl),jjv).').*(-Yv(jjv)); %kolonnnr för Ts==0
                end
            end,
        end
        ss=nma;
        for ku=1:nu
            if fd
                if Tsdat{kexp}>0
                    indb=nkm(ku)+1:nkm(ku)+nbkm(ku);
                    if nkm(ku)==0, indb =[indb,nbkm(ku)+1];end
                else
                    indb = nbkm(ku):-1:1;
                end
                if vz
                    if Tsdatv{kexp}>0
                        indbv=nkm(ku)+1:nkm(ku)+nbkm(ku);
                    else
                        indbv = nbkm(ku):-1:1;
                    end
                end
            end
            if fd
                nnkm = 1;
                if nkm(ku)==0
                    nend = nbkm(ku)+1;
                else
                    nend = nbkm(ku);
                end
            else
                nnkm = nkm(ku);
                nend = nbkm(ku);
            end
            for kl=nnkm:nend,
                if ntz&nez
                    if fd
                        phi(:,ss+kl+1-nnkm)=(OM(indb(kl),jj).').*(U(jj,ku));
                    else
                        phi(:,ss+kl+1-nnkm)=z(jj-kl,ku+1);
                    end
                end
                if vz & ntzv & nezv
                    if fd
                        phiv(:,ss+kl+1-nnkm)=(OMv(indbv(kl),jjv).').*(Uv(jjv,ku));
                    else
                        phiv(:,ss+kl+1-nnkm)=zv(jjv-kl,ku+1);
                    end
                end
            end
            ss=ss+nend-nnkm+1;%nkm(ku)+1;
        end
        if ntz&nez
            R=R+phi'*phi;
            if fd
                F = F+phi'*YY(jj);
            else
                F=F+phi'*z(jj,1);
            end
        end
        if vz & ntzv & nezv
            Rv=Rv+phiv'*phiv;
            if fd
                Fv = Fv + phiv'*YYv(jjv);
            else
                Fv=Fv+phiv'*zv(jjv,1);
            end
        end
    end
    %
    % *** compute loss functions ***
    %
    if nezv
        v1 = v1+zv(nnm+1:Ncapv,1)'*zv(nnm+1:Ncapv,1);%??LL%%LL FD?
    end
end
V=zeros(nlorig+1,nmorig);
jj=0;
for j=1:nm
    estparno=na(j)+sum(nb(j,:));
    if estparno>0
        jj=jj+1;
        s=[1:na(j)];rs=nma;
        for ku=1:nu
            s=[s,rs+nk(j,ku)-nkm(ku)+1:rs+nb(j,ku)+nk(j,ku)-nkm(ku)];
            rs=rs+nbkm(ku)-nkm(ku)+1;
        end
        
        RR=R(s,s);
        FF=F(s);
        if vz,
            RRv=Rv(s,s);
            FFv=Fv(s);
        end
        TH=(RR\FF);
        if vz, %Don't compensate for length(parvec). That is done in AIC.
            V(1,jj)=(v1-2*FFv'*TH + TH'*RRv*TH)/(Ncapv-nmax*Ne);
        else
            V(1,jj)=(v1-FF'*TH)/(Ncap-nmax*Ne);
        end
        V(1,jj)=max(V(1,jj),eps);
        
        V(2:nlorig+1,jj)=nnorig(j,:)';
    end % if estparno>0
end;
V(1,jj+1)=sum(Ncaps)-nmax*Ne;  
V(2,jj+1)=v1/(sum(Ncapsv)-nmax*Ne);  
V=V(:,1:jj+1);
V = real(V);

