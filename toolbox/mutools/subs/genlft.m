% function [out] = genlft(top,bot,topfeedout,botfeedout)
%   forms Redheffer star-product of two CONSTANT matrices.
%   main subroutine for STARP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out] = genlft(top,bot,dim1,dim2)
   if nargin ~= 4
     disp('usage: [out] = genlft(top,bot,topfeedout,botfeedout)')
     return
   end
   [nrtop,nctop] = size(top);
   [nrbot,ncbot] = size(bot);
   dimout1 = nrtop - dim1;
   dimin1 = nctop - dim2;
   dimout2 = nrbot - dim2;
   dimin2 = ncbot - dim1;
   top11 = top(1:dimout1,1:dimin1);
   top12 = top(1:dimout1,dimin1+1:nctop);
   top21 = top(dimout1+1:nrtop,1:dimin1);
   top22 = top(dimout1+1:nrtop,dimin1+1:nctop);
   bot11 = bot(1:dim2,1:dim1);
   bot12 = bot(1:dim2,dim1+1:ncbot);
   bot21 = bot(dim2+1:nrbot,1:dim1);
   bot22 = bot(dim2+1:nrbot,dim1+1:ncbot);
   tb = top22 * bot11;
   [nrtb nctb] = size(tb);
   imtb = eye(nrtb) - tb;
%  should check the invertibility of imtb at this point, but
%  we have had trouble with COND on large, sparse matrices
   bt = bot11*top22;
   [nrbt,ncbt] = size(bt);
   imbt = eye(nrbt) - bt;
   x = imbt\bot12;
   y = imtb\top21;
   upper = [ (top11 + top12 * bot11 * y) top12*x ];
   lower = [ bot21*y (bot22 + bot21 * top22 * x) ];
   out = [upper ; lower];
%
%