function [mdum,z,order,args] = pemdecod(call,varargin)
%PEMDECOD  Decodes the input arguments to pem to honor
%          various syntaxes

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.21.4.1 $ $Date: 2004/04/10 23:18:46 $

% First a quick exit if this is a class from inival or iv:
mdum = [];
order =[];
args ={};
ny=[];
nl = length(varargin);

% Allow order confusion between model and data:

if isa(varargin{2},'iddata')|isa(varargin{2},'idfrd')|isa(varargin{2},'frd')
    varargin = varargin([2 1 3:nl]);
end
z = varargin{1};
if isa(z,'frd')
    z = idfrd(z);
end
if isa(z,'idfrd')
    z = iddata(z);
end
if isa(z,'iddata')
    setid(z);
    
    z = nyqcut(z);
    [N,nyd,nud] = size(z);
    if nyd==0
        error('The data set must contain an output signal.')
    end
    nzd = nyd+nud;
    iddatflag = 1;
    dom = pvget(z,'Domain');
    dom = lower(dom(1));
else
    dom = 't';
    [N,nzd]=size(z);
    if N<nzd
        error(sprintf(['The data matrix must have outputs and inputs as column vectors.', ...
                '\nIt is preferred to use the IDDATA object to contain data. See HELP IDDATA.']))
    end
    iddatflag= 0;
end
% First kick out FD TS data:
if dom=='f' & nud == 0
    error(sprintf(['PEM does not support frequency domain time series data.',...
            '\nUse ARX for parametric models and SPA, ETFE or SPAFDR for non-parametric',...
            ' spectral models.']))
end
createmdum = 1;
switch class(varargin{2})
    case 'idpoly'
        createmdum = 0;
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
            [args,datarg] = pnsortd(args);
            if ~isempty(datarg)&iddatflag, z = pvset(z,datarg{:});end
            set(mdum,args{:});
        end
    case 'cell' % Multiinput process model
        mdum = varargin{2}; order = mdum;
        args = varargin(3:end);
        return
    case 'char' % syntax pem(data,'na',na,...)
        if varargin{2}(1)=='P' % process model
            mdum = varargin{2}; order = mdum;
            args = varargin(3:end);
            return
        end
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
            mdum = pvset(mdum,'NoiseVariance',1);
        end
        if length(args)>0
            [args,datarg] = pnsortd(args);
            if ~isempty(datarg)&iddatflag,z = pvset(z,datarg{:});end
            set(mdum,args{:});
            ktc = find(strcmp('nk',lower(args(1:2:end))));
            ts = pvget(z,'Ts');
            tcflag = (dom=='f'&ts{1}==0);
            if ~isempty(ktc)&tcflag
                warning(sprintf(['For continuous time data and OE models',...
                        ' the time delays (''nk'')\n have no meaning.']))
            end
            
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
                [args,datarg] = pnsortd(args);
                if ~isempty(datarg)&iddatflag, z = pvset(z,datarg{:});end
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
                mdum = pvset(mdum,'NoiseVariance',1);
                try
                ts = pvget(z,'Ts');
            catch
                ts ={1};
            end
                tcflag = (dom=='f'&ts{1}==0);
                % txt = '';
                %                                 if dom=='f'
                %                                     ts = pvget(z,'Ts');ts=ts{1};
                %                                     if ts==0
                %                                         nn = [nn,zeros(1,nud)];
                %                                         nc = size(nn,2);
                %                                         txt = ['For time continuous frequency domain data ',...
                %                                                 'nk has no meaning and shall be omitted.'];
                %                                     end
                %                                 end
                switch call
                    case 'pem'
                        nrcheck = 3+3*nud;
                        if nud==0,nrcheck = 2; end
                        if ~tcflag
                            if nc ~= nrcheck,  
                                error(sprintf(['   Incorrect number of orders specified.',...
                                        '\n   You should have m0 = [na nb nc nd nf nk],',...
                                        '\n   where nb, nf and nk are row vectors of length equal to',...
                                        '\n   the number of inputs.',...
                                        '\n   For a scalar time series m0 =[na nc].'...
                                        '\n   If you intended to try a vector of state space model orders,',... 
                                        '\n   use PEM(z,''nx'',orders,..)']))
                            end
                        else %tcflag
                            if nc == nrcheck
                                warning(sprintf(['For time continuous data,\nthe time',...
                                        ' delay orders (''nk'') have no meaning.']))
                            elseif nc == nrcheck - nud % correct
                                nn = [nn,zeros(1,nud)];
                            else % wrong orders
                                error(sprintf(['Incorrect number of orders specified.',...
                                        '\nFor time continuous data it is better to use',...
                                        ' OE(data,[nb,nf]),\nwhere nb and nf are row vectors of',...
                                        ' the same length as the number of inputs.']))
                            end
                        end
                        if nud>0
                            nb=nn(2:1+nud); % This is to set nf's to zero, where nb are zero
                            if sum(abs(nb)) == 0 
                                %error('This model structure does not make sense if all B-orders are zero.')
                            end
                            kz=find(nb(1:nud)==0);
                            if ~isempty(kz),nn(nud+kz+3)=zeros(1,length(kz));end
                        end
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
                        if tcflag % continuous time data
                            if (nc == nrcheck)
                                warning(sprintf(['Note that the delay coefficients (''nk'') have no meaning',...
                                        '\nfor continuous-time data.']))
                                nn(2*nud+1:3*nud) = zeros(1,nud);
                            elseif (nc == nrcheck-nud) % correct
                                nn = [nn,zeros(1,nud)];
                            else
                                error(sprintf(['Incorrect number of orders specified. For continuous time data',...
                                        '\nOE should have m0 = [nb nf], where nb anf nf are row vectors of',...
                                        '\nlength equal to the number of inputs.',...
                                        '\nNote that the time delay orders (''nk'') have no meaning\n for continuous time',...
                                        ' OE models.']))
                            end
                        else % no tcflag
                            
                            if (nc ~= nrcheck),  
                                
                                error(sprintf(['   Incorrect number of orders specified.',...
                                        '\n   You should have m0 = [nb nf nk],',...
                                        '\n   where nb, nf and nk are row vectors of length equal to',...
                                        '\n   the number of inputs.\n   ']))
                                
                            end
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
                        if dom=='f'
                            error(['ARMAX cannot be applied to frequency domain data.',...
                                    ' Use OE instead.'])
                        end
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
                        if dom=='f'
                            error(['BJ cannot be applied to frequency domain data.',...
                                    ' Use OE instead.'])
                        end
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
                        [args,datarg] = pnsortd(args);
                        if ~isempty(datarg)&iddatflag,z = pvset(z,datarg{:});end
                        set(mdum,args{:});
                    end % if nl
                end % case nc
                
        end % switch varargin{2}
        try
            [dum,nutest] = size(mdum);
            nbtest = pvget(mdum,'nb');
        catch
            nutest=0;nbtest=1;
        end
            if sum(nbtest)==0&nutest>0
                error(sprintf(['You have an input signal, but demand no B-estimate.',...
                        '\nRemove the input from the data (Data(:,:,[]))',...
                        '\nand estimate a time series model instead.']))
            end
            
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
            if isempty(ny)|nc==1
                ny = 1;
                if nzd>2
                    warning(sprintf(['Data interpreted as single output.',...
                            '\nUse IDDATA to package the data in an unambigous manner.']))
                end
            end
            z = iddata(z(:,1:ny),z(:,ny+1:end),pvget(mdum,'Ts'));
        else
            Ts = pvget(z,'Ts'); Ts = Ts{1};
            if modtsflag&Tsm~=Ts&Tsm~=0
                warning(sprintf(['The set Model Sampling time is different from Data''s',...
                        '\nThe Data sampling time %0.5g will be used'],Ts))
            end
            
            if isa(mdum,'idmodel')
                Tm = pvget(mdum,'Ts');
                if Tm&~Ts % cont data and discrete model
                    if ~createmdum
                        warning(sprintf(['Continuous time data and discrete time initial model.',...
                                '\nThe initial model has been converted to continuous time.']))
                    end
                    try
                        mdum = d2c(mdum);
                    catch
                        mdum = pvset(mdum,'Ts',Ts);
                    end
                end
                if ~Tm&Ts % discrete data and continuous model
                    if ~createmdum
                        warning(sprintf(['Discrete time data and continuous time initial model.',...
                                '\nThe initial model has been sampled (using zoh).',...
                                '\nConvert the resulting model to continuous time using D2C, if desired.']))
                    end
                    try % This is to handle trivial models
                        mdum = c2d(mdum,Ts);
                    catch
                        mdum = pvset(mdum,'Ts',Ts);
                    end
                end
                if ~createmdum&(Ts~=Tm)&Tm*Ts~=0
                    warning(sprintf(['The initial model has a different sampling interval',...
                            ' from the data set. \nThe Data sampling interval is used.']))
                end
                mdum = pvset(mdum,'Ts',Ts);
                
            end
        end
        try
            ut=pvget(z,'Utility');
            if ut.idfrd&strcmp(z,'Domain','Frequency');
                if length(args)>0
                    [args,datarg] = pnsortd(args);
                    if ~isempty(datarg)&iddatflag, z = pvset(z,datarg{:});end
                    set(mdum,args{:}); % Just to get the right message below
                end
                ini = pvget(mdum,'InitialState');
                if any(lower(ini(1))==['e','b'])
                    warning(sprintf(['The data apparently do not support estimation of initial states.',...
                            '\n''InitialState'' has been set to ''Zero''.']))
                end
                mdum = pvset(mdum,'InitialState','Zero');
                args = [args,{'InitialState','Zero'}];
            end
        end
        try
            z = estdatch(z,pvget(mdum,'Ts'));
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
        
