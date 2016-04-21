function y = conv2(varargin)
%CONV2 Overloaded function for UINT16 input.

%   $Revision: 1.1.6.2 $  $Date: 2004/03/02 21:46:35 $
%   Copyright 1984-2004 The MathWorks, Inc. 

warnIssued = false;
for k = 1:length(varargin)
  if (isa(varargin{k},'uint16'))
    if ~warnIssued && (k == 1 || k == 2)
      warning('MATLAB:conv2:uint16Obsolete', ...
        ['CONV2 on values of class UINT16 is obsolete.\n' ...
        '         Use CONV2(DOUBLE(A),DOUBLE(B)) or CONV2(SINGLE(A),SINGLE(B)) instead.']);
      warnIssued = true;
    end
    varargin{k} = double(varargin{k});
  end
end

y = conv2(varargin{:});

