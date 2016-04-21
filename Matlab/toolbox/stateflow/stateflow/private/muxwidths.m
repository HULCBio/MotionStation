function widthStr = muxwidths(v)
%WIDTHSTR = MUXWIDTHS( v )

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:58:47 $

if (length(v) ~= 2)
	disp('Error input to v must be a two element vector!');
	keyboard;
end;

v = [ones(1,v(1)) v(2)];
v(v==0) = [];

if ~isempty(v),
	vStr = num2str(v);
	widthStr = ['[',vStr,']'];
else,
	widthStr = '[1]';
end;
