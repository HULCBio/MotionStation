function curs = cursor(connect,sqlQuery)
%CURSOR Cursor constructor.
%   CURS = CURSOR(CONNECT,SQLQUERY) returns a cursor object.
%   CONNECT is a database connection object, QUERY is a valid SQL query.
%
%   This function is called by EXEC and never invoked directly from
%   the MATLAB command line.
%
%   See also FETCH.
 
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.27.4.5 $	$Date: 2004/04/06 01:05:07 $%

%Create parent object for generic methods
dbobj = dbtbx;

% Initialize all the elements of the structure.

curs.Attributes     = [];
curs.Data           = 0 ;
curs.DatabaseObject = [];
curs.RowLimit       = 0;
curs.SQLQuery       = [];
curs.Message        = [];

% These fields will be invisible to the user
curs.Type = 'Database Cursor Object';
curs.ResultSet      = 0 ;
curs.Cursor         = 0 ;
curs.Statement      = 0 ;
curs.Fetch          = 0 ;

if nargin == 0
  curs.Message = 'Function requires connection handle and SQL statement.';
  curs=class(curs,'cursor',dbobj);
  return
end

%Process inputs
curs.DatabaseObject = connect;
curs.SQLQuery       = sqlQuery;

% 
% Test for valid connection handle .. non empty value.
%
 
if (isempty(class(connect.Handle))),
    
 curs.Message = 'Invalid Connection';
 return;
 
end

% Call Constructor 
%
		
% Fetch all rows matching the SQL query.

curs.Cursor = com.mathworks.toolbox.database.sqlExec(curs.SQLQuery ,connect.Handle);


if (isempty(class(curs.Cursor))),
   
   curs.Message = 'Invalid SQL statement';
   return;
   
else,
  
  % Now execute the sql statement and returns the result set for
  % the open cursor 
  
  statementVector = createTheSqlStatement(curs.Cursor);
  status = validStatement(curs.Cursor,statementVector);
  
  % Test for error condition .. if SQL statement is invalid then zero 
  % value object handle is returned.
  
  if (status ~= 0),
    
     % Return the valid SQL statement object
     curs.Statement = getValidStatement(curs.Cursor,statementVector);
    
     % convert string to same case for testing if SELECT present in the 
     % SQL command string
     
     if ((isempty(strmatch('UPDATE ',upper(curs.SQLQuery))) == 0) |...
           (isempty(strmatch('DELETE ',upper(curs.SQLQuery))) == 0) |...
           (isempty(strmatch('INSERT ',upper(curs.SQLQuery))) == 0) |...
           (isempty(strmatch('COMMIT ',upper(curs.SQLQuery))) == 0) | ...
           (isempty(strmatch('ROLLBACK ',upper(curs.SQLQuery))) == 0)),

       % Doing an INSERT, UPDATE, DELETE,Commit or Rollback operation.
      
      rowsAltered = executeTheSqlStatement(curs.Cursor,curs.Statement);
      
      % Check to see if an error value has been returned .. if so get
      % the error message.
      
      if (rowsAltered == -5555)
        
        message = statementErrorMessage(curs.Cursor,curs.Statement);        
        try   %Close statement object if it was created to free resources
          close(curs.Statement);
        catch
        end   
        curs.Cursor         = 0;
        curs.Statement      = 0;
        curs.Message = message;
        return;
        
      end
      
      if (rowsAltered == 0), 
        
         
         if ((isempty(findstr('COMMIT',upper(curs.SQLQuery))) ~= 0) & ...
            (isempty(findstr('ROLLBACK',upper(curs.SQLQuery))) ~= 0)),
            
            try   %Close statement object if it was created to free resources
              close(curs.Statement);
            catch
            end   
            curs.Cursor         = 0;
            curs.Statement      = 0;
            curs.Message = 'Error:Commit/Rollback Problems';
         end
         
         
      else,
        
        % Delete, insert and update SQL operations.
        % Set the resultSet object element to be zero as these operations
        % do not return a result set.        
        curs.ResultSet = 0;
          
     end
     
  else,
     
     	% Doing a Select, stored procedure or DML query.
     
      % Get the result set.
             
      resultSetVector = executeTheSelectStatement(curs.Cursor,curs.Statement);
      status = validResultSet(curs.Cursor,resultSetVector);
        
      % Test for error condition on SQL select statements .. result set 
      % object handle has a zero value.
      
      if (status == 0)  
         
         % Reset the elements to 0           
 
        message = statementErrorMessage(curs.Cursor,curs.Statement);
        try   %Close statement object if it was created to free resources
          close(curs.Statement);
        catch
        end     
        curs.Cursor         = 0 ;
        curs.Statement      = 0 ;
        curs.Message        = message;
        curs=class(curs,'cursor',dbobj);
        return;
        
      else
        
        curs.ResultSet = getValidResultSet(curs.Cursor,resultSetVector);
        
      end
      
      
  end
  
  
else
 
 
 % Reset the elements to 0           
 
   message = errorCreatingStatement(curs.Cursor);  
   
   curs.Cursor         = 0 ;
   curs.Statement      = 0 ;
   curs.Message        = message;
   curs=class(curs,'cursor',dbobj);
   return;
end

end

curs=class(curs,'cursor',dbobj);
