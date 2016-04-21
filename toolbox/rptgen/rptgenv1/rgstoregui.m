function out=rgstoregui(in)
%RGSTOREGUI saves a RPTGUI object in persistent memory

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:53 $

persistent KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE

mlock

if nargin>0
   KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE=in;
end

out=KEEP_THIS_GUI_OBJECT_FOR_FUTURE_REFERENCE;
