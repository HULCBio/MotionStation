% function sys = nd2sys(num,den,gain)
%
%   ND2SYS converts a numerator/denominator single-input/
%   single-output transfer function into a SYSTEM matrix.
%   GAIN is an optional argument that scales the output SYS.
%
%   See also:  PCK, PSS2SYS, SYS2PSS, TF2SS, UNPCK, SYSIC, and ZP2SYS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sys = nd2sys(num,den,gain)
  if nargin < 2
    disp('usage: sys = nd2sys(num,den,gain)');
    return
  end
  if length(num) > length(den)
    error('numerator order is larger than denominator order');
    return
  else
    cmdcall = '[a,b,c,d]=nd2ssms(num,den);';
    spt = exist('tf2ss');
%   use Control Toolbox if available
    if spt ==2 | spt ==3 | spt ==4 | spt == 5
      cmdcall = '[a,b,c,d]=tf2ss(num,den);';
    end
    eval(cmdcall);
    if nargin == 2
      sys = pck(a,b,c,d);
    else
      sys = pck(a,b,c,d);
      sys = mscl(sys,gain);
    end
  end
  if length(den)>1
	rd = roots(den);
	if max(real(rd))<-10*(length(den)+1)*eps
		sys = sysbal(sys);
	else
		[mtype,mrows,mcols,mnum] = minfo(sys);
		ssmat = sys2pss(sys);
		blk = [ones(mnum,2);mcols mrows];
		[bb,dd] = mu(ssmat,blk,'sUw');
		[dl,dr] = unwrapd(dd,blk);
		sys = pss2sys(dl*ssmat/dr,mnum);
	end
  end