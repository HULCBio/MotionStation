function out=execute(c)
%EXECUTE returns report output
%   S=EXECUTE(CFRTEXT)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:56 $

%make sure text is not in a character array (don't want trailing spaces)
if ischar(c.att.Content)
   c.att.Content = cellstr(c.att.Content);
end

if c.att.isParseContent
   out=parsevartext(c.rptcomponent,c.att.Content);
else
   out=c.att.Content;
end

if c.att.isEmphasis
   out=set(sgmltag,...
       'tag','Emphasis',...
       'data',out,...
       'indent',logical(0));
end

if c.att.isLiteral
   out=set(sgmltag,...
      'tag','ProgramListing',...
      'data',out,...
      'indent',logical(0));   
end
%Note: We really want LiteralLayout here because it doesn't
%force the use of a fixed-width font.  Unfortunately, the HTML
%stylesheets can't handle generic inlines inside linespecific
%text.  The <i> tag, for example, isn't smart enough to preserve
%the <p class="linespecific"> tag's line-preserving.
%ProgramListing uses <pre>, which DOES preserve linebreaks with
%inline content.

