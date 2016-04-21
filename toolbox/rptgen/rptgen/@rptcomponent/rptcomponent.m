function out=rptcomponent(varargin)
%RPTCOMPONENT constructor method for @rptcomponent class

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:16 $

if nargin==0
   %retrun an empty object
   out.Desc = 'Component container class';
   parent=rptparent;
   out = class(out,'rptcomponent',parent);
elseif isa(varargin(1),'rptcomponent')
   out=in;
else
   varargin(1)=parent;
      
end