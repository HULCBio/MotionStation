function obj = analoginput(varargin)
%ANALOGINPUT Construct analog input object.
%
%    AI = ANALOGINPUT('ADAPTOR')
%    AI = ANALOGINPUT('ADAPTOR',ID) constructs an analog input object
%    associated with adaptor, ADAPTOR, with device identification, ID.
%
%    The supported adaptors are:
%       advantech
%       hpe1432
%		keithley
%		mcc
%       nidaq
%       winsound
% 
%    ID does not need to be specified for the winsound adaptor if the
%    ID = 0.  The analog input object is returned to AI.
%
%    In order to perform a data acquisition task with the object, AI,
%    channels must be added with ADDCHANNEL.
%
%    Examples:
%       AI = analoginput('winsound');
%       AI = analoginput('nidaq',16);
%
%    See also ADDCHANNEL, PROPINFO.
%

%    CP 2-25-98
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.16.2.8 $  $Date: 2004/04/16 22:01:42 $

%    Object fields
%       .handle     - hidden unique handle from DAQMEX associated with the
%                     channel.
%       .version    - class version number.
%       .info       - Structure containing strings used to provide object
%                     methods with information regarding the object.  Its
%                     fields are:
%                       .prefix     - 'a' or 'an' prefix that would preceed the
%                                     object type name.
%                       .objtype    - object type with first characters capitalized.
%                       .addchild   - method name to add children, ie. 'addchannel'
%                                     or 'addline'.
%                       .child      - type of children associated with the object
%                                     such as 'Channel' or 'Line'.
%                       .childconst - constructor used to create children, ie. 'aichannel',
%                                     'aochannel' or 'dioline'.

% Default constructor.
if nargin==0 
   error('daq:analoginput:argcheck', 'ADAPTOR and ID must be specified.');
end

% Initialize variables.
name_tag='-AI';
PropName='Name';  % OBJ property name used to contain the default object name.
tlbx_version=1.0;

% Structure of descriptive information used to generalize object methods.
info.prefix='an';
info.objtype='Analog Input';
info.addchild='addchannel';
info.child='Channel';
info.childconst='aichannel';

if isa(varargin{1},'int32'),
   %  First argument is an int32 type.
   %  DAQMEX is calling the constructor and is passing a numerical handle.
   %  Create the object with a DAQDEVICE parent, pass it back to DAQMEX, and get out.
   obj.handle = varargin{1};
   obj.version = tlbx_version;
   obj.info = info;
   
   dev = daqdevice;
   obj = class(obj, 'analoginput', dev);
   return
   
elseif ischar(varargin{1}),
   % User is calling the constructor.  Expect a DRIVERNAME and possibly 
   % an ID.  Create and return the object to the user.
   try
      if isempty(varargin{1}),
         error('daq:analoginput:invalidadaptor', 'ADAPTOR specified cannot be empty.')
      end
      
      % Make sure the additional inputs are either strings or numbers.
      for i=2:nargin,
         if any(strcmp(class(varargin{i}),{'double' 'char'})) && ~isempty(varargin{i}),
            varargin{i} = num2str(varargin{i});            
         else
            error('daq:analoginput:invalidid', 'ID must be specified as a string or number.')
         end                  
      end
      
      % Store the adaptor information for the name creation.
      adaptor = varargin{1};
    
      %  Append tag1 and tag2 to DRIVERNAME to assemble the proper DLL name
      %  to pass to DAQMEX.
      %  Pass all other arguments to DAQMEX to create the object.
      try
         obj =[];
         obj = daqmex('AnalogInput', varargin{:});
      catch
         errmsg=lasterr;
         
         if (findstr('Class not registered',errmsg))
            % Try to create the object.
            evalc('daqregister(varargin{1});obj = daqmex(''AnalogInput'', varargin{:});','lasterr');
         end
         if isempty(obj)
            error('daq:analoginput:unexpected', errmsg);
         end
         
      end
      
      % Define the object's name.
      hwid = daqmex(obj, 'daqhwinfo', 'ID');
      objName = [adaptor hwid name_tag];
      
      %  Set the object's name to the default objname created.
      try 
           daqmex(obj, 'set', PropName, objName)
           daqmex(obj, 'setdefaultvalue', PropName, objName)
      catch 
           warning('daq:analoginput:name', 'Object was not given a default name.')
      end
      
   catch
         error('daq:analoginput:unexpected', deblank(lasterr))
   end
   
else
   error('daq:analoginput:invalidadaptor', 'ADAPTOR must be passed as a single string.')
end