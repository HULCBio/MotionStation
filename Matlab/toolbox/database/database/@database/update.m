function update(connect,tableName,fieldNames,data,whereClause)
%UPDATE Replace data in database table with data from MATLAB cell array.
%   UPDATE(CONNECT,TABLENAME,FIELDNAMES,DATA,WHERECLAUSE). 
%   CONNECT is a datbase connection object, FIELDNAMES 
%   is a string array of database column names, TABLENAME is the 
%   database table, DATA is a MATLAB cell array and WHERECLAUSE 
%   is a SQL where clause used to specify the row(s) to be updated. 
%
%   Example:
%
%   The following UPDATE command updates the contents of
%   the cell array in to the database table yearlySales
%   for the columns defined in the cell array colNames.
%
% 
%   update(conn,'yearlySales',colNames,monthlyTotals,whereClause);
%
%   where 
%
%   The cell array colNames contains the value:
%
%   colNames = {'salesTotal'};
%
%   monthlyTotals is a cell array containing the data to be
%   used in updating the appropriate rows ofthe database table 
%   yearlySales.
%   
%   whereClause is a string that contains the where condition 
%   that must be satisfied for a row in the table to be updated.
%
%   whereClause = 'where month = ''Nov'''
%
%   is an example of a valid whereClause.
%
%   update(conn,'yearlySales',colNames,monthlyTotals,whereClause);
%
%
%  See also: INSERT.


%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.2 $	$Date: 2004/04/06 01:05:27 $

% Check for valid connection

if isa(connect.Handle,'double')
   
   error('database:database:invalidConnection','Invalid connection.')
   
end

%Get dimensions of data
switch class(data)
    
  case {'cell','double'}
    [numberOfRows,cols] = size(data);	%data dimensions
    
  case 'struct'
    sflds = fieldnames(data);
    fchk = setxor(sflds,fieldNames);
    if ~isempty(fchk)
      error('database:database:writeMismatch','Structure fields and insert fields do not match.')
    end
    numberOfRows = size(data.(sflds{1}),1);
    cols = length(sflds);
   
  otherwise
    error('database:database:invalidWriteDataType','Input data must be a cell array, matrix, or structure')
end

% Create the head of the SQL statement
startOfString = [ 'UPDATE '  tableName ' SET ' ];

% Get NULL string and number preferences 
prefs = setdbprefs;
nsw = prefs.NullStringWrite;
nnw = str2num(prefs.NullNumberWrite);

% Add the data for all the columns in the cell array.
for i = 1:numberOfRows,  
  
  dataString ='';
  
  for j = 1:cols,
    
    switch class(data)
        
      case {'cell','double'}

        try, tmp = data{i,j}; catch, tmp = data(i,j); end    %Index as cell array, or matrix, if not cell array
        
      case 'struct'
          
        try
          tmp = data.(sflds{j}){i};
        catch
          tmp = data.(sflds{j})(i);
        end
        
    end  
    
    if isa(tmp,'double')  %Test for data type.
      
      % Substitute NULL value for NullNumberWrite value
      if (isempty(tmp) & isempty(nnw)) | (~isempty(nnw) & ~isempty(tmp) & tmp == nnw) | (isnan(tmp) & isnan(nnw)) 
        tmpstr = 'NULL';
      else
        tmpstr = num2str(tmp,15);
      end
      % Numeric data.      
      if (j == cols), % Last column in the cell array.
        
        % The final comma in the field string is not required. 
        dataString = [ dataString fieldNames{j} ' = ' tmpstr ];
        
      else,
        dataString = [ dataString fieldNames{j} ' = ' tmpstr ','];
        
      end
      
    else,
      
      % Substitute NULL value for NullStringWrite value
      if (isempty(tmp) & isempty(nsw)) | strcmp(tmp,nsw)
        tmpstr = 'NULL';
      else
        tmpstr = ['''' tmp ''''];
      end

      % Character/String data.
      if (j == cols), % Last column in the cell array.
        
        % The final comma in the field string is not required. 
        dataString= [ dataString fieldNames{j} ' = ' tmpstr];
        
      else,	   
        dataString= [ dataString fieldNames{j} ' = ' tmpstr ','];
        
      end
      
    end
    
  end % End of cols loop
  
  writeString = [startOfString dataString ' ' whereClause];
  
  % Now update the table
  cursTemp = exec(connect,writeString);
  
  if isa(cursTemp.Cursor,'com.mathworks.toolbox.database.sqlExec'),  %Valid cursor is sqlExec class
    
     % Close the cursor.
     
    close(cursTemp);
    
  else
    
  	  error(cursTemp.Message);
      
  end
  
end %End of Rows loop
