function [varargout] = unicode2native(varargin)
%UNICODE2NATIVE	Convert Unicode characters to bytes.
%   BYTES = UNICODE2NATIVE(UNICODESTR) takes a char vector of Unicode
%   characters, UNICODESTR, converts it to the native character set of
%   the machine, and returns the bytes as a uint8 vector BYTES. The
%   output vector, BYTES, has the same general array shape as UNICODESTR.
%   You can save the output of UNICODE2NATIVE in a file using FWRITE.
%
%   BYTES = UNICODE2NATIVE(UNICODESTR,CHARSET) converts the Unicode
%   characters to the characters from the character set CHARSET instead
%   of the native character set.
%
%   For example,
%
%       fid = fopen('japanese_in.txt');
%       b = fread(fid,'*char')';
%       fclose(fid);	
%       str = native2unicode(b,'Shift_JIS');
%
%       disp(str);
%
%       b = unicode2native(str,'Shift_JIS');
%       fid = fopen('japanese_out.txt','w');
%       fwrite(fid,b);		 
%       fclose(fid);
%
%   reads, displays, and writes some Japanese text. The disp(str)
%   command requires that str consist entirely of Unicode characters to
%   display correctly. The example calls FWRITE to save the text to a
%   file 'japanese_out.txt'. To write this file using the original
%   character set, call UNICODE2NATIVE first to convert the Unicode
%   string back to 'Shift_JIS'.
%
%   Common names for CHARSET are 'US-ASCII', and 'Shift_JIS'. The
%   CHARSET string must use 'US-ASCII' characters. Case does not
%   matter. For the preferred list of names for CHARSET consult the
%   WEB site:
%
%       http://www.iana.org/assignments/character-sets
%
%   See also NATIVE2UNICODE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/05/05 00:59:09 $
%   Built-in function.

if nargout == 0
  builtin('unicode2native', varargin{:});
else
  [varargout{1:nargout}] = builtin('unicode2native', varargin{:});
end

