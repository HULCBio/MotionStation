function c=crgtds(varargin)
%Time/Date Stamp
%   Inserts the current time and/or date into the report
%   in a variety of customizable formats.  Note that the
%   stamp is placed as text.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:30 $

c=rptgenutil('EmptyComponentStructure','crgtds');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});



