function a=horzcat(a,varargin)
%HORZCAT horizontal concatentation [a,b]

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:41 $

for i=1:length(varargin)
   if isa(varargin{i},'rptcp')
      a.h=[a.h,varargin{i}.h];
   elseif ishandle(varargin{i})
      a.h=[a.h,varargin{i}];
   elseif isa(varargin{i},'rptcomponent')
      a =[a varargin{i}.comp.ID];
   end
end
