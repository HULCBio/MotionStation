function daqdoc7_1
%DAQDOC7_1 Digital I/O documentation example.
% 
%    DAQDOC7_1 is divided into four distinct sections:
%      1. Creating a device object
%      2. Adding lines
%      3. Reading and writing values
%      4. Cleaning up
%
%    DAQDOC7_1 demonstrates how to:
%      - Read and write values from digital lines
%      - Use DEC2BINVEC
%
%    DAQDOC7_1 is constructed to be used with National Instruments boards.
%    You should feel free to modify this file to suit your specific needs.

%    DD 5-11-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:45:01 $%

%1. Create a device object - Create the digital I/O object dio for a National 
%Instruments board. The installed adaptors and hardware IDs are found with daqhwinfo.
dio = digitalio('nidaq',1);

%2. Add lines - Add eight output lines from port 0 (line-configurable). 
addline(dio,0:7,'out');

%3. Read and write values - Write a value of 13 to the first four lines as a decimal 
%number and as a binary vector, and read back the values.
data = 13;
putvalue(dio.Line(1:4),data)
val1 = getvalue(dio);
bvdata = dec2binvec(data);
putvalue(dio.Line(1:4),bvdata)
val2 = getvalue(dio);
%Write a value of 3 to the last four lines as a decimal number and as a binary vector, 
%and read back the values.
data = 3;
putvalue(dio.Line(5:8),data)
val3 = getvalue(dio.Line(5:8));
bvdata = dec2binvec(data,4);
putvalue(dio.Line(5:8),bvdata)
val4 = getvalue(dio.Line(5:8));
%Read values from the last four lines but switch the most significant bit (MSB) and 
%the least significant bit (LSB).
val5 = getvalue(dio.Line(8:-1:5));

%4. Clean up - When you no longer need dio, you should remove it from memory and from 
%the MATLAB workspace.
delete(dio)
clear dio
