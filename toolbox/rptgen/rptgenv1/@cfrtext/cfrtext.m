function c=cfrtext(varargin)
%   Text
%   Inserts plain text into the report.
%
%   Note that text should not be inserted directly into the
%   report stream: it should be parented by a paragraph, list
%   or used as a section/paragraph title.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:55 $

c=rptgenutil('EmptyComponentStructure','cfrtext');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

