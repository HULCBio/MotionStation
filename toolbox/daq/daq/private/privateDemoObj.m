function [obj, Fs, errflag] = privateDemoObj(subsystem, adaptor, id, chanID, sampleRate)
%PRIVATEDEMOOBJ Create requested data acquisition object.
%
%    [OBJ, FS, ERRFLAG] = PRIVATEDEMOOBJ(SUBSYSTEM,ADAPTOR,ID,CHANID,FS) 
%    creates a subsystem data acquisition object, OBJ, for adaptor, ADAPTOR 
%    and id, ID.  The channels, CHANID are added to OBJ.  The SampleRate of
%    OBJ is set to FS and returned.  If an error occurred during the objects
%    construction, the error flag, ERRFLAG, is set to 1.
%
%    PRIVATEDEMOOBJ is a helper function for DAQPLAY and DAQRECORD.
%

%    MP 01-12-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:42:16 $


% Initialize variables.
errflag = 0;
Fs = [];
obj = [];

% Determine the channel id.
if isempty(chanID)
   switch lower(adaptor)
   case {'winsound', 'hpe1432'}
      chanID = 1;
   case {'nidaq','mcc'}
      chanID = 0;
   end
end

% Create and configure the object.
try
   obj = feval(subsystem, adaptor, id);
   addchannel(obj, chanID);  
catch
   errflag = 1;
   return;
end

if exist('sampleRate','var'),
  try
     setverify(obj, 'SampleRate', sampleRate);
  catch
     warning(['Unable to set SampleRate to ' num2str(sampleRate) '. Using default value.'])
  end
end

Fs=obj.SampleRate;
