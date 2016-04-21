%function pert = randel(blk,nrm,opt)
%
%  Generates a random, block structured perturbation
%  with specified norm (i.e. max singular value). The
%  block structure is specified by the argument BLK,
%  and the norm is specified by the argument NRM.
%
%  The complex blocks have norm = NRM, and the real
%  blocks have norm specified as: (default is 'i')
%
%  If opt = 'i' the real blocks have norm <=  NRM
%  If opt = 'b' the real blocks have norm  =  NRM
%
%  See also: CRAND, DYPERT, and SYSRAND.

%       Authors:  Matthew P. Newlin and Peter M. Young
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $


function  pert = randel(blk,nrm,opt)
if nargin < 2
	disp('   usage:  pert = randel(blk,nrm,opt)')
	return
end

if length(blk)==0
        error('   BLK is empty')
end
if length(blk(1,:))~=2 | any(abs(round(real(blk))-blk) > 1e-6)
        error('   BLK is invalid')
elseif any(round(real(blk(:,1)))) == 0 | any(abs(blk)==NaN)
        error('   BLK is invalid')
else
        blk = round(real(blk));
end
for ii=1:length(blk(:,1))
        if all( blk(ii,:) == [ 1 0] )
        	blk(ii,:)  = [ 1 1] ;
	end
        if all( blk(ii,:) == [-1 1] )
        	blk(ii,:)  = [-1 0] ;
	end
        if all( blk(ii,:) == [-1 -1] )
        	blk(ii,:)  = [-1 0] ;
	end
end
if any(blk(:,2)<0)
	error('   BLK is invalid');
end
if any(blk(:,2)~=0&blk(:,1)<0),
	error('   Real FULL blocks not allowed');
end
if any(abs(blk)>500)
        error('   No blocks larger than 500, please')
end

[nsiz1,nsiz2] = size(nrm);
if nsiz1~=1 | nsiz2~=1
	error('   NRM is not a scalar')
elseif abs(nrm)==inf | abs(nrm)==NaN
	error('   NRM is inf or NaN')
elseif abs(abs(nrm)-nrm) > (1e-6)*abs(nrm)
	error('   NRM is not a nonnegative real number')
else
	nrm = abs(nrm);
end

if nargin < 3
	opt = 'i';
end

[nblk,dum] = size(blk);
blk1 = blk;
blk = abs(blk);
for i=1:nblk
	if blk(i,2) == 0 & blk(i,1) == 1
		blk(i,2) = 1;
	end
end

blkp = ptrs(blk);
pert = zeros(blkp(nblk+1,1)-1,blkp(nblk+1,2)-1);
for i=1:nblk
	if blk1(i,2) == 0;
		if blk1(i,1) < 0
			delta = 5*rand(1);
			if abs(delta) > 1
				delta = delta/abs(delta);
			end % if abs
			if any(opt=='b')
				if delta >= 0
					delta = 1;
				else
					delta = -1;
				end
			end % if any
			delta = nrm*delta;
			deltab = delta*eye(blk(i,1));
		else
			delta = crand(1);
			if abs(delta) > 1e-50
				delta = nrm*delta/abs(delta);
			else
				delta = nrm;
			end % if abs
			deltab = delta*eye(blk(i,1));
		end % if blk1
	else
		delta = crand(blk(i,1),blk(i,2));
		normdiv = norm(delta);
		if normdiv > 1e-50
			deltab = nrm*delta/normdiv;
		else
			scalfac =  sqrt(blk(i,1)*blk(i,2));
			deltab = nrm*ones(blk(i,1),blk(i,2))/scalfac;
		end % if norm
	end % if blk1
	pert(blkp(i,1):blkp(i+1,1)-1,blkp(i,2):blkp(i+1,2)-1) = deltab;
end % for

if all(blk1(:,1)<0)
	if max(abs(diag(pert))) > 1e-50
		pert = nrm*pert/max(abs(diag(pert)));
	else
		pert = nrm*eye(length(pert));
	end % if max
end