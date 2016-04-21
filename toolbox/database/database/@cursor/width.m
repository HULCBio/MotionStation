function wth = width(cursor,columnNumber)
%WIDTH Get field size of column in fetched data set.
%   WTH = WIDTH(CURSOR,COLUMNNUMBER) returns the width of a 
%   specific column in database table. CURSOR is a cursor 
%   object and COLUMNNUMBER is an integer that specifies 
%   the column. 
%
%   Example:
%
%
%   cursor=exec(conn,'select * from employees');
%   cursor=fetch(cursor);
%   colwidth=width(cursor,3)
%
%   MATLAB returns:
%
%   colwidth = 10
%
%   indicating the width of column 3 is 12 bytes. 
%   
%   See also FETCH.

%   Author: E.F. McGoldrick, 09-02-97, C.F.Garvin, 06-15-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.3 $	$Date: 2004/04/06 01:05:14 $%

% funtion returns number of Rows fetched

if isa(cursor.Fetch,'com.mathworks.toolbox.database.fetchTheData')
  
  md = getTheMetaData(cursor.Fetch);
  status = validResultSet(cursor.Fetch,md);
     
end

if (status ~= 0 )
  
  resultSetMetaData = getValidResultSet(cursor.Fetch,md);
  wth = columnWidth(cursor.Fetch,columnNumber,resultSetMetaData);

else
   
  wth = 0;
   
end
