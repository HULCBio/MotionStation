function m=ivx(data,nn,xe,maxsize,Tsamp,p)
%IVX    Computes instrumental variable estimates for ARX-models.
%
%   MODEL = IVX(Z,NN,X)
%
%   MODEL: returned as the IV-estimate of the ARX-model
%   A(q) y(t) = B(q) u(t-nk) + v(t)
%   along with relevant structure information. See HELP IDPOLY for
%   the exact structure of MODEL.
%
%   Z : the output-input data as an IDDATA objcet. See HELP IDDATA.
%
%   NN: NN=[na nb nk] gives the orders and delays associated with the
%   above model.
%   X : is the vector of instrumental variables. This should be of the
%   same size as the y-vector (i.e. Z.y). So if Z contains several
%   experiments, X must be a cellarray with as many signals as there are
%   experiments.
%
%   See IV4 for good, automatic choices of instruments.
%   A multioutput variant is given by IDARX/IVX
%
%   TH=ivx(Z,NN,X,maxsize) makes certain that no matrix with more than
%   maxsize elements is formed by the algorithm.

%   L. Ljung 10-1-86, 4-12-87
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/10 23:19:06 $

%
% *** Some initial tests on the input arguments ***
%

if nargin<6, p=1;end
if nargin<5, Tsamp=1;end
if nargin<4, maxsize=[];end
if maxsize<0,maxsize=[];end
if Tsamp<0,Tsamp=1;end
if p<0,p=1;end
if isempty(Tsamp),Tsamp=1;end,
ny=size(nn,1);
nr=ny;
if ~iscell(xe)
    xe={xe};
end
if p==1&isa(data,'iddata')
    try
        [mdum,data,p,fixflag,fixp] = arxdecod(data,nn);
    catch
        error(lasterr)
    end
    if size(mdum,'ny')>1
        m = ivx(data,mdum,xe,maxsize,Tsamp,p)
        return
    end
end
if isa(data,'frd')|isa(data,'idfrd')
    data = iddata(idfrd(data));
end
if isa(data,'iddata')
    if strcmp(lower(pvget(data,'Domain')),'frequency')
        nu = size(data,'nu');
        tsdat = pvget(data,'Ts');
        [a,b,cov]=ivx_f(data,xe,nn(1),nn(2:nu+1),nn(nu+2:2*nu+1),maxsize);
        m = idpoly(a,b,'Ts',tsdat{1});
        was = warning;
        warning off
        e = pe(data,m,'e');
        warning(was)
        ey = pvget(e,'OutputData');
        ey = cat(1,ey{:});
        loss = ey'*ey;
        V = loss/length(ey);

        nv = loss/(length(ey)-length(pvget(m,'ParameterVector')));
        idm = pvget(m,'idmodel');
        idm = idmname(idm,data);
        m = pvset(m,'NoiseVariance',nv,'CovarianceMatrix',V*cov,'idmodel',idm);
        return

    end
end
if p==1
    if  ~isa(data,'iddata')
        data = iddata(data(:,1:ny),data(:,ny+1:end),Tsamp);
    end

    [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
    error(errflag)
else % This is a call from inival or iv
    ze = data;
    if ~iscell(ze),ze={ze};end
    Ne = length(ze);
    if length(xe)~=Ne
        error('The number of experiment in the data set must match the number of cells in x.')
    end

    ny = 1;
    Ncaps =[];
    nz = size(ze{1},2);
    nu = nz-1;
    for kexp = 1:Ne
        [Nc,nx] = size(xe{kexp});
        Ncaps = [Ncaps,size(ze{kexp},1)];
        if Ncaps(kexp)~=Nc | nx~=1,
            error('The x-vector should be a column vector with the same number of elements as z!')
        end

    end

end
%
[nnr,nnc]=size(nn);
maxsdef=idmsize(max(Ncaps));


if isempty(maxsize),maxsize=maxsdef;end
if nr>1, %multioutput case
    th = idarx;
    ny = nr; nu = (nc-nr)/2;
    th = llset(th,{'na','nb','nk'},{nn(:,1:ny),nn(:,ny+1:ny+nu),...
        nn(:,ny+nu+1:end)});
    m = ivx(data,th,xe,maxsize,Tsamp,p);
    return,
end
if length(nn)~=1+2*nu,disp('Incorrect number of orders specified!'),
    disp('nn should be nn=[na nb nk]'),
    disp('where nb and nk are row vectors of length equal to the number of inputs'),error('see above'),return,end
na=nn(1);nb=nn(2:1+nu);nk=nn(2+nu:1+2*nu);n=na+sum(nb);
%
% construct regression matrix
%
nmax=max([na+1 nb+nk])-1;
M=floor(maxsize/n);
Rxx=zeros(na);Ruu=zeros(sum(nb));Rxu=zeros(na,sum(nb));Rxy=zeros(na);
Ruy=zeros(sum(nb),na); F=zeros(n,1);
for kexp=1:Ne
    z = ze{kexp};
    x = xe{kexp};
    Ncap = Ncaps(kexp);
    for k=nmax:M:Ncap-1
        jj=(k+1:min(Ncap,k+M));
        phix=zeros(length(jj),na); phiy=phix; phiu=zeros(length(jj),sum(nb));
        for kl=1:na, phiy(:,kl)=-z(jj-kl,1); phix(:,kl)=-x(jj-kl); end
        ss=0;
        for ku=1:nu
            for kl=1:nb(ku), phiu(:,ss+kl)=z(jj-kl-nk(ku)+1,ku+1);end
            ss=ss+nb(ku);
        end
        Rxy=Rxy+phix'*phiy;
        if nu>0,Ruy=Ruy+phiu'*phiy;
            Rxu=Rxu+phix'*phiu;
            Ruu=Ruu+phiu'*phiu;
        end
        Rxx=Rxx+phix'*phix;
        if na>0, F(1:na)=F(1:na)+phix'*z(jj,1);end
        F(na+1:n)=F(na+1:n)+phiu'*z(jj,1);
    end
end
clear phiu, clear phix, clear phiy,
%
% compute estimate
%
if nu==0,TH=pinv(Rxy)*F;end
if nu>0,TH=pinv([Rxy Rxu;Ruy Ruu])*F;end
if p==0, m=TH; return,end
%
% proceed to build up THETA-matrix
%
m = idpoly;
m=llset(m,{'na','nb','nk','nf','nc','nd'},{na,nb,nk,zeros(size(nb)),0,0});
m=parset(m,TH);


%
% build up the theta-matrix
%
e=pe(ze,m,'z');
V=e'*e/(length(e)-nmax);%%LL%% Check what we should divide by
try
    cov=V*pinv([Rxx Rxu;Rxu.' Ruu]);
catch
    disp('Numerical difficulties: No covariance matrix computed.')
    cov=[];
end

if p==2 % internal call from iv4
    m1.model=m;
    m1.cov=cov;
    m1.V = V;
    m=m1;
else
    idm = pvget(m,'idmodel');
    it_inf = pvget(idm,'EstimationInfo');
    it_inf.DataLength=Ncap;
    it_inf.DataTs=data.Ts;
    it_inf.DataInterSample=data.InterSample;%'Zero order hold';
    it_inf.Status='Estimated model (IVX)';
    it_inf.Method = 'IVX';
    it_inf.DataName=Name;
    it_inf.LossFcn = V;
    it_inf.FPE = V*(1+length(TH)/sum(Ncaps))/(1-length(TH)/sum(Ncaps));
    idm = pvset(idm,'ParameterVector',TH,'MaxSize',maxsize,'CovarianceMatrix',cov,...
        'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',V);%'InputName',...
    idm = idmname(idm,data);
    m = llset(m,{'idmodel'},{idm});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b,cov] = ivx_f(data,YHd,na,nb,nk,maxsize)
realflag = realdata(data);
nm = max([na,nb+nk-1]);
nu = length(nb);
n1 = na + sum(nb);
Yc = pvget(data,'OutputData');
Uc = pvget(data,'InputData');
Wc = pvget(data,'Radfreqs');
if isa(YHd,'iddata')
    YHc = pvget(YHd,'OutputData');
else
    YHc = YHd;
end
R=0;Re=0;Rc = 0;
Tc = pvget(data,'Ts');
if isempty(maxsize)|ischar(maxsize) % safety
    maxsize = idmsize;
end
M = floor(maxsize/(nm+1));

for kexp = 1:length(Yc)

    Y1 =Yc{kexp};
    YH1 = YHc{kexp};
    U1 = Uc{kexp};
    w1 = Wc{kexp};
    T = Tc{kexp};
    N = size(Y1,1);
    for kM = 1:M:N
        jj=[kM:min(N,kM-1+M)];
        Y =Y1(jj,:);
        YH = YH1(jj,:);
        U = U1(jj,:);
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
            Rc = Rc + real([DH Db]'*[DH Db]);
            Re = Re + real([DH Db]'*YY);
        else
            R = R + [DH Db]'*[D Db];
            Rc = Rc + [DH Db]'*[DH Db];
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

try
    cov=pinv(Rc);
catch
    disp('Numerical difficulties: No covariance matrix computed.')
    cov=[];
end
