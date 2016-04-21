function c=crg_comment(varargin)
%Comment
%   The Comment Component inserts a comment into the SGML source file
%   created by the report generation process. The comment is not visible
%   in the generated report.
%
%   This component can have children. Child components insert their output
%   into the SGML source file, but this output appears inside comment tags
%   and does not appear in the final report.
%
%   If you want the comment text to appear in the report, follow these steps:
%   1) Edit the SGML source file (the SGML source file has the same name as
%      your report file, but has a .sgml extension). Note that you must
%      generate a report to create the SGML source file.
%   2) Find the comment area in the SGML source file by locating the comment
%      tags: <-- and -->. Remove both of these tags.
%   3) Convert the SGML source file using the RPTCONVERT command
%      for more details on the rptconvert command).
%
%   See also RPTCONVERT

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:50 $

%--------1---------2---------3---------4---------5---------6---------7---------8

c=rptgenutil('EmptyComponentStructure','crg_comment');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

