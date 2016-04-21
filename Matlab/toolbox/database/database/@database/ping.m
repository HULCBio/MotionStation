function p = ping(connect)
%PING Get status information about database connection. 
%   P = PING(CONNECT) determines the status of a database connection.
%   CONNECT is a database connection object. If the connection 
%   is valid status information for a database connection is returned. 
%   If the connection is invalid then an error message is returned.
%
%   Example:
%
%   p = ping(connect)
%
%   where
%
%   connect is a database connection.
%
%   This function returns the following information for an ODBC connection.
%   For a Microsoft Access database:
% 
%   p =
%
%      DatabaseProductName: ACCESS
%   DatabaseProductVersion: 3.5 Jet
%           JDBCDriverName: JDBC-ODBC Bridge (odbcjt32.dll)
%        JDBCDriverVersion: 1.1001 (03.50.3428.00)
%   MaxDatabaseConnections: 64
%          CurrentUserName: admin
%              DatabaseURL: jdbc:odbc:ralph
%   AutoCommitTransactions: True
%
%   This function returns the following information for a JDBC connection.
%   For an ORACLE database:
%
%   p = 
%
%      DatabaseProductName: Oracle
%   DatabaseProductVersion: Oracle7 Server Release 7.3.3.0.0 - Production 
%                               Release With the distributed, replication and 
%                               parallel query options PL/SQL Release 2.3.3.0.0
%                               - Production
%           JDBCDriverName: Oracle JDBC driver
%        JDBCDriverVersion: 7.3.3.1.3
%   MaxDatabaseConnections: 0
%          CurrentUserName: scott
%              DatabaseURL: jdbc:oracle:oci7:oracle
%   AutoCommitTransactions: True
%
%   The information returned details the type of database, connection type and 
%   driver used, username etc.
%
%   See also ISCONNECTION.

%   Author: E.F. McGoldrick, 09-02-97, C.F.Garvin, 11-20-98
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.2 $	$Date: 2004/04/06 01:05:22 $%

pingConnection = 0;
pingConnection.Message = [];

if ~isa(connect.Handle,'double')  %Invalid connection = 0
  
  connh = com.mathworks.toolbox.database.sqlExec(connect.Handle);
  
  % Check to see if the database connection is closed .. 
  % this will involve making a tempoprary
  % connection to the database to see if it is "alive".
  
       
  connectionVector =  makeDatabaseConnection(connect.Constructor);
  
	% Check to see if the connection is valid .. must get the status element
	% of the connection vector.
   
  status = validConnectionMade(connect.Constructor,connectionVector);
   
 	if (status == 1)
      
  	% Valid connection has been established
      
    connection.Handle = getValidConnection(connect.Constructor,connectionVector);
      
	else
      
    connection.Handle = 0;
      
	end
     
  % Test to see if temporary connection established.  
  
  if ~isa(connection.Handle,'double'),
		
		% Close the temporary connection.
    % Call to the class constructor
      
    databaseConnection = com.mathworks.toolbox.database.closeTheDatabaseConnection(connection.Handle);
      
    %  Call to the class method closing the connection 
    %  .. returns true if successful.
      
    returnVal = closeTheConnection(databaseConnection);

		% Connection is still alive ... get the connection information.
      
    connectionString = connectionPing(connh,connect.Handle);
    
    %Convert any single apostrophes in string to ''
   
    %',' is cell array delimiter
    delim = findstr(''',''',connectionString);
    
    %Get single 's excluding first and last '
    singlea = findstr('''',connectionString);
    singlea([1,end]) = [];
    
    %Find set differences
    delim = [delim delim+2];    %Add 2 to vector to get indices of ''s in cell array delimiters
    x = setdiff(singlea,delim);
    
    %Remove single 's
    connectionString(x) = [];
        
    % Break the String Vector in to a cell array.
    
    transitionStage=eval(['{' connectionString '}']);
    
    %Now Display the values in the cell array
    
    rowCol = size(transitionStage);	% Dimensions of cell array.
    
    % Should be 1 x n columns (n = 1 or 8)
    
    try
      for (i = 1:rowCol(2)),
        displayString = transitionStage{1,i};    %Store information in fields
        L = length(displayString);               %Extract fields and info
        ci = find(displayString == ':');
        fn = displayString(1:ci(1)-1);
        j = find(fn == ' ' | fn == '.');
        fn(j) = [];
        eval(['p.' fn '=' displayString(ci(1)+2:L) ';'],...
          ['p.' fn '=''' displayString(ci(1)+2:L) ''';'])
      end
    catch
      error('database:database:pingError','%s',displayString)
    end
    
  else 
    
    pingConnection.Message = getTheErrorMessage(connect.Constructor);
    error('database:database:pingConnectionError','%s',pingConnection.Message);
    
  end
  
else
   
   error('database:database:invalidConnection','Invalid connection.')
  
end
