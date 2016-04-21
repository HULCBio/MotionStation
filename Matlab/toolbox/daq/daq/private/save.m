function save
%SAVE Save data acquisition objects to a MAT-file.
%
%    SAVE FILENAME saves all variables in the MATLAB workspace to the 
%    specified MAT-file, FILENAME.  If an extension is not specified
%    for FILENAME, then a .MAT extension is used.
%
%    SAVE FILENAME OBJ1 OBJ2 ... saves data acquisition objects, OBJ1,
%    OBJ2,... to the specified MAT-file, FILENAME.  If an extension is 
%    not specified for FILENAME, then a .MAT extension is used.
%
%    SAVE can be used in the functional form as well as the command form
%    shown above.  When using the functional form, you must specify the 
%    file name and data acquisition objects as strings.
%
%    Any samples available associated with the data acquisition object 
%    will not be stored in the MAT-file.  These samples can be brought 
%    into the MATLAB workspace with GETDATA and saved to the MAT-file
%    using a separate variable name.  Samples can also be logged to disk 
%    by specifying the LoggingMode property to 'Disk' or 'Disk&Memory'.
%
%    Values for read-only properties will be restored to their default
%    values upon loading.  For example, the EventLog property will be 
%    restored to an empty vector.  PROPINFO can be used to determine if 
%    a property is read-only.
%
%    Values for the BufferingConfig property when the BufferingMode 
%    property is set to Auto and the MaxSamplesQueued property may not
%    be restored to the same value since both these property values are
%    based on available memory.
%
%    Examples:
%      ai = analoginput('winsound');
%      addchannel(ai, [1 2]);
%      set(ai, 'TriggerRepeat', 4, 'SamplesPerTrigger', 2048);
%      save fname ai
%      set(ai, 'TriggerFcn', @daqcallback);
%      save('fname1', 'ai')
%
%    See also DAQHELP, GETDATA, DAQREAD, DAQ/PRIVATE/LOAD, DAQCALLBACK.
%

%   MP 10-21-98
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:42:33 $
