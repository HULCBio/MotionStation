function out=getattx(p,varargin)
%GETATTX an interface to the component's GETATTX method

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:37 $

out=getattx(get(p.h,'UserData'),varargin{:});
