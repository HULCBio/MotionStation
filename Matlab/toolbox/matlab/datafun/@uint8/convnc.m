function y = convnc(varargin)
%CONVNC Overloaded function for UINT8 input.

%   $Revision: 1.8 $  $Date: 2002/06/17 13:29:04 $
%   Copyright 1984-2002 The MathWorks, Inc. 

for k = 1:length(varargin)
  if (isa(varargin{k},'uint8'))
    varargin{k} = double(varargin{k});
  end
end

y = convnc(varargin{:});

