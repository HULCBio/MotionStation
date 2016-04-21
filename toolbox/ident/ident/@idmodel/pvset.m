function sys = pvset(sys,varargin)
%PVSET  Set properties of IDMODEL models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET. 

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.28.4.2 $ $Date: 2004/04/10 23:17:35 $

% RE: PVSET is performing object-specific property value setting
%     for the generic LTI/SET method. It expects true property names.


% The commented part below only for I/O names and units

 ut = sys.Utility;
 if isfield(ut,'Pmodel')|isfield(ut,'Idpoly') % To check if ynames etc shall be
                                   % updated in Utility models
     utupdate = 1;
 else
     utupdate = 0;
 end
pnflag = 0;
covflag =0;
        ionameflag = 0;

for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    if utupdate
        if any(strcmp(Property,{'InputName','OutputName','InputUnit','OutputUnit'}))
            sys = utfix(sys,Property,Value);
        end
    end
    % Set property values
    switch Property      
    case 'Ts'
        if isempty(Value),  
            Value = 1;  
        end
        if ndims(Value)>2 | length(Value)~=1 | ~isreal(Value) | ~isfinite(Value),
            error('Sample time must be a real number.')
        elseif Value<0 %& Value~=-1,
            error('Negative sample time not allowed. Use Ts = 0 to denote continuous time.');
        end
        sys.Ts = Value;
    case 'Name'
        sys.Name = Value;
    case 'InputName'
        sys.InputName = ChannelNameCheck(Value,'InputName');
        ionameflag = 1;
      if ~isempty(idchnona(Value))
          error(sprintf(['Channel names that are abbreviations of ''measured''',...
              ' and ''noise'' are not allowed.']))
  end
   case 'OutputName'
      sys.OutputName = ChannelNameCheck(Value,'OutputName');
              ionameflag = 1;
          if ~isempty(idchnona(Value))
          error(sprintf(['Channel names that are abbreviations of ''measured''',...
              ' and ''noise'' are not allowed.']))
  end
      
   case 'InputUnit'
      sys.InputUnit =  ChannelNameCheck(Value,'InputUnit');
      
   case 'OutputUnit'
      sys.OutputUnit = ChannelNameCheck(Value,'OutputUnit');
      
   case 'InputDelay'
      if ~isa(Value,'double')|~isreal(Value)
         error('InputDelay must be a vector of reals.')
      end
      Value = Value(:);
      sys.InputDelay = Value;  
      
   case 'Notes'
      sys.Notes = Value;
      
   case 'UserData'
      sys.UserData = Value;
   case 'TimeUnit'
      sys.TimeUnit = Value;
      
   case 'Algorithm'
      [dum,fie,typ,def] = iddef('algorithm');
      if ~isstruct(Value)
         disp('Algorithm must be a structure with the following fields:')
         disp(fie')
         error(' ')
      end
      
      fie2 = fieldnames(Value);
      for kk = 1:length(fie)
         kf = find(strcmp(fie{kk},fie2)==1);
         if isempty(kf)
            disp(['Algorithm must contain the following fields:'])
            disp(fie')
            error(' ')
         else
            [Value1,err] = checkalg(fie2{kf},getfield(Value,fie2{kf}),fie,typ,def);
            Value=setfield(Value,fie2{kf},Value1);
         end
      end
      sys.Algorithm = Value;
      
   case 'EstimationInfo',
      sys.EstimationInfo = Value;
      
   case 'ParameterVector'
      sys.ParameterVector = Value(:);
   case 'PName'
      pnflag = 1;
      sys.PName =  ChannelNameCheck(Value,'PName');   
   case 'CovarianceMatrix'
      if ischar(Value),
         if lower(Value(1))=='e'
            Value =[];
         else
            Value = 'None';
         end
      end
      sys.CovarianceMatrix = Value;
      covflag = 1;
      
   case 'NoiseVariance'
        if max(abs(imag(diag(Value))))>eps
          error('The Noise Variance matrix must have real diagonal elements.')
      end
      Value = (Value'+Value)/2;
      if size(Value,1)~=size(Value,2)
          error('The Noise Variance matrix must be square.')
      end
      if any(any(isnan(Value)))
          Value=eye(size(Value));
          warning(sprintf(['NoiseVariance contains NaNs.\nThis could mean',...
              ' that the model has some serious problems. \nNoiseVariance has been',...
              ' replaced by the identitity matrix.']));
      end
       eigtest = min(eig(Value));
      if eigtest<0
          Value = Value + abs(eigtest)*eye(size(Value));
         warning(sprintf(['NoiseVariance must be a positive',...
                 ' semidefinite matrix. \nIt has been adjusted to be that.']))
         end
      sys.NoiseVariance = Value;
   case 'Utility'
      sys.Utility = Value;
   case 'Version'
      sys.Version = Value;
   case 'UserData'
      sys.UserData = Value;
   otherwise  
      [dum,PropAlg,TypeAlg,DefValue]=iddef('algorithm');
      [Value,errormsg] = checkalg(Property,Value,PropAlg,TypeAlg,DefValue);
      error(errormsg)
      Algorithm = sys.Algorithm;
      Algorithm = setfield(Algorithm,Property,Value);
      sys.Algorithm = Algorithm;  
   end % switch
end % for
np = length(sys.ParameterVector);
if np ~= length(sys.PName)& ~isempty(sys.PName)
   if pnflag
      error('The length of PName must equal the length of ParameterVector.')
   end
   sys.PName = defnum(sys.PName,'',np);
end
if sys.Ts
   if ~isempty(sys.InputDelay)&(any(sys.InputDelay~=fix(sys.InputDelay)))
      error('For discrete time systems, InputDelay must be integers.')
   end
end
if ionameflag
     ChannelNameCheck([sys.InputName;sys.OutputName],'Input/Output Name');
end
if covflag
    cov = sys.CovarianceMatrix;
    if ~ischar(cov)&~isempty(cov)
        [n1,n2] = size(cov);
        if n1~=np|n2~=np
            error('Covariance Matrix must be square of size length(ParameterVector).')
        end
    elseif (ischar(cov)&strcmp(lower(cov(1)),'n'))|isempty(cov) % If covariance has been nullified the "variance models" should be deleted:
        ut = sys.Utility; 
        try
            ut.Pmodel = [];
            ut.Idpoly = [];
        end
        sys.Utility = ut;
    end 
end
% Note: size consistency checks deferred to idss/pvset, idpoly/pvset,...
%       to allow resizing of the I/O dimensions

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = utfix(sys,Property,Value);
ut = sys.Utility;
try 
    ut.Pmodel = pvset(ut.Pmodel,Property,Value);
end
  try
    idp = ut.Idpoly;
catch
    idp = [];
end
if ~isempty(idp)
    for ki = 1:length(idp)
        idp{ki} = pvset(idp{ki},Property,Value);
    end
    ut.Idpoly = idp;
end
sys.Utility = ut;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Value,errormsg] = checkalg(Property,Value,PropAlg,TypeAlg,DefValue)
errormsg = [];
switch Property
case PropAlg
   focskip = 0;
   if strcmp(Property,'Focus')  
       if isa(Value,'idmodel')|isa(Value,'lti')|iscell(Value)
           focskip = 1;
           if iscell(Value)
               if ~any(length(Value)==[2,4,5])%&length(Value)~=2&length(Value)~=5
                   error(sprintf(['The Focus Filter must be either an LTI object or an',...
                           '\nIDMODEL object or {a,b,c,d} or {num,den}.']))
               end
           else
               [ny,nu]=size(Value); 
               if max(ny,nu)>1|nu==0
                   error('The Focus Filter must be a SISO system.')
               end
           end
           return
       end
       if isnumeric(Value),  %%TM
           if size(Value,2)==2 | size(Value,2)==1,
               return
           end
       end
   end
   
   nr = strcmp(Property,PropAlg);
   prop = PropAlg(find(nr));
   typ = TypeAlg(find(nr)); 
   if isempty(Value), Value = DefValue{nr};return,end
   if strcmp(prop,'Focus')&~focskip
      try
         [Value,status]=pnmatchd(Value,typ{:},6); 
      catch
         error(sprintf(['Invalid value for ''Focus''.',...
               '\nShould be ''Prediction'', ''Simulation'',''Stability'', or a filter.']))           
      end
   elseif strcmp(prop,'N4Horizon')
      if ischar(Value)
         Value = 'Auto';
      else
         [nr,nc] = size(Value);
         if nc == 1
            Value = Value*ones(1,3);
         elseif nc~=3
            error(sprintf([' Invalid value for ''N4Horizon''.\n It should be a ',...
                  'column vector or matrix with 3 columns.']));
         end
         if ~isempty(Value)&(isstr(Value)|~isreal(Value)|any(Value<0)|...
               any(fix(Value)~=Value))
            error([prop{1},' must be an array of positive integers.'])
         end
         
      end
   elseif strcmp(prop,'N4Weight')
      typ = typ{1};
      
      try
         [Value,status]=pnmatchd(Value,{typ{:}},6); 
      catch
         error(sprintf(['Invalid value for ''N4Weight''.',...
               '\nShould be ''Auto'', ''MOESP'', or ''CVA''.']))
      end
      
   else 
      typ = typ{1};
      if length(typ)>1
         try
            [Value,status]=pnmatchd(Value,{typ{:}},6);
         catch
            disp(['Possible values for ',prop{1},':']) 
            disp(typ)
            error(lasterr)
         end
      else
         switch typ{1}
         case 'positive'
            if isstr(Value)|~isreal(Value)|length(Value)>1|any(Value<0)
               error([Property,' must be a positive real number or 0.'])
            end
         case 'integer'
            if strcmp(Property,'MaxSize')&(isstr(Value)|isempty(Value))
               Value = 'Auto';
            elseif strcmp(Property,'MaxIter')&(Value==-1|Value==0)
            elseif isstr(Value)|~isreal(Value)|length(Value)>1|...
                  any(Value<=0)|any(fix(Value)~=Value)
               error([Property,' must be a positive integer.'])
            end
            if strcmp(Property,'MaxSize')&~ischar(Value)
                if Value<50
                    warning('Such a small value of MaxSize may cause problems.')
                end
            end
            
         case 'intarray'
            if ~strcmp(prop,'N4Horizon')
               if ~isempty(Value)&(isstr(Value)|~isreal(Value)|any(Value<0)|...
                     any(fix(Value)~=Value))
                  error([Property,' must be an array of positive integers.'])
               end
            end
         case 'structure'
            if ~isstruct(Value)
               error([Property, ' must be a structure.'])
            end
            % More tests could be added 
         end
      end
   end
otherwise   
   error('Unexpected property name.')
end
