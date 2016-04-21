function v = get(d,p,n)
%GET    Get resultset properties.
%   V = GET(D,'PropertyName',N) returns the value of the specified 
%   properties for the resultset object, D.  'PropertyName'
%   is a string or cell array of strings containing property names. 
%   N is the column number or name for which the properties are returned.
%
%   V = GET(D,N) returns a structure where each field name is the name
%   of a property of D and each field contains the value of that 
%   property for the column index or name N.  All properties are returned 
%   for the given columns.
%
%   V = GET(D) returns all properties for all columns.
%
%   See also GET, NAMECOLUMN.

%   Author(s): C.F.Garvin, 07-09-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10 $   $Date: 2002/06/17 12:01:12 $

%Build properties if none are given   
prps = {'AsciiStream';...
        'BinaryStream';...
        'Boolean';...
        'Byte';...
        'Bytes';...
        'CursorName';...
        'Date';...
        'Double';...
        'Float';...
        'Int';...
        'Long';...
        'MetaData';...
        'Object';...
        'Short';...
        'String';...
        'Time';...
        'Timestamp';...
        'UnicodeStream';...
        'Warnings';...
        };   

%Determine which properties and/or columns are requested
if nargin == 1   
  
  %All properties for all columns
  p = prps;
  tmp = getMetaData(d.Handle);
  y = 1:double(getColumnCount(tmp));
  
elseif nargin == 2
  
  %Subset of properties or columns, determine which one
  if isstr(p)  
    p = {p};
  end
  
  if iscell(p)               %Could be properties or columns
    
    x = namecolumn(d,p{1});  %Try to match first element to column index
    
    if x                     %Assume no column names match property names
      for i = 1:length(p)
        y(i) = namecolumn(d,p{i});    %Column names to indices
      end
      p = prps;                       %Get all properties
    else                              %Properties given
      tmp = getMetaData(d.Handle);
      y = 1:double(getColumnCount(tmp));             
      p = chkprops(d,p,prps);  
    end
    
  else
    
    y = p;     %Indices given
    p = prps;  %Get all properties
    
  end
    
else
  
  if isstr(p) 
    p = {p};
  end
  
  p = chkprops(d,p,prps);
  
  if isstr(n)    %Column names to column indices if necessary
    n = {n};
  end
  if iscell(n) & isstr(n{1})
    for i = 1:length(n)
      y(i) = namecolumn(d,n{i});
    end
  else
    y = n;
  end
  
end

tmp = com.mathworks.toolbox.database.databaseResultSet;  %Constructor needed for some methods.
%Get property values
for j = 1:length(y)
  for i = 1:length(p)
    try
      if strcmp(p{i},'CursorName')
        eval(['v.' p{i} '{j} = ' rsCursorName(tmp,d.Handle) ';'])
      elseif strcmp(p{i},'String')
        eval(['v.' p{i} '{j} = ' rsString(tmp,d.Handle,y(j)) ';'])
      elseif any(strcmp(p{i},{'MetaData','Warnings'}))
        eval(['v.' p{i} '{j} = get' p{i} '(d.Handle);'])
      else
        eval(['v.' p{i} '{j} = get' p{i} '(d.Handle,y(j));'])  
      end
    catch
      eval(['v.' p{i} '{j} = [];'])
    end
  end
end

if length(p) == 1
  eval(['v = v.' char(p) ';'])
end
