function flushinput(obj)
%FLUSHINPUT Remove data from input buffer.
%
%   FLUSHINPUT(OBJ) removes remaining data from the interface object's
%   input buffer and sets the BytesAvailable property to 0 for the
%   interface object, OBJ. 
%  
%   If FLUSHINPUT is called during an asynchronous (nonblocking) read 
%   operation, the data currently stored in the input buffer is flushed
%   and the read operation continues. You can read data asynchronously 
%   from the instrument using the READASYNC function.
%
%   The input buffer is automatically flushed when you connect an object
%   to the instrument with the FOPEN function.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       fopen(g);
%       fprintf(g, 'Curve?')
%       readasync(g, 512);
%       flushinput(g);
%       fclose(g);
%
%   See also ICINTERFACE/FLUSHOUTPUT, ICINTERFACE/READASYNC, 
%   INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:30 $

% Error checking.
if (length(obj) > 1)
    error('instrument:flushinput:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Call flushinput on the java object.
try
   flushinput(igetfield(obj, 'jobject'));
catch
   error('instrument:flushinput:opfailed', lasterr);
end   
