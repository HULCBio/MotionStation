function out=daqhwinfo(varargin)
%DAQHWINFO Return information on the available hardware.
%
%    OUT = DAQHWINFO returns a structure, OUT, which contains data acquisition
%    hardware information.  This information includes the toolbox version,
%    MATLAB version and installed adaptors.
%
%    OUT = DAQHWINFO('ADAPTOR') returns a structure, OUT, which contains 
%    information related to the specified adaptor, ADAPTOR.
%
%    OUT = DAQHWINFO('ADAPTOR','Property') returns the adaptor information for
%    the specified property, Property. Property must be a single string. OUT is
%    a cell array.
%
%    OUT = DAQHWINFO(OBJ) where OBJ is any data acquisition device object, 
%    returns a structure, OUT, containing hardware information such as adaptor, 
%    board information and subsystem type along with details on the hardware
%    configuration limits and number of channels/lines.  If OBJ is an array 
%    of device objects then OUT is a 1-by-N cell array of structures where 
%    N is the length of OBJ.   
%
%    OUT = DAQHWINFO(OBJ, 'Property') returns the hardware information for the 
%    specified property, Property.  Property can be a single string or a cell
%    array of strings.  OUT is a M-by-N cell array where M is the length of OBJ 
%    and N is the length of 'Property'.
%
%    Example:
%      out = daqhwinfo
%      out = daqhwinfo('winsound')
%      ai  = analoginput('winsound');
%      out = daqhwinfo(ai)
%      out = daqhwinfo(ai, 'SingleEndedIDs')
%      out = daqhwinfo(ai, {'SingleEndedIDs', 'TotalChannels'})
%
%    See also DAQHELP.
%

%    MP 4-23-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.16.2.5 $  $Date: 2003/10/15 18:28:06 $

ArgChkMsg = nargchk(0,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:daqhwinfo:argcheck', ArgChkMsg);
end
if nargout > 1,
   error('daq:daqhwinfo:argcheck', 'Too many output arguments.')
end 

switch nargin
case 0  % DAQ page
   % Get the list of visible adaptors.
   try
      % Store the error message.
     
      
      % Remove the tags from varargin{1}.
      adaptorName = dir(fullfile(matlabroot,'toolbox','daq','daq','private','*.dll'));
      
      % Try to register.  If can't error with the original
      % error message.
      for adptLp=1:length(adaptorName),
         try
            evalc('daqregister(adaptorName(adptLp).name);', 'lasterr');
         catch
         end        
      end
         
      adaptors = daqmex('daqhwinfo');
   catch
      error('daq:daqhwinfo:unexpected', '%s', lasterr)
   end
   % Get a list of unique adaptors in nice format.
   adaptors = localGetAdaptors(adaptors);
   
   % Create the output structure.
   out.ToolboxName = 'Data Acquisition Toolbox';
   out.ToolboxVersion = localGetVersion('daq');
   out.MATLABVersion = localGetVersion('matlab');
   out.InstalledAdaptors = adaptors;
   
case {1,2}  % Driver and Adaptor Page.   
   if (ischar(varargin{1}))
      adaptor = varargin{1};
      % Get the Driver and Adaptor information adaptors.
      try
         out = daqmex('adaptorinfo',varargin);
      catch
         try
            if exist(adaptor)==3 || exist(['mw', adaptor])==3            
                daqregister(adaptor);
                out = daqmex('adaptorinfo',varargin);
          else
             error('daq:daqhwinfo:unexpected', '%s', lasterr)
          end
         catch
            error('daq:daqhwinfo:unexpected', '%s', lasterr)
         end
      end
   else
      error('daq:daqhwinfo:invalidadaptor', 'Invalid ADAPTOR specified.  Type ''daqhwinfo'' for a list of valid adaptors.')
   end
end

% *******************************************************************
% Get the unique adaptor names.
function out = localGetAdaptors(adaptors)

if ~isempty(adaptors)
	% Clear CBI out of the registry
	index = strmatch('cbi', adaptors);
	if index
		try
			daqmex('unregisterdriver', 'cbi');
			adaptors(index) = [];
		catch
		end
	end
   out = unique(lower(adaptors));
else
   % Adaptors may be empty if the user has a wrong dll.
   % Try to register and create an object for 'winsound' and 'nidaq'.
   % If successful add to the out list.
   try
      winsound = daqmex('adaptorinfo', 'winsound');
   catch
      winsound = [];
   end
   try
      nidaq = daqmex('adaptorinfo', 'nidaq');
   catch
      nidaq = [];
   end
   
   % Create the out list.
   out = {};
   if ~isempty(winsound)
      out = {'winsound'};
   end
   if ~isempty(nidaq)
      out = {out{:}; 'nidaq'};
   end
end
   
% *********************************************************************
% Output the version of the toolbox.
function str = localGetVersion(product)

try
   % Get the version information.
   % Ex. Data Acquisition Toolbox                Version 1.0 (R11) Beta 1 01-Sep-1998  
   verinfo = ver(product);

   % Build the version string.
   str = [verinfo.Version,' ',verinfo.Release];
catch
   str = '';
end

   