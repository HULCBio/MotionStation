function result=isreadable(cc,address,datatype,count)
%ISREADABLE Check if specified memory block can be read. 
%   ISREADABLE(CC,ADDRESS,DATATYPE,COUNT) returns logical true if the
%   memory block defined by ADDRESS, DATATYPE and COUNT is available for
%   reading on the DSP processor referenced by CC. Conversely, this test
%   will return a logical false if any portion of the memory block is not
%   available. For convenience, the memory block specification mirrors the
%   READ syntax.  The data block under test begins on the memory location
%   defined by the ADDRESS parameter.  DATATYPE defines the data format and
%   is used to determine the number of bytes per value.  Finally, the
%   optional COUNT defines the number of values in the write block.  The
%   follow description examines details of each parameter: 
%
%   ADDRESS is a decimal or hexadecimal representation of a memory address 
%   in the target DSP.  In all cases, the full address consist of two
%   parts: the offset and the memory page.  However, many DSP processors
%   have only a single page, in which case the page portion of the full
%   address should always be 0.  The page value can be explicitly defined
%   using a numeric vector representation of the address (see below).
%   Alternatively, the CC object has a default page value which is applied
%   if the page value is not explicitly incorporated into the passed
%   address parameter.  In DSP processors with only a single page, by
%   setting the CC object page value to zero it is possible to specify all
%   addresses using the abbreviated (implied page) format.  The address
%   parameter can be specified in two ways, first as a numerical value
%   which is a decimal representation of the DSP address.  Alternatively, a
%   string is interpreted as a hexadecimal representation of the address.
%   (See HEX2DEC, which is used for the conversion to a decimal value).
%   When the address is defined by a string, the page is always derived
%   from the CC object.  Thus, there is no method of explicitly defining
%   the page when the address is passed as a hexadecimal string.
%
%   Examples of the address parameter:
%       '1F'  Address is decimal 31, with the page taken from cc.page
%         10  Address is decimal 10, with the page taken from cc.page
%     [18 1]  Address is decimal 18, with page equal to decimal 1
%   
%   DATATYPE is a string representation of a supported MATLAB data type.
%   This parameter is used to determine the number of bytes per value,
%   which is used in conjunction with the COUNT parameter to determine a
%   total memory block size.  The following MATLAB data types are
%   supported: 
%
%    'double'  IEEE Double-precision floating point
%    'single'  IEEE Single-precision floating point
%     'uint8'  8-bit unsigned binary integer
%    'uint16'  16-bit unsigned binary integer
%    'uint32'  32-bit unsigned binary integer
%      'int8'  8-bit signed 2's complement integer
%     'int16'  16-bit signed 2's complement integer
%     'int32'  32-bit signed 2's complement integer
%
%   COUNT is a numeric scalar or vector that defines the number of DATATYPE 
%   values to be checked for read ability.  To mimic the syntax of READ, 
%   this parameter can be a vector to define multidimensional data blocks.  
%   The size of the data block that is tested by this routine is always
%   equal to the product of all elements in the COUNT vector.  Thus the
%   following examples are equivalent:
%     cc.isreadable('1000','int16',[6 3 2])  % check read status of 3d array
%     cc.isreadable('1000','int16',36)       % Same as above
%
%   ISREADABLE(CC,ADDRESS,DATATYPE)  Same as above, except COUNT defaults 
%   to 1, which causes this method to check the memory status of a single
%   DATATYPE value.
%
%   Note, this routine relies on the memory map option available in Code 
%   Composer Studio(R). If the memory map is not defined properly in the 
%   Code Composer workspace, this method will not produce meaningful
%   results. 
%
%   See also ISWRITABLE, READ, HEX2DEC.

% Copyright 2004 The MathWorks, Inc.
