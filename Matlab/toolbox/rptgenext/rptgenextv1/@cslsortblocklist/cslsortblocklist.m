function c=cslsortblocklist(varargin)
%Sorted Block List
%   Creates a list or table of all blocks in the model displayed
%   in their execution order.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:59 $

if ~strcmp(get_param(0,'RtwLicensed'),'on')
   error('Sorted Block List component requires RTW');
end

c=rptgenutil('EmptyComponentStructure','cslsortblocklist');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});


