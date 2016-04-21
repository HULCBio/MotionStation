function sys = pvset(sys,varargin)
%PVSET  Set properties of IDSS models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.23.4.2 $ $Date: 2004/04/10 23:18:13 $


try
    [a,b,c,d,k,x0]=ssdata(sys); 
catch
    a=[];b=[];c=[];d=[];k=[];x0=[];
end

[nx,nu] = size(b);
abcdkx = zeros(1,6);  % keeps track of which state-space matrices are reset
nabcdkx = zeros(1,6);
inn = zeros(1,3);
parflag = 0; 
sspchange=0;
oldsspar = [];
oldssp = sys.SSParameterization;
canflag = 0;
ni=length(varargin);
IDMProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the IDMODEL parent
is = [];
nm = [];
nk = [];

for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property      
        case 'As' 
            sys.As = Value;
            nabcdkx(1)=1;
        case 'Bs' 
            sys.Bs = Value;
            nabcdkx(2)=1;
        case 'Cs' 
            sys.Cs= Value;
            nabcdkx(3)=1;
        case 'Ds' 
            sys.Ds = Value;
            nabcdkx(4)=1;
        case 'Ks' 
            sys.Ks = Value;
            nabcdkx(5)=1;
        case 'X0s'
            sys.X0s=Value;
            nabcdkx(6)=1;
        case 'StateName'
            stn= idnamchk(Value,'StateName');
            sys.StateName = stn;
            ut = pvget(sys,'Utility');
            try
                ut.Pmodel = pvset(ut.Pmodel,'StateName',stn);
                sys = uset(sys,ut);
            end
        case {'dA','dB','dC','dD','dK','dX0'}
            error('Standard deviations cannot be set. Use Covariance Matrix.')
        case 'idmodel'
            sys.idmodel=Value;
        case 'SSParameterization'
            PossVal = {'Free';'Structured';'Canonical'};
            try
                Value = pnmatchd(Value,PossVal,2);
            catch
                disp('Invalid property for ''SSParameterization''')
                error('Should be one on [''Free'',''Canonical'',''Structured'']')
            end
            oldsspar = sys.SSParameterization;
            sys.SSParameterization = Value;
            sspchange = 1; 
        case 'A'
            a = Value;
            abcdkx(1) = 1;
        case 'B'
            b = Value;
            abcdkx(2) = 1;
        case 'C'
            c = Value;
            abcdkx(3) = 1;
        case 'D'
            d = Value;
            abcdkx(4) = 1;
        case 'K'
            k = Value;
            abcdkx(5) = 1;
        case 'X0'
            x0 = Value;
            abcdkx(6) = 1;
        case 'InitialState' % some value tests
            PossVal = {'Estimate';'Zero';'Fixed';'Auto';'Backcast'};
            try
                Value = pnmatchd(Value,PossVal,2);
            catch
                disp('Invalid property for ''InitialState''')
                error(['Should be one of ''Auto|Backcast|Estimate|Zero|Fixed'''])
            end
            sys.InitialState = Value;
            is = Value;
            inn(1)=1;
        case 'DisturbanceModel'
            if ~ischar(Value)
                error(sprintf(['DisturbanceModel shoule be one of ''Estimate'','...
                        ' ''None'', or ''Fixed''.']))
            end
            if strcmp(lower(Value(1)),'z')
                Value  = 'None';
            end
            
            PossVal = {'Estimate';'None';'Fixed'};
            try
                Value = pnmatchd(Value,PossVal,2);
            catch
                error(sprintf(['Invalid property for ''DisturbanceModel'''...
                        '\nShould be one of ''Estimate|None|Fixed''']))
            end
            nm = Value;
            inn(2)=1;
            
        case 'CanonicalIndices'
            if ischar(Value)
                Value = 'Auto';
            elseif ~all(fix(Value)==Value)|any(Value)<0
                error('''nf'' must be a vector of non-negative integers.')
            else
                Value = Value(:).';
            end
            sys.CanonicalIndices = Value;
            canflag = 1;
        case 'nk'
            nk = Value;
            inn(3)=1;
            
            
        case 'ParameterVector',
            ParameterVector = Value;  
            parflag=1;  
            sys.idmodel=pvset(sys.idmodel,'ParameterVector', Value);
            
            
        otherwise
            IDMProps([i i+1]) = 1;
            varargin{i} = Property;
    end %switch
    
end % for
IDMProps = find(IDMProps);
if ~isempty(IDMProps)
    sys.idmodel = pvset(sys.idmodel,varargin{IDMProps});
    
end

sys = timemark(sys);


if ~(any([abcdkx,nabcdkx,inn,parflag,sspchange,canflag]))
    if size(sys.As,1) ~= length(sys.StateName)
        sys.StateName = defnum(sys.StateName,'x',size(sys.As,1));
    end
    sys.idmodel = idmcheck(sys.idmodel,[size(d,1),size(d,2)]);
    return
end
% Possible conflicts
if inn(3)
    if length(nk)~=size(sys.Bs,2)
        error('''nk'' must be a row vector of length = # of inputs.')
    end
end

%idmodel=sys.idmodel;
Est=pvget(sys.idmodel,'EstimationInfo');
if strcmp(Est.Status(1:3),'Est')   
    Est.Status='Model modified after last estimate';
    sys.idmodel=pvset(sys.idmodel,'EstimationInfo',Est);
    
    % Special treatment of setting canonical from just estimatad free model
    if sspchange&nargin==3&strcmp(oldsspar,'Free')&...
            strcmp(sys.SSParameterization,'Canonical')
        try
            ut = pvget(sys.idmodel,'Utility');
            sys1 = ut.Pmodel;
            if ~isempty(sys1)
                sys = sys1;
                return
            end
        end
    end
    
end

%
if isempty(a)&isempty(d)%was a
    if isempty(pvget(sys.idmodel,'ParameterVector'))
        sys =parset(sys,zeros(1000,1)); 
    end
    [a,b,c,d,k,x0]=ssdata(sys);
end

parmat.a=a;parmat.b=b;parmat.c=c;
parmat.d=d;parmat.k=k;parmat.x0=x0;
nu = size(b,2);
nans.as=sys.As;nans.bs=sys.Bs;nans.cs=sys.Cs;%;
nans.ds=sys.Ds;nans.ks=sys.Ks;nans.x0s=sys.X0s;

if any(abcdkx) % touched the matrices
   
    if parflag
        error('Cannot set both ParameterVector and matrices')
    end
    
    if isempty(d),d=zeros(size(c,1),size(b,2));parmat.d=d;end
    if isempty(k),k=zeros(size(c))';parmat.k=k;end
    if isempty(x0),x0=zeros(size(a,1),1);parmat.x0=x0;end
    
    error(abccheck(a,b,c,d,k,x0,'par'))
    [nans,status] = checknan(parmat,nans);
    if status
         sys.As = nans.as; sys.Bs = nans.bs;
        sys.Cs = nans.cs; sys.Ds = nans.ds;
        sys.Ks = nans.ks; sys.X0s = nans.x0s;
    end
end   

if any(nabcdkx) % touched the structure matrices
    
    error(abccheck(sys.As,sys.Bs,sys.Cs,sys.Ds,sys.Ks,sys.X0s,'nan'))
    if any(nabcdkx(1:3))
        sys.SSParameterization = 'Structured';
    end
    if nabcdkx(4) % Ds
        for kk = 1:size(sys.Ds,2)
            if ~(all(isnan(sys.Ds(:,kk)))|norm(sys.Ds(:,kk))==0)
                sys.SSParameterization = 'Structured';
            end
        end
    end
    if nabcdkx(5) % kS
        ssch = 1;
        if all(all(isnan(sys.Ks))')
            ssch = 0;
        elseif ~any(any(isnan(sys.Ks))')
            if norm(sys.Ks)==0
                ssch =0;
            end
        end
        if ssch
            sys.SSParameterization = 'Structured';
        end
    end
    if nabcdkx(6) %X0s
        if norm(sys.X0s)==0 & any(strcmp(sys.InitialState,{'Estimate','Fixed'}))
            sys.InitialState = 'Zero';
        elseif ~any(isnan(sys.X0s)) & ...
                any(strcmp(sys.InitialState,{'Estimate','Zero'}))
            sys.InitialState = 'Fixed';
        elseif all(isnan(sys.X0s)) &any(strcmp(sys.InitialState,{'Fixed','Zero'}))
            sys.InitialState = 'Estimate';
        else % Mixed nans
            sys.SSParameterization = 'Structured';
            if any(strcmp(sys.InitialState,{'Fixed','Zero'}))
                sys.InitialState = 'Estimate';
            end
        end
    end
end    
SSParameterization = sys.SSParameterization;
if any(strcmp(SSParameterization,{'Canonical','Free'})) 
    if nu>0  
        if isempty(nk)
            if isempty(sys.Ds)
                nk = zeros(1,0);
            elseif strcmp(oldssp,'Structured')
                nks = (sys.Ds~=0);
                if size(nks,1)>1
                    nks = max(nks);
                end
                nk = 1-nks;
            else
                nk=findnk(sys.As,sys.Bs,sys.Ds); 
            end
            nkold=nk;
        else
            nkold=findnk(sys.As,sys.Bs,sys.Ds);
        end
        if any(nkold>1)
            parmat=rmnk(parmat,nkold);
%%%% WHAT ABOUT NANS??
        end
    end % nu>0
    if canflag&~ischar(sys.CanonicalIndices)
        nxt = sum(sys.CanonicalIndices);
        nyt = length(sys.CanonicalIndices);
        [ny,nx]=size(parmat.c);
        if nyt~=ny|nxt~=nx
            error(...
                sprintf(['   CanonicalIndices must be a row vector with as many elements',...
                    ' as outputs.\n   The sum of these elements must be equal to the model',...
                    ' order. \n   (Note that the model order here does NOT include delays',...
                    ' caused by any nk>1. \n   The order should in this case be %d.)',...
                    '\n   A safe choice is CanonicalIndices = ''Auto''.'],nx))
        end
    end
    
    if isempty(nm)
        if any(any(isnan(sys.Ks))')
            nm = 'Estimate';
        elseif norm(k)==0|norm(sys.Ks)==0
            nm = 'None';
        else
            nm = 'Fixed';
        end
    end
    if isempty(is)
        if any(any(isnan(sys.X0s))')
            is = 'Estimate';
        elseif norm(x0)==0
            is = 'Zero';
        else 
            is = 'Fixed';
        end
    end
    if strcmp(SSParameterization,'Canonical')      
        [parmat,nans]=sscan(parmat,sys.CanonicalIndices,nk,nm,is); 
    else
        nans.as=NaN*ones(size(parmat.a));nans.bs=NaN*ones(size(parmat.b));
        nans.cs=NaN*ones(size(parmat.c));
        switch nm
            case 'Estimate'
                nans.ks=NaN*ones(size(parmat.k));
            case 'Fixed'
                nans.ks=parmat.k;
            otherwise
                nans.ks=zeros(size(parmat.k));
        end
        
        switch sys.InitialState
            case {'Estimate','Auto'}
                nans.x0s=NaN*ones(size(parmat.x0));
            case  'Fixed'
                nans.x0s=parmat.x0;
            case {'Zero','Backcast'}
                nans.x0s=zeros(size(parmat.x0));
        end % For 'Auto' and 'Backcast' no modifications of nans.
    end
    
    if nu>0
        if any(nk>1) 
            parmat=addnk(parmat,nk,'par');
            nans=addnk(nans,nk,'nans');
        end
    end
    nans.ds=zeros(size(parmat.d));
    if nu>0
        for kk=find(nk==0)
            nans.ds(:,kk)=NaN*ones(size(parmat.d,1),1);
        end
    end
    
    abcdkx=ones(1,6);
    sys.As=nans.as;
    sys.Bs=nans.bs;
    sys.Cs=nans.cs;
    sys.Ds=nans.ds;
    sys.Ks=nans.ks;
    sys.X0s=nans.x0s;
    
    
    [pars,status] = findnan(struct2cell(parmat),struct2cell(nans));
    % status flags that there is a discrepancy between par and nans.
    %if status, warning('Discrepancy!!'),end
    if parflag
        if length(ParameterVector)~=length(pars)
            error(...
                'The length of the parameter vector must equal the number of free parameters.')
        else
            pars = ParameterVector;
        end
    end
    
    sys.idmodel=pvset(sys.idmodel,'ParameterVector', pars);
    
elseif strcmp(SSParameterization,'Structured')
    if ~isempty(nk)&inn(3)
        error('Cannot set ''nk'' for ''Structured'' SSParameterization')
    end
    if ~isempty(nm)
        switch nm
            case 'Estimate' %Possibly more cases
                sys.Ks=NaN*ones(size(parmat.k));
            case 'Fixed'
                sys.Ks=k;
            otherwise
                sys.Ks=zeros(size(parmat.k));
        end
    end
    if ~isempty(is)
        switch is %Possibly more cases
            case 'Estimate'
                sys.X0s=NaN*ones(size(parmat.x0));
            case  'Fixed'
                sys.X0s=x0;
            case 'Zero'
                sys.X0s=zeros(size(parmat.x0));
        end %Auto and Backcast does not affect nans
    end
    nans.ks=sys.Ks; nans.x0s=sys.X0s;
    [pars,status] = findnan(struct2cell(parmat),struct2cell(nans));
    
    if parflag
        if length(ParameterVector)~=length(pars)
            error('The length of the parameter vector must equal the number of free parameters.')
        else
            pars = ParameterVector;
        end
    end        
    sys.idmodel=pvset(sys.idmodel,'ParameterVector',pars);     
end

try
    if ~inn(3)
        nk = pvget(sys,'nk');
    end
catch
    nk =[];
end

Ts = pvget(sys,'Ts');
if any(nk>1)&Ts==0
    error(sprintf(['The relative degree (''nk'') cannot be larger',...
            '\nthan 1 for continuous time models.']))
end
indp = pvget(sys,'InputDelay');
if ~all(indp==0)&any(nk>1)&Ts>0
    warning(sprintf(['You have specified both ''InputDelay''',...
            ' and ''nk'' to be nonzero.',...
            '\nThe total delay will be the sum of these.']))
end
if size(sys.As,1) ~= length(sys.StateName)
    sys.StateName = defnum(sys.StateName,'x',size(sys.As,1));
end
sys.idmodel = idmcheck(sys.idmodel,[size(d,1),size(d,2)]); 






