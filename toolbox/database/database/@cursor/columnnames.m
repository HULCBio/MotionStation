function fieldString = columnnames(cursor)
%COLUMNNAMES Get names of columns in fetched data set.
%   FIELDSTRING = columnnames(CURSOR) returns the column names 
%   of the data selected from database table. The column names 
%   are enclosed in quotes and seperated by commas.
%
%   For example, issuing the SQL query, against the Microsoft
%   Access database Northwind. 
%
%   'select * from employees'
%
%   returns all columns from the database table employees.
%
%   Invoking the columnnames function as follows:
%
%   fieldString = columnnames(cursor) 
%
%   returns a string that contains all the column names for
%   the columns selected.
% 
%   fieldString = 'EmployeeID','LastName','FirstName','Title',
%                 'TitleOfCourtesy','BirthDate','HireDate','Address',
%                 'City','Region','PostalCode','Country','HomePhone',
%                 'Extension','Photo','Notes','ReportsTo'
%
%   See also: FETCH.


%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.12 $	$Date: 2002/06/17 12:01:43 $%
% 

fieldString = [];

if isempty(cursor.Cursor)
   
   % cursor Problem return empty string.
   
   return;
   
end

if ~isempty(cursor.Fetch)
  
  md = getTheMetaData(cursor.Fetch);
  status = validResultSet(cursor.Fetch,md);
  resultSetMetaData = getValidResultSet(cursor.Fetch,md);      
       
else
   
   % cursor Problem return empty string.

   return;
   
end

fieldString = columNames(cursor.Fetch,resultSetMetaData);
