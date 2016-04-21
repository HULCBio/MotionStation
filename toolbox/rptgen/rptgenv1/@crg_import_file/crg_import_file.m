function c=crg_import_file(varargin)
%Import File
%   Inserts plain text from a file into the report.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:04 $

c=rptgenutil('EmptyComponentStructure','crg_import_file');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

