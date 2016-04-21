% Measurement Map
% Control Map
% BLK Scale Factor

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [fixcl,fixcr,fixclpl,fixclpr,swolic,thismeas,thiscont] = ...
        yublksel(blk,olic,blkfac,nmeas,usey,ncntrl,useu);

blk = abs(blk);
if nargin == 2
  blkfac = olic;
  blkdims = blk;
  repscal = find(blkdims(:,2)==0);
  if ~isempty(repscal)
    blkdims(repscal,2) = blkdims(repscal,1);
  end
  blksize = sum(blkdims);
  blkpt = cumsum([1 1;blkdims]);

  rpert = [];
  rmat = [];
  cpert = [];
  cmat = [];
  useblk = find(abs(blkfac)>0);
  if ~isempty(useblk)
    for i=1:length(useblk)
     rpert = [rpert blkpt(useblk(i),1):blkpt(useblk(i)+1,1)-1];
     rmat = [rmat sqrt(abs(blkfac(useblk(i))))*ones(1,blkdims(useblk(i),1))];
     cpert = [cpert blkpt(useblk(i),2):blkpt(useblk(i)+1,2)-1];
     cmat = [cmat sqrt(abs(blkfac(useblk(i))))*ones(1,blkdims(useblk(i),2))];
    end
    newblk = blk(useblk,:);
  else
    error('Problem within YUBLKSEL')
    return
  end
  fixclpl = cmat;
  fixclpr = rmat;
  fixcl = fixclpl;
  fixcr = fixclpr;

else
  useu = useu(:)';
  usey = usey(:)';

  blkdims = blk;
  repscal = find(blkdims(:,2)==0);
  if ~isempty(repscal)
    blkdims(repscal,2) = blkdims(repscal,1);
  end
  blksize = sum(blkdims);
  blkpt = cumsum([1 1;blkdims]);

  rpert = [];
  rmat = [];
  cpert = [];
  cmat = [];
  useblk = find(abs(blkfac)>0);
  if ~isempty(useblk)
    for i=1:length(useblk)
     rpert = [rpert blkpt(useblk(i),1):blkpt(useblk(i)+1,1)-1];
     rmat = [rmat sqrt(abs(blkfac(useblk(i))))*ones(1,blkdims(useblk(i),1))];
     cpert = [cpert blkpt(useblk(i),2):blkpt(useblk(i)+1,2)-1];
     cmat = [cmat sqrt(abs(blkfac(useblk(i))))*ones(1,blkdims(useblk(i),2))];
    end
    newblk = blk(useblk,:);
  else
    error('You have no Problem')
  end

  usey = sort(floor(abs(usey)));
  loc = find(diff([0 usey])>0);
  refy = usey(loc);
  usey = usey(loc) + blksize(2);
  thismeas = length(usey);

  useu = sort(floor(abs(useu)));
  loc = find(diff([0 useu])>0);
  refu = useu(loc);
  useu = useu(loc) + blksize(1);
  thiscont = length(useu);

  useout = [cpert usey];
  usein = [rpert useu];

  fixclpl = cmat;
  fixclpr = rmat;

  wolic = sel(olic,useout,usein);
  rmat = [rmat ones(1,thiscont)];
  cmat = [cmat ones(1,thismeas)];
  swolic = mmult(diag(cmat),wolic,diag(rmat));

  fixcl = eye(ncntrl);
  fixcl = fixcl(:,refu);
  fixcr = eye(nmeas);
  fixcr = fixcr(refy,:);
end