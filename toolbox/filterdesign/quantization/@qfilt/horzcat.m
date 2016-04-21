function output=horzcat(varargin)
%HORZCAT Horizontal concatenation of quantized filter objects.

%   Author(s): Chris Portal
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:30:43 $

if nargin==1,
   % Catch [obj] case.
   output = varargin{1};
else
   error('Concatenation of quantized filter objects is not supported.')
end
