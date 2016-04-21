function disconnect(obj)
%DISCONNECT Disconnect device object from instrument.
%
%   DISCONNECT(OBJ) disconnects device object, OBJ, from the instrument.
%
%   If OBJ was successfully disconnected from the instrument, OBJ's Status
%   property is configured to closed. OBJ can be reconnected to the instrument
%   with the CONNECT function.
%
%   If OBJ is an array of device objects and one of the objects cannot be 
%   disconnected from the instrument, the remaining objects in the array will 
%   be disconnected from the instrument and a warning will be displayed.
%
%   Example:
%       % Construct a device object that has specific information about a 
%       % Tektronix TDS 210 instrument.
%       g = gpib('ni', 0, 2);
%       d = icdevice('tektronix_tds210', g);      
%
%       % Connect to the instrument
%       connect(d);
%
%       % List the oscilloscope settings that can be configured.
%       props = set(d);
%
%       % Get the current configuration of the oscilloscope.
%       values = get(d);
%
%       % Disconnect from the instrument and cleanup.
%       disconnect(d);
%       delete([d g]);
%
%   See also ICDEVICE/CONNECT, INSTRUMENT/DELETE, INSTRHELP.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/03/05 18:10:09 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% Call close on each java object. Keep looping even if one of the objects
% could not be closed.  
for i=1:length(jobject),
   try
      % Execute cleanup code.
      try
          code = char(getCleanupCode(jobject(i)));
          localEvaluateCode(code, jobject(i));
      catch
          close(jobject(i));
          errorOccurred = true;
          lasterr(sprintf('An error occurred while executing the driver disconnect code.\n%s', lasterr));
      end           
      close(jobject(i));
   catch
   	  errorOccurred = true;	    
   end   
end   

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
		lasterr([lasterr sprintf('\n') 'If this error is not an instrument error, use MIDEDIT to inspect the driver.'], 'instrument:disconnect:opfailed');
        rethrow(lasterror);
    else
        warnState = warning('backtrace', 'off');
        warnID = 'icdevice:disconnect:invalid';
        warning(warnID, instrgate('privateMessageLookup', warnID));
        warning(warnState);
    end
end

% -----------------------------------------------------------------
% Evaluate the cleanup code.
function localEvaluateCode(fcn, jobj)

obj = icdevice(jobj);

% Evaluate the code.
instrgate('privateEvaluateCode', obj, fcn);



