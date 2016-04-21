function timeOut = querytimeout(cursor)
%QUERYTIMEOUT Get time allowed for a database SQL query to succeed.
%   TIMEOUT = QUERYTIMEOUT(CURSOR) returns the current value
%   of time allowed for a database query to be successful. 
%   CURSOR is a cursor object. 
%
%   Example:
%
%   time = querytimeout(cursor)
%
%   where cursor is a valid database cursor.
%
%   time will contain the current value for timing out on
%   a SQL query.
%
%   See also: EXEC, FETCH.

%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $	$Date: 2004/04/06 01:05:09 $

% function is retreiving the current time 
% out value for a database query operation.

timeOut = getQueryTimeout(cursor.Statement);

% Check for a negative value that indicates an error and then 
% if true get the error message.

if (timeOut == -1),
  
  message = queryErrorMessage(cursor.Cursor,cursor.Statement);
 
  error('database:cursor:queryTimeOutError','%s',message);
 
end
