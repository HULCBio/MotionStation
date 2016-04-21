function sys = pvset(sys,varargin)
%PVSET  Set properties of IDPOLY models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.20.4.1 $ $Date: 2004/04/10 23:18:00 $


[a,b,c,d,f]=polydata(sys); % check

nu = size(b,1);
if any(sys.nb>0)&isempty(b)
    b=zeros(nu,max(sys.nb));
end
   
abcdf = zeros(1,6);  % keeps track of which state-space matrices are reset
nabcdfk = zeros(1,6);
parflag = 0; 
covflag = 0;
tsflag = 0;
ni=length(varargin);
IDMProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the LTI parent

for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property      
    case 'na' 
        if fix(Value)~=Value|Value<0|length(Value)>1
            error('''na'' must be a non-negative integer.')
        end
        
        sys.na = Value;
        nabcdfk(1)=1;
    case 'nb' 
        if ~all(fix(Value)==Value)|any(Value<0)
            error('''nb'' must be a vector of non-negative integers.')
        end
        if size(Value,1)>1
            error('''nb '' must be a row vector.')
        end
        %Value = Value(:).';
        sys.nb = Value;
        nabcdfk(2)=1;
    case 'nc' 
        if fix(Value)~=Value|Value<0|length(Value)>1
            error('''nc'' must be a non-negative integer.')
        end
        
        sys.nc = Value;
        nabcdfk(3)=1;
    case 'nd' 
        if fix(Value)~=Value|Value<0|length(Value)>1
            error('''nd'' must be a non-negative integer.')
        end
        
        sys.nd = Value;
        nabcdfk(4)=1;
    case 'nf' 
        if ~all(fix(Value)==Value)|any(Value<0)
            error('''nf'' must be a vector of non-negative integers.')
        end
        if size(Value,1)>1
            error('''nf'' must be a row vector.')
        end
       % Value = Value(:).';
        sys.nf = Value;
        nabcdfk(5)=1;
    case 'nk'
        if ~all(fix(Value)==Value)|any(Value<0)
            error('''nk'' must be a vector of non-negative integers.')
        end
        Value = Value(:).';
        
        sys.nk=Value;
        nabcdfk(6)=1;
    case 'a'
        a = Value;
        abcdf(1) = 1;
    case 'b'
        b = Value;
        abcdf(2) = 1;
    case 'c'
        c = Value;
        abcdf(3) = 1;
    case 'd'
        d = Value;
        abcdf(4) = 1;
    case 'f'
        f = Value;
        abcdf(5) = 1;
    case {'da','db','dc','dd','df'}
        error('Standard deviations cannot be set. Use CovariaceMatrix.')
    case 'InitialState'
        PossVal = {'Estimate';'Zero';'Fixed';'Backcast';'Auto'};
        try
            Value = pnmatchd(Value,PossVal,2);
        catch
            disp('Invalid property for ''InitialState''')
            error(['Should be one of ''Estimate|Zero|Fixed|Backcast|Auto'''])
        end
        
        sys.InitialState = Value;
        
    case 'ParameterVector',
        Value=Value(:);
        sys.idmodel=pvset(sys.idmodel,'ParameterVector', Value);
        parflag=1;                       
        
    case 'idmodel'
        sys.idmodel = Value;
        
    otherwise
        IDMProps([i i+1]) = 1;
        varargin{i} = Property;
        if strcmp(Property,'CovarianceMatrix')
            covflag = 1;
        end
        if strcmp(Property,'Ts');
            
            tsold = pvget(sys,'Ts');
            tsnew = varargin{i+1};
            if (tsold>0&tsnew==0)|(tsold==0&tsnew>0)
                tsflag =1; %then we need to recompute orders
            end
        end
    end %switch
    
end % for
IDMProps = find(IDMProps);
if ~isempty(IDMProps)
    sys.idmodel = pvset(sys.idmodel,varargin{IDMProps});
end

sys = timemark(sys);
if ~any([nabcdfk,abcdf,parflag,tsflag])
    sys.idmodel = idmcheck(sys.idmodel,[1,nu]);
    return
end
Est=pvget(sys.idmodel,'EstimationInfo');
if strcmp(Est.Status(1:3),'Est')  
    Est.Status='Model modified after last estimate';
    sys.idmodel=pvset(sys.idmodel,'EstimationInfo',Est);
end

%
if parflag
    nn = length(pvget(sys.idmodel,'ParameterVector'));
    if nn~=sum([sys.na sys.nb sys.nc sys.nd sys.nf])
        error('The length of the ParameterVector is not consistent with model orders')
    end
end

if nabcdfk(2)
    if isempty(sys.nf),sys.nf=zeros(size(sys.nb));end
    if isempty(sys.nk),sys.nk=ones(size(sys.nb));end
end

nu1 = size(sys.nb,2); nu2 = size(sys.nk,2); nu3 = size(sys.nf,2);
if ~all(nu1 == [nu2 nu3])
    error('nb, nf, and nk must all be the same size, 1-by-nu.')
end
nu = nu1;



if ~isempty(pvget(sys.idmodel,'ParameterVector'))&~parflag
    if any(nabcdfk)
        abcdf(1)=1; 
        if nabcdfk(6)&pvget(sys,'Ts')==0
            error('''nk'' cannot be set for time-continuous models.')
        end
        if nabcdfk(1)
            a = ordmod(a,sys.na,1);
        end
        if nabcdfk(2)|nabcdfk(6)
            b = ordmod(b,sys.nb,0,sys.nk);
        end
        if nabcdfk(3)
            c = ordmod(c,sys.nc,1);
        end
        if nabcdfk(4)
            d = ordmod(d,sys.nd,1);
        end
        if nabcdfk(5)
            f = ordmod(f,sys.nf,1);
        end
    end
end



if any(abcdf)&parflag
    
    error('Cannot change both ParameterVector and polynomials')
end
if any(abcdf)|(tsflag&~isempty(pvget(sys.idmodel,'ParameterVector')))
    npar = length(pvget(sys.idmodel,'ParameterVector'));
    [na,nb,nc,nd,nf,nk,par,nu] = polychk(a,b,c,d,f,[],sys.idmodel.Ts);
    
    sys.na = na; sys.nb = nb; sys.nc = nc;
    sys.nd = nd; sys.nf = nf; sys.nk = nk;
    % $$$    cov = pvget(sys.idmodel,'CovarianceMatrix');
    % $$$    if size(cov,1)~=length(par)
    % $$$        if covflag
    % $$$            error(sprintf(['You cannot change the size of the ParameterVector and set the',...
    % $$$                    '\nCovarianceMatrix at the same time.']))
    % $$$        end
    % $$$        if ~isempty(cov)
    % $$$            warning('CovarianceMatrix has been set to the empty matrix.')
    % $$$        end
    sys.idmodel=pvset(sys.idmodel,'ParameterVector',par);
    if npar~=length(par)
        sys.idmodel=pvset(sys.idmodel,'CovarianceMatrix',[]);
    end
    
end
sys.idmodel = idmcheck(sys.idmodel,[1,nu]);
 
%% FUNCTION ORDMOD

function p = ordmod(p1,np,stab,nk)   
if nargin==3
    nk=[];
end
if isempty(p1),
    if isempty(nk)
        p1=zeros(size(np,2),0);
    else
        p1=1;   
    end
end

nr=size(p1,1);
for kk=1:nr
    pol = p1(kk,:);
    if ~isempty(nk)
        %strip leading and trailing zeros
        polnr = find(pol~=0);
        polst = pol(min(polnr):max(polnr));%pol(find(pol~=0));
        np1=length(polst);
        if np1>np(kk)
            po = polst(1:np(kk));
            if stab,po=fstab(po);end
        elseif np1<np(kk)
            po = [polst,eps*ones(1,np(kk)-np1)];%[pol,eps*ones(1,np(kk)-np1)];
        else
            po = polst(1:np(kk));
        end
        po = [zeros(1,nk(kk)),po];
    else
        np1=length(pol)-1;
        
        if np1>np(kk)
            po = pol(1:np(kk)+1);
            if stab,po=fstab(po);end
        else 
            po = [pol,eps*ones(1,np(kk)-np1)];
        end
    end    
    p(kk,1:length(po))=po;
end





