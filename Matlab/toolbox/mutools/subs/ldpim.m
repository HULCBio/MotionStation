% function pimout = ldpim(pim,ld)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function pimout = ldpim(pim,ld)

	if nargin ~= 2
		disp('usage: pim = ldpim(pim,ld)');
		return
	end
	largenum = 123456;	% need inf, but not INF

	[mtype,mrows,mcols,mnum] = minfo(pim);
	[nr,nc] = size(ld);

	if strcmp(mtype,'pckd') & nr==1 & nc==1
		if floor(ld)==ceil(ld) & ld>0 & ld<largenum
			pimout = pim;
			pimout(1) = ld;
		else
			error('Leading dimension must be Positive integer');
			return
		end
	else
		error('Incorrect input arguments');
		return
	end