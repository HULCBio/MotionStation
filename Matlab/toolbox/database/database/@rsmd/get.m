function v = get(d,p,n)
%GET    Get resultset metadata properties.
%   V = GET(D,'PropertyName',N) returns the value of the specified 
%   properties for the resultset metadata object, D.  'PropertyName'
%   is a string or cell array of strings containing property names. 
%   N is the column number representing the column for which the properties
%   are returned.
%
%   V = GET(D,N) returns a structure where each field name is the name
%   of a property of D and each field contains the value of that 
%   property for the column index N.  All properties are returned for the
%   given columns.
%
%   V = GET(D) returns all properties for all columns.
%
%   See also RSMD.

%   Author(s): C.F.Garvin, 07-10-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9 $   $Date: 2002/06/17 12:01:08 $

%Build property list if none are given   
prps = {'CatalogName';...
        'ColumnCount';...
        'ColumnDisplaySize';...
        'ColumnLabel';...
        'ColumnName';...
        'ColumnType';...
        'ColumnTypeName';...
        'Precision';...
        'Scale';...
        'SchemaName';...
        'TableName';...
        'isAutoIncrement';...
        'isCaseSensitive';...
        'isCurrency';...
        'isDefinitelyWritable';...
        'isNullable';...
        'isReadOnly';...
        'isSearchable';...
        'isSigned';...
        'isWritable';...
       };   

%Determine which properties are requested and if second arg is property or index
if nargin == 1
  
  %All properties for all columns
  p = prps;
  n = 1:double(getColumnCount(d.Handle));
  
elseif nargin == 2 & any(strcmp(class(p),{'char','cell'}))
  
  %Given properties for all columns 
  n = 1:double(getColumnCount(d.Handle));
  
elseif nargin == 2 & ~any(strcmp(class(p),{'char','cell'}))
  
  %Given properties for given columns
  n = p;
  p = prps;
  
end

%Perform error checking on properties
if isstr(p)
  p = {p};
end
p = chkprops(d,p,prps);

%Get property values, Some methods not directly accessible thru MATLAB
a = com.mathworks.toolbox.database.databaseRSMD;    
for j = 1:length(n)
  for i = 1:length(p)
    
    if strcmp(p{i},'ColumnCount')    %Properties with no column index
      eval(['v.' p{i} ' = get' p{i} '(d.Handle);'])
    else
      
      try                            %Default to "get" property
        eval(['v.' p{i} '{j} = get' p{i} '(d.Handle,n(j));'])
      catch  %Do not precede property with "get"
        try
          eval(['v.' p{i} '{j} = ' p{i} '(d.Handle,n(j));'])
        catch   %Method not directly accessible from MATLAB 
          eval(['v.' p{i} '{j} = rsmd' p{i} '(a,d.Handle,n(j));'])
        end    
      end
      
    end
  end
end

%For single property, return array not structure.
if length(p) == 1
  eval(['v = v.' char(p) ';'])
end
