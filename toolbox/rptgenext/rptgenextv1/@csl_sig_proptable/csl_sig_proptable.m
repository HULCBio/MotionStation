function c=csl_sig_proptable(varargin)
%Signal Property Table
%   Inserts a property-value table for the signal defined by
%   the Signal Loop component.
%
%   See also CSL_SIG_LOOP, RPTPROPTABLE

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:30 $

c=rptgenutil('EmptyComponentStructure','csl_sig_proptable');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});


