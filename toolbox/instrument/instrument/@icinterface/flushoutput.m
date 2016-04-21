function flushoutput(obj)
%FLUSHOUTPUT Remove data from output buffer.
%
%   FLUSHOUTPUT(OBJ) removes remaining data from the interface object's
%   output buffer and sets the BytesToOutput property to 0 for the
%   interface object, OBJ.  
%
%   If data is being written asynchronously, the write operation will
%   be stopped and the remaining data will be flushed. Additionally, 
%   the M-file callback function specified for OBJ's OutputEmptyFcn
%   property is executed. Data is written asynchronously to the 
%   instrument with the FPRINTF or FWRITE functions.
%
%   The output buffer is automatically flushed when you connect an 
%   object to the instrument with the FOPEN function.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       fopen(g);
%       fprintf(g, 'Function:Shape Sin', 'async')
%       flushoutput(g);
%       fclose(g);
%
%   See also ICINTERFACE/FLUSHINPUT, ICINTERFACE/FPRINTF, ICINTERFACE/FWRITE, 
%   INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:31 $

% Error checking.
if (length(obj) > 1)
    error('instrument:flushoutput:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Call flushoutput on the java object.
try
   flushoutput(igetfield(obj, 'jobject'));
catch
   error('instrument:flushoutput:opfailed', lasterr);
end   
