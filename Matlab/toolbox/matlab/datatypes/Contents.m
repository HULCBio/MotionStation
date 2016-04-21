% Data types and structures.
%
% Data types (classes)
%   double          - Convert to double precision.
%   char            - Create character array (string).
%   logical         - Convert numeric values to logical.
%   cell            - Create cell array.
%   struct          - Create or convert to structure array.
%   single          - Convert to single precision.
%   uint8           - Convert to unsigned 8-bit integer.
%   uint16          - Convert to unsigned 16-bit integer.
%   uint32          - Convert to unsigned 32-bit integer.
%   uint64          - Convert to unsigned 64-bit integer.
%   int8            - Convert to signed 8-bit integer.
%   int16           - Convert to signed 16-bit integer.
%   int32           - Convert to signed 32-bit integer.
%   int64           - Convert to signed 64-bit integer.
%   inline          - Construct INLINE object.
%   function_handle - Function handle array.
%   javaArray       - Construct a Java array.
%   javaMethod      - Invoke a Java method.
%   javaObject      - Invoke a Java object constructor.
%
% Class determination functions.
%   isnumeric       - True for numeric arrays.
%   isfloat         - True for floating point arrays, both single and double.
%   isinteger       - True for arrays of integer data type.
%   islogical       - True for logical array.
%   ischar          - True for character array (string).
%
% Multi-dimensional array functions.
%   cat             - Concatenate arrays.
%   ndims           - Number of dimensions.
%   ndgrid          - Generate arrays for N-D functions and interpolation.
%   permute         - Permute array dimensions.
%   ipermute        - Inverse permute array dimensions.
%   shiftdim        - Shift dimensions.
%   squeeze         - Remove singleton dimensions.
%
% Cell array functions.
%   cell            - Create cell array.
%   cellfun         - Functions on cell array contents.
%   celldisp        - Display cell array contents.
%   cellplot        - Display graphical depiction of cell array.
%   cell2mat        - Combine cell array of matrices into one matrix.
%   mat2cell        - Break matrix up into cell array of matrices.
%   num2cell        - Convert numeric array into cell array.
%   deal            - Deal inputs to outputs.
%   cell2struct     - Convert cell array into structure array.
%   struct2cell     - Convert structure array into cell array.
%   iscell          - True for cell array.
%
% Structure functions.
%   struct          - Create or convert to structure array.
%   fieldnames      - Get structure field names.
%   getfield        - Get structure field contents.
%   setfield        - Set structure field contents.
%   rmfield         - Remove structure field.
%   isfield         - True if field is in structure array.
%   isstruct        - True for structures.
%   orderfields     - Order fields of a structure array.
%
% Function handle functions.
%   @               - Create function_handle.
%   func2str        - Convert function_handle array into string.
%   str2func        - Convert string into function_handle array.
%   functions       - List functions associated with a function_handle.
%
% Object oriented programming functions.
%   class           - Create object or return object class.
%   struct          - Convert object to structure array.
%   methods         - List names and properties of class methods.
%   methodsview     - View names and properties of class methods.
%   isa             - True if object is a given class.
%   isjava          - True for Java objects.
%   isobject        - True for MATLAB objects.
%   inferiorto      - Inferior class relationship.
%   superiorto      - Superior class relationship.
%   substruct       - Create structure argument for SUBSREF/SUBSASGN.
%
% Overloadable operators.
%   minus           - Overloadable method for a-b.
%   plus            - Overloadable method for a+b.
%   times           - Overloadable method for a.*b.
%   mtimes          - Overloadable method for a*b.
%   mldivide        - Overloadable method for a\b.
%   mrdivide        - Overloadable method for a/b.
%   rdivide         - Overloadable method for a./b.
%   ldivide         - Overloadable method for a.\b.
%   power           - Overloadable method for a.^b.
%   mpower          - Overloadable method for a^b.
%   uminus          - Overloadable method for -a.
%   uplus           - Overloadable method for +a.
%   horzcat         - Overloadable method for [a b].
%   vertcat         - Overloadable method for [a;b].
%   le              - Overloadable method for a<=b.
%   lt              - Overloadable method for a<b.
%   gt              - Overloadable method for a>b.
%   ge              - Overloadable method for a>=b.
%   eq              - Overloadable method for a==b.
%   ne              - Overloadable method for a~=b.
%   not             - Overloadable method for ~a.
%   and             - Overloadable method for a&b.
%   or              - Overloadable method for a|b.
%   subsasgn        - Overloadable method for a(i)=b, a{i}=b, and a.field=b.
%   subsref         - Overloadable method for a(i), a{i}, and a.field.
%   colon           - Overloadable method for a:b.
%   end             - Overloadable method for a(end)
%   transpose       - Overloadable method for a.'
%   ctranspose      - Overloadable method for a'
%   subsindex       - Overloadable method for x(a).
%   loadobj         - Called when loading an object from a .MAT file.
%   saveobj         - Called with saving an object to a .MAT file.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.38.4.4 $  $Date: 2004/03/08 02:01:30 $
