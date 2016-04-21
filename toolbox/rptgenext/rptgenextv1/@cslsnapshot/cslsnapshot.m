function c=cslsnapshot(varargin)
%System Snapshot
%   Inserts an picture of the current system into the report.
%   The current system is defined by the System Loop component.
%
%   See also CSL_SYS_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:52 $

c=rptgenutil('EmptyComponentStructure','cslsnapshot');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});




