function c=cfrsection(varargin)
%   Chapter/Subection
%   This component divides a report into sections which
%   have a title and content.  Sections can be nested
%   and titles will automatically become smaller inside
%   sub-sections.  There are seven levels of nesting
%   possible: 
% 
%   * Chapter
%   * Sect1-Sect5
%   * Simple Section
%
%   If Chapter/Subsection components are nested more than
%   seven components deep, no section will be created, but
%   the output of the subcomponents will still appear
%   in the report.
%
%   The title of the section can be specified or 
%   determined from the first subcomponent.
%
%   Subcomponents of this component are placed inside
%   the section.  If the title is taken from the first
%   subcomponent, section content is drawn from the
%   second subcomponent until the end of the 
%   subcomponent list.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:47 $

c=rptgenutil('EmptyComponentStructure','cfrsection');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

