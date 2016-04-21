%function rat_pert = dypertsb(pvec,blk,bnds,blks)
%
%  Creates rational, stable perturbation which
%  interpolates the frequency varying perturbation, PVEC,
%  at the peak value of the lower bound in BNDS (frequency
%  where the perturbation is the smallest). PVEC is
%  perturbation vector generated from MU, BLK is the
%  block structure, BNDS is the upper and lower bounds
%  generated from MU, BLKS is the optional numbers of
%  the blocks which are to be included in the rational
%  perturbation output.
%
%   See also: MU, UNWRAPD, UNWRAPP, and SISORAT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function rat_pert = dypertsb(pertrv,blk,bnds,blks)
  if nargin < 3
    disp('usage: sys = dypertsb(row_p,blk,bnds)')
    return
  end
  [nblk,dum] = size(blk);
  if nargin == 3
    blks = 1:nblk;
  end
  [btype,brows,bcols,bnum] = minfo(bnds);
  [ptype,prows,pcols,pnum] = minfo(pertrv);
  code = 0;
  if code == 1
    error('different # of frequency points')
    return
  elseif code == 2
    error('bounds and perturbations need to be frequency varying')
    return
  elseif code == 3
    error('frequency points are different')
    return
  end
%
  [peak,peakloc] = max(bnds(1:bnum,2));
%
  rowp = pertrv(peakloc,1:pcols);
  omegap = pertrv(peakloc,pcols+1);
  sys = [];
  loc = 1;
  for i=1:nblk
    if blk(i,2) == 0 | (blk(i,1)*blk(i,2) == 1)
      if any(blks==i)
        gain = rowp(loc);
        block = [];
        delta = sisorat(omegap,gain);
        for j=1:blk(i,1)
          block = daug(block,delta);
        end
        sys = daug(sys,block);
      end
      loc = loc + 1;
    else
      if blk(i,1) == 1
        if any(blks==i)
          block = [];
          for j=1:blk(i,2)
            block = sbs(block,sisorat(omegap,rowp(loc)));
            loc = loc + 1;
          end
          sys = daug(sys,block);
        else
          loc = loc + blk(i,2);
        end
      else
        if blk(i,2) == 1
          if any(blks==i)
            block = [];
            for j=1:blk(i,1)
              block = abv(block,sisorat(omegap,rowp(loc)));
              loc = loc + 1;
            end
            sys = daug(sys,block);
          else
            loc = loc + blk(i,1);
          end
        else
          if any(blks==i)
            tmp=reshape(rowp(loc:loc-1+(blk(i,1)*blk(i,2))),blk(i,2),blk(i,1));
            [u,s,v]=svd(tmp.');
            col = u(:,1)*sqrt(s(1));
            row = (v(:,1))'*sqrt(s(1));
            rtcol = [];
            rtrow = [];
            for j=1:blk(i,2)
              rtrow = sbs(rtrow,sisorat(omegap,row(j)));
            end
            for j=1:blk(i,1)
              rtcol = abv(rtcol,sisorat(omegap,col(j)));
            end
            block = mmult(rtcol,rtrow);
            sys = daug(sys,block);
          end
          loc = loc + blk(i,1)*blk(i,2);
        end
      end
    end
  end
  rat_pert = sys;
%
%