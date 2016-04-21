function fontname=fixedwidthfont(anObject)
%FIXEDWIDTHFONT returns a fixed width font name

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:16 $

if strcmpi(get(0,'Language'),'japanese')
   fontname=get(0,'defaultuicontrolfontname');
else
   fontname='courier';
end

