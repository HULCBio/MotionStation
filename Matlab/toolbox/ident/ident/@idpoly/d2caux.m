function thc=d2caux(th,inters,varargin)
%D2CAUX Help function to IDMODEL/D2C 

%   L. Ljung 10-1-86,4-20-87,8-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $ $Date: 2004/04/10 23:16:28 $

if nargin < 1
    disp('Usage: MC = D2C(MD)')
    disp('       MC = D2C(MD,''InputDelay'',0,''Covariance'',''None'')')    
    return
end
if nargin==1;
    inters = 'zoh';
end
T=pvget(th.idmodel,'Ts');
dif=[];
if T==0, error('This model is already  continuous time!'),end
[ny,nu]=size(th);
na=th.na;nb=th.nb;nc=th.nc;nddd=th.nd;nf=th.nf;
nk=th.nk;
errm = sprintf(['Arguments should be D2C(M,''Covariance'',''None'')',...
        '\n or D2C(M,''InputDelay'',0) (or both).']);
nv = length(varargin);
if fix(nv/2)~=nv/2
    error(errm);
end
delays = 1;
cov = 1;
noisenorm = 1;
for kk = 1:2:nv
    if ~ischar(varargin{kk})
        error(errm)
    elseif lower(varargin{kk}(1))=='c'
        if lower(varargin{kk+1}(1))=='n'
            cov = 0;
        end
    elseif lower(varargin{kk}(1))=='i'
        if varargin{kk+1}(1)==0
            delays = 0;
        end
    else
        error(errm)
    end
end
ndd=na+sum(nb)+nc+nddd+sum(nf);
par=pvget(th.idmodel,'ParameterVector');
P=pvget(th.idmodel,'CovarianceMatrix');
if ischar(P) || norm(P)==0 || isempty(P) || ~cov, 
    nkder=0;
else 
    nkder=[0:ndd];
end
dt=nuderst(par');
th1=th;
if isempty(th.nb)&th.nd>0 % This is an 'unorthodox' ARMA. Will be converted to a real one.
    th = pvset(th,'a',conv(pvget(th,'a'),pvget(th,'d')),'d',1);
end
armax = (sum(th.nf)+th.nd == 0);
oe = (th.na+th.nc+th.nd ==0);
ccnew=1;
ddnew=1;
lam = pvget(th.idmodel,'NoiseVariance');
if isempty(lam)|norm(lam)==0
    lam = 0;
else
    lam = 1;
end
was = warning;
for kder = nkder
    par1 = par;
    if kder>0
        par1(kder)=par(kder)+dt(kder);
        th1 = parset(th1,par1);
    end
    if armax
        if delays
            th1.nk = (nk>0);
        end
        [A,B,C,D,K] = ssdata(th1);
        if kder==0
            ei = eig(A);
            if any(abs(ei)<eps), 
                warning('Pole in the origin. Result may be unreliable.'),
            end
            
            if any(abs(ei-1))<eps 
                warning('Pure integration. Result may be unreliable.'),
            end
            if any((ei==real(ei)) & (real(ei)<0)),
                warning('Pole on the negative real axis. Result may be unreliable.'),
            end
            warning off
        end
        nx = size(A,1); nu = size(B,2); nz = 1+nu;
        [Ac,Bc,Cc,Dc,Kc,noisenorm] = idsample(A,B,C,D,K,T,inters,0);
        ff=poly(Ac); 
        thb = [];
        if nu==0,nbn = zeros(1,0);end
        nkn=[];
        for ku =1:nu
            % Transform to i/o form
            bb=poly(Ac-Bc(:,ku)*C)+(Dc(1,ku)-1)*ff;
            
            if Dc(1,ku)==0,bb=bb(2:length(bb));nkn(ku)=1;else nkn(ku)=0;end 
            nbn(ku) = length(bb);
            thb = [thb bb];     
        end
        if lam
            cc = poly(Ac-Kc*C);
            cc = cc(2:end);
        else
            cc = zeros(1,0);
        end
        thh = [ff(2:end) thb cc];
    else % not armax
        [a,b,c,d,f]=polydata(th1);
        ss=1;
        thb=[];thcc=[];thd=[];thf=[];ncn=0;ndn=0;
        b(nu+1,1:length(c))=c;
        f(nu+1,1:length(d))=d;
        nk(nu+1)=0;nb(nu+1)=nc+1;nf(nu+1)=nddd;
        if oe
            list = [1:nu];
            ncn = 0; ndn = 0;
        else
            list =[nu+1,1:nu];
        end
        for k = list
            den=conv(a,f(k,1:nf(k)+1));
            if delays~=0,
                nkmod = max(nk(k),1);
            else 
                nkmod = 1;
            end
            num=b(k,nkmod:nb(k)+nk(k));
            nd=length(den);, nn=length(num);
            n=max(nd,nn);
            de=zeros(1,n);, de(1:nd)=den;
            if kder==0
                if abs(de(n))<eps, 
                    warning('Pole in the origin. Result may be unreliable.'),
                end
                rp=roots(de);
                if any(abs(rp-1))<eps 
                    warning('Pure integration. Result may be unreliable.'),
                end
                if any((rp==real(rp)) & (real(rp)<0)),
                    warning('Pole on the negative real axis. Result may be unreliable.'),
                end
            end
            nume=zeros(1,n);, nume(1:nn)=num;
            A=[-de(2:n);eye(n-2,n-1)]; % Transform to state-space
            B=eye(n-1,1);
            C=nume(2:n)-nume(1)*de(2:n);
            D=nume(1);
            
            [Ac,Bcc,Cc,D] = idsample(A,B,C,D,zeros(n-1,0),T,inters,0);
             ff=poly(Ac);                % Transform to i/o form
            bb=poly(Ac-Bcc*C)+(D-1)*ff;
            bb1{k}=bb;
            ff1{k}=ff;
            if D==0
                bb=bb(2:length(bb));nkn(ss)=1;
            else 
                if k==nu+1
                    noisenorm = bb(1);
                    bb=bb/bb(1); %noise normalization
                    bbl{k}=bb;
                end
                nkn(ss)=0;
            end
            if k<nu+1,
                nbn(ss)=length(bb);nfn(ss)=length(ff)-1;ss=ss+1;
                thb=[thb bb]; thf=[thf ff(2:length(ff))];
                
            end
            if k==nu+1,
                ncn=length(bb)-1;ndn=length(ff)-1;
                thcc=bb(2:length(bb)); thd=ff(2:length(ff));
                ccnew = bb; ddnew=ff;
            end
            
        end
        thh=[thb thcc thd thf];
    end
    
    
    if kder==0,
        
        thc=th;
        thc.idmodel=pvset(thc.idmodel,'Ts',0);
        thc.idmodel = pvset(thc.idmodel,'NoiseVariance',pvget(th,'NoiseVariance')*T*noisenorm^2);
        if armax
            thc.na = length(ff)-1;
            thc.nb = nbn;
             thc.nc = length(cc);
             nknew = (nkn>0); thc.nk = nknew(1:nu); 
        thc = parset(thc,thh.');
        else
            % First sort out the orders, so as to construct b and f.
            b = zeros(nu,max(nbn+nkn));
            f = zeros(nu,max(nfn)+1);
            for k = 1:nu
                b(k,end-length(bb1{k})+1:end)=bb1{k};
                f(k,end-length(ff1{k})+1:end)=ff1{k};
            end
            thc = pvset(thc,'a',1,'b',b,'c',ccnew,'d',ddnew,'f',f);
        end
       
        if delays & nu>0 
            del = pvget(th,'InputDelay')'; %add zeo to del, since noise is an extra input
            if length(nk) == length(del)+1
                del = [del 0];
            end
            nk1=(max(nk,1)-1)*T + del*T; 
            thc = pvset(thc,'InputDelay',nk1(1:nu)');            
        end
        thh0=thh;
    else
        dif(:,kder)=(thh-thh0)'/dt(kder);
    end
end
warning(was)
if ~isempty(dif),
    Pc=dif*P*dif';
else 
    Pc=[]; 
end
try % It may happen that the parameter dimension drops
thc.idmodel = pvset(thc.idmodel,'CovarianceMatrix',Pc);
end

