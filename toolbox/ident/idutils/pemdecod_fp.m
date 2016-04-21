function [mdum,z,order,args] = pemdecod(call,varargin)
%PEMDECOD  Decodes the input arguments to pem   to honor
%          various syntaxes

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2004/04/10 23:18:47 $

% First a quick exit if this is a class from inival or iv:
mdum = [];
order =[];
args ={};
ny=[];
nl = length(varargin);

% Allow order confusion between model and data:

if isa(varargin{2},'iddata')|isa(varargin{2},'idfrd')
    varargin = varargin([2 1 3:nl]);
end
z = varargin{1};
if isa(z,'idfrd')
        z = idfrd2iddata(z);
         
varargin{nl+1}='init';varargin{nl+2}='zero'; % LL Fix this
nl = nl+2;
%     resp = z.resp;
%     fre = z.fre;
%     resp = squeeze(resp);
%     z = iddata(resp(:),ones(length(resp),1),'Ts',z.ts,'domain','freq');
%     z.fre = fre;
end
if isa(z,'iddata')
    [N,nyd,nud] = size(z);
    if nyd==0
        error('The data set must contain an output signal.')
    end
    nzd = nyd+nud;
    iddatflag = 1;
else
    [N,nzd]=size(z);
    iddatflag= 0;
end
switch class(varargin{2})
case 'idpoly'
    mdum = varargin{2};
    if iddatflag
        if nyd~=1
            error('Polynomial models (ARMAX, BJ, OE etc) are only supported for single-output data.')
        end
    else
        nud = nzd-1;
        nyd = 1;
    end
    
    if nl>2
        args = oldtest(varargin(3:end),-1,call);
        set(mdum,args{:});
    end
case 'char' % syntax pem(data,'na',na,...)
    args = varargin(2:end);
    % First check if state space model is indicated
    kf = find(strcmp('nx',lower(args(1:2:end)))); 
    if ~isempty(kf) % Then a state space model is indicated
        kf = kf(1);
        order = args{2*kf};
        args=args([1:kf*2-2,kf*2+1:end]);
        mdum=idss([],zeros(0,nud),zeros(nyd,0),zeros(nyd,nud));
    else
        mdum = idpoly;
    end
    if length(args)>0
        set(mdum,args{:});
    end
case 'double' % syntax arx(data,[na nb nk],...)
    nn = varargin{2};
    [ny,nc] = size(nn); %check nonnegative integers
    switch nc
    case 1 %state space model
        order = nn;
        mdum = idss;
        if nl>2
            args = oldtest(varargin(3:end),-1,call);
        end
    otherwise % polynomial models
        if iddatflag
            if nyd~=1
                error('Polynomial models (ARMAX, BJ, OE etc) are only supported for single-output data.')
            end
        else
            nud = nzd-1;
            nyd = 1;
        end
        mdum = idpoly;
        switch call
        case 'pem'
            nrcheck = 3+3*nud;
            if nud==0,nrcheck = 2; end
            if nc ~= nrcheck,  
                error(sprintf(['   Incorrect number of orders specified.',...
                        '\n   You should have m0 = [na nb nc nd nf nk],',...
                        '\n   where nb, nf and nk are row vectors of length equal to',...
                        '\n   the number of inputs.',...
                        '\n   For a scalar time series m0 =[na nc].'...
                        '\n   If you intended to try a vector of state space model orders,',... 
                        '\n   use PEM(z,''nx'',orders,..)']))
            end
            
            
            nb=nn(2:1+nud); % This is to set nf's to zero, where nb are zero
             if sum(abs(nb)) == 0 
                error('This model structure does not make sense if all B-orders are zero.')
            end
            kz=find(nb(1:nud)==0);
            if ~isempty(kz),nn(nud+kz+3)=zeros(1,length(kz));end
            
            if nud==0
                if sum(nn(1:2))==0
                    error('All orders are zero. Nothing to estimate.')
                end
                mdum = pvset(mdum,'na',nn(1),'nc',nn(2));
            else
                if sum(nn(1:2*nud+3))==0
                    error('All orders are zero. Nothing to estimate.')
                end
                mdum = pvset(mdum,'na',nn(1),'nb',nn(2:nud+1),'nc',nn(nud+2:nud+2),...
                    'nd',nn(nud+3:nud+3),'nf',nn(nud+4:2*nud+3),'nk',nn(2*nud+4:3*nud+3)); 
            end
        case 'oe'
            if nud==0
                error('The Output Error Method does not make sense for a time series (no input).')
            end
            
            nrcheck = 3*nud;
            if nc ~= nrcheck,  
                error(sprintf(['   Incorrect number of orders specified.',...
                        '\n   You should have m0 = [nb nf nk],',...
                        '\n   where nb, nf and nk are row vectors of length equal to',...
                        '\n   the number of inputs.']))
                
            end
             nb=nn(1:nud); % This is to set nf's to zero, where nb are zero
             if sum(abs(nb)) == 0
                error('The Output Error model does not make sense if all B-orders are zero.')
            end
             kz=find(nb(1:nud)==0);
            if ~isempty(kz),nn(nud+kz)=zeros(1,length(kz));end
            mdum = pvset(mdum,'nb',nn(1:nud),...
                'nf',nn(nud+1:2*nud),'nk',nn(2*nud+1:3*nud)); 
            
        case 'armax'
            nrcheck = 2+2*nud;
            if nud==0,nrcheck = 2; end
            if nc ~= nrcheck,  
                error(sprintf(['   Incorrect number of orders specified.',...
                        '\n   You should have m0 = [na nb nc nk],',...
                        '\n   where nb and nk are row vectors of length equal to',...
                        '\n   the number of inputs.',...
                        '\n   For a scalar time series m0 =[na nc].']))
                
            end
            if nud==0
                mdum = pvset(mdum,'na',nn(1),'nc',nn(2));
            else
                mdum = pvset(mdum,'na',nn(1),'nb',nn(2:nud+1),'nc',nn(nud+2:nud+2),...
                    'nk',nn(nud+3:2*nud+2)); 
            end
        case 'bj'
            if nud==0
                error('The Box-Jenkins model does not make sense for a time series.Use ARMAX instead.')
            end
            
            nrcheck = 2+3*nud;
            if nc ~= nrcheck,  
                error(sprintf(['   Incorrect number of orders specified.',...
                        '\n   You should have m0 = [nb nc nd nf nk],',...
                        '\n   where nb, nf and nk are row vectors of length equal to',...
                        '\n   the number of inputs.']))
            end
            
            
            nb=nn(1:nud); % This is to set nf's to zero, where nb are zero
             if sum(abs(nb)) == 0
                error('The Box-Jenkins model does not make sense if all B-orders are zero.')
            end
            kz=find(nb(1:nud)==0);
            if ~isempty(kz),nn(nud+kz+2)=zeros(1,length(kz));end
            mdum = pvset(mdum,'nb',nn(1:nud),'nc',nn(nud+1:nud+1),...
                'nd',nn(nud+2:nud+2),'nf',nn(nud+3:2*nud+2),'nk',nn(2*nud+3:3*nud+2)); 
        end
        if nl>2
            npar = sum(nn(1:end-nud));
            args = oldtest(varargin(3:end),npar,call);
            set(mdum,args{:});
        end % if nl
    end % case nc
    
end % switch varargin{2}
modtsflag = 0;
if nl > 2
    try 
        cht = lower(args(1:2:end));
    catch
        error('Arguments must come in Property/Value pairs')
    end
    kts = find(strcmp('ts',cht));
    if isempty(kts)
        Tsm = 1;
    else
        Tsm = args{2*kts};
        modtsflag = 1;
    end
end

if ~isa(z,'iddata')
    if isempty(ny)
        ny = 1;
        if nzd>2
            disp('Data interpreted as single output.')
            disp('Use IDDATA to package the data in an unambigous manner.')
        end
    end
    z = iddata(z(:,1:ny),z(:,ny+1:end),pvget(mdum,'Ts'));
else
    Ts = pvget(z,'Ts'); Ts = Ts{1};
    if modtsflag&Tsm~=Ts&Tsm~=0
        disp(sprintf(['Warning: The set Model Sampling time is different from Data''s',...
                '\nThe Data sampling time %0.5g will be used'],Ts))
    end
    if ~isempty(mdum)
        mdum = pvset(mdum,'Ts',Ts);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

function args = oldtest(argold,npar,call)

ml = length(argold);
if (ml==1&strcmp(argold{1},'trace'))|(~ischar(argold{1})&~iscell(argold{1}))
    % This is the old syntax
    if strcmp(call,'pem')
        prop={'fixedpar','maxiter','tol','lim','maxsize','Ts'};
    else
        prop={'maxiter','tol','lim','maxsize','Ts'};
        npar = -1;
    end
    for kk=1:ml
        if strcmp(argold(kk),'trace');
            args{2*kk-1}='trace';args{2*kk}='Full';
        else
            if kk==1&~isempty(argold{kk})&npar>=0
                argold{kk}=indinvert(argold{kk},npar); %npar
            end
            
            args{2*kk-1}=prop{kk};
            args{2*kk}=argold{kk};
            %if strcmp(prop{kk},'Ts')
            % Ts = argold{kk};
            %end
            
        end % if trace
    end %for
else
    args = argold;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind3 = indinvert(ind1,npar)
if npar==0
    error('Transformation of old syntax for INDEX failed.')
end

ind2 = [1:npar]';
indt = ind2*ones(1,length(ind1))~=ones(npar,1)*ind1(:)';
if size(indt,2)>1, indt=all(indt');end
ind3 = ind2(find(indt));

