%RTWPRIVATE is a gateway for internal support functions used by 
%           Real-Time Workshop.
%   VARARGOUT = RTWPRIVATE('FUNCTION_NAME', VARARGIN) 
%   
%   

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.3 $

function varargout = rtwprivate(function_name, varargin)
  
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});

