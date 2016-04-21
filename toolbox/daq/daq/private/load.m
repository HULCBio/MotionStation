function load
%LOAD Load data acquisition objects in the MATLAB workspace.
%
%    LOAD FILENAME returns all variables from the MAT-file, FILENAME,
%    into the MATLAB workspace.
%
%    LOAD FILENAME OBJ1 OBJ2 ... returns the specified data acquisition
%    objects from the MAT-file, FILENAME, into the MATLAB workspace.
%
%    S = LOAD('FILENAME', 'OBJ1', 'OBJ2',...) returns the structure, S, with
%    the specified data acquisition objects from the MAT-file, FILENAME, 
%    instead of directly loading the data acquisition objects into the
%    workspace.  The fieldnames in S match the names of the data acquisition
%    objects that were retrieved.  If no objects are specified, then all 
%    variables existing in the MAT-file are loaded.
%
%    If a loaded device object already exists in the engine but not
%    the MATLAB workspace, the loaded device object automatically 
%    reconnects to the engine device object.
%
%    If a loaded device object already exists in the workspace or the 
%    engine but has different properties than the loaded object, then
%    these rules are followed:
%      - The read-only properties are automatically reset to their
%        default values.  For example, the EventLog property will be
%        reset to an empty vector.  PROPINFO can be used to determine
%        if a property is read-only.
%      - All other property values are given by the loaded object and
%        a warning is issued stating that property values of the 
%        workspace object have been updated.
%      - If the workspace device object is running, then it is stopped
%        before loading occurs.
%
%    Examples:
%      ai = analoginput('winsound');
%      ch = addchannel(ai, [1 2]);
%      set(ai, 'TriggerRepeat', 4, 'SamplesPerTrigger', 2048);
%      save fname ai ch
%      load fname
%      load fname ch
%      load('fname', 'ai', 'ch')
%
%    See also DAQHELP, DAQ/PRIVATE/SAVE.
%    

%   MP 10-21-98
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:42:07 $
