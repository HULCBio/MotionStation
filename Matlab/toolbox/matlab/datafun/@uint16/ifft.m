function y = ifft(varargin)
%IFFT Overloaded function for UINT16 input.

%   $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:38 $
%   Copyright 1984-2004 The MathWorks, Inc. 

for k = 1:length(varargin)
  if (isa(varargin{k},'uint16'))
    if (k == 1)
      warning('MATLAB:ifft:uint16Obsolete', ...
        ['IFFT on values of class UINT16 is obsolete.\n' ...
        '         Use IFFT(DOUBLE(X)) or IFFT(SINGLE(X)) instead.']);
    end
    varargin{k} = double(varargin{k});
  end
end

y = ifft(varargin{:});

