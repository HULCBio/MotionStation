function connection = database(instance,UserName,Password,Driver,URL)
%DATABASE Connect to database.
%   CONNECT = DATABASE(INSTANCE,USERNAME,PASSWORD,DRIVER,DATABASEURL) 
%   returns a database connection object. INSTANCE is the name of the 
%   database, USERNAME is the user name. PASSWORD is the password 
%   that permits access to the database. DRIVER is a JDBC driver name and 
%   DATABASEURL is the URL for the database. The latter arguments are 
%   optional but both must be used in conjunction with each other. 
%
%   Use LOGINTIMEOUT before DATABASE to set the maximum time for a 
%   connection attempt.
%
%   Example:
%
%   JDBC-ODBC connection:
%
%   conn=database('oracle','scott','tiger')
%
%   where:
% 
%   'oracle' is the ODBC datasource name for an ORACLE database.
%   'scott'  is the user name.
%   'tiger'  is the password.
%
%
%   JDBC connection:
%
%   conn=database('oracle','scott','tiger',
%                'oracle.jdbc.driver.OracleDriver','jdbc:oracle:oci7:')
%
%   where:
%
%   'oracle' is the database name.
%   'scott'  is the user name.
%   'tiger'  is the password.
%   'oracle.jdbc.driver.OracleDriver' is the JDBC driver to be used 
%                                     to make the connection.
%   'jdbc:oracle:oci7:' is the URL as defined by the Driver vendor
%                       to establish a connection with the database.
%   
%   See also: CLOSE 

%
%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.17.4.3 $

%Create parent object for generic methods
dbobj = dbtbx;

% This function makes the connection to a Database using the JAVA built-in functionality.

conn = 0;
connection.Instance	= [];
connection.UserName = [];
connection.Driver		= [];
connection.URL	    = [];
connection.Constructor = [];
connection.Message = [];
connection.Handle=[];

message='';

numinputs = nargin;

if isunix  %Must use five input syntax, set numinputs to 5 to avoid java crash
  numinputs = 5;
end
  
switch numinputs,
  case 3,

  % Using the JDBC/ODBC Bridge as the connection mechanism.
 
    conn=com.mathworks.toolbox.database.databaseConnect(instance,UserName,Password);

    connection.Instance = instance;
    connection.UserName	= UserName;
    % The following elements are set as empty in this case. 
    connection.Driver   = [];
    connection.URL      = [];
    connection.Constructor = conn;

  case 5,
 
    % Using a third party JDBC Driver.

    conn=com.mathworks.toolbox.database.databaseConnect(instance,UserName,Password,Driver,URL);

    connection.Instance = instance;
    connection.UserName = UserName;
    connection.Driver   = Driver;
    connection.URL      = URL;
    connection.Constructor = conn;
    
 otherwise,

  % All arguments are not specified .. set all elements of the connection structure to be 
  % either empty or zero.

  connection.Message = 'Function requires three or five arguments to be defined';  
  errorhandling(connection.Message);
  connection=class(connection,'database',dbobj);
  return;
     
 end % switch
  
connection.Message  = [];
connection.Handle=[];

connectionVector = makeDatabaseConnection(conn);
   
% Check to see if the connection is valid .. must get the status element
% of the connection vector.
   
status = validConnectionMade(conn,connectionVector);
   
if (status == 1)
      
  % Valid connection has been established
      
  connection.Handle = getValidConnection(conn,connectionVector);
  
else
      
  connection.Handle = 0;
      
end
   
% Check to see if the connection has been made successfully .. non zero value returned.
% Issue a warning if connection has not been made.

if (strcmp(class(connection.Handle),'double')),

	message=getTheErrorMessage(conn);
	
	% Connection failure .. set all elements of the connection structure to be 
	% either empty or zero.

	conn = 0;
	connection.Instance	= instance;
  connection.UserName = UserName;
  connection.Driver		= [];
  connection.URL	      = [];
  connection.Message   = message;
   
      
end

connection.TimeOut=[];
connection.AutoCommit='off';
connection.Type='Database Object';
connection=class(connection,'database',dbobj);

if ~isempty(message),
  errorhandling(message);
  return;
end

%Trap logintimeout error under Linux (method not supported)
try
  connection.TimeOut=logintimeout;
catch
  connection.TimeOut = 0;
end


%%Subfunctions

function errorhandling(s)
%ERRORHANDLING Error processing based on preference setting.
%   ERRORHANDLING(S) performs error processing based on the 
%   SETDBPREFS property ErrorHandling.  S is the contents
%   of the connection.Message field.

switch (setdbprefs('ErrorHandling'))
  
  case 'report' 
        
    %Throw error
    error('database:database:connectionFailure','%s',s);
        
  case {'store','empty'}
        
    %Message field is populated, do nothing else
      
end
