function thd=d2caux(thc,method,varargin)
%D2CAUX Help functionto IDMODEL/D2C  

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:17:54 $

if nargin < 1
    disp('Usage: SYSD = D2C(SYSC)')
    disp('       SYSD = D2C(SYSC,METHOD)')
    disp('       METHOD is one of ''Zoh'' or ''Foh''')
    return
end
errm = sprintf(['Arguments should be D2C(M,''Covariance'',''None'')',...
        '\n or D2C(M,''InputDelay'',0) (or both).']);
nv = length(varargin);
if fix(nv/2)~=nv/2
    error(errm);
end
delays = 1;
cov = 1;
for kk = 1:2:nv
    if ~ischar(varargin{kk})
        error(errm)
    elseif lower(varargin{kk}(1))=='c'
        if lower(varargin{kk+1}(1))=='n'
            cov = 0;
            thc = pvset(thc,'CovarianceMatrix','None');
        end
    elseif lower(varargin{kk}(1))=='i'
        if varargin{kk+1}(1)==0
            delays = 0;
        end
    else
        error(errm)
    end
end
P = pvget(thc,'CovarianceMatrix');
if ischar(P)|isempty(P)
    cov = 0;
end
Inpd = pvget(thc,'InputDelay');
Told = pvget(thc.idmodel,'Ts'); 
if Told==0,
    error('This model is already  continuous-time!')
end
utflag = 0;
if  strcmp(thc.SSParameterization,'Free')
    % In this case Pmodel has no value, since it will loose its
    % covarianceinformation. Instead create Idpoly, if neccessary,
    % unless covariance = 'none'
    setcov(thc);
    ut = pvget(thc,'Utility');
    utflag = 1;
    try
        ut.Pmodel = [];
        thc = pvset(thc,'Utility',ut);
    end
end
lamscale = Told; 
[ny,nu] = size(thc);
p = pvget(thc.idmodel,'ParameterVector');
covp = pvget(thc.idmodel,'CovarianceMatrix');
lam = pvget(thc.idmodel,'NoiseVariance');
nk = pvget(thc,'nk');
if isempty(nk)
    delays = 0;
end

if delays&any(nk>1)
    nknew = nk>=1;
    thc = pvset(thc,'nk',nknew);
    adjnk = nk-nknew;
else
    adjnk = zeros(1,nu);
end
[A,B,C,D,K,X0]=ssdata(thc); 
nx = size(A,1);
[ny,nu] = size(D);
[A,B,Cc,D,K,Ls] = idsample(A,B,C,D,K,Told,method(1),0);
thd = pvset(thc,'SSParameterization','Free');
if norm(D)>0
    thd=pvset(thd,'Ds',NaN*ones(size(D)));
end
thd = pvset(thd,'A',A,'B',B,'C',C,'D',D,'K',K,'NoiseVariance',lamscale*Ls*lam*Ls',...
    'Ts',0,'CovarianceMatrix',[],...
    'InputDelay',Told*(adjnk+Inpd'));
if utflag
    thd = uset(thd,ut);
end
if strcmp(thc.SSParameterization,'Canonical')
    thd = pvset(thd,'SSParameterization','Canonical');
end

%%%% Now for the hidden models

thd = sethidmo(thd,'d2c',varargin{:});
