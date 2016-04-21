function obj = saveobj(obj)
%SAVEOBJ Method to pre-process CFIT objects before saving

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:40:58 $

% Remove function handles that will be useless if loaded later
obj = clearhandles(obj);
