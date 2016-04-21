function t=sgmltag(varargin)
%SGMLTAG - parsed representation of an SGML element
%   The SGMLTAG object has fields:
%   T.tag - the tag text  <tag>
%   T.data - tag content.  Can be numbers, strings, 
%       other SGMLTAG objects, or a cell array
%   T.att - a Nx2 cell array.  Column 1 is the
%       attribute name, Column 2 is the attribute
%       value.  
%   T.opt is an options vector
%       opt(1) = IndentContents.  If true, will indent subtags and cdata.
%       opt(2) = EndTag.  If true, inserts an endtag.
%       opt(3) = Expanded.  If true, tag and data are on different lines.
%       opt(4) = SGML.  Contents are SGML - do not replace <,& with
%                escape characters.
%
%   SGMLTAG object:
%     T.tag='foo';
%     T.data='bar';
%     T.att={'att1',0;'att2',a};
%     T.opt=[1 1 1 0];
%
%   SGML text:
%       <foo att1=0 att2="a">
%          bar
%       </foo>
%
%   See also: SGMLTAG/CHAR, SGMLTAG/SET, SGMLTAG/SHOW

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:40 $

t=struct('tag','',...
   'data','',...
   'att',{cell(0,2)},...
   'opt',logical([1 1 1 0]));

if nargin==1
   t.data=varargin{1};
elseif nargin>1
   t.data={varargin{:}};
end

t=class(t,'sgmltag');

