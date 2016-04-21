function h = transaction(RootObj,varargin)
% Returns instance of @transaction class

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:36 $

h = ctrluis.transaction;
h.RootObjects = RootObj;

% Create transaction and set its  properties
T = handle.transaction(get(RootObj(1).classhandle.package,'DefaultDatabase'));
T.set(varargin{:});
h.Transaction = T;

% Set name
h.Name = T.Name;