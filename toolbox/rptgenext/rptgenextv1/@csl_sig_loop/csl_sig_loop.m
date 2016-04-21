function c=csl_sig_loop(varargin)
%Signal Loop
%   This component runs its subcomponents for each
%   signal in the current context.  Context is defined
%   by the Model Loop, System Loop, or Block Loop 
%   components.
%
%   See also CSL_MDL_LOOP, CSL_SYS_LOOP, CSL_BLK_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:22 $

c=rptgenutil('EmptyComponentStructure','csl_sig_loop');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});