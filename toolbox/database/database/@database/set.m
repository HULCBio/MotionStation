function x = set(varargin)
%SET Set properties for database connection.
%   SET(H, 'PROPERTY', 'VALUE') sets the VALUE of the given PROPERTY for the
%   Database object, H. 
%
%   SET(H) returns the list of properties that can be modified.
%
%   See also GET.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.15.4.2 $ $Date: 2004/04/06 01:05:24 $

if nargin == 1
  x = {...
      'AutoCommit';...
      'Catalog';...
      'Driver';...
      'Handle';...
      'Instance';...
      'Message';...
      'ReadOnly';...
      'TimeOut';...
      'TransactionIsolation';...
      'Type';...
      'URL';...
      'UserName';...
      'Warnings';...
      };
  return
end

H=varargin{1};

% Check for valid database object handle .. should not be empty.

if (isempty(H.Handle) == 0),
   
   switch lower(varargin{2}),
      
   case 'autocommit',
      
     constructor = com.mathworks.toolbox.database.databaseConnect;
   
     % Convert the flag returned from the driver .. true = on & false = off.
   
     switch lower(varargin{3}),
       case 'on',
      
         toggle = 'true';
      
       case 'off',
      
         toggle = 'false';
      
       otherwise,
      
         error('database:database:invalidAutoCommitValue','Invalid flag value:  %s',varargin{3});
      
     end
   
     autoC = toggleAutoCommit(constructor,H.Handle,toggle);	
   
     % Convert the flag returned from the driver .. true = on & false = off.
      
      
     if (strcmp(autoC,'true') == 1)
      
      	autoC = 'on';
      
     else
      
      	autoC = 'off';
      
     end
   
   case 'readonly'
     
     setReadOnly(H.Handle,varargin{3})
     
   case 'transactionisolation'
     
     setTransactionIsolation(H.Handle,varargin{3})
     
   case 'timeout',
   
 	   error('database:database:useLogintimeout','Use logintimeout function to change the property : %s',varargin{2});

	 case {'driver','instance','handle','message','warnings','username','url',...
   	   'type','catalog'}

	   % Users not allowed to set/reset the following properties of a connection.

	   error('database:database:readOnlyProperty','Attempt to modify read-only Database property: %s',varargin{2});
   
	otherwise,
   
  		error('database:database:invalidProperty','Invalid Database property name: %s',varargin{2});
  
	end % switch    
   
else
   
   error('database:database:invalidConnection','Invalid connection.')
   
end 

