% function sys = zp2sys(zeros,poles,gain)
%
%   Similar to the MATLAB ZP2SS command; takes
%   ZEROS, POLES and GAIN data, and converts this into a
%   single-input, single-output SYSTEM matrix.
%
%   See also:  ND2SYS, PCK, PSS2SYS, SYS2PSS, UNPCK, and SYSIC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sys = zp2sys(zeros,poles,gain)
  if nargin < 2
    disp('usage: sys = zp2sys(zeros,poles,gain)');
    return
  end
  if length(zeros) > length(poles)
    error('more zeros than poles');
    return
  else
    [nr,nc] = size(zeros);
    if nr == 1
      zeros = zeros.';
    elseif min([nr nc]) > 1
       error('too many zeros')
       return
    end
    [nr,nc] = size(poles);
    if nr == 1
      poles = poles.';
    elseif min([nr nc]) > 1
       error('too many poles')
       return
    end
    if nargin ~= 3
      [a,b,c,d] = zp2ss(zeros,poles,1);
    else
      [a,b,c,d] = zp2ss(zeros,poles,gain);
    end
    sys = pck(a,b,c,d);
  end
  if max(real(poles))<0
    sys = sysbal(sys);
  end