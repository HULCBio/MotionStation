%SFPRIVATE is a gateway for internal support functions used by 
%           Stateflow.
%   VARARGOUT = RTWPRIVATE('FUNCTION_NAME', VARARGIN) 
%   
%   

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

function varargout = sfprivate(fcnName, varargin)
  
   if(nargout>0)
       varargout = cell(1,nargout);
       [varargout{:}] = feval(fcnName,varargin{:});
   else
       feval(fcnName,varargin{:});
   end

