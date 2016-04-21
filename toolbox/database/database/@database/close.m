function close(connect)
%CLOSE Close database connection.
%   CLOSE(CONNECT) closes the database connection.
%   CONNECT is a database connection object returned by 
%   DATABASE.
%  
%   See also DATABASE.

%   Author: E.F. McGoldrick, 09-02-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.2 $	$Date: 2004/04/06 01:05:16 $%

if (isempty(connect.Handle))
   
   return;
   
end

% Call to the class constructor
databaseConnection = com.mathworks.toolbox.database.closeTheDatabaseConnection(connect.Handle);

%  Call to the class method closing the connection 
%  .. returns true if successful.

returnVal = closeTheConnection(databaseConnection);
