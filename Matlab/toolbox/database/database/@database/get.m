function v = get(c,p)
%GET Get property of database connection.
%   VALUE = GET(HANDLE, PROPERTY) will return the VALUE of the PROPERTY 
%   specified for the given HANDLE to a Database object.
%
%   VALUE = GET(HANDLE) returns VALUE as a structure containing all the
%   property values of the Database object.
%
%   See also SET.

% Copyright 1984-2002 The MathWorks, Inc.
% $Revision: 1.16 $ $Date: 2002/06/17 12:02:01 $

%Build property list 
prps = {...
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
  
%Set return property list or validate given properties
if nargin == 1
  p = prps;
else
  p = chkprops(c,p,prps);
end

%Get property values
for i = 1:length(p)
  try  
    switch p{i}
      case 'Catalog'
        tmp = com.mathworks.toolbox.database.databaseConn;
        eval(['v.' p{i} ' = ' connCatalog(tmp,c.Handle) ';'])    
      case 'AutoCommit'
        tmp = getAutoCommit(c.Handle);
        if tmp
          v.AutoCommit = 'on';
        else
          v.AutoCommit = 'off';
        end
      case 'ReadOnly'
        v.ReadOnly = isreadonly(c); 
      otherwise
        eval(['v.' p{i} ' = c.' p{i} ';'])
    end
  catch
    eval(['v.' p{i} ' = get' p{i} '(c.Handle);'])
  end
end

%Do not return structure if only one property is requested
if length(p) == 1
  eval(['v = v.' char(p) ';'])
end
