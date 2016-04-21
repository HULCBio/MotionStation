function c=cfrparagraph(varargin)
%   Paragraph
%   Inserts a paragraph into the report.  Paragraph text
%   can be specified in the component or drawn from a
%   child text component.  The paragraph may be untitled 
%   or titled: titles can be specified in the component
%   or drawn from the first subcomponent.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:40 $

c=rptgenutil('EmptyComponentStructure','cfrparagraph');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

