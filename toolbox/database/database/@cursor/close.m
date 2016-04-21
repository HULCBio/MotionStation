function close(cursor)
%CLOSE Close cursor.
%   CLOSE(CURSOR) closes the database cursor.
%   CURSOR is a cursor structure with all elements defined.
%
%   See also: FETCH

%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $	$Date: 2004/04/06 01:05:06 $%

% funtion closes the cursor for the SQL statement
if ~isa(cursor.ResultSet,'double')
  try
    close(cursor.ResultSet);
  catch
    %Trap exception in case ResultSet is already closed
  end
end
message = closeSqlStatement(cursor.Cursor,cursor.Statement);
