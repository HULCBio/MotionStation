% function [dleft,dright] = unwrapd(dvec,blk)
%
%   Unwraps the D scaling matrices in DVEC (from an
%   upper bound MU calculation) into the block diagonal form.
%
%   See also: MU and MUUNWRAP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [dleft,dright] = unwrapd(dvec,blk)
 if nargin ~= 2
   disp(['usage: [dleft,dright] = unwrapd(dvec,blk)'])
   return
 end
 [nblk,dum] = size(blk);
 if dum ~= 2
   error('block data incorrect format')
   return
 end

 [dleft,dright] = muunwrap(dvec,blk);
%
%