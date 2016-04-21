function varargout=noop(varargin)
%NOOP does nothing, returns emptys as needed

% Copyright 2003 The MathWorks, Inc.

if nargout>0
    for k=1:nargout
        varargout{k}=[];
    end
end