function c=csl_sys_loop(varargin)
%System Loop
%   This component runs it subcomponents for each
%   System defined in the current context.  Context
%   is defined by the Model Loop component.
%
%   Note that systems can be excluded from looping by
%   using a System Filter component.
%
%   See also CSL_MDL_LOOP, CSLFILTER

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:45 $

c=rptgenutil('EmptyComponentStructure','csl_sys_loop');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});

