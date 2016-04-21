function out=rptparent(varargin)
%RPTPARENT Report generator parent object

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:25 $

if nargin==0
   %out.comp(1)=cgnmainloop;
   out.Desc='Report generator container class';
   
   out = class(out,'rptparent');
elseif isa(varargin(1),'rptparent')
   out=in;
else
   varargin(1)=parent;
end