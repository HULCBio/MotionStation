function c=coutline(varargin)
%COUTLINE the first component of any setup file
%   Output File Options
%   This component specifies the format and filename of the 
%   report.  It is always the first component in the setup
%   file and can not be moved, deactivated, added, or deleted.  
%
%   The report file location is shown in bold above the directory
%   and filename options.
%
%   Some stylesheets are only available with certain output format
%   selections.  If a format is selected for which the current
%   stylesheet is not valid, the stylesheet will automatically
%   change to be a valid sheet.
%
%   The "Description" field has no effect on report generation - 
%   it is a place for notes and comments.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:10:22 $



%Hardcode this in order to remove dependency on v1 fcn
%c=rptgenutil('EmptyComponentStructure','coutline');
c=struct('comp',struct('Class','coutline',...
   'Active',true),...
   'att',[],...
   'ref',[],...
   'x',[]);

c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});
