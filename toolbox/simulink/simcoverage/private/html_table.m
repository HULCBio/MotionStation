function    str = html_table(data,format,options)
%HTML_TABLE - Format MATLAB structure data into an HTML table
%
%   STR = HTML_TABLE(DATA,FORMAT)  Use the format described by
%   the nested cell array FORMAT to generate an HTML table.  The
%   FORMAT entries can contain references and iterations across
%   fields and subfields within DATA.
%
%   The elements in the cell array FORMAT are read and interpretted
%   in order and the results are placed in table cells.  Format entry
%   types:
%
%       String elements
%
%       '$text'     - The text after the $ is placed in a table entry.
%       '#var'      - The fiels value, context.var is placed in a table   
%                     entry. If the value is a number it is converted 
%                     to a string value.  See below for more info
%       '\n'        - The current table row is terminated and a new line 
%                     is started.
%       '&mlfunc'   - The internal or MATLAB function mlfunc is invoked and
%                     if output is produced it is placed in a table entry.
%       '@n'        - The nth loop index, counted from innermost outward, is
%                     converted to a string.  Loops always start with 0
%       
%       Numeric elements
%
%       1.23        - Numeric elements are converted to text strings and 
%                     placed in a table entry.
%
%       Nested cell array elements
%
%       {'Cat', ... } 
%       Concatenate the remaining elements into a single string. 
%       Example:    {'Cat', '$Name: ', '#name' } produces the same string as 
%                   sprintf('Name: %s',data.name)   
%
%       {'ForN', cnt, ... }  
%       Repeat the table entry commands in the 3rd through the last cell element 
%       for cnt repetitions.
%
%       {'ForEach', '#var', ... } 
%       Repeat the table entry commands in the 3rd through the last cell element 
%       for each index in the substructure var.  The data context for referencing 
%       fields will become context.var(i).
%
%       {'RpnExpr', ... } 
%       Perform an RPN calculation. Each cell that evaluates to a 
%       number is placed on a stack. Operators remove entries from the
%       top of the stack, perform an operation, and place the result at
%       the top of the stack.  The entry at the top is the final result.
%       Available operators include '+', '-', '*', '/', '!', '>', '<', 
%       '==', '!=', '>=', '<='  
%
%       {'&func', ... }  
%       Call a function with arguments.  Each cell is evaluated and the result is 
%       passed to the function.  The function name is resolved with a table of 
%       internal functions and if it is not matched then MATLAB is called.
%
%       {'CellFormat', contents, colSpan, align} 
%       Format a single cell with a colspan and an alignment string.
%
%       {'#var', ... } 
%       Variable array indexing. The remaining elements are converted 
%       to integers and used to index into data.var.
%       Example:    {'#var', 1, '@1'} is equivalent to context.var(1,i)
%                   where i is the loop index.
%
%       {'If', testVal, ... , 'Else', ... } 
%       If the testVal is nonzero evaluate and create table entries for the third 
%       element until the end or an 'Else' element is found. If the testVal is 
%       false and an 'Else' element exists evaluate and create table entries for 
%       all elements after this.
%
%
%   Data contexts and field access
%
%   The data passed to html_table must be an array of structures.  Initialy the 
%   input data serves as the context for all field references, So that input 
%   such as '#name' is interpretted as data.name when the HTML is generated.
%   
%   When a 'ForEach' tag is implemented it results in a change of context.  For 
%   example
%   
%       {'ForEach','#block','#name'}  is equivalent to:
%       
%       for i=1:length(data.block)
%           data.block(i).name
%       end
%   
%   In this case '#name' was interpretted to data.block(i).name because the context 
%   was set to data.block(i).  
%   
%   The data context is refined with each nested 'ForEach' tag.  You can reference 
%   an ancestor context by using a sequence of < characters. Each < character 
%   moves up one generation in the data context. For example
%   
%       {'ForEach','#block','#<name'}  is equivalent to:
%       
%       for i=1:length(data.block)
%           data.name
%       end
%   
%   
%   Field references can include subfields separated by periods, e.g., '#model.name'
%   would be interpretted as data.model.name.  Subfield references can be combined
%   with < characters in references like {'ForEach','#block','#<model.name'}
%  
%  
%   STR = HTML_TABLE(DATA,FORMAT,TABLEPARAMS)  Allows the table layout to be adjusted
%   with various structure fields. TABLEPARAMS should be a nested structure which
%   can contain any combination of the following fields
%
%       TABLEPARAMS.textSize    The default text size for all entries in the table (1-7)
%       TABLEPARAMS.table       A string of attributes and values placed in the <table> tag
%       TABLEPARAMS.imageDIr    A subdirectory or path where image files are located.
%
%   The following substructure arrays determine row and column layout, if there are
%   more rows in the table than elements of the structure array the last structure
%   element is repeated for the remaining rows or columns.  The structure array can
%   contain any combination of the following fields
%
%       TABLEPARAMS.cols(i).align    A string value for the align="" attribute
%       TABLEPARAMS.cols(i).size     A text size that overides the table default
%       TABLEPARAMS.cols(i).width    The column width
%  
%       TABLEPARAMS.rows(i).align    A string value for the align="" attribute
%       TABLEPARAMS.rows(i).size     A text size that overides the table default
%  
%  

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/03/23 03:00:16 $

