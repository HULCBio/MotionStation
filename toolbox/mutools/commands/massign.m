% function out = massign(matin,rowindex,colindex,data)
%
%	out = massign(matin,rowindex,colindex,data)
%
%	Performs a matrix assignment like operation on VARYING
%	and SYSTEM matrices.  It is functionally equivalent
%	to:
%		matin(rowindex,colindex) = data,
%
%	where rowindex and colindex are vectors specifying the
%	rows and columns (or outputs and inputs if matin is
%	a SYSTEM) to be changed.
%
%	data must either be a constant or of the same type
%	as matin.  The dimension of data must be consistent
%	with the length of rowindex and colindex.
%
%	Warning:  when applied to a SYSTEM, the result will
%	almost always be non-minimal.
%
%	See also:  SEL
%
%-------------------------------------------------------------

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = massign(matin,rowindex,colindex,data)


if nargin ~= 4,
    disp('Usage: out = massign(matin,rowindex,colindex,data)')
    return
    end

[rtype,nrr,ncr,ntpr] = minfo(rowindex);
[ctype,nrc,ncc,ntpc] = minfo(colindex);
if rtype ~= 'cons' | ctype ~= 'cons',
  error('row/column indexes must be vectors')
  return
  end
rowindex = rowindex(:)';
colindex = colindex(:)';

[datatype,nrdata,ncdata,npts] = minfo(data);
if nrdata ~= length(rowindex),
  error('row dimension of data inconsistent with rowindex')
  return
elseif ncdata ~= length(colindex),
  error('column dimension of data inconsistent with colindex')
  return
  end

[mattype,nrmat,ncmat,nptsmat] = minfo(matin);
[nr,nc] = size(matin);

%	create the complementary indices with a very obscure
%	piece of code.

l = length(rowindex);
notr = find(~any((diag([rowindex,zeros(1,nrmat-l)])*ones(nrmat)- ...
		ones(nrmat,nrmat)*diag(1:nrmat))==0));
l = length(colindex);
notc = find(~any((diag([colindex,zeros(1,ncmat-l)])*ones(ncmat)- ...
		ones(ncmat,ncmat)*diag(1:ncmat))==0));

if mattype == 'cons',
  if datatype ~= 'cons',
    error('data must be CONSTANT')
    return
    end
  out = matin;
  out(rowindex,colindex) = data;
elseif mattype == 'syst',
  if datatype ~= 'syst' & datatype ~= 'cons',
    error('data must be SYSTEM or CONSTANT')
    return
    end
  M1 = sel(matin,notr,[notc,colindex]);
  M21 = sel(matin,rowindex,notc);
  out = abv(M1,sbs(M21,data));
  [r,rreord] = sort([notr,rowindex]);
  [c,creord] = sort([notc,colindex]);
  out = sel(out,rreord,creord);
elseif mattype == 'vary',
  if datatype ~= 'vary' & datatype ~= 'cons',
    error('data must be VARYING or CONSTANT')
    return
    end
  M1 = sel(matin,notr,[notc,colindex]);
  M21 = sel(matin,rowindex,notc);
  out = abv(M1,sbs(M21,data));
  [r,rreord] = sort([notr,rowindex]);
  [c,creord] = sort([notc,colindex]);
  out = sel(out,rreord,creord);
else
  out = [];
  end

return