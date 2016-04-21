%% Introduction to digital I/O objects.
%    DEMODIO_INTRO illustrates a basic data acquisition session using a
%    digital I/O object.  This is demonstrated by adding lines to  the
%    digital I/O object and writing and reading data from the  configured
%    lines.
% 
%    See also DIGITALIO, ADDLINE, DAQHELP, PROPINFO.
%
%    MP 3-24-99 
%    Copyright 1998-2003 The MathWorks, Inc. 
%    $Revision: 1.5.2.5 $  $Date: 2003/08/29 04:45:23 $

%%
% Find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this demo, digital input/output interactions will be 
% explored. This demo will use National Instruments hardware. 
% The information obtained for this demonstration has been 
% pre-recorded so if you do not have a National Instruments
% card, you can still see how the digital input/output 
% interactions are handled by the Data Acquisition Toolbox.

%%
% To begin, let's create a digital I/O object associated with 
% National Instruments hardware having a device id of 1.  
% Four output lines will be added to the digital I/O object 
% from port 0. This configuration will allow you to write 
% values to these lines. 
% 
% >> dio = digitalio('nidaq', 1);
% >> addline(dio, 0:3, 0, 'Out')
% 
%   Index:  LineName:  HwLine:  Port:  Direction: 
%   1       ''         0        0      'Out'      
%   2       ''         1        0      'Out'      
%   3       ''         2        0      'Out'      
%   4       ''         3        0      'Out'      

%%
% You can write values to the digital I/O lines as either a 
% decimal value or as a binvec value. A binvec value is a 
% binary vector, which is written with the least significant  
% bit as the leftmost vector element and the most significant 
% bit as the rightmost vector element. For example, the decimal 
% value 23 is written in binvec notation as
% 
%     [1 1 1 0 1]
% 
% The binvec value is converted to a decimal value as follows
% 
%     1*2^0 + 1*2^1 + 1*2^2 + 0*2^3 + 1*2^4

%%
% The toolbox provides you with two convenience functions 
% for converting between decimal values and binvec values. 
% 
% You can convert a decimal value to a binvec value with 
% the DEC2BINVEC function. 
% 
% >> binvec = dec2binvec(196)
% 
% binvec = 
% 
%       0     0     1     0     0     0     1     1
% 
% You can convert a binvec value to a decimal value with 
% the BINVEC2DEC command.
% 
% >> decimal = binvec2dec([1 0 1 0 1 1])
% 
% decimal = 
% 
%        53

%%
% You can use the PUTVALUE command to write values to the  
% digital I/O object's lines. You can write to a line 
% configured with a direction of 'Out'. An error will occur 
% if you write to a line configured with a direction of 'In'.
% 
% For example, to write the binvec value [ 0 1 0 0 ] to the  
% digital I/O object, dio
% 
% >> putvalue(dio, [0 1 0 0]);
% 
% Similarly, you can write to a subset of lines as follows
% 
% >> putvalue(dio.Line([ 1 3 ]), [ 1 1 ]);
% 
% The lines not written to will remain at their current values 
% (in this example, lines with index 2 and index 4 remain at  
% [1 0], respectively).
% 
% It is important to note that if a decimal value is written 
% to a digital I/O object, and the value is too large to be 
% represented by the object, then an error is returned.
% Otherwise the word is padded with zeros.

%%
% In this example, the digital I/O object contains four lines.  
% Therefore, the largest decimal value allowed is 15 or 
%
% (1*2^0 + 1*2^1 + 1*2^2 + 1*2^3).  
% 
% If the decimal value 5 is written to the digital I/O object,  
% only a three element binvec vector is needed to represent 
% the decimal value. The remaining line will have a value 
% of 0 written to it. Therefore, the following two commands 
% are equivalent.
% 
% >> putvalue(dio, 5);
% >> putvalue(dio, [1 0 1 0]);

%%
% However, the following command will return an error.
%
% >> putvalue(dio, 42);
% ??? Error using ==> digitalio/putvalue
%
% The specified DATA value is too large to be represented by 
% OBJ.
% 
% The error occurs because the decimal value 42 is equivalent 
% to the binvec value [ 0 1 0 1 0 1 ]. The binvec value 
% contains six elements, but there are only four lines 
% contained by the digital I/O object. 

%%
% You can read the values of the digital I/O lines with the 
% GETVALUE command. GETVALUE always returns a binvec value.
% You can read from a line configured with a direction of 
% either 'In' or 'Out'.
% 
% >> value = getvalue(dio)
% 
% value = 
% 
%       1
%       0
%       1
%       0
% 
% You can convert the binvec value to a decimal value with the 
% BINVEC2DEC command.
% 
% >> value = binvec2dec(getvalue(dio))
% 
% value = 
% 
%       5

%%      
% Similarly, you can read a subset of lines as follows
% 
% >> getvalue(dio.Line([ 1 3 ]))
% 
% value = 
% 
%       1
%       1

%%
% This completes the introduction to digital I/O objects. 
% You should delete the digital I/O object, dio, with the 
% DELETE command to free memory and other physical resources.
% 
% >> delete(dio);

