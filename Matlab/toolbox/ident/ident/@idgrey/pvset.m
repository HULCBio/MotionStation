function sys = pvset(sys,varargin)
%PVSET  Set properties of IDGREY models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:17:01 $

% RE: PVSET is performing object-specific property value setting
%     for the generic IDMODEL/SET method. It expects true property names.


excheck = 1; % Default to perform exit checks
try
    if strcmp(varargin{end},'noexit')
        excheck = 0;
        varargin = varargin(1:end-1);
    end
end
parflag = 0; 
ni=length(varargin);
IDMProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the IDMODEL parent
Knew = [];
Xnew = [];
for i=1:2:ni,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property      
    case 'MfileName' 
        if ~isa(Value,'char')
            error('''MfileName'' must be a string.')
        end
        sys.MfileName = Value;
        
    case 'FileArgument' 
        sys.FileArgument = Value;
    case 'CDmfile'
        %err = 0;
        %if ~ischar(Value),err = 1;end
        try
            Value = pnmatchd(Value,{'c';'cd';'d'});
        catch
            error(sprintf(['Invalid value for ''CDmfile''.\nShould be one of ''c'', ''d'', or ''cd''.']))
        end
        sys.CDmfile = Value;
    case 'StateName'
        sys.StateName = idnamchk(Value,'StateName');
    case {'A','B','C','D'}%,'K','X0'} 
        error('Matrix values cannot be set for IDGREY models.')
    case 'K'
        Knew = Value;
    case 'X0'
        Xnew = Value;
    case {'dA','dB','dC','dD','dK','dX0'}
        error('Standard deviations cannot be set. Use ''CovarianceMatrix''.')
        
    case 'ParameterVector',
        if ~isa(Value,'double')
            error('''ParameterVector'' must be a vector of numbers.')
        end
        
        Value=Value(:);
        sys.idmodel=pvset(sys.idmodel,'ParameterVector', Value);
        parflag=1; 
    case 'InitialState' % same value tests
        PossVal = {'Model';'Auto';'Estimate';'Zero';'Fixed';'Backcast'};
        try
            Value = pnmatchd(Value,PossVal,2);
        catch
            disp('Invalid property for ''InitialState''')
            error(['Should be one of ''Model|Auto|Estimate|Zero|Fixed|Backcast'''])  
        end
        sys.InitialState = Value;
    case 'DisturbanceModel' % same value tests
        PossVal = {'Model';'Estimate';'None';'Zero';'Fixed'};
        try
            Value = pnmatchd(Value,PossVal,2);
        catch
            disp('Invalid property for ''DisturbanceModel''')
            error(['Should be one of ''Model|Estimate|None|Fixed'''])  
        end
        if strcmp(Value,'Zero')
            Value = 'None';
        end
        sys.DisturbanceModel = Value;
        case 'idmodel'
        sys.idmodel = Value;
    otherwise
        IDMProps([i i+1]) = 1;
        varargin{i} = Property;
    end %switch
    
end % for

IDMProps = find(IDMProps);
if ~isempty(IDMProps)
    sys.idmodel = pvset(sys.idmodel,varargin{IDMProps});
end
sys = timemark(sys,'l');
if excheck
Est=pvget(sys.idmodel,'EstimationInfo');
if strcmp(Est.Status(1:3),'Est')   
    Est.Status='Model modified after last estimate';
    sys.idmodel=pvset(sys.idmodel,'EstimationInfo',Est);
end
end
%
try
    [a,b,c,d,k,x0]=ssdata(sys);
catch
    error(sprintf(['Cannot evaluate model. Check MfileName and size of ParameterVector.',...
            '\nError message:',lasterr]))
end
if ~isempty(Xnew)
    x0 = Xnew;
end
error(abccheck(a,b,c,d,k,x0,'mat')) %% should be val if xnew was set
[ny,nu]=size(d);nx = size(a,1);
if ~isempty(Knew)
    if ~any(strcmp(sys.DisturbanceModel,{'Fixed';'Estimate'}))
        error('''K'' can be set only if ''DisturbanceModel'' is ''Fixed'' or ''Estimate''');
    else
        [nxk,nyk] = size(Knew);
        if nxk~=nx|nyk~=ny
            error(sprintf('The K-matrix must be %d-by-%d.',nx,ny))
        end
        ut = pvget(sys,'Utility');
        ut.K = Knew;
        sys = pvset(sys,'Utility',ut);
    end
end
if ~isempty(Xnew)
    if ~any(strcmp(sys.InitialState,{'Fixed';'Estimate'}))
        error('''X0'' can be set only if ''InitialState'' is ''Fixed'' or ''Estimate''');
    else
        [nxk,nyk] = size(Xnew);
        if nxk~=nx|nyk~=1
            error(sprintf('X0 must be a %d-by-%d column vector',nx,1))
        end
        ut = pvget(sys,'Utility');
        ut.X0 = Xnew;
        sys = pvset(sys,'Utility',ut);
    end
end     
if nx ~= length(sys.StateName)
    sys.StateName = defnum(sys.StateName,'x',nx);
end
sys.idmodel = idmcheck(sys.idmodel,[ny,nu]);



