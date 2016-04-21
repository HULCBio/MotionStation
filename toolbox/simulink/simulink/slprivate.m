%SLPRIVATE is a gateway for internal support functions used by 
%           Simulink.
%   VARARGOUT = SLPRIVATE('FUNCTION_NAME', VARARGIN) 
%   
%   

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/15 00:49:35 $

function varargout = slprivate(function_name, varargin)
  
   [varargout{1:nargout}] = feval(function_name, varargin{1:end});

