function [th,ref]=ar(data,n,varargin)
%AR   Computes AR-models of signals using various approaches.
%   Model = AR(Y,N)  or  TH = AR(Y,N,Approach)  or TH = AR(Y,N,Approach,Win)
%
%   Model: returned as an IDPOLY model with the estimated parameters of the
%          AR-model, see HELP IDPOLY.
%
%   Y: The time series to be modelled, an IDDATA object. (See HELP IDDATA)
%   N: The order of the AR-model
%   Approach: The method used, one of the following ones:
%      'fb' : The forward-backward approach (default)
%      'ls' : The Least Squares method
%      'yw' : The Yule-Walker method
%      'burg': Burg's method
%      'gl' : A geometric lattice method
%      For the two latter ones, reflection coefficients and loss functions
%      are returned in REFL by [Model,REFL] = AR(y,n,approach)
%   Win : Windows employed, one of the following ones:
%      'now' : No windowing (default, except when approach='yw')
%      'prw' : Prewindowing
%      'pow' : Postwindowing
%      'ppw' : pre- and post-windowing
%
%   The Property/Value pairs 'MaxSize'/maxsize and 'Ts'/Ts can be added to
%   set the MaxSize property (see also IDPROPS ALG) and to override the sampling
%   interval of the data: Example: Model = AR(Y,N,Approach,'MaxSize',500).
%   The Property/Value pair 'CovarianceMatrix'/'None' will suppress the
%   calcualtion of the covariance matrix.
%
%   See also IVAR and for the multi-output case ARX and N4SID.

%   L. Ljung 10-7-87
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/04/10 23:18:49 $


if nargin <2
    disp('Usage: TH = AR(Y,ORDER)')
    disp('       TH = AR(Y,ORDER,APPROACH,WINDOW)')
    disp('       APPROACH is one of ''fb'', ''ls'', ''yw'', ''burg'', ''gl''.')
    disp('       WINDOW is one of ''now'', ''prw'', ''pow'', ''ppw''.')
    return
end
ref = [];
maxsize = 'auto';
T = 1;
approach = 'fb';
win = 'now';
pt = 1;
Tflag = 0;
% Some initial tests on the input arguments
indc = 1;
list = {'Maxsize','Ts','fb','ls','yw','burg','gl','now',...
        'prw','pow','ppw','CovarianceMatrix','None','Estimate'};
while indc<=length(varargin)
    arg = varargin{indc};
    if ischar(arg)
        if arg(end)=='0'
            pt = 0;
            arg=arg(1:end-1);
        end
        try
            [prop,im] = pnmatchd(arg,list,7,0);
        catch
            error(lasterr)
        end
        if im==1
            maxsize = varargin{indc+1};
            indc = indc+1;
        elseif im==2
            T = varargin{indc+1};
            indc=indc+1;
            Tflag = 1;
        elseif im<8
            approach = prop;
        elseif im < 12
            win = prop;
        elseif im == 13
            pt = 0;
        end
            
    elseif indc == 3
        maxsize = varargin{indc};
    elseif indc==4
        T = varargin{indc};
        Tflag = 1;
    end
    indc=indc+1;
end
pt1 = pt;
errn=0;
if ~isa(n,'double')
    errn=1;
elseif n~=fix(n)|n<=0|~isreal(n)
    errn=1;
end

if errn
    error('The order, n, must be a positive integer.')
end
if isa(data,'frd')|isa(data,'idfrd')|(isa(data,'iddata')&strcmp(pvget(data,'Domain'),'Frequency'))
error('For frequency domain data, use ARX instead of AR.')
end

if ~isa(data,'iddata')
    [N,ny]=size(data);
    if min(N,ny)~=1
    error('AR only handles single output time series.')
end
if N<ny
    data = data';
end
data = iddata(data,[],T);
end
if Tflag, data = pvset(data,'Ts',T);end
[yor,Ne,ny,nu,T,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
error(errflag)
y = yor; % Keep the original y for later computatation of e
if ny>1
    error('Only scalar time series can be handled. Use ARX for multivariate signals.')
end
if nu>0
    error('This routine is for scalar time series only. Use ARX for the case with input.')
end
maxsdef=idmsize(max(Ncaps),n);
if isempty(maxsize)|ischar(maxsize), 
    maxsize=maxsdef;
    maxs = 1;
else
    maxs = 0;
end

if strcmp(approach,'yw') 
    win='ppw';
end
if win=='prw' | win=='ppw',
    for kexp = 1:Ne
        y{kexp}=[zeros(n,1);y{kexp}];
    end
    Ncaps = Ncaps+n;
end
if win=='pow' | win=='ppw',
    for kexp =1:Ne
        y{kexp} = [y{kexp};zeros(n,1)];
    end
    Ncaps = Ncaps+n;
    
end
th = idpoly;
if maxs
    Max = 'auto';
else
    Max = maxsize;
end
th = pvset(th,'MaxSize',Max);
% First the lattice based algorithms

if any(strcmp(approach,{'burg','gl'})) 
    ef=y;eb=y;
    [ss,l]=sumcell(y,1,Ncaps);rho(1)=ss/l;
    for p=1:n
        nef = sumcell(ef,p+1,Ncaps);  
        neb=sumcell(eb,p,Ncaps-1); 
        if strcmp(approach,'gl')
            den=sqrt(nef*neb);
        else
            den=(nef+neb)/2;
        end
        ss=0;
        for kexp=1:Ne
            ss=ss+(-eb{kexp}(p:Ncaps(kexp)-1)'*ef{kexp}(p+1:Ncaps(kexp)));
        end
        
        r(p)=ss/den; 
        A(p)=r(p);
        A(1:p-1)=A(1:p-1)+r(p)*conj(A(p-1:-1:1));
        rho(p+1)=rho(p)*(1-r(p)*r(p));
        efold=ef;
        for kexp = 1:Ne
            Ncap = Ncaps(kexp);
            ef{kexp}(2:Ncap)=ef{kexp}(2:Ncap)+r(p)*eb{kexp}(1:Ncap-1);
            eb{kexp}(2:Ncap)=eb{kexp}(1:Ncap-1)+conj(r(p))*efold{kexp}(2:Ncap);
        end
    end
    th = pvset(th,'a',[1 A]);
    ref=[0 r;rho];
else
    pt1 = 1; %override pt for the other appoaches
    
end
% Now compute the regression matrix
if pt1
    nmax=n;
    M=floor(maxsize/n);
    R1 = zeros(0,n+1);
    fb=strcmp(approach,'fb');
    if strcmp(approach,'fb')
        R2 = zeros(0,n+1);
        for kexp = 1:Ne
            yb{kexp}=conj(y{kexp}(Ncaps(kexp):-1:1));
        end
    end
    for kexp = 1:Ne
        Ncap = Ncaps(kexp);
        yy = y{kexp};
        for k=nmax:M:Ncap-1
            jj=(k+1:min(Ncap,k+M));
            phi=zeros(length(jj),n);
            if fb,
                phib=zeros(length(jj),n);
            end
            for k=1:n,
                phi(:,k)=-yy(jj-k);
            end
            if fb
                for k=1:n,
                    phib(:,k)=-yb{kexp}(jj-k);
                end
            end
            if fb,
                R2 = triu(qr([R2;[[phi;phib],[yy(jj);yb{kexp}(jj)]]]));
                [nRr,nRc] =size(R2);
                R2 = R2(1:min(nRr,nRc),:);
            end
            R1 = triu(qr([R1;[phi,yy(jj)]]));
            [nRr,nRc] =size(R1);
            R1 = R1(1:min(nRr,nRc),:);
            %end
        end
    end
    P = pinv(R1(1:n,1:n));
    
    if ~any(strcmp(approach,{'burg','gl'}))%appr~='bu' & appr~='gl'
        if ~fb
            t = P * R1(1:n,n+1);%R\F;
        else
            t = pinv(R2(1:n,1:n)) * R2(1:n,n+1);
        end
        th = pvset(th,'a',[1 t.']);
    end
    P = P*P';
else
    P = [];
end
if ~pt
    P = [];
end
e = pe(yor,th);
lam=e'*e/(length(e)-n);
es = pvget(th,'EstimationInfo');
es.FPE = lam*(1+n/sum(Ncaps))/(1-n/sum(Ncaps));
es.Status = 'Estimated Model (AR)';
es.Method = ['AR (''',approach,'''/''',win,''')'];
es.DataLength = sum(Ncaps);
es.LossFcn = lam;
es.DataTs = T;
es.DataName = Name;
es.DataInterSample = 'Not Applicable';
idm=pvget(th,'idmodel'); 
idm=pvset(idm,'Ts',T,'CovarianceMatrix',lam*P,'NoiseVariance',lam,...
    'EstimationInfo',es,...
    'OutputName',pvget(data,'OutputName'),'OutputUnit',...
    pvget(data,'OutputUnit'));
th = pvset(th,'idmodel',idm); 
th = timemark(th);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [s,ln] = sumcell(y,p,N)
ln = 0;
s = 0;
for kexp = 1:length(y)
    y1 = y{kexp};
    s=s+y1(p:N(kexp))'*y1(p:N(kexp));
    ln = ln + length(y1); 
end
