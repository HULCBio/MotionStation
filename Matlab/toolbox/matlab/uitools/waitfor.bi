%WAITFOR Block execution and wait for event.
%   WAITFOR(H) returns when the graphics object identified by handle
%   is deleted.  If handle does not exist, waitfor returns immediately
%   without processing any events.
%
%   WAITFOR(H,'PropertyName'), in addition to the conditions in
%   the previous syntax, returns when the value of 'PropertyName'
%   for the graphics object handle changes. If 'PropertyName' is
%   not a valid property for the object, waitfor returns
%   immediately without processing any events.
%
%   WAITFOR(H,'PropertyName',PropertyValue), in addition to the
%   conditions in the previous syntax, returns when the value of
%   'PropertyName' for the graphics object handle changes to
%   PropertyValue. If 'PropertyName' is set to PropertyValue,
%   waitfor returns immediately without processing any events.
%
%   While waitfor blocks an execution stream, it processes events
%   as would drawnow, allowing callbacks to execute.  Nested calls
%   to waitfor are supported, and earlier calls to waitfor will
%   not return until all later calls have returned, even if the
%   condition upon which the earlier call is blocking has been
%   met.
%
%   See also DRAWNOW, UIWAIT, UIRESUME.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 03:25:37 $
%   Built-in function.
