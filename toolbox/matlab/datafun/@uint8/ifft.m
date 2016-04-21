function y = ifft(varargin)
%IFFT Overloaded function for UINT8 input.

%   $Revision: 1.9.4.3 $  $Date: 2004/03/02 21:46:43 $
%   Copyright 1984-2004 The MathWorks, Inc. 

for k = 1:length(varargin)
  if (isa(varargin{k},'uint8'))
    if (k == 1)
      warning('MATLAB:ifft:uint8Obsolete', ...
        ['IFFT on values of class UINT8 is obsolete.\n' ...
        '         Use IFFT(DOUBLE(X)) or IFFT(SINGLE(X)) instead.']);
    end
    varargin{k} = double(varargin{k});
  end
end

y = ifft(varargin{:});

