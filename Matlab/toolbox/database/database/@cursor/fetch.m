function cursor = fetch(initialCursor,rowLimit)
%FETCH Import data into MATLAB.
%   CURSOR = FETCH(INITIALCURSOR,ROWLIMIT) returns a cursor 
%   object with values for all five elements of the structure
%   if successful otherwise returns the input cursor unchanged. 
%   INITIALCURSOR  is a cursor object that has values for defined 
%   for the first three elements from the sqlexec function. ROWLIMIT 
%   is an optional argument that is specifies the maximum  number of
%   rows returned by a database fetch.
%
%  Example:
%
%  When all data satisfying the SQL query are to be returned at one 
%  time FETCH is used as follows:
%
%  cursor = fetch(cursor)
%
%  When the data satisfying the SQL query are to be returned using the
%  ROWLIMIT argument then FETCH is used as follows:
%
%  cursor = fetch(cursor,10)
%
%  This returns 10 rows of data to MATLAB. Repeating the command will 
%  return the next 10 rows. This process can be repeated until all
%  data are returned.
%
%  See also EXEC, FETCHOBJECTS.

%   Author: E.F. McGoldrick, 09-02-97, C.F.Garvin, 06-12-98
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.27.4.5 $	$Date: 2004/04/06 01:05:08 $%

if isempty(initialCursor.Cursor) || isa(initialCursor.Cursor,'double')
   
   initialCursor.Message = 'Invalid Cursor';
   errorhandling(initialCursor.Message);
      
  % Return input cursor.
  cursor = initialCursor;
  
  %Modify Data field based on ErrorHandling preference
  switch setdbprefs('ErrorHandling')
    case 'empty'
      cursor.Data = [];
    case {'store','report'}
      %Do not change Data field
  end    
  
  return;
  
end

if isempty(initialCursor.ResultSet) || isa(initialCursor.ResultSet,'double')
  
  initialCursor.Message = 'Invalid Result Set';
  errorhandling(initialCursor.Message);
      
  % Return input cursor.
  
  cursor = initialCursor;
  return;
  
else
  
   if (nargin == 1),
    
    rowLimit = get(initialCursor,'Rowlimit');
    if rowLimit > 0
       fet = com.mathworks.toolbox.database.fetchTheData(initialCursor.DatabaseObject.Handle,...
          initialCursor.ResultSet, ...
          initialCursor.SQLQuery,rowLimit);
    else
      fet = com.mathworks.toolbox.database.fetchTheData(initialCursor.DatabaseObject.Handle,...
          initialCursor.ResultSet, ...
          initialCursor.SQLQuery);
    end
      
  elseif (nargin == 2),
    
    fet = com.mathworks.toolbox.database.fetchTheData(initialCursor.DatabaseObject.Handle,...
          initialCursor.ResultSet, ...
          initialCursor.SQLQuery,rowLimit);
  end
  
  if ~isempty(fet),
     
     % Copy the input cursor element values into the output cursor structure.	
     
     cursor = initialCursor;
    
     % Set the fetch element of the cursor structure.
     
     cursor.Fetch = fet;
    
     % Get Metadata so that all the data can be retrieved and parsed
     
     md = getTheMetaData(fet);
     status = validResultSet(fet,md);
     
     % Return the data as a long string vector
    
     if (status ~= 0)
        
       %Get NULL read value settings
       p = setdbprefs({'NullStringRead';'NullNumberRead';'DataReturnFormat'});
       
       % Valid cursor .. valid MetaData object returned to MATLAB.
       resultSetMetaData = getValidResultSet(fet,md);
       dataFetched = dataFetch(fet,resultSetMetaData,p.NullStringRead,p.NullNumberRead);
              
       % First .. check to see if error message has been returned by the fetch.
       % If there is a problem print the message to MATLAB session window otherwise
       % process the data.
         
       if isa(dataFetched,'java.util.Vector')
      
         %Find number of rows and columns in returned data
         
          numberOfRows = double(rows(cursor));
          numberOfColumns = double(cols(cursor));
      
          % Check for 'No Data' message.
      
          if  (numberOfRows == 0),
         
            cursor.Data = {'No Data'};
             
          else
            
            switch p.DataReturnFormat
                
              case 'cellarray'
                  
                %system_dependent(44,...) converts java.util.vector to cell array
                cursor.Data = system_dependent(44,dataFetched,numberOfRows)'; 
            
                %Convert NullNumberRead value into numeric value
                i = find(strcmp(cursor.Data,p.NullNumberRead));
                cursor.Data(i) = {str2num(p.NullNumberRead)};
                  
              case 'numeric'
            
                %java method VectorToDouble converts java.util.vector to matrix of doubles
                cursor.Data = fet.VectorToDouble(dataFetched,numberOfRows,numberOfColumns);
                
                %convert non-numeric placeholder to NullNumberRead value
                i = find(isnan(cursor.Data));
                cursor.Data(i) = str2num(p.NullNumberRead);
                
              case 'structure'
               
                %Get resultset metadata to determine data types
                rs = rsmd(cursor);
                
                %Get data types and field names
                x = get(rs,{'ColumnName';'ColumnType'});
                
                %Initialize structure
                for i = 1:length(x.ColumnType)
                  
                  colName = toCharArray(x.ColumnName{i})';
                  
                  switch x.ColumnType{i}
                      
                    case {-6,-5,2,3,4,5,6,7,8}
                        
                      %Numerics
                      eval(['cursor.Data.' colName ' = fet.VectorToNumber(dataFetched,numberOfRows,numberOfColumns,i-1);'])
                      
                      %Set Nulls (placeholder value of NaN to p.NullNumberRead value)
                      eval(['j = find(isnan(cursor.Data.' colName '));cursor.Data.' colName '(j) = str2num(p.NullNumberRead);'])
                      
                    otherwise
                        
                      %Strings or other data types, create vector of strings and use system_dependent(44,...) to convert to cell array
                      eval(['cursor.Data.' colName ...
                            ' = system_dependent(44,' ...
                            'fet.VectortoStringVector(dataFetched,numberOfRows,numberOfColumns,i-1),' ...
                            'numberOfRows)'';'])
                      
                      %Set Nulls (placeholder value of 'NaN' to p.NullNumberRead value)
                      eval(['j = find(strcmp(cursor.Data.' colName ',''NaN''));' ....
                            'if ~isempty(j),cursor.Data.' colName '{j} = p.NullStringRead;end'])
                      
                  end
                end
                
            end
            
         end
                 
      else
       
         
         % Problem with data returned.
         
         cursor.Message = dataFetched;
         errorhandling(cursor.Message);
         return;
         
      end
       
   else
         
      % Invalid cursor use must return adjusted cursor structure and message.
               
      cursor.ResultSet = 0;
      cursor.Cursor = 0;
      cursor.Data = 0;
      cursor.Message = 'Error: Invalid cursor';
      errorhandling(cursor.Message);
      return;
      
   end        
  
  
else
    
   cursor.Message = 'Fetch failed';
        
end
end

errorhandling(cursor.Message);


%%Subfunctions

function errorhandling(s)
%ERRORHANDLING Error processing based on preference setting.
%   ERRORHANDLING(S) performs error processing based on the 
%   SETDBPREFS property ErrorHandling.  S is the contents
%   of the cursor.Message field.

switch (setdbprefs('ErrorHandling'))
  
  case 'report' 
        
    %Throw error
    if ~isempty(s)
      error('database:cursor:fetchError','%s',s);
    end
    
  case {'store','empty'}
        
    %Message field is populated, do nothing else
      
end
