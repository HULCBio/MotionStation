function curs = exec(connect,sqlQuery)
%EXEC Execute SQL statement and open Cursor
%   CURSOR = EXEC(CONNECT,SQLQUERY) returns a cursor object
%   CONNECT is a database object returned by DATABASE. sqlQuery
%   is a valid SQL statement. Use FETCH to retrieve data associated
%   with CURSOR.
%
%   Example:
%
%   cursor = exec(connect,'select * from emp')
%
%   where:
%
%   connect is a valid database object.
%
%   'select * from emp' is a valid SQL statement that selects all
%   columns from the emp table.
%
%   See also: FETCH.
 
%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $	$Date: 2004/04/06 01:05:19 $%

% Check for valid connection handle.

if ~(isempty(class(connect.Handle)))
   
	curs=cursor(connect,sqlQuery);
   
else
   
   curs.Message = 'Invalid connection';
   
end

%Handle error based on ErrorHandling preference setting
switch (setdbprefs('ErrorHandling'))
  
  case 'report' 
        
    %Throw error
    if ~isempty(curs.Message)
      error('database:database:cursorError','%s',curs.Message);
    end
        
  case {'store','empty'}
        
    %Message field is populated, do nothing else
      
end
