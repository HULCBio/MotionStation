function Out = pvset(dat,varargin)
%PVSET  Set properties of IDDATA objects.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.


%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.27.4.1 $ $Date: 2004/04/10 23:16:17 $

% RE: PVSET is performing object-specific property value setting
%     for the generic IDDATA/SET method. It expects true property names.

ni = nargin;
no = nargout;
if ~isa(dat,'iddata')
    % Call built-in SET. Handles calls like set(gcf,'user',ss)
    builtin('set',dat,varargin{:});
    return
end

if ni<=2,
    [AllProps,AsgnValues] = pnames(dat);
else
    AllProps = pnames(dat);
end


% Handle read-only cases
if ni==1,
    if strcmp(lower(dat.Domain),'frequency')
        AllProps(13:16)={'Fs';'Fstart';'SamplingFrequencies';'FrequencyUnit'};
        AsgnValues(13:16)={ 'Scalar  (Sampling frequency, empty if non-equal sampling)';...
                'Scalar  (First frequency)';...
                'N-by-1 matrix (leave empty if equidistant sampling)';...
                'String'};
    end
    
    % SET(DAT) or S = SET(DAT)
    if no,
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        disp('Necessary properties:') 
        for i=[1 3 6]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        disp(' ')
        disp('Optional output properties:') 
        for i=[4 5 ]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        disp(' ')
        disp('Optional input properties:') 
        for i=[ 7 8 9]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        text=AsgnValues{10};
        disp(['  ',AllProps{10},':  ',text{1}])
        disp(['        ',text{2}])
        
        disp(' ')
        disp('Optional sampling properties:') 
        for i=[11 12 13 14]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        disp(' ')
        disp('Optional user properties:') 
        for i=[2 15 16 17]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        
        disp(' ')
        disp('Type "iddprops" for more details')
    end % if no
    return
    
elseif ni==2,
    % SET(DAT,'Property') or STR = SET(DAT,'Property')
    Property = varargin{1};
    if ~isstr(Property),
        error('Property names must be single-line strings,')
    end
    
    % Return admissible property value(s)
    [Property,imatch] = pnmatchd(Property,AllProps,7);
    
    if no,
        Out = AsgnValues{imatch};
    else
        disp(AsgnValues{imatch})
    end
    return
    
end


% Now left with SET(DAT,'Prop1',Value1, ...)
name = inputname(1);
if isempty(name),
    error('First argument to SET must be a named variable.')
elseif rem(ni-1,2)~=0,
    error('Property/value pairs must come in even number.')
end
%datnew=dat;
flag=zeros(1,20);

for i=1:2:ni-1,
    % Set each PV pair in turn 
    
    Property = varargin{i}; 
    Value = varargin{i+1};
    [nrv,ncv]=size(Value);nrtest=min(nrv,ncv);
    
    switch Property
    case 'Domain'
        if length(varargin)==2
            warning(sprintf(['Just changing the DOMAIN will not change the data.',...
                    '\nUse FFT or IFFT to recalculate the data.']))
        end
        if ~(strcmp(lower(Value(1)),'t')|strcmp(lower(Value(1)),'f'))
            error('Domain must be one of ''Time'' or ''Frequency''')
        end
        if lower(Value(1))=='t'
            Value = 'Time';
        else
            Value = 'Frequency';
            % warning('All features for frequency domain data currently not supported.');
        end
        dat.Domain=Value;
        flag(1)=1;
    case 'Name'
        if ~isa(Value,'char')
            error('The name must be a string')
        end
        dat.Name = Value;
        flag(2)=1;
    case 'OutputData'
        [Value,error_str] = datachk(Value,'OutputData');  
        error(error_str)  
        dat.OutputData=Value;
        flag(3)=1;
        
    case 'OutputName'
        dat.OutputName = ChannelNameCheck(Value,'OutputName');
        if ~isempty(idchnona(Value))
            error(sprintf(['Channel names that are abbreviations of ''measured''',...
                    ' and ''noise'' are not allowed.']))
        end
        flag(5)=1;
    case 'OutputUnit'      
        dat.OutputUnit = ChannelNameCheck(Value,'OutputUnit');
        flag(6)=1;
        
    case 'InputData'
        [Value,error_str] = datachk(Value,'InputData');
        error(error_str)
        dat.InputData=Value;
        flag(7)=1;
        
    case 'InputName'
        dat.InputName = ChannelNameCheck(Value,'InputName');
        if ~isempty(idchnona(Value))
            error(sprintf(['Channel names that are abbreviations of ''measured''',...
                    ' and ''noise'' are not allowed.']))
        end
        flag(9)=1;
    case 'InputUnit'
        dat.InputUnit = ChannelNameCheck(Value,'InputUnit');
        flag(10) = 1;
    case 'Period'
        [Value,error_str] = datachk(Value,'Period');    
        error(error_str)
        if Value{1}<0 % Check also the others
            error('The period must be a positive integer or inf')
        end
        dat.Period = Value;
        %%LL Checks
        flag(18)=1;
    case 'InterSample'
        %[Value,stat] = cstrchk(Value,'InterSample');error(stat)
        if ~isstr(Value)&~iscell(Value)
            error('InterSample must be a string or a cell array.')
        end
        if isstr(Value)
            Value={Value};
        end
        [n1,n2]=size(Value);
        for k1=1:n1
            for k2=1:n2
                Name = Value{k1,k2};
                if ~any(strcmp(Name,{'zoh','foh','bl'}) )
                    error(['InterSample must be one of ''zoh'' (zero order hold) ,''foh'' (first order hold), or ''bl'' (band limited)']);
                end
            end
        end
        if isa(Value,'char'),Value={Value};end
        dat.InterSample = Value;
        flag(19)=1;
    case 'Ts',
        [Value,error_str] = datachk(Value,'Ts');    
        error(error_str)
        for kk = 1:length(Value)
            if length(Value{kk})>1|Value{kk}<0 % Check also the others
                error('The sampling interval must be a positive number or the empty matrix')
            end
        end
        dat.Ts=Value; 
        flag(13)=1;
    case 'Tstart'
        % The value check is deferred to the exit checks due to the
        % Unit/Tstart duality
        Tstartold = dat.Tstart;
         dat.Tstart = Value;
        flag(14) = 1;
        
    case 'SamplingInstants'
        if dat.Domain(1)=='F'
            str = 'The Frequency Vector';
        else
            str = 'The Sampling instants vector';
        end
        [Value,error_str] = datachk(Value,str);
        error(error_str)
        dat.SamplingInstants = Value; % Check column or row?
        flag(15) = 1;   
    case 'TimeUnit'
        if ~isa(Value,'char')
            error('The time unit must be a string')
        end
        dat.TimeUnit = Value;
        flag(16) = 1;
    case 'ExperimentName'
        [Value,stat] = cstrchk(Value,'ExperimentName');error(stat)
        if nrtest>1, error('ExperimentName must be of size [1,ne]'),end
        if isa(Value,'char'),Value={Value};end
        dat.ExperimentName = Value;
        flag(17) = 1; 
    case 'Notes'
        dat.Notes = Value;
        
    case 'UserData'
        dat.UserData = Value;
    case 'Utility'
        dat.Utility = Value;
    otherwise
        Property
        Value
        error('Unknown Property')
        
    end % switch
end % for


% EXIT CHECKS:
if any(flag([5 9])) % i/o name
    ChannelNameCheck([dat.InputName;dat.OutputName],'Input/Output Name');
end
dom = dat.Domain;
if strcmp(lower(dom),'frequency')
    sampi = 'frequencies';
    strts = 'Sampling Frequency';
else
    sampi = 'Sampling Instants';
    strts = 'Sampling Interval';
end
% First check te consistencies of the data sizes
dat = timemark(dat);
if any(flag([3,7])) % New data have been defined
    Ney = length(dat.OutputData);
    Neu = length(dat.InputData);
    if isempty(dat.OutputData{1})
        for kk = 1:Neu
            [N,nu]=size(dat.InputData{kk});
            y{kk} = zeros(N,0);
        end
        Ney = Neu;dat.OutputData = y; % 
    end
    if isempty(dat.InputData{1})
        for kk = 1:Ney
            N = size(dat.OutputData{kk},1);
            u{kk} = zeros(N,0);
        end
        Neu = Ney;dat.InputData = u;
    end
    if Neu~=length( dat.ExperimentName)
        dat.ExperimentName = defnum(dat.ExperimentName,'Exp',Neu);
    end
    if ~all(Neu == [Ney,length(dat.ExperimentName)])
        error('OutputData, InputData, and ExperimentName must contain the same number of cells.')
    end
    for kk = 1:Neu
        [Nu,nuk] = size(dat.InputData{kk});
        [Ny,nyk] = size(dat.OutputData{kk}); 
        if kk == 1
            nu1 = nuk; ny1 = nyk;
        end
        if Nu~=Ny 
            error('Each experiment must have the same number of input and output measurements(rows)')
        end
        if nuk ~=nu1 | nyk ~= ny1
            error('The number of input (output) channels must be the same in all experiments.')
        end
    end
end % End of the new data checks (flag 3, 7)

Ne=length(dat.InputData);

if ~flag(13)
    if length(dat.Ts)<Ne
        for kk=length(dat.Ts)+1:Ne
            dat.Ts(kk)=dat.Ts(1);
        end
    elseif length(dat.Ts)>Ne
        dat.Ts=dat.Ts(1:Ne);
    end
end
if ~flag(14)
    if length(dat.Tstart)<Ne
        for kk=length(dat.Tstart)+1:Ne
            dat.Tstart(1,kk)=dat.Tstart(1);
        end
    elseif length(dat.Tstart)>Ne
        dat.Tstart=dat.Tstart(1:Ne);
    end
end

Sampl=dat.SamplingInstants;Ts=dat.Ts;Tstart=dat.Tstart;
if strcmp(lower(dom),'time')
    if flag(13) % Ts has been set
        if Ne>1
            if length(Ts)==1
                Tst=Ts;
                for kk=1:Ne
                    Ts(kk)=Tst;
                end
            elseif Ne~=length(Ts)
                error('The number of SamplingIntervals must equal the number of experiments.')
            end
        end
        for kk=1:Ne
            if ~isempty(Ts{kk})
                Nk=size(dat.InputData{kk},1);
                Sampl{kk}=zeros(Nk,0);
            elseif isempty(Sampl{kk})
                error('If Ts is empty, SamplingInstants must be specified.')
            end
        end
        for kk = 1:Ne
            if ~isempty(Ts{kk})
                if Ts{kk}==0
                    error('For time domain data Ts must be strictly positive.')
                end
            end
        end
    end
    if flag(14) % Tstart has been set
        [Tstart,error_str] = datachk(Tstart,'Tstart');
        error(error_str)
        for kk = 1:length(Tstart)
            if ~ischar(Tstart{kk})&length(Tstart{kk})>1 % Check also the others
                error('Tstart must be a scalar or a cell array of scalars.')
            end
        end
        
        if Ne>1
            if length(Tstart)==1
                Tstartt=Tstart;
                for kk=1:Ne
                    Tstart(kk)=Tstartt;
                end
            elseif Ne~=length(Tstart)
                error('The number of Tstart values must equal the number of experiments.')
            end
        end
        for kexp = 1:Ne
            if isempty(Ts{kexp})&~isempty(Tstart{kexp})
                error('Tstart can be defined only if ''Ts'' is defined (equal sampling).')
            end
        end
    end
    if Ne>1
        if length(Sampl)==1
            Samplt=Sampl;
            for kk=1:Ne
                Sampl(kk)=Samplt;
            end
        elseif Ne~=length(Sampl)
            error('The number of cells in SamplingInstants must equal the number of experiments.')
        end
    end
    for kk=1:Ne
        Nk=size(dat.InputData{kk},1);
        if isempty(Sampl{kk})
            Sampl{kk}=zeros(Nk,0);
        end
        if size(Sampl{kk},1)~=Nk
            error('The number of specified SamplingInstants must equal the number of observations.')
        end
        if ~isempty(Sampl{kk})
            % First check if it is equal sampling:
            ds = diff(Sampl{kk});
            if isempty(ds),ds=1;end
            if norm(ds(1)-ds)<(0.00001/max(ds)) % This might be tuned
                Ts{kk} = ds(1); Tstart{kk}=Sampl{kk}(1);
                Sampl{kk} = zeros(Nk,0);
            else
                %disp('Warning: Ts and Tstart have been set to [].')
                Ts{kk} = []; Tstart{kk} = [];
            end
        elseif isempty(Ts{kk})
            error('If Ts is empty, SamplingInstants must be specified.')
        end
    end
else %% Here are the tests in the frequency domain case
    if isempty(Sampl{1})
        error(sprintf(['A frequency vector must always be supplied for Frequency Domain Data',...
                '\nInclude the pair ...''Freq'',Frequencies,... in the SET or IDDATA command.']))
    end
    if flag(14) % Tstart = unit has been set
        if ischar(Tstart)
            tss = Tstart;clear Tstart
            for kexp = 1:Ne
                Tstart{1,kexp} = tss;
            end
        end
        
        [Tstart,errorstr] = cstrchk(Tstart,'Unit');
         error(errorstr)
         try
         dispw = 0;
         for kexp = 1:length(Tstart)
             if lower(Tstart{kexp}(1))~=lower(Tstartold{kexp}(1))
                 dispw = 1;
             end
         end
         if dispw
             tsw = sprintf('%s ',Tstart{:});
             tsw = tsw(1:end-1);
             if length(Tstart)>1
                 tsw = ['{',tsw,'}'];
             end
        warning(sprintf(['The frequency unit has been set to ', tsw,'.',...
                '\nTo convert the Units and automatically scale frequency',...
                ' points, use CHGUNITS instead.']))
    end
end
        
        if length(Tstart)~=Ne
            error('''Unit'' must be a cell array of length equal to the number of experiments.')
        end
    end
    if flag(15) % SamplingInstants = Frewuency has been set
        if Ne>1
            if length(Sampl)==1
                Samplt=Sampl;
                for kk=1:Ne
                    Sampl(kk)=Samplt;
                end
            elseif Ne~=length(Sampl)
                error('The number of cells in ''Frequency'' must equal the number of experiments.')
            end
        end
        for kk=1:Ne
            Nk=size(dat.InputData{kk},1);
%             if isempty(Sampl{kk})
%                 Sampl{kk}=zeros(Nk,0);
%             end
Sampl{kk}=Sampl{kk}(:);  %%LL
            if size(Sampl{kk},1)~=Nk
                error('The number of rows in ''Frequency'' must equal the number of observations.')
            end
        end
    end
    if flag(13) % Ts has been set
        if Ne>1
            if length(Ts)==1
                Tst=Ts;
                for kk=1:Ne
                    Ts(kk)=Tst;
                end
            elseif Ne~=length(Ts)
                error('The number of SamplingIntervals must equal the number of experiments.')
            end
        end
        for kk=1:Ne
            if isempty(Ts{kk})
                error('For frequency domain data Ts must be a nonegative number (not empty).')
            end
        end
    end
end
dat.Ts=Ts;dat.SamplingInstants=Sampl;dat.Tstart=Tstart;
nu=size(dat.InputData{1},2);ny=size(dat.OutputData{1},2);

%if ny>0
if length(dat.OutputName)~=ny 
    if flag(5)
        error('The number of OutputNames must equal the number of output channels. Use a cell array.')
    else
        dat.OutputName = defnum(dat.OutputName,'y',ny);
    end
end
if length(dat.OutputUnit)~=ny 
    if flag(6)
        error('The number of OutputUnits must equal the number of output channels.')
    else
        dat.OutputUnit = defnum(dat.OutputUnit,'',ny);
    end
end
%end  

%if nu>0
if length(dat.InputName)~=nu
    if flag(9)
        error('The number of InputNames must equal the number of input channels.')
    else
        dat.InputName = defnum(dat.InputName,'u',nu);
    end
end
if length(dat.InputUnit)~=nu
    if flag(10)
        error('The number of InputUnits must equal the number of input channels.')
    else
        dat.InputUnit = defnum(dat.InputUnit,'',nu);
    end
end
%end  
if length(dat.ExperimentName)~=Ne
    if flag(17)
        error('The number of ExperimentNames must equal the number of Experiments.')
    else
        dat.ExperimentName = defnum(dat.ExperimentName,'Exp',Ne);
    end
end

for kk=1:nu
    if length(strmatch(dat.InputName{kk},dat.InputName,'exact'))>1
        error('The Inputs must have unique names.')
    end
end
for kk=1:ny
    if length(strmatch(dat.OutputName{kk},dat.OutputName,'exact'))>1
        error('The Outputs must have unique names.')
    end
end
for kk=1:Ne
    if length(strmatch(dat.ExperimentName{kk},dat.ExperimentName,'exact'))>1
        error('The Experiments must have unique names.')
    end
end

if any(flag([18 19 3 7]))
    Np=length(dat.Period);
    [nui,Ni]=size(dat.InterSample);
    if Np~=Ne
        if flag(18)
            error('''Period'' must have the same number of cells as the number of experiments')
        elseif Np>Ne
            dat.Period=dat.Period(1:Ne);
        else
            for kk=Np+1:Ne
                dat.Period{kk}=inf*ones(nu,1);
            end
        end
    end
    if (Ne~=Ni|nui~=nu) & (nu>0) %%LL%%
        if flag(19)
            error('''InterSample'' must be a cell array of size # of inputs by # of experiments.')  
        elseif Np>Ne
            dat.InterSample=dat.InterSample(:,1:Ne);
        else
            for kk=1:Ne
                if nu==0
                    dat.InterSample = cell(0,Ne);
                end
                
                for ku=1:nu
                    dat.InterSample{ku,kk}='zoh'; %%LL only new values here!
                end
            end
        end
    end
    
    for ke=1:Ne
        [nup,nitest]=size(dat.Period{ke});
        if nitest~=1|nup~=nu
            if flag(18)
                error('For each experiment, ''Period'' must be a nu-by-1 vector.')
            elseif nu<nup
                dat.Period{ke}=dat.Period{ke}(1:nu,1);
            else
                dat.Period{ke}(nup+1:nu,1)=inf*ones(nu-nup,1);
            end
        end
    end
end
%Dito expname

Out = dat;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name)
% Checks specified I/O names
if isempty(a),  
    a = a(:);   % make 0x1
    return  
end

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(a) & ndims(a)==2,
    % A is a 2D array of padded strings
    a = cellstr(a);
    
elseif iscellstr(a) & ndims(a)==2 & min(size(a))==1,
    % A is a cell vector of strings. Check that each entry
    % is a single-line string
    a = a(:);
    if any(cellfun('ndims',a)>2) | any(cellfun('size',a,1)>1),
        error(sprintf('All cell entries of %s must be single-line strings.',Name))
    end
    
else
    error(sprintf('%s %s\n%s',Name,...
        'must be a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])',...
        'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'))
end

% Make sure that nonempty I/O names are unique
as = sortrows(char(a));
repeat = (any(as~=' ',2) & all(as==strvcat(as(2:end,:),' '),2));
test = 1;
try
    if strcmp(lower(Name(end-3:end)),'unit')
        test = 0;
    end
end

if any(repeat)&test
    error(sprintf('%s: channel names must be unique.',Name))
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
