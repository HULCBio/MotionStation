function getdata(varargin)
%GETDATA Return acquired data samples from engine to MATLAB workspace.
%
%    DATA = GETDATA(OBJ) returns the number of samples specified in the
%    SamplesPerTrigger property of analog input object OBJ.  DATA is a
%    M-by-N matrix where M is the number of samples returned and N is the
%    number of channels in OBJ.  OBJ must be a 1-by-1 analog input object.
%
%    DATA = GETDATA(OBJ, SAMPLES) returns the specified number, SAMPLES, 
%    of data.
% 
%    [DATA, TIME] = GETDATA(OBJ) returns the number of samples specified 
%    in the SamplesPerTrigger property of analog input object OBJ in 
%    time-value pairs. TIME is a M-by-1 matrix, where M is the number of 
%    samples returned in DATA, indicating the relative time, in seconds, 
%    of each sample relative to the first trigger.                                                            
%
%    [DATA, TIME] = GETDATA(OBJ,SAMPLES) returns the specified number, 
%    SAMPLES, of data in time-value pairs.
%
%    DATA = GETDATA(OBJ, SAMPLES, TYPE)
%    [DATA, TIME] = GETDATA(OBJ, SAMPLES, TYPE) allows for DATA to be 
%    returned as the data type specified by the string TYPE.  TYPE can either
%    be 'double', for data to be returned as doubles, or 'native', for data 
%    to be returned in it's native data type.  If TYPE is not specified, 
%    'double' is used as the default.
%
%    [DATA, TIME, ABSTIME] = GETDATA(...) returns the absolute time ABSTIME  
%    of the trigger, which can also be found in OBJ's InitialTriggerTime
%    property.  ABSTIME is returned as a CLOCK vector.
%
%    [DATA, TIME, ABSTIME, EVENTS] = GETDATA(...) returns the structure EVENTS 
%    which contains a log of events associated with OBJ.
%
%    GETDATA is a blocking function that returns execution control to the 
%    MATLAB workspace once the requested number of samples become available. 
%    OBJ's SamplesAvailable property will automatically be reduced by the 
%    number of samples returned by GETDATA.  If the requested number of samples
%    is greater than the samples to be acquired, then an error is returned.
%
%    TIME=0 is defined as the point at which data logging begins, i.e., OBJ's 
%    Logging property is set to 'On'.  TIME is measured continuously with 
%    respect to 0 until the acquisition is stopped, i.e., OBJ's Running 
%    property is set to 'Off'.
%
%    If GETDATA returns data from multiple triggers, the data from each 
%    trigger is separated by a NaN.  This will increase the length of DATA 
%    and TIME by the number of triggers.  If multiple triggers occur, 
%    ABSTIME, is the absolute time of the first trigger.
%
%    It is possible to issue a ^C (Control-C) while GETDATA is blocking.  This
%    will not stop the acquisition but will return control to MATLAB.
%
%    See also DAQHELP, FLUSHDATA, GETSAMPLE, PEEKDATA, PROPINFO.
%

%    CP 4-10-98
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.10.2.6 $  $Date: 2004/03/30 13:03:44 $

error('daq:getdata:invalidtype','Wrong object type passed to GETDATA. Use the object''s parent.');
