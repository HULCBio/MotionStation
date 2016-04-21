function obj = clearhandles(obj)
%CLEARHANDLES Method to remove function handles, called by the
%  SAVEOBJ method for this class or a derived class

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/02/01 21:41:26 $

% Remove function handles that will be useless if loaded later
if isa(obj.expr,'function_handle')
   obj.expr = [];
end
if isa(obj.derexpr,'function_handle')
   obj.derexpr = [];
end
if isa(obj.intexpr,'function_handle')
   obj.intexpr = [];
end
if isa(obj.startpt,'function_handle')
   obj.startpt = [];
end

