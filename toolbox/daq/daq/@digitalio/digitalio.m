function obj = digitalio(varargin)
%DIGITALIO Construct digital I/O object.
%
%    DIO = DIGITALIO('ADAPTOR', ID) constructs a digital I/O object 
%    associated with adaptor, ADAPTOR, with device identification, ID.  
%
%    The supported adaptors are:
%       advantech
%		keithley
%		mcc
%       nidaq
%       parallel
%
%    The digital I/O object is returned to DIO.
%
%    Examples:
%       DIO = digitalio('nidaq',1);
%
%    See also ADDLINE, PROPINFO.
%

%    CP 4-10-98
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.14.2.8 $  $Date: 2004/04/16 22:01:44 $

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
   error('daq:digitalio:argcheck', 'ADAPTOR and ID must be specified.');
end

% Initialize variables.
name_tag = '-DIO';
PropName='Name';  % OBJ property name used to contain the default object name.
tlbx_version = 1.0;

% Structure of descriptive information used to generalize object methods.
info.prefix='a';
info.objtype='DigitalIO';
info.addchild='addline';
info.child='Line';
info.childconst='dioline';

if isa(varargin{1},'int32'),
   %  First argument is an int32 type.
   %  Daqmex is calling the constructor and is passing a numerical handle.
   %  Create the object, pass it back to daqmex via the output argument, and get out.
   obj.handle = varargin{1};
   obj.version = tlbx_version;
   obj.info = info;
   
   dev = daqdevice;
   obj = class(obj, 'digitalio', dev);
   return
   
elseif ischar(varargin{1}),
   %  User is calling the constructor.
   %  Expect a DRIVERNAME and possibly a DRIVERID passed.
   %  Create and return the object to the user.
   try
      if isempty(varargin{1}),
         error('daq:digitalio:invalidadaptor', 'ADAPTOR specified cannot be empty.')
      end
      
      for i=2:nargin,
         % Make sure the additional inputs are either strings or
         % numbers.
         if any(strcmp(class(varargin{i}),{'double' 'char'})) && ~isempty(varargin{i}),
            varargin{i} = num2str(varargin{i});            
         else
            error('daq:digitalio:invalidid', 'ID must be specified as a string or number.')
         end                  
      end
      
      % Store the adaptor information for the name creation.
      adaptor = varargin{1};
      
      %  Modify the first argument to assemble the proper name to pass as
      %  the DLL driver name.
      %  Then pass user's arguments to daqmex which returns the object.
      try
         obj = daqmex('DigitalIO', varargin{:});
      catch
         errmsg=lasterr;
         % Try to create the object.
         h = evalc('daqregister(varargin{1});obj = daqmex(''DigitalIO'', varargin{:});','lasterr');
         if ~isempty(h)
            error('daq:digitalio:unexpected', errmsg);
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
         warning('daq:digitalio:name', 'Object was not given a default name.')
      end
      
   catch
      error('daq:digitalio:unexpected', lasterr)
   end
   
else
   error('daq:digitalio:invalidadaptor', 'ADAPTOR must be passed as a single string.')
   
end