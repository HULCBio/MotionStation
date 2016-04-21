function putdata(obj,samples)
%PUTDATA Queue data samples to engine for output.
%
%    PUTDATA(OBJ,DATA) outputs source data specified in DATA to the hardware
%    associated with 1-by-1 analog output object OBJ.
%
%    DATA can consist of native data types but cannot contain NaNs.  DATA
%    must contain a column of data for each channel contained in OBJ.  If
%    DATA contains any data points that are not within the UnitsRange of the
%    channel it pertains to, the data points will be clipped to the bounds of
%    the UnitsRange property.
%
%    PUTDATA can be used to queue data in memory before the START command 
%    is issued, or it can be used to directly output data after START has 
%    been issued.  In either case, no data is output until the trigger occurs. 
%    If PUTDATA is called before START is issued, then data is queued to 
%    memory until:
%       1) OBJ's MaxSamplesQueued is reached.  If this value is exceeded,
%          an error will occur.
%       2) The limitations of your hardware and computer are reached.
%
%    If the value of the RepeatOutput property is greater than 0, then all 
%    data queued before START is issued will be requeued (repeated) until the
%    RepeatOutput value is reached.
%
%    If PUTDATA is called after START is issued, then the RepeatOutput property
%    cannot be used. If MaxSamplesQueued is exceeded, PUTDATA becomes a blocking
%    function until there is enough space in the queue to add the additional 
%    data. 
%
%    It is possible to issue a ^C (Control-C) while PUTDATA is blocking.  This
%    stops the data from being added to the queue.  It does not stop data from
%    being output.
%
%    As soon as a trigger occurs, samples can be output.  The SamplesOutput
%    property keeps a running count of the total number of samples per channel
%    that have been output. Additionally, the SamplesAvailable property tells 
%    you how many samples are ready to be output from the engine per channel.
%    When data is output, SamplesAvailable is reduced by the number of samples
%    sent to the hardware.
%
%    See also DAQHELP, PUTSAMPLE, DAQDEVICE/START, PROPINFO.
%

%    CP 2-1-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.4 $  $Date: 2003/08/29 04:39:53 $


if ~isnumeric(samples)
   error('daq:putdata:invaliddata', 'DATA data type must be either double or native.');
end
   
try
   daqmex(obj,'putdata',samples);
catch
   error('daq:putdata:unexpected', lasterr)
end