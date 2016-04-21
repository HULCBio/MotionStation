function sys = pvset(sys,varargin)
%PVSET  Set properties of IDFRD models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2001/08/10 15:26:12 $

unitsChanged = 0;
freqChanged = 0;
for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property      
    case 'Ts'
        if isempty(Value),  
            Value = 1;  
        end
        if ndims(Value)>2 | length(Value)~=1 | ~isreal(Value) | ~isfinite(Value),
            error('Sample time must be a real number.')
        elseif Value<0 
            error('Negative sample time not allowed.');
        end
        sys.Ts = Value;
        
    case 'InputName'
        sys.InputName = ChannelNameCheck(Value,'InputName');
           if ~isempty(idchnona(Value))
          error(sprintf(['Channel names that are abbreviations of ''measured''',...
              ' and ''noise'' are not allowed.']))
  end
        
    case 'OutputName'
        sys.OutputName = ChannelNameCheck(Value,'OutputName');
           if ~isempty(idchnona(Value))
          error(sprintf(['Channel names that are abbreviations of ''measured''',...
              ' and ''noise'' are not allowed.']))
  end
        
    case 'InputUnit'
        sys.InputUnit =  ChannelNameCheck(Value,'InputUnit');
        
        
    case 'OutputUnit'
        sys.OutputUnit = ChannelNameCheck(Value,'OutputUnit');
        
    case 'Notes'
        sys.Notes = Value;
        
    case 'UserData'
        sys.UserData = Value;
        
    case 'EstimationInfo',
        sys.EstimationInfo = Value;
        
    case 'ResponseData'  
        
        sys.ResponseData = Value;
        
    case 'CovarianceData'  
        sys.CovarianceData = Value;
        
    case 'SpectrumData'
        sys.SpectrumData = Value;
    case 'NoiseCovariance'
        sys.NoiseCovariance = Value;
    case 'Frequency'
        nd = ndims(Value);
        m = min(size(Value));
        if nd~=2 | m ~= 1
            error('FREQS must be a vector of nonnegative real values.')
        end
        if any(Value<0)|any(imag(Value)~=0)
            error('FREQS must be a vector of nonnegative real values.')
        end
        
        sys.Frequency = Value(:);
        freqChanged = 1;
    case 'Units'
        if ~isstr(Value),
            error('The property "Units" must be set to a string.');
        elseif strncmpi(Value,'r',1)
            Value = 'rad/s';
        elseif strncmpi(Value,'h',1)
            Value = 'Hz';
        else
            error('"Units" property must be either ''rad/s'' or ''Hz''');
        end
	if ~strcmp(sys.Units,Value)
        unitsChanged = 1;
	sys.Units = Value;
	end
        
    case 'InputDelay'
        if ~isa(Value,'double')|~isreal(Value)
            error('InputDelay must be a vector or reals.')
        end
        Value = Value(:);
        sys.InputDelay = Value;  
    case 'Version'
        sys.Version = Value;
    case 'Notes'
        sys.Notes = Value;
    case 'UserData'
        sys.UserData = Value;
    case 'Utility'
        sys.Utility = Value;
    case 'Name'
        sys.Name = Value;
    otherwise
        disp(['Unexpected Property ',Property])   
    end % switch
end % for

%%%% Consistency checks
sys = timemark(sys);
Nf = length(sys.Frequency);
Value = sys.ResponseData;
nd = ndims(Value);
if Nf>1
    if nd == 2
        nd = min(size(Value));
    end
    if ~any(nd==[0 1 3]) 
        error(sprintf(['The response data must be a vector for SISO systems',...
                '\nor a 3-D array RESPONSE(NY,NU,FREQS) for MIMO, MISO and SIMO.']))
    end       
    if nd == 1
        Va = zeros(1,1,length(Value));
        Va(1,1,:) = Value;
        sys.ResponseData = Va;
    end
end

[nyr,nur,Nr] = size(sys.ResponseData);

Value = sys.CovarianceData;
if ~isempty(Value)
    nd = ndims(Value);
    if nd~=5
        error(sprintf(['The covariance data must be a 5-D',...
                ' array COVARIANCE(NY,NU,FREQS,:,:)\nwhere the last two',...
                ' dimensions hold the 2-by-2 covariance matrix.']))
    end
    [n1,n2,n3,n4,n5]=size(Value);
    if ~(n4==2&n5==2) | n3~=Nf | nyr~=n1 |n2~=nur
        error(sprintf(['The covariance data must be a 5-D',...
                ' array COVARIANCE(NY,NU,FREQS,:,:)\nwhere the last two',...
                ' dimensions hold the 2-by-2 covariance matrix.']))
    end
end

Value = sys.SpectrumData;
if ~isempty(Value)
    if Nf>1 
        nd = ndims(Value);
        if nd == 2
            nd = min(size(Value));
        end
        if ~(nd==1 | nd==3)
            error(sprintf(['The spectrum data must be a vector for SISO systems',...
                    '\nor a 3-D array SPECTRUM(NY,NY,FREQS) for multioutput systems.']))
        end  
        if nd == 1
            Va = zeros(1,1,length(Value));
            Va(1,1,:) = Value;
            sys.SpectrumData = Va; 
        end
    end
    [nys,nus,nfs]= size(sys.SpectrumData);
    if nys~=nus|nfs~=Nf
        error('Spectrum data must be a Ny-by-Ny-by-Nf 3-D array.')
    end
    if nyr>0
        if nys~=nyr 
            error(['The Spectrum data must have the same number of outputs',...
                    ' as the Response data.'])
        end
    end
else 
    nys = 0;
end
Value = sys.NoiseCovariance;
if ~isempty(Value)
    if Nf > 1
        nd = ndims(Value);
        if nd ==2
            nd = min(size(Value));
        end
        if ~(nd==1 | nd==3)
            error(sprintf(['The spectrum variance data must be a vector for SISO systems',...
                    '\nor a 3-D array COVSPECT(NY,NY,FREQS) for multioutput systems.']))
        end
        if nd == 1
            Va = zeros(1,1,length(Value));
            Va(1,1,:) = Value;
            sys.NoiseCovariance = Va;
        end
        [nyn,nun,nfn]= size(sys.NoiseCovariance);
        if nyn~=nun|nyn~=nys|nfn ~= Nf
            error('Spectrum variance data must be a Ny-by-Ny-by-Nf 3-D array.')
        end
    end
end

ny = max(nys,nyr);
sys = idmcheck(sys,[ny,nur]);
if unitsChanged & ~freqChanged 
    warning(sprintf('%s\n%s','''Units'' property changed. To convert IDFRD Units and', ...
        'automatically scale frequency points, use CHGUNITS instead.'));
end

if sys.Ts
    if any(sys.InputDelay~=fix(sys.InputDelay))
        error('For discrete time systems, InputDelay must be integers.')
    end
end

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
