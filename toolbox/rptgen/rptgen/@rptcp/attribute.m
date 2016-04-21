function attribute(p,varargin)
%ATTRIBUTE an interface to the component's ATTRIBUTE method
%   ATTRIBUTE(P,'action',argin1,argin2,argin3,...)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:25 $

c=attribute(get(p.h,'UserData'),varargin{:});
if isa(c,'rptcomponent')
   set(p.h,'UserData',c);
end
