function attributes = attr(cursor,column);
%ATTR Get attributes of columns in fetched data set.
%   ATTRIBUTES = ATTR(CURSOR,COLUMN) returns the attributes 
%   of a single table column, defined by the input argument 
%   COLUMN, or all the table columns, if the COLUMN argument 
%   is not defined, in the data set set described by the fetch 
%   and resultSet elements of the input argument CURSOR. 
%
%   Example:
%
%   To return the attributes for all columns/fields in the SQL
%   select statement the sqlattr command is used as follows:
%
%   columnAtts = attr(cursor)
%
%   This will return a struct array with the following structure
%   elements:
%
%   fieldName   - Database column/field name.
%   typeName    - String indicating the data type.
%   typeValue   - Numeric value for indicating the data type.
%   columnWidth - Width of database column/field.
%   precision   - Precision value for float and double data 
%                 types. Empty value returned for strings. 
%   scale       - Precision value for real and numeric data
%                 types. Empty value returned for strings. 
%   currency    - Flag to indicate whether the column/field is
%                 a currency column/field.
%   readOnly    - Flag to indicate whether column/field is
%                 read only.
%   nullable    - Flag to indicate whether column/field can
%                 contain a null.
%
%   To access an element of the array and view the elements type   
%   columnAtts(1) and the following would be displayed.
%
%
%   fieldName: 'EmployeeID'
%   typeName: 'LONG'
%   typeValue: 4
%   columnWidth: 11
%   precision: []
%   scale: []
%   currency: 'false'
%   readOnly: 'true'
%   nullable: 'false'
%
%   To return the attributes for a single column/field in the SQL
%   select statement the ATTR command is used as follows:
%
%   columnAtts = attr(cursor,1)
%
%   To view the data type columnAtts and the following information
%   would be displayed.
%
%   fieldName: 'EmployeeID'
%   typeName: 'LONG'
%   typeValue: 4
%   columnWidth: 11
%   precision: []
%   scale: []
%   currency: 'false'
%   readOnly: 'true'
%   nullable: 'false'
%
%   See also: FETCH.

%   Author: E.F. McGoldrick, 09-02-97, C.F.Garvin, 06-15-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.18 $	$Date: 2002/06/17 12:01:53 $%

% First check to ensure that the input arguments are in the correct order and of the
% correct type.

% Initalize the structure.

attributes.fieldName   = [];	
attributes.typeName    = [];	
attributes.typeValue   = 0;	
attributes.columnWidth = 0;	
attributes.precision   = 0;	
attributes.scale       = 0;	
attributes.currency    = [];	
attributes.readOnly    = [];	
attributes.nullable    = [];
attributes.Message     = [];

if (nargin == 1)
  
  if (isa(cursor,'cursor') ~= 1)
     
     cursor.Message = 'First argument of function must be a cursor';
     return;
     
  end
  
elseif (nargin == 2)
  
  if ((isa(cursor,'cursor') ~= 1) | ...
      (isa(column,'double') ~= 1))
     
   cursor.Message = 'Arguments of function must be a cursor and column value';  
   return;
    
 end
  
end	

if ~isa(cursor.Fetch,'com.mathworks.toolbox.database.fetchTheData')
  attributes.Message = 'Error: Invalid cursor';
  return
end

md= getTheMetaData(cursor.Fetch);
status = validResultSet(cursor.Fetch,md);

if (status == 0)
   
  % Improper cursor passed in.
   
  attributes.Message = 'Error: Invalid cursor';
  return
   
else
  
  resultSetMetaData = getValidResultSet(cursor.Fetch,md);

end

% Must determine if just one field or all fields are to be described. 
   
if (nargin == 1)
    
   
   % All fields in the record (columns in the database table) are to be described.
       
   columns = maximumColumns(cursor.Fetch,resultSetMetaData);
   
   % Get the field/column attributes.
  
   for (i = 1:double(columns))
            
   	 % Get the field name
          
     attributes(i).fieldName = columnName(cursor.Fetch,i,resultSetMetaData);   
   
   	 % Get the column type value.
      
     attributes(i).typeName = columnTypeName(cursor.Fetch,i,resultSetMetaData);
     
     % Get data type value
     
     attributes(i).typeValue = columnType(cursor.Fetch,i,resultSetMetaData);
     
     % Get the field width
     
     attributes(i).columnWidth = columnWidth(cursor.Fetch,i,resultSetMetaData);
         
     % Get the precison of the field if applicable ... test for floats,reals,doubles etc. 
    
     if ( (attributes(i).typeValue == 2)     | ...
         (attributes(i).typeValue == 3)      | ...
         (attributes(i).typeValue == 6)      | ...
         (attributes(i).typeValue == 7)      | ...
         (attributes(i).typeValue == 8)),
       
       attributes(i).precision = precision(cursor.Fetch,i,resultSetMetaData);
        
     else
      
       % Default value .. empty to conform with MATLAB convention.
           
       attributes(i).precision = [];  
      
     end
    
     % Get the scale of the field if applicable .. test for reals and numerics.
    
     if ( (attributes(i).typeValue == 2)      | ...
        (attributes(i).typeValue == 7)),
      
       attributes(i).scale = scale(cursor.Fetch,i,resultSetMetaData);
        
     else
      
       attributes(i).scale = []; % Default value .. empty to conform with MATLAB convention.
      
     end
    
     % Check if field is a currency field.
     curr = currency(cursor.Fetch,i,resultSetMetaData);
         
     if (curr == 1),
      attributes(i).currency = 'true';
     else,
      attributes(i).currency = 'false';
     end 
    
     % Get field priveleges
     readO = readOnly(cursor.Fetch,i,resultSetMetaData);
       
     if (readO  == 1),
       attributes(i).readOnly  = 'true';
     else,
       attributes(i).readOnly  = 'false';
     end
     
     isNullable = nullable(cursor.Fetch,i,resultSetMetaData);
     if (isNullable == 1),
       attributes(i).nullable = 'true';
     else
       attributes(i).nullable = 'false';
     end
    
   end
else
  
  % Single field attributes requested.
  % First check to see if the column index argument is valid column number.
  maxCols = cols(cursor);
  
  if ((column > maxCols) 	|...
      (column <= 0)),
    
    attributes.Message = 'Invalid Column Number';
    return;
    
  end;
  
  i = column;
  % Get the field name
  attributes.fieldName = columnName(cursor.Fetch,i,resultSetMetaData);
    
  % Get the column type value.
  attributes.typeName = columnTypeName(cursor.Fetch,i,resultSetMetaData);
    
  % Get data type value
  attributes.typeValue = columnType(cursor.Fetch,i,resultSetMetaData);
    
  % Get the field width
  attributes.columnWidth = columnWidth(cursor.Fetch,i,resultSetMetaData);
    
  % Get the precison of the field if applicable ... test for floats,reals,doubles etc.  
  if ( (attributes.typeValue == 2)      | ...
      (attributes.typeValue == 3)      | ...
      (attributes.typeValue == 6)      | ...
      (attributes.typeValue == 7)      | ...
      (attributes.typeValue == 8)),
    
    attributes(i).precision = precision(cursor.Fetch,i,resultSetMetaData);
  else,
    attributes.precision = [];  % Default value .. empty to conform with MATLAB convention.
  end
  
  % Get the scale of the field if applicable .. test for reals and numerics.
  
  if ( (attributes.typeValue == 2)      | ...
      (attributes.typeValue == 7)),
    
    attributes.scale = scale(cursor.Fetch,i,resultSetMetaData);
        
  else,    
    attributes.scale = []; % Default value .. empty to conform with MATLAB convention.
    
  end
  
  % Check if field is a currency field.
  
  curr = currency(cursor.Fetch,i,resultSetMetaData);
    
  if (curr == 1),    
    attributes.currency = 'true';
    
  else,    
    attributes.currency = 'false';
    
  end 
  
  % Get field priveleges
  readO = readOnly(cursor.Fetch,i,resultSetMetaData);
  
  if (readO  == 1),    
    attributes.readOnly  = 'true';
    
  else,    
    attributes.readOnly  = 'false';
    
  end
  
  isNullable = nullable(cursor.Fetch,i,resultSetMetaData);
  
  if (isNullable == 1),    
    attributes.nullable = 'true';
    
  else,    
    attributes.nullable = 'false';
    
  end
  
end
