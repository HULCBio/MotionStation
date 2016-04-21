function c=crgnestset(varargin)
%Nest Setup Files
%   Allows one setup file (.rpt) to be run inside of another.  Specify
%   the name of the setup file in the edit box.
%
%   "Create a separate report"
%   This mode runs the setup file and creates a report in a separate
%   file than the current report.  Nothing is inserted into the
%   current report.
%
%   "Inline new setup file"
%   This mode temporarily pastes the specified setup file's components
%   into the current setup file.  The following diagram shows a 
%   simplified outline for the original setup file ('foo.rpt') and
%   the inserted file ('bar.rpt')
%
%   [-] Report - foo.rpt                [-] Report - bar.rpt
%     [ ] A                               [ ] 1
%     [-] B                               [ ] 2
%        [ ] Nest Setfile - bar.rpt       [-] 3
%        [ ] C                              [ ] 4
%     [ ] D                                 [ ] 5
%
%   The report will execute as if the original setup file looked 
%   like this:
%
%   [-] Report - foo.rpt
%     [ ] A
%     [-] B
%        [ ] 1
%        [ ] 2
%        [-] 3
%          [ ] 4
%          [ ] 5
%        [ ] C
%     [ ] D
%   
%   Note that components which determine their behavior from
%   their parents such as "Chapter/Subsection will be affected
%   by components in the parent setup file.
%
%   See also: CFRSECTION
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:18 $

c=rptgenutil('EmptyComponentStructure','crgnestset');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});



