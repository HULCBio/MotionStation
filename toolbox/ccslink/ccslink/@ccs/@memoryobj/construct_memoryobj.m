function mm = constructor_memoryobj(mm,args)
%MEMORYOBJ  Constructor for raw memory object 
%  MM = MEMORYOBJ('PropertyName',PropertyValue,...)  Constructs an MM
%   object  numeric arrays of data between MATLAB
%   and DSP memory.  An MM object can only be created with
%   a valid LINK object. In fact, the LINK object has a method
%   (MEMORYOBJ) that can be used to directly generate a MM object.
%   Alternately, this object can be created by passing a valid 
%   LINK object.  Several properties of the MM object are inherited 
%   from the LINK object, such as endianness.  
%   With an MM object it is possible to read/write blocks of DSP 
%   memory and apply precise numeric interpretations to the raw 
%   DSP memory blocks. The interpretation of memory is defined by 
%   the properties of the MM object. The TYPE string input can be 
%   used to assign the MM properties for a common set of datatypes.  
%   (SEE the CAST method of MM for more information on the predefined
%   datatypes).  DIMNUM defines the dimensions of the memory array.
%   For simple vectors, this can be a scalar length.
%  
%   Note - the resulting MM object retains a reference to the LINK
%   object.  Therefore, to complete clear a COM interface requires
%   deleting any outstanding MM objects.  
%
%  Major Properties of NUMERICMEM
%  -----------------
%  DIMNUM - Defines the dimensions of the numeric array as a vector
%   of sizes.  One place this propetty is used directly is by 
%   the read methods to determine the size of the returned numeric 
%   array.  For example, DIMNUM = [2 2 2] means 
%
%  ADDRESS - Defines the starting address of the memory
%   block.  It is formatted in the style of the parent
%   DSP object from which the MM object was created.
%  
%  AUBITS - (read-only) Bits per Address unit.  This value 
%    indicates how many bits are given per DSP address 
%    value.  For example, on byte addressable CPUs, the AUBITS
%    will be set to 8. Any value is possible but other common 
%    values include 16,32 and 24.  When the MEMORY object is 
%    created, this value is set according to the DSP type and 
%    address value. 
%
%  AUNUM - Number of address units used to define a value. For
%   example, IEEE single-precision floating point requires 32 bits,
%   therefore in byte-addressable memory (aubits=8) the ANUM 
%   property equals 4 (i.e. 8x4=32 bits).
%
%  ENDIANNESS - Specifes the endianness of data values that
%   span multiple address units.  This property is initialized
%   to match the DSP device and memory type.
%
%  ARRAYORDER - Defines ordering of values when converting MATLAB
%    arrays to/from linearily addressable memory blocks.
%    'row-major' (default) - Rows filled first (C Style)
%    'col-major' - Columns filled first (Matlab Style)
%
%  See Also CAST, READ, WRITE.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.6.2.3 $ $Date: 2004/04/08 20:46:21 $

% Process constructors input arguments if any
if nargin <= 1
    return;      % Use defualts
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['MEMORYOBJ constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
end

% Get property / value pairs from argument list
for i = 1:2:nargs,
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error('Property Name must be a string entry');
    end
    if ~isempty( strmatch(prop,{'procsubfamily','bitsperstorageunit','link','address','aulength','maxaddress','timeout','objectdata'},'exact'))
        mm.(prop) = val;
    else
        error(['Unknown property ''' prop ''' specified for CCSDSP object.'])
    end
end            
% Inherent DSP properties

% [EOF] construct_memoryobj.m
 