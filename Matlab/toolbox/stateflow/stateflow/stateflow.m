function [varargout] = stateflow( varargin )
%STATEFLOW  Opens SIMULINK and calls sfnew when appropriate.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 01:01:52 $

   if nargout>0
      [varargout{:}] = sf( varargin{:} );
   else
      sf(varargin{:});
   end



