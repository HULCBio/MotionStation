function c=csl_mdl_loop(varargin)
%Model Loop
%   This component controls which Simulink models will be
%   included in the report.  It also decides which systems
%   in those models will be included in the report.
%
%   See also CSL_SYS_LOOP, CSL_BLK_LOOP, CSL_SIG_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:05 $

c=rptgenutil('EmptyComponentStructure','csl_mdl_loop');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});
