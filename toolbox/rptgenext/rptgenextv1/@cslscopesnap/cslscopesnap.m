function c=cslscopesnap(varargin)
%Block Type: Scope Snapshot
%   Inserts a picture of all scopes in the current context.
%  

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:36 $

c=rptgenutil('EmptyComponentStructure','cslscopesnap');
c=class(c,c.comp.Class,rptcomponent,zslmethods);
c=buildcomponent(c,varargin{:});