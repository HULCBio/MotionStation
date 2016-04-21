function result = daqregister(varargin)
%DAQREGISTER Register or unregister Data Acquisition Toolbox adaptor DLLs. 
%
%    DAQREGISTER('ADAPTOR') registers the ADAPTOR for the Data Acquisition
%    Toolbox.  
%
%    DAQREGISTER('ADAPTOR','unload') unregisters ADAPTOR. 
%
%    RESULT = DAQREGISTER(...) captures the resulting message in RESULT.
%
%    Example:
%      daqregister('nidaq')
%
%    See also DAQHELP.
%

%    CP 4-24-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.11.2.5 $  $Date: 2003/10/15 18:28:25 $

ArgChkMsg = nargchk(0,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:daqregister:argcheck', ArgChkMsg);
end

if ~iscellstr(varargin), 
   error('daq:daqregister:argcheck', 'ADAPTOR and the ''unload'' option must be strings.')
end

% Determine what was provided by the user:
[filepath, name, ext]=fileparts(varargin{1});

if isempty(filepath),
   % If no path specified, check the extension.
   % If no extension, prepend with 'mw' and append with '.dll'.
   % If extension specified, then we have the dll name.
   if isempty(ext)
      dll=['mw', name, '.dll'];
      if exist(dll)~=3
            dll=[name, '.dll'];
      end
   else
      dll=varargin{1};
   end
   
   % Since no path provided, use which to find where the file lives.
   % If the file is not found, we display message and return out.
   dllpath=which(dll);
   if isempty(dllpath),
      if nargout == 1
         result = sprintf(['''', dll, ''' not found.  Make sure it is on the MATLAB path.']);
      else
         warning('daq:daqregister:notfound', '''%s'' not found.  Make sure it is on the MATLAB path.', dll);
      end
      return
   end
   
else
   % If path was specified, then we use it and assemble the
   % dll name with extension..
   dll=[name, ext];
   dllpath=[filepath, filesep, name, ext];
end

% If two arguments passed in, then user is attempting to use the 'unload' option.
if nargin == 2,
   option=varargin{2};
   if ~strcmpi(option,'unload'),
      error('daq:daqregister:argcheck', 'The second input: ''%s'' is not recognized.\nTo unload the ADAPTOR, the second input argument must be ''unload''.', option)
   end
else
   option='';
end

try
	if isempty(option)
		try
			% Determine adaptor path
			adaptorpath=fileparts(dllpath);
			% Save current directory
			curPath = pwd; 
			% Determine if adaptor is an internal adaptor (i.e. in \private)
			if ~isempty(findstr(adaptorpath, 'private'))
				% Change to adaptor directory for registration
				cd (adaptorpath);
			end
			% Register adaptor with daq engine
			daqmex('registerdriver',dllpath)
		catch
			cd(curPath);		
			if nargout == 1
				result = lasterr;
				return;
			else
				error('daq:daqregister:unexpected', '%s', lasterr);
			end
		end
		% Restore saved directory
		cd(curPath);		
		result = sprintf('%s','''',dll,''' successfully registered.');
	else
		try
			% Determine adaptor path
			adaptorpath=fileparts(dllpath);
			% Save current directory
			curPath = pwd; 
			% Determine if adaptor is an internal adaptor (i.e. in \private)
			if ~isempty(findstr(adaptorpath, 'private'))
				% Change to adaptor directory for registration
				cd (adaptorpath);
			end
			daqmex('unregisterdriver',dllpath)
		catch
			cd(curPath);		
			warning('daq:daqregister:unregister', 'Unable to self unregister adaptor.  Manually removing from registry')
			daqmex('unregisterdriver',name)
		end
		% Restore saved directory
		cd(curPath);		
		result = sprintf('%s','''',dll,''' successfully unregistered.');
	end
catch
		if nargout == 1
      result = lasterr;
      return;
   else
      error('daq:daqregister:unexpected', '%s', lasterr);
   end
end