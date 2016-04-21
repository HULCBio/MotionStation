function y = conv2(varargin)
%CONV2 Overloaded function for UINT8 input.

%   $Revision: 1.8.4.3 $  $Date: 2004/03/02 21:46:40 $
%   Copyright 1984-2004 The MathWorks, Inc. 

warnIssued = false;
for k = 1:length(varargin)
  if (isa(varargin{k},'uint8'))
    if ~warnIssued && (k == 1 || k == 2)
      warning('MATLAB:conv2:uint8Obsolete', ...
        ['CONV2 on values of class UINT8 is obsolete.\n' ...
        '         Use CONV2(DOUBLE(A),DOUBLE(B)) or CONV2(SINGLE(A),SINGLE(B)) instead.']);
      warnIssued = true;
    end
    varargin{k} = double(varargin{k});
  end
end

y = conv2(varargin{:});

