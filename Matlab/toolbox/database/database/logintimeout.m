function timeOut = logintimeout(firstArg,secondArg)
%LOGINTIMEOUT Set or get time allowed to establish database connection.
%   TIMEOUT = LOGINTIMEOUT(FIRSTARG,SECONDARG) returns the current
%   value of time allowed for a connection to a database to be 
%   successful. FIRSTARG, an optional argument, is a string that 
%   specifies the JDBC driver to be used establishing the database 
%   connection. SECONDARG, an optional argument, is an integer that 
%   specifies the length of time the driver will attempt to make a 
%   connection to a database. If FIRSTARG is not specified then the 
%   default JDBC/ODBC bridge is used to establish the connection to 
%   the database. If function is used without arguments then the 
%   current time out value is returned.  
%
%
%   Examples:
%
%   Case 1: No function arguments.
%
%   timeout = logintimeout
%
%   Function returns the current timeout value for the JDBC/ODBC 
%   bridge. If 0 is returned then the connection is made 
%   instantaneously.
%
%   Case 2: New time out value.
%
%   timeout = logintimeout(5)
%
%   Function sets the new time out value to 5 seconds.
%
%   Case 3: JDBC driver argument specified.
%
%   timeout = logintimeout('oracle.jdbc.driver.OracleDriver')
%
%   Function returns the current timeout value for the JDBC 
%   driver.
%   
%   Case 4: Both arguments defined, time value and JDBC driver.
%
%   timeout = logintimeout('oracle.jdbc.driver.OracleDriver',10)
%
%   Function sets the new time out value for the JDBC driver 
%   to 10 seconds.
%
%   See also: DATABASE, CLOSE    

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2004/04/06 01:05:52 $%

if (nargin == 0),
  % Using the JDBC/ODBC Bridge as the connection mechanism.
  % and getting the current value of the login time out.
  conn = com.mathworks.toolbox.database.databaseConnect;
  timeOut = connectionTimeOut(conn);
  
elseif (nargin == 1),
  
  % First check to see if first argument is a string
  % If it is then not using the JDBC/ODBC bridge for
  % the connection.
  
  if (ischar(firstArg) ~= 1),
     
    % Integer value  .. setting the login time out
    % to a new value  
    conn = com.mathworks.toolbox.database.databaseConnect;
    timeOut = connectionTimeOut(conn,firstArg);

  else

    % Checking time out value using a third party JDBC driver.
    conn = com.mathworks.toolbox.database.databaseConnect(firstArg);
    timeOut = connectionTimeOut(conn);
  
  end

elseif (nargin == 2),
  
  % Resetting the login time out using a third party JDBC driver.
  
  % Sanity check on the arguments to make sure right values
  % are assigned to the correct variables.
  if ((ischar(firstArg) ~= 1) && (ischar(secondArg) == 1)),
    
    conn = com.mathworks.toolbox.database.databaseConnect(secondArg);
    timeOut = connectionTimeOut(conn,firstArg);
    
  elseif ((ischar(firstArg) == 1) && (ischar(secondArg) ~= 1)),
    
    conn = com.mathworks.toolbox.database.databaseConnect(firstArg);
    timeOut = connectionTimeOut(conn,secondArg);
    
  else
    
    warning('database:logintimeout:invalidArguments','Arguments must be integer value (time out interval) and driver name');
    
    % Return default value .. no arguments passed.
    conn = com.mathworks.toolbox.database.databaseConnect;
    timeOut = connectionTimeOut(conn);

  end

end

% Check for a negative value that indicates an error and then 
% if true get the error message.
if (timeOut == -1),  
  message = queryErrorMessage(conn,'');
  error('database:logintimeout:timeOutError','%s',message);
end
