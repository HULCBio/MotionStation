function sys = pvset(sys,varargin)
%PVSET  Set properties of IDPROC models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $ $Date: 2004/04/10 23:18:06 $

% RE: PVSET is performing object-specific property value setting
%     for the generic IDMODEL/SET method. It expects true property names.

parflag = 0; 
ni=length(varargin);
IDMProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the IDMODEL parent
Knew = [];
Xnew = [];
typec = i2type(sys);
[Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);%deal
procp = [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz]';
procp=procp(:);
flags=zeros(1,12);
fa = pvget(sys,'FileArgument');
dm=fa{3};

dmflag = 0;
for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property
        case 'Type'
            if ~iscell(Value),
                Value={Value};
            end
            nu = length(Value);
            if nu~=length(typec)
                error(sprintf(['''Type'' should be a field with ',int2str(length(typec)),...
                        ' entries.\nTo change the number of inputs you',...
                        ' cannot just change the properties.',...
                        '\nTo increase the number of inputs use concatenation: Mod = [Mod1,Mod2]',...
                        '\nTo decrease the number of inputs use subselection: Mod = Mod([nr1,n2r,..])']))
            end
            for ku = 1:nu
                type = Value{ku};
                Type ='';
                if ~isa(type,'char')|lower(type(1))~='p'
                    error('Type must be a string starting with ''P''.')
                end
                Type(1)='P';
                if any(findstr(type,'0'))
                    Type(2)='0';
                    npar=1;
                elseif any(findstr(type,'1'))
                    Type(2)='1';
                    npar = 2;
                elseif any(findstr(type,'2'))
                    Type(2)='2';
                    npar = 3;
                elseif any(findstr(type,'3'))
                    Type(2)='3';
                    npar = 4;
                else
                    error('The second character of Type must be ''0'', ''1'', ''2'' or ''3''.')
                end
                nr=3;
                if any(findstr(lower(type),'d'))
                    Type(nr) ='D';
                    nr = nr+1;
                    npar = npar +1;
                end
                if any(findstr(lower(type),'z'))
                    Type(nr) = 'Z';
                    nr = nr+1;
                    npar = npar +1;
                end
                if any(findstr(lower(type),'i'))
                    Type(nr) = 'I';
                    nr = nr+1;
                end
                if any(findstr(lower(type),'u'))
                    Type(nr) = 'U';
                    nr = nr+1;
                end
                typec{ku} = Type;
            end % for ku
            flags(1)=1;
        case 'Kp'
            if isnumeric(Value)
                Kp = Value(:);
            else
                [Value,Kp] = errchk(Value,'Kp',sys.Kp,Kp);
                sys.Kp = Value;
            end
            flags(2)=1;
        case 'Td'
            if isnumeric(Value)
                Td = Value(:);
            else
                [Value,Td] = errchk(Value,'Td',sys.Td,Td);
                sys.Td = Value;
            end
            flags(8)=1;
        case 'Tp1'
            if isnumeric(Value)
                Tp1 = Value(:);
            else
                [Value,Tp1] = errchk(Value,'Tp1',sys.Tp1,Tp1);
                sys.Tp1 = Value;
            end
            flags(3)=1;
        case 'Tp2'
            if isnumeric(Value)
                Tp2 = Value(:);
            else
                [Value,Tp2] = errchk(Value,'Tp2',sys.Tp2,Tp2);
                sys.Tp2 = Value;
            end
            flags(4)=1;
        case 'Tw'
            if isnumeric(Value)
                Tw = Value(:);
            else
                [Value,Tw] = errchk(Value,'Tw',sys.Tw,Tw);
                sys.Tw = Value;
            end
            flags(5) =1;
        case 'Zeta'
            if isnumeric(Value)
                zeta = Value(:);
            else
                [Value,zeta] = errchk(Value,'Zeta',sys.Zeta,zeta);
                sys.Zeta = Value;
            end
            flags(6) = 1;
        case 'Tp3'
            if isnumeric(Value)
                Tp3 = Value(:);
            else
                [Value,Tp3] = errchk(Value,'Tp3',sys.Tp3,Tp3);
                sys.Tp3 = Value;
            end
            flags(7) = 1;
        case 'Tz'
            if isnumeric(Value)
                Tz = Value(:);
            else
                [Value,Tz] = errchk(Value,'Tz',sys.Tz,Tz);
                sys.Tz = Value;
            end
            flags(9)=1;
        case 'InputLevel'
            if isnumeric(Value)
                sys.InputLevel.value = Value(:)';
            else
                [Value,ulev] = errchk(Value,'InputLevel',sys.InputLevel,sys.InputLevel.value);
                sys.InputLevel = Value;
                nr= find(strcmp(Value.status,'zero'));
                sys.InputLevel.value(nr) = zeros(size(nr));
                    
            end
            
        case 'Integration'
            if ~iscell(Value);
                Value = {Value};
            end
            for ku = length(Value)
                if ~ischar(Value{ku})|~any(strcmp(lower(Value{ku}),{'on','off'}))
                    error('''Integration'' must be ''on'' or ''off''.')
                end
            end
            sys.Integration = Value;
        case 'InputDelay'
            sys.idgrey = pvset(sys.idgrey,'InputDelay',Value(:));
            flags(10) =1;
        case 'ParameterVector',
            if ~isa(Value,'double')
                error('''ParameterVector'' must be a vector of numbers.')
            end
            Value=Value(:);
            sys.idgrey=pvset(sys.idgrey,'ParameterVector', Value);
            parflag=1; 
        case 'InitialState' 
            grey = sys.idgrey;
            grey = pvset(grey,'InitialState',Value);
            sys.idgrey = grey;
            
        case 'DisturbanceModel' 
            PossVal = {'None';'Estimate';'ARMA1';'ARMA2';'Zero';'Fixed'};
            model =[];
            dmpar1 = [];
            if isa(Value,'idpoly');
                model = Value;
                Value = 'Estimate';
            end
            if iscell(Value)
                if length(Value)>1
                    model = Value{2};
                end
                Value = Value{1};
            end
            try
                Value = pnmatchd(Value,PossVal,5);
            catch
%                 txt1 = 'Invalid property for ''DisturbanceModel''';
%                 if V
                disp('Invalid property for ''DisturbanceModel''')
                error(['Should be one of ''None|Estimate|ARMA1|ARMA2|Fixed'''])  
            end
            if strcmp(Value,'Zero')
                Value = 'None';
            end
            flags(11) = 1;
            if strcmp(Value,'Estimate')
                dm = 'ARMA2';
            else
                dm = Value;
            end
            if ~isempty(model)
                err = 0;
                if ~isa(model,'idpoly')
                    err=1;
                elseif pvget(model,'na')>2|any(pvget(model,'nb')>0)|pvget(model,'nd')>0|...
                        pvget(model,'nc')>2|any(pvget(model,'nf')>0)|pvget(model,'Ts')>0
                    err = 1;
                else
                    pmod = pvget(model,'ParameterVector');
                    if any(pmod<0)
                        err = 1;
                    end
                end
                if err
                    error(sprintf(['When a model has been specified as in ',...
                            '''DisturbanceModel'',{''Fixed'',Model}, \nModel must be ',...
                            'a continuous time IDPOLY ARMA model with na<=2 and nc<=2.',...
                            '\n(Example: Model = IDPOLY([1 1 1],[],[1 2 3],''Ts'',0);) ',...
                            '\nModel must also be stable and inversely stable.']));
                end
                ut = pvget(sys,'Utility');
                ut.NoiseModel = model;
                sys = uset(sys,ut);
                nr = max(pvget(model,'na'),pvget(model,'nc'));
                dm = ['ARMA',int2str(nr)];
                a = pvget(model,'a'); a = [a,0];
                c = pvget(model,'c'); c = [c,0];
                dmpar = [a(2:nr+1),c(2:nr+1)];
                dmpar = dmpar(:);
            end
            if strcmp(dm,'ARMA1')&length(dmpar)~=2
                dmpar =zeros(2,1);
            elseif strcmp(dm,'ARMA2')&length(dmpar)~=4
                dmpar = zeros(4,1);
            elseif strcmp(Value,'Fixed')|strcmp(Value,'None')
                dmpar1 = dmpar;
                %dmpar =zeros(0,1);
                dm = Value;
            elseif strcmp(Value,'None')
                dmpar = zeros(0,1);
            end
            if strcmp(Value(1:2),'AR')
                Value = 'Estimate';
            end
            grey = sys.idgrey;
            grey = pvset(grey,'DisturbanceModel',Value);
            sys.idgrey = grey;
        case 'Ts'
            if Value~=0
                error('IDPROC models are continuoius time: Ts must be 0.')
            end
        case 'idmodel'
            grey = sys.idgrey;
            grey = pvset(grey,'idmodel',Value);
            sys.idgrey = grey;
            flags(12)=1;
        case 'FixedParameter'
            if isnumeric(Value)
                pnam = pvget(sys,'PName');
                Value = pnam(Value);
            end
            if ~iscell(Value),
                Value = {Value};
            end
            for k1 = 1:length(Value)
                prop = Value{k1};
                k1p = find(prop=='(');
                if ~isempty(k1p)
                    nr = prop(k1p+1:end-1);
                    prop = prop(1:k1p-1);
                    gg = getfield(sys,prop);
                    gg.status{eval(nr)} = 'fixed';
                else
                    gg = getfield(sys,prop);
                    gg.status = {'fixed'};
                end
                sys = setfield(sys,prop,gg);
                
            end
            
        otherwise
            IDMProps([i i+1]) = 1;
            varargin{i} = Property;
            
    end %switch
    
end % for
IDMProps = find(IDMProps);
model = pvget(sys,'idmodel');
if ~isempty(IDMProps)
    
    model = pvset(model,varargin{IDMProps});
end
sys = timemark(sys,'l');
Est=pvget(model,'EstimationInfo');
if strcmp(Est.Status(1:3),'Est') 
    Est.Status='Model modified after last estimate';
    model=pvset(model,'EstimationInfo',Est);
end
sys.idgrey = pvset(sys.idgrey,'idmodel',model);

if parflag&any(flags)
    error('You cannot change the ParameterVector and the parameters at the same time.')
end
if flags(8)&flags(10)
    error('You cannot change ''Td'' and ''InputDelay'' at the same time.')
end
if flags(10) 
    Td = pvget(sys,'InputDelay');
end
if flags(10)|flags(8)
    Tdd = Td;
    Tdd(find(isnan(Td)))=zeros(size(find(isnan(Td))));
    sys.idgrey = pvset(sys.idgrey,'InputDelay',Tdd);
end
file = pvget(sys.idgrey,'FileArgument');
if parflag
    [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);%deal
     Tdd = Td;
    Tdd(find(isnan(Td)))=zeros(size(find(isnan(Td))));
    sys.idgrey = pvset(sys.idgrey,'InputDelay',Tdd);
end
if any(flags)
    if flags(1)
        sys = type2stat(sys,typec);
    end
    try 
        procp = [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz]';
        procp =procp(:);
    catch
        nu = length(typec);
        error(['The process parameter values must have ',int2str(nu),' rows.'])
    end
    if flags(11)
        file{3} = dm;
        file{4} = dmpar; 
    end
    
    tpflag = flags(3:6);
    for ku = 1:length(sys.Tp1.status)
        stat = [strcmp(sys.Tp1.status{ku},'zero'),strcmp(sys.Tp2.status{ku},'zero'),...
                strcmp(sys.Tw.status{ku},'zero'),strcmp(sys.Zeta.status{ku},'zero')];
        if (stat(1)&tpflag(1))% Tp1 has been set to zero
            sys.Tp2.status{ku} = 'zero';
        end
        if (~stat(1)&tpflag(1))|(~stat(2)&tpflag(2))% Tp1 or Tp2 has been set to non-zero
            sys.Tw.status{ku} = 'zero';
            sys.Zeta.status{ku} = 'zero';
            if ~stat(2)&tpflag(2)&stat(1) % Tp2 has been set to non-zero while Tp1 is zero
                sys.Tp1.status{ku} ='est';
            end
        end
        if (~stat(3)&tpflag(3))|(~stat(4)&tpflag(4))% Tw or Zeta has been set to non-zero
            sys.Tp1.status{ku} = 'zero';
            sys.Tp2.status{ku} = 'zero';
            if ~stat(3)&tpflag(3)&stat(4) % Tw has been set to non-zero while Zeta is zero
                sys.Zeta.status{ku} ='est';
            end
            if ~stat(4)&tpflag(4)&stat(3) % Zeta has been set to non-zero while Tw is zero
                sys.Tw.status{ku} ='est';
            end
        end
    end
    typec = i2type(sys);
    [par,Type,pnr,dnr] = parproc(procp,typec); %%LL 
    par = [par;dmpar];
    file{5} = pnr;
    sys.idgrey = pvset(sys.idgrey,'ParameterVector',par,'FileArgument',file);
    [sys,par] = considp(sys,flags(3:6));
    
    file{1} = i2type(sys);
    file{5} = pnr;
    file{6} = dnr;
    file{8} = sys.InputLevel;
    pna = cell(length(par),1);
    pna(:)={''};
    pna1 = setpname(sys,0);
    pna(1:length(pna1))=pna1;
    
    sys.idgrey = pvset(sys.idgrey,'ParameterVector',par,'FileArgument',file,...
        'PName',pna);
end
%%%%%%%%%%%%%%%%%%%%%%%
function [Value,par] = errchk(Value,pna,prop,par1);
nu = length(prop.status);
if iscell(Value) % This is when assigning status to several inputs
    % or when using pvset(..,'kp',{'max',3})
    if ischar(Value{1})
        sw = lower(Value{1});
        if length(sw)<2, 
            sw=[sw,' '];
        end
        switch sw(1:2)
            case 'va'
                par = Value{2};
                pp = prop;
                pp.value = par;
                Value = pp;
            case 'st'
                Value = Value(2:end);
            case 'mi'
                pp = prop;
                pp.min = Value{2};
                pp.value = par1(:);
                Value = pp;
            case 'ma'
                pp = prop;
                pp.max = Value{2};
                pp.value = par1(:);
                Value = pp;
        end
    end
end
if iscell(Value)
    if ischar(Value{1});
        pp = prop;
        pp.status = Value;
        pp.value = par1(:)';%%LL was without '
        Value = pp;
    end
end
if ischar(Value)
    pp  = prop;
    pp.status = Value;
    pp.value = par1(:);
    Value = pp;
end
if isstruct(Value)
    try
        dum.status = 'dum';dum.min=-inf;dum.max=inf;dum.value=0;
        [Value,dum];
    catch
        error(sprintf([pna,' must be a structure with the fields (in this order):\n',...
            'status, min, max, value.']))
    end
end
if isfield(Value,'status')
    ms = Value.status;
    if ~iscell(ms),
        ms={ms};
    end
    if length(ms)~=nu
        error(sprintf(['''status'' should be a field with ',int2str(nu),...
                ' entries.\nTo change the number of inputs you',...
                ' cannot just change the properties.',...
                '\nTo increase the number of inputs use concatenation: Mod = [Mod1,Mod2]',...
                '\nTo decrease the number of inputs use subselection: Mod = Mod([nr1,n2r,..])']))
    end
    if strcmp(pna,'Kp')&any(strcmp(ms,'zero'))
        error('The ''Kp.status'' property cannot be ''zero''.')
    end
    for ku = 1:length(ms)
        mss = ms{ku};
        if ~ischar(mss)
            error(['The ''status'' field of ',pna,' must be a cell array of string.']);
        end
        mm = lower(mss(1));
        switch mm
            case 'e'
                ms{ku} = 'estimate';
            case 'z';
                ms{ku} = 'zero';
            case 'f'
                ms{ku} = 'fixed';
            otherwise
                error(['The ''status'' field of ',pna,' must be ''estimate'', ''Zero'', or ''Fixed''.']);
        end
    end
    
else
    error(['The property ',pna,' must be structure with a field ''status''.'])
end
Value.status = ms;
if isfield(Value,'value')
    mv = Value.value;
    if ~isnan(mv)&~isa(mv,'double')
        error(['The ''value'' field of ',pna,' must be numeric or NaN.'])
    end
    %check size!
    par = mv(:);
    if ~strcmp(pna,'InputLevel')
    Value = rmfield(Value,'value');
end
else
    error(['The property ',pna,' must be structure with a field ''value''.'])
end
if isfield(Value,'min')
    mv = Value.min;
    if ~isnan(mv)&~isa(mv,'double')
        error(['The ''min'' field of ',pna,' must be numeric or NaN.'])
    end
    %check size!
else
    error(['The property ',pna,' must be structure with a field ''min''.'])
end
if isfield(Value,'max')
    mv = Value.max;
    if ~isnan(mv)&~isa(mv,'double')
        error(['The ''max'' field of ',pna,' must be numeric or NaN.'])
    end
    %check size!
else
    error(['The property ',pna,' must be structure with a field ''max''.'])
end

