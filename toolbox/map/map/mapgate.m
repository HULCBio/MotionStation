function varargout = mapgate(varargin)
%MAPGATE Gateway routine to call private functions.
%   MAPGATE is used to access private functions. 
%
%   [OUT1, OUT2,...] = MAPGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/map/map/private with input arguments
%   VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%
%   FHNDL = MAPGATE(FCN) returns the function handle.
 
%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:23:20 $

switch nargin
   case 0
      eid = sprintf('%s:%s:invalidInputFunction', getcomp, mfilename);
      msg = sprintf('MAPGATE expected a function name as the first input.'); 
      error(eid,'%s',msg);

   case 1
      if nargout==0,
         eid = sprintf('%s:%s:invalidNumberOfOutputs', getcomp, mfilename);
         msg = sprintf('MAPGATE expected one output argument.'); 
         error(eid,'%s',msg);
      else
         varargout{1:nargout} = str2func(varargin{:});
      end
  
   otherwise
      if nargout==0,
         feval(varargin{:});
      else
         [varargout{1:nargout}] = feval(varargin{:});
      end
end
%#function geoReservedNames getprojdirs checkrefmat checkrefvec 
