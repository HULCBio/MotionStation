function y = ifftn(varargin)
%IFFTN Overloaded function for UINT16 input.

%   $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:39 $
%   Copyright 1984-2004 The MathWorks, Inc. 

for k = 1:length(varargin)
  if (isa(varargin{k},'uint16'))
    if (k == 1)
      warning('MATLAB:ifftn:uint16Obsolete', ...
        ['IFFTN on values of class UINT16 is obsolete.\n' ...
        '         Use IFFTN(DOUBLE(X)) or IFFTN(SINGLE(X)) instead.']);
    end
    varargin{k} = double(varargin{k});
  end
end

y = ifftn(varargin{:});

