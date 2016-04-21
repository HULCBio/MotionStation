function TH=iv(data,nn,NF,MF,maxsize,Ts,p)
%IV     Computes instrumental variable estimates for single output ARX-models.
%
%   MODEL = IV(Z,NN,NF,MF)
%
%   MODEL: returned as the IV-estimate of the ARX-model 
%   A(q) y(t) = B(q) u(t-nk) + v(t)
%   along with relevant structure information. See HELP IDPOLY for
%   the exact structure of MODEL.
%
%   Z : the output-input data as a single output IDDATA object. See HELP IDDATA.  
%
%   NN: NN=[na nb nk] gives the orders and delays associated with the
%   above model.
%   NF and MF define the instruments X as
%   NF(q) x(t) = MF(q) u(t)
%   See IV4 for good, automatic choices of instruments.
%
%   MODEL = IV(Z,NN,NF,MF,maxsize)
%   allows access to some parameters associated with the algorithm.
%   See IDPROPS ALGORITHM for an explanation of these.

%   L. Ljung 10-1-86
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/04/10 23:19:03 $

if nargin<4
   disp('Model = IV(Data, Orders, Filter_den, Filter_num)')
   return
end
if nargin<7, p=1;end
if nargin<6, Ts=1;end
if nargin<5, maxsize=[];end
if isempty(Ts), Ts=1;end,
if isa(data,'iddata')
    if strcmp(lower(pvget(data,'Domain')),'frequency')
        tsdat = pvget(data,'Ts');
        ivm = idpoly(NF,MF,'ts',tsdat{1}); %%LL Different Sampling intervals?
        ivm = pvset(ivm,'InputName',pvget(data,'InputName'),...
            'OutputName',pvget(data,'OutputName'));
        xe = sim(ivm,data);
        xe = pvget(xe,'OutputData');
        TH=ivx(data,nn,xe,maxsize);
        %% Set more
        return
    end 
    end

if p==1
   if  ~isa(data,'iddata')
       ny = size(nn,1);
      data = iddata(data(:,1:ny),data(:,ny+1:end),Ts);
   end
   
   [ze,Ne,ny,nu,Ts,Name,Ncaps,errflag]=idprep(data,0,inputname(1));
   error(errflag)
else % This is a call from inival or iv
   ze = data;
   if ~iscell(ze),ze={ze};end
   Ne = length(ze);
   ny = 1;
   Ncaps =[];
   nz = size(ze{1},2);
   nu = nz-1;
   for kexp = 1:Ne
      Ncaps = [Ncaps,size(ze{kexp},1)];
   end
   
end
%% Now ze is a cell array of the type {[y u]}


%[Ncap,nz]=size(z); nu=nz-1;
na=nn(1);nb=nn(2:1+nu);nk=nn(2+nu:1+2*nu);n=na+sum(nb);
if isempty(maxsize),maxsize=idmsize(max(Ncaps),n);end

%

% *** construct instruments (see (7.111)-(7.112)) ***
for kexp = 1:Ne
   x{kexp}=zeros(Ncaps(kexp),1);
   z = ze{kexp};
   for k=1:nu
      x{kexp}=x{kexp}+filter(MF(k,:),NF,z(:,k+1));
   end
end

%
if p==1
    pp = 0;
else
    pp = p;
end
TH=ivx(ze,nn,x,maxsize,Ts,pp); % p=0 means that just the vector is returned
if p==1,
    m = idpoly;
TH = pvset(m,'na',na,'nb',nb,'nk',nk,'ParameterVector',TH,'Ts',Ts);
%%LL Set more
   es = pvget(TH,'EstimationInfo');
es.Method = 'IV';
es.Status = 'Estimated Model (IV)';
TH = pvset(TH,'EstimationInfo',es);
end
