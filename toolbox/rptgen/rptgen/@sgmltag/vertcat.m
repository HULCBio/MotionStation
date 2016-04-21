function base=vertcat(base,varargin)
%VERTCAT combines SGMLTAG objects
%   VERTCAT(A,B) appends B to A's data.  Puts B between A's tags.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:12:46 $

if ~isa(base,'sgmltag')
   base=sgmltag(base);
end

base.data=LocCell(base.data);

for i=1:length(varargin)
   base.data=[base.data LocCell(varargin{i})];
end
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=LocCell(in)

if iscell(in)
   out=in;
elseif isa(in,'sgmltag')
   if isempty(in.tag) & ...
         all(in.opt==[1 1 1 0]) %this is isSGML "on"
      out=LocCell(in.data);
   else
      out={in};
   end
else
   out={in};
end
