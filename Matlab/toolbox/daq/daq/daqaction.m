function daqaction(obj, event)
%DAQACTION Display event information (obsolete).
%
%    DAQACTION(OBJ, EVENT) an action function which displays a 
%    message which contains the type of the event and the name 
%    of the object which caused the event to occur.  If an error
%    event occurs, the time of the event and the error message 
%    is also displayed.
%
%    By default, an analog input object's DataMissedAction and 
%    RuntimeErrorAction properties are set to 'daqcallback' and an 
%    analog output object's RuntimeErrorAction property is set to 
%    'daqcallback'.
%
%    If the event type is DataMissed, the object is stopped. 
%
%    DAQACTION should only be used as a property value for an
%    action property.  To display event information on an object,
%    SHOWDAQEVENTS should be used.
%
%
%    See also DAQCALLBACK.
%

%    MP 9-21-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.9.2.4 $  $Date: 2003/08/29 04:40:42 $

%
warning('DAQACTION is obsolete and will be discontinued. Use DAQCALLBACK instead.')
daqcallback(obj,event)
