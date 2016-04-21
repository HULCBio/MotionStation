function s = expand_double_byte_string(s)
% Usage: expandedString = expand_double_byte_string( doublebyteString )
% Every double-byte char larger than 255 is expanded to two chars.

%	E. Mehran Mestchian
%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.5.2.1 $  $Date: 2004/04/15 00:57:37 $

doubleBytes = find(s>255);
if isempty(doubleBytes), return; end

doubleBytes = doubleBytes(end:-1:1);
for i = doubleBytes
	c = uint16(s(i));
	s(i) = char(bitand(255,c)); % trailing byte
	% add leading byte
	if (i>1)
		s = [s(1:i-1) char(bitshift(c,-8)) s(i:end)];
	else
		s = [char(bitshift(c,-8)) s(i:end)];
	end
end


