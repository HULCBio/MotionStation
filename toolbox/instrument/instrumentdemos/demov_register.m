%% Introduction to Register-Based Functionality.
%
% Copyright 1999-2004 The MathWorks, Inc. 
% $Revision: 1.9.2.4 $  $Date: 2004/03/24 20:40:31 $

%% Introduction
% This demo explores register-based read and write operations
% for VISA-VXI and VISA-GPIB-VXI objects.  
% 
% The information obtained for this demonstration was prerecorded. 
% Therefore, you do not need an actual instrument 
% to learn about register-based functions. 
% 
% The instrument used was a Hewlett-Packard (HP) E1432A 16-Channel 
% 51.2 kSa/s Digitizer plus DSP Module.
% 
% The examples given throughout this tutorial use a VISA-VXI
% object. However, you can also use a VISA-GPIB-VXI object.
% Refer to the command-line help on the VISA function to see
% how to create a VISA-GPIB-VXI object.
%
% VXI instruments are either message-based or register-based. 
% Generally, it is assumed that the message-based instruments 
% are easier to use while the register-based instruments are 
% faster.
% 
% A message-based instrument has its own processor that allows 
% it to interpret high-level commands such as a SCPI command. 
% Therefore, to communicate with a message-based instrument, 
% you can use the ASCII or binary read and write functions
% (FSCANF, FREAD, FPRINTF, FWRITE,...). If the message-based 
% instrument also contains shared memory, you can access 
% the shared memory through register-based read and write 
% operations.
% 
% A register-based instrument usually does not have its own 
% processor to interpret high-level commands. Therefore, to
% communicate with a register-based instrument, you need to 
% use read and write functions that access the registers.  
%
% All VXI instruments have an A16 memory space consisting of 
% 64 bytes. It is known as an A16 space because the addresses 
% are 16 bits wide. Register-based instruments provide a  
% memory map of the address space that includes details about
% the information contained within the A16 space. For example,
% the HP E1432A instrument contains the following information:
% 
%    Offset              Information
%    ------              -----------
%    0                   ID Register
%    2                   Device Type Register
%    4                   Status Register
%    6                   Offset Register
% 
% Some VXI instruments also have an A24 or A32 space if the 
% 64 bytes provided by the A16 space are not enough to perform
% the necessary tasks. A VXI instrument cannot use both the 
% A24 and A32 space. 

%% Functions and Properties
% These functions are used to perform register-based read
% and write operations:
% 
%   MEMMAP           - Map memory for low-level memory  
%                      read and write.
%   MEMPEEK          - Low-level memory read of instrument 
%                      register.
%   MEMPOKE          - Low-level memory write of instrument 
%                      register.
%   MEMREAD          - High-level memory read of instrument 
%                      register.
%   MEMUNMAP         - Unmap memory for low-level memory 
%                      read and write.
%   MEMWRITE         - High-level memory write to instrument
%                      register.
% 
% These properties are associated with register-based read 
% and write operations:
% 
%   MappedMemoryBase - The base address of the mapped memory
%   MappedMemorySize - The size of the mapped memory
%   MemoryBase       - Indicate the base address of the A24 
%                      or A32 space
%   MemoryIncrement  - Indicate whether the VXI registers are 
%                      read from or written to as block or FIFO
%   MemorySize       - Indicate the size of the A24 or A32 
%                      space
%   MemorySpace      - Indicate the type of memory space the
%                      instrument supports

%% Creating a VISA Object
% To begin, create a VISA-VXI object. The HP E1432A VXI
% instrument is in the first chassis and has a logical address 
% of 8.  
% 
%  >> v = visa('agilent', 'VXI0::8::INSTR');
% 
%    VISA-VXI Object Using AGILENT Adaptor : VISA-VXI0-8
% 
%    Communication Address 
%       ChassisIndex:       0
%       LogicalAddress:     8
% 
%    Communication State 
%       Status:             closed
%       RecordStatus:       off
% 
%    Read/Write State  
%       TransferStatus:     idle
%       BytesAvailable:     0
%       ValuesReceived:     0
%       ValuesSent:         0
% 

%% Connecting the VISA Object to Your Instrument
% Before you can perform a read or write operation, you must
% connect the VISA-VXI object to the instrument with the 
% FOPEN function. If the VISA-VXI object was successfully
% connected, its Status property is automatically configured
% to open.
% 
%  >> fopen(v)
%  >> get(v, 'Status')
% 
%  ans =
% 
%  open 

%% Register Characteristics
%% Register Characteristic Properties -- MemorySpace
% The MemorySpace property indicates the type of memory space
% the instrument supports. By default, all instruments support 
% A16 memory space. However, this property can be A16/A24 or
% A16/A32 if the instrument also supports A24 or A32 memory
% space, respectively.
% 
%  >> get(v, 'MemorySpace')
% 
%  ans =
% 
%  A16/A24
% 
% Note that the VXI object must be connected to the instrument
% before the MemorySpace property is queried, otherwise the 
% default value of A16 is returned.

%% Register Characteristic Properties -- MemoryBase and MemorySize
% The MemoryBase property indicates the base address of the 
% A24 or A32 space, and is defined as a hexadecimal string. 
% The MemorySize property indicates the size of the A24 or 
% A32 space. If the VXI instrument supports only the A16
% memory space, MemoryBase defaults to '0H%' and MemorySize
% defaults to 0.
% 
%  >> get(v, {'MemoryBase', 'MemorySize'})
% 
%  ans = 
% 
%     '200000H'    [262144]

%% High-Level Memory Read and Write Operations
% The Instrument Control toolbox provides both high-level and low-level
% memory functions. High-level memory functions allow you to access memory 
% through simple function calls. Unlike low-level memory  functions,
% high-level memory functions do not require that memory be mapped to a
% window. The memory mapping is  handled automatically for you by the
% functions. As a result, the high-level memory functions are easier to use
% but are slower than the low-level memory functions. The high-level
% functions also allow you to read or write multiple registers at once.
%

%% High-Level Memory Read
% Before you perform a read or write operation, you should
% understand the information stored by your instrument's
% registers. The HP E1432A documentation states that the
% first 16-bit register, the ID Register, provides information 
% about the instrument's configuration. It is always defined 
% as CFFF:
% 
%        Bits     Value     Description
%        ====     =====     ===========
%        15-14    11        indicating that the instrument 
%                           is register-based
%        13-12    00        indicating that the instrument 
%                           supports the A24 memory space
%        11-0     all 1's   HP's ID
% 
% MEMREAD allows you to read uint8, uint16, uint32, or single
% values from the specified memory space with the specified 
% offset. For example, read the first 16-bit register
% (offset is 0) as a uint16.
% 
%  >> data = memread(v, 0, 'uint16', 'A16')
% 
%  data =
% 
%       53247
% 
%  >> dec2hex(data)
% 
%  ans =
% 
%  CFFF
% 
%  >> dec2bin(53247)
% 
%  ans =
% 
%  1100111111111111

%% High-Level Memory Read -- Reading a Block of Data
% It is also possible to read a block of data with the
% MEMREAD function. For example, read the instrument's
% ID Register and Device Type Register.
% 
% The ID Register was read in the previous example and
% should have a value of CFFF. The Device Type Register
% is the next register and is defined as follows:
% 
%      Bits               Contents
%      ----               --------
%      15-12              required A24 memory
%      11-0               Model Code - should be 201H
% 
%  >> data = memread(v, 0, 'uint16', 'A16', 2)
% 
%  data =
% 
%       53247
%       20993 

%% High-Level Memory Write
% The MEMWRITE function allows you to write uint8, uint16, 
% uint32, or single values to the specified memory space with 
% the specified offset. 
% 
% Write a value to the Offset Register, which is at 
% offset 6 in the A16 space. The Offset Register defines the
% base address of the device's A24 registers. Note that 
% this value should be restored to it's original values if 
% you want to access the A24 registers.
% 
%  >> original_Value = memread(v, 6, 'uint16', 'A16');
%  >> memwrite(v, 40960, 6, 'uint16', 'A16');
%  >> memread(v, 6, 'uint16', 'A16')
% 
%  ans =
% 
%     40960
% 
%  >> memwrite(v, original_Value, 'uint16', 'A16');

%% Low-Level Memory Read and Write Operations
% The low-level memory functions are faster than the high-level memory
% functions but require you to map the memory to be read or written. The
% low-level memory functions  allow you to read and write one register at a
% time.  Additionally, to increase speed, the low-level memory  functions
% do not report back any errors that may have  occurred.

%% Mapping the Memory Space
% To begin using the low-level memory routines, you must 
% first map your memory space with the MEMMAP function.  
% 
% Note that if the memory requested by the MEMMAP function
% does not exist, an error is returned.  
% 
% In this example, map the first 16 registers of the 
% A16 memory space:
% 
%  >> memmap(v, 'A16', 0, 16);

%% Low-Level Memory Properties -- MappedMemoryBase and MappedMemorySize
% The VISA-VXI object has two properties that indicate if
% memory has been mapped: MappedMemoryBase and MappedMemorySize.
% These properties are similar to the MemoryBase and MemorySize
% properties that describe the A24 or A32 memory space. The
% MappedMemoryBase property is the base address of the mapped
% memory and is defined as a hexadecimal string. The 
% MappedMemorySize property is the size of the mapped memory.  
% 
%  >> get(v, {'MappedMemoryBase', 'MappedMemorySize'})
% 
%  ans = 
% 
%     '16737610H'    [16]

%% Low-Level Memory Read
% The MEMPEEK function allows you to read uint8, uint16, uint32, 
% or single values from the specified offset in the mapped 
% memory space. 
% 
% For example, read the information in the ID Register.
% This is the first register in the A16 space:
% 
%  >> mempeek(v, 0, 'uint16')
%  
%  ans =
% 
%        53247
% 
% Now read the information in the Device Type Register.
% This register also provides information on the instrument's
% configuration. 
% 
%  >> mempeek(v, 2, 'uint16')
% 
%  ans =
% 
%        20993

%% Low-Level Memory Write 
% The MEMPOKE function allows you to write uint8, uint16,  
% uint32, or single values to the specified offset in the 
% mapped memory space. 
% 
% For example, write a value to the Offset Register 
% and verify that the value was written by reading the Offset
% Register's new value.
% 
%  >> original_Value = mempeek(v, 6, 'uint16');
%  >> mempoke(v, 45056, 6, 'uint16');
%  >> mempeek(v, 6, 'uint16')
% 
%  ans =
% 
%      45056
% 
%  >> mempoke(v, original_Value, 6, 'uint16');

%% Unmapping the Memory Space
% Once you have finished reading the registers or writing 
% to the registers, you should unmap the memory with the
% MEMUNMAP function.
% 
%  >> memunmap(v)
%  >> get(v, {'MappedMemoryBase', 'MappedMemorySize'})
% 
%  ans = 
% 
%     '0H'    [0]
% 
% Note that if memory is still mapped when the object is 
% disconnected from the instrument, the memory is automatically
% unmapped for you.

%% Cleanup
% If you are finished with the VISA-VXI object, disconnect
% it from the instrument, remove it from memory, and remove it 
% from the workspace.
% 
%  >> fclose(v);
%  >> delete(v);
%  >> clear v
