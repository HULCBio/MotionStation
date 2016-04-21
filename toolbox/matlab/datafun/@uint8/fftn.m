function y = fftn(varargin)
%FFTN Overloaded function for UINT8 input.

%   $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:42 $
%   Copyright 1984-2004 The MathWorks, Inc. 

for k = 1:length(varargin)
  if (isa(varargin{k},'uint8'))
    if (k == 1)
      warning('MATLAB:fftn:uint8Obsolete', ...
        ['FFTN on values of class UINT8 is obsolete.\n' ...
        '         Use FFTN(DOUBLE(X)) or FFTN(SINGLE(X)) instead.']);
    end
    varargin{k} = double(varargin{k});
  end
end

y = fftn(varargin{:});

