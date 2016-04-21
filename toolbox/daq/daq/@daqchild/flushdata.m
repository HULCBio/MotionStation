function flushdata(varargin)
%FLUSHDATA Remove remaining data from data acquisition engine.
%
%    FLUSHDATA(OBJ) removes all data from the data acquisition engine for 
%    the analog input object, OBJ. OBJ can be a single analog input object 
%    or an array of analog input objects.
%
%    FLUSHDATA(OBJ,MODE) removes data from the data acquisition engine for 
%    the analog input object, OBJ. MODE can be either of the following values:
%    
%    'all'      Removes all data from the object and sets the SamplesAvailable 
%               property to 0. This is the default mode when mode is not 
%               specified, FLUSHDATA(OBJ).
%
%    'triggers' Removes the data acquired during one trigger. TriggerRepeat must
%               be greater then 0 and SamplesPerTrigger must not be set to Inf.  
%               The data associated with the oldest trigger is removed first.
%
%    See also DAQHELP, GETDATA, PROPINFO.
%

%    CP 4-10-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.12.2.5 $  $Date: 2003/12/04 18:38:30 $

error('daq:flushdata:invalidtype', 'Wrong object type passed to FLUSHDATA.  Use the object''s parent.');
