function [varargout] = native2unicode(varargin)
%NATIVE2UNICODE	Convert bytes to Unicode characters.
%   UNICODESTR = NATIVE2UNICODE(BYTES) takes a vector containing
%   numeric values in the range [0,255] and converts these values
%   as a stream of 8-bit bytes to Unicode characters. The stream
%   of bytes is assumed to be in the native character set of the
%   machine. The Unicode characters are returned in the char vector
%   UNICODESTR with the same general array shape as BYTES. BYTES
%   can be a vector of numeric or character data. You can use the
%   commands FREAD, FGETL, and FSCANF to generate input to this
%   function.
%
%   UNICODESTR = NATIVE2UNICODE(BYTES,CHARSET) does the conversion
%   and assumes that the byte stream is composed of characters
%   from character set CHARSET.
%
%   For example,
%
%       fid = fopen('japanese.txt');
%       b = fread(fid,'*char')';
%       fclose(fid);
%       str = native2unicode(b,'Shift_JIS');
%       disp(str);
%  
%   reads and displays some Japanese text. For the final command,
%   disp(str), to display this text correctly, the contents of str
%   must consist entirely of Unicode characters. The call to
%   NATIVE2UNICODE converts text read from the file to Unicode and
%   returns it in str. The Shift_JIS argument ensures that str
%   contains the same string on any computer, regardless of how it
%   is configured for language. Note that the computer must be
%   configured to display Japanese (e.g. a Japanese Windows machine)
%   for the output of disp(str) to be correct.
%
%   Common names for CHARSET are 'US-ASCII', and 'Shift_JIS'. The 
%   CHARSET string must use 'US-ASCII' characters. Case does not
%   matter. For the preferred list of names for CHARSET consult the
%   WEB site:
%
%       http://www.iana.org/assignments/character-sets
%
%   See also UNICODE2NATIVE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/05/05 00:59:08 $
%   Built-in function.

if nargout == 0
  builtin('native2unicode', varargin{:});
else
  [varargout{1:nargout}] = builtin('native2unicode', varargin{:});
end

