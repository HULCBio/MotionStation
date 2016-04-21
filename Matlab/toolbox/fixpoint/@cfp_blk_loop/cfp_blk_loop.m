function c=cfp_blk_loop(varargin)
%Fixed-Point Block Loop
%   This component runs its subcomponents for each
%   Fixed-Point block in its context.  Parent components which 
%   can define context are the Model Loop, System Loop, 
%   and Signal Loop.
%
%   See also CSL_MDL_LOOP, CSL_SYS_LOOP, CSL_SIG_LOOP, CSL_BLK_LOOP

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/10 16:54:51 $

c=rptgenutil('EmptyComponentStructure','cfp_blk_loop');
c=class(c,c.comp.Class,rptcomponent,rptfpmethods,zslmethods);
c=buildcomponent(c,varargin{:});

