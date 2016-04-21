function nrows  = rows(cursor)
%ROWS Get number of rows in fetched data set.
%   NROWS = ROWS(CURSOR) returns the number of rows 
%   retrieved by a database fetch operation. CURSOR is 
%   a cursor structure in which all elements have values.
%
%   Example:
%
%   nrows = rows(cursor)
%
%   upon execution of the function nrows contains the
%   the number of rows returned by the fetch.
%
%   cursor=exec(conn,'select * from employees');
%   cursor=fetch(cursor);
%   nrows=rows(cursor)
%
%   nrows = 9
%
%   indicating there are 9 rows returned by FETCH.
%
%   See also FETCH.

%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $	$Date: 2004/04/06 01:05:11 $%

if isempty(cursor.Cursor) 
   
  nrows = -1;
  return;   
     
end

if ~isempty(cursor.Fetch)
  
  nrows = double(rowsFetched(cursor.Fetch));

else
   
  nrows = -1;
   
end;   


