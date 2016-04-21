function c=csl_blk_bus(varargin)
%Block Type: Bus
% 	 Displays a list of signals connected to a bus block  
%   

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:12 $

c=rptgenutil('EmptyComponentStructure','csl_blk_bus');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});