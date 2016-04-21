function mm = memoryobj(varargin)
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
%   datatypes).  SIZE defines the dimensions of the memory array.
%   For simple vectors, this can be a scalar length.
%  
%   Note - the resulting MM object retains a reference to the LINK
%   object.  Therefore, to complete clear a COM interface requires
%   deleting any outstanding MM objects.  
%
%  Major Properties of NUMERICMEM
%  -----------------
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
%  NUMBEROFSTORAGEUNITS - Number of Address units in this object.  The size
%    will (read-only?)
% 
%  TIMEOUT -
%  LINK 
%
%  See Also READ, WRITE, WRITE

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $ $Date: 2004/04/08 20:46:23 $

mm = ccs.memoryobj;
construct_memoryobj(mm,varargin);   % All heavy lifing in hear (avoid UDD issue with base class constructors)

% [EOF] memoryobj.m
 