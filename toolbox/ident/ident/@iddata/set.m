function Out = set(sys,varargin)
%SET  Set properties of IDDATA objects.
%
%   SET(DAT,'PropertyName',VALUE) sets the property 'PropertyName'
%   of the IDDATA object to DAT the value VALUE.  An equivalent syntax 
%   is 
%       DAT.PropertyName = VALUE .
%
%   SET(DAT,'Property1',Value1,'Property2',Value2,...) sets multiple 
%   IDDATA property values with a single statement.
%
%   SET(DAT,'Property') displays legitimate values for the specified
%   property of DAT.
%
%   SET(DAT) displays all properties of DAT and their admissible 
%   values.  Type IDPROPS IDDATA for more details on IDDAAT properties.
%
%
%   See also GET, IDDATA, IDPROPS.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $ $Date: 2004/04/10 23:16:21 $

ni = nargin;
no = nargout;

if ~isa(sys,'iddata'),
   % Call built-in SET. Handles calls like set(gcf,'user',ss)
   builtin('set',sys,varargin{:});
   return
elseif no & ni>2,
   error('Output argument allowed only in SET(SYS) or SET(SYS,Property).');
end
if nargin>4 % Take out domain first to handle time/frequency correclty
    
    domt = find(strncmp(lower(varargin(1:2:ni-1)),'d',1));
   
    if ~isempty(domt)
        Value = varargin{2*domt};
       if ~(strcmp(lower(Value(1)),'t')|strcmp(lower(Value(1)),'f'))
            error('Domain must be one of ''Time'' or ''Frequency''')
        end
        if lower(Value(1))=='t'
            Value = 'Time';
        else
            Value = 'Frequency';
        end
        sys.Domain=Value;
         varargin(2*domt-1:domt*2)=[];
        set(sys,varargin{:});  
        sysname =inputname(1);
        assignin('caller',sysname,sys)
         return
    end
end
% If property 'f(frequency)' is listed, be forgivning and change
% frequency domain:
if nargin>2 & lower(sys.Domain(1))=='t'
    for kp = 1:2:nargin
        try
            pnmatchd(varargin{kp},{'Frequency'});
            sys.Domain = 'Frequency';
            warning('IDENT:Message','Data Domain set to ''Frequency''.')
            set(sys,varargin{:});  
            sysname =inputname(1);
            assignin('caller',sysname,sys)
            return
        end
    end
end
     % Get public properties and their assignable values
    [AllProps,AsgnValues] = pnames(sys); 
    if strcmp(lower(sys.Domain),'frequency')
        freqflag = 1;
        tsnames = AllProps(11:14);
        %fsnames = {'Fs';'Fstart';'SamplingFrequencies';'FrequencyUnit'};
        fsnames = {'Ts';'Units';'Frequency';'TimeUnit'}; %Ts and TimeUnit not changed
        AllProps(11:14)= fsnames;
        AsgnValues(11:14)={  'Sampling Interval (0 means continuous time data)';...
                'String: Frequency unit';...
                'N-by-1 matrix of frequency values';...
                'String'};
    else
        freqflag = 0;
    end
    
    % Handle read-only cases
    if ni==1,
   % SET(SYS) or S = SET(SYS)
   if no,
      Out = cell2struct(AsgnValues,AllProps,1);
   else
      propse = cell(19,1);
      valse = cell(19,1);
      propse([1 2 3 5 6 7 9:19]) = AllProps(1:17);
      valse([1 2 3 5 6 7 9:19]) =AsgnValues(1:17);
      propse{4} = 'y';
      valse{4} = 'Same as OutputData';
      propse{8} = 'u';
      valse{8} = 'Same as InputData';
      cell2struct(valse,propse,1)
      disp(sprintf('\nType "idprops %s" for more details.',class(sys)))
   end
   
elseif ni==2,
   % SET(SYS,'Property') or STR = SET(SYS,'Property')
   % Return admissible property value(s)
   try
      [Property,imatch] = pnmatchd(varargin{1},AllProps,7);
      if no,
         Out = AsgnValues{imatch};
      else
         disp(AsgnValues{imatch})
      end
   catch 
      error(lasterr)
   end
   
else
   % SET(SYS,'Prop1',Value1, ...)
   
   sysname = inputname(1);
   if isempty(sysname),
      error('First argument to SET must be a named variable.')
   elseif rem(ni-1,2)~=0,
      error('Property/value pairs must come in even number.')
   end
   
   % Match specified property names against list of public properties and
   % set property values at object level
   try
      for i=1:2:ni-1 
         varargin{i} = pnmatchd(varargin{i},AllProps,7);
         if freqflag
            fsind = strmatch(varargin{i},fsnames,'exact');
            if ~isempty(fsind)
               varargin(i) = tsnames(fsind);
            end
         end
         
      end
      sys = pvset(sys,varargin{:});
   catch
      error(lasterr)
   end
   
   % Assign sys in caller's workspace
   assignin('caller',sysname,sys)
   
end

