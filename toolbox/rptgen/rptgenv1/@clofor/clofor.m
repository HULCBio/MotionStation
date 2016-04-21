function c=clofor(varargin)
%FOR Loop
%   This component runs its subcomponents several times.  It
%   acts the same as the MATLAB "for" loop.  Loops can be
%   specified by start/increment/end numbers or a vector of
%   indices.  These are equivalent to the MATLAB expressions
%   "for i=X:Y:Z" and "for i=[A B C D E]" respectively.
%
%   Inputs to the start/increment/end/vector fields may be
%   numbers or the name of a workspace variable.
%
%   See also FOR, CLO_WHILE, CLOIF

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:00 $


c=rptgenutil('EmptyComponentStructure','clofor');
c=class(c,c.comp.Class,rptcomponent);
c=buildcomponent(c,varargin{:});

