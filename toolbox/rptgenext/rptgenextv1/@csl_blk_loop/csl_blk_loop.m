function c=csl_blk_loop(varargin)
%Block Loop
%   This component runs its subcomponents for each
%   block in its context.  Parent components which 
%   can define context are the Model Loop, System Loop, 
%   and Signal Loop.
%
%   See also CSL_MDL_LOOP, CSL_SYS_LOOP, CSL_SIG_LOOP

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:33 $

c=rptgenutil('EmptyComponentStructure','csl_blk_loop');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});

