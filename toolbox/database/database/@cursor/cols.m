function columns = cols(cursor)
%COLS Get number of columns in fetched data set.
%   COLUMNS = COLS(CURSOR) returns the number of columns 
%   in a database table. CURSOR is a cursor structure in 
%   which all elements have values. 
%
%   Example:
%
%   columns = cols(cursor)
%
%   Function returns the number of columns selected in the
%   SQL query to columns.
%
%   For example, issuing the SQL query, against the Microsoft
%   Access database Northwind. 
%
%   'select * from employees'
%
%   returns all columns from the database table employees.
%
%   Invoking the sqlcols command as follows:
%
%   columns = cols(cursor)
%
%   returns the following calue to the variable columns:
%
%   columns = 17
%
%   indicating there are 17 fields in cursor.
%
%   See also FETCH.

    
%   Author: E.F. McGoldrick, 09-02-97, C.F.Garvin, 06-15-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.17 $	$Date: 2002/06/17 12:01:51 $%

status = 0;

if ~isempty(cursor.Fetch)
  
  md = getTheMetaData(cursor.Fetch);
  status = validResultSet(cursor.Fetch,md);
    
end

if (status ~= 0)
  
  resultSetMetaData = getValidResultSet(cursor.Fetch,md);
  columns = double(maximumColumns(cursor.Fetch,resultSetMetaData));
      
else
   
  columns = -1;
   
end   
