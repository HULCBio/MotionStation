% function matout = tackon(mat1,mat2)
%
%   Concatenates two VARYING matrices, which must be
%   of the same row and column dimension.
%
%   See also: GETIV, SORT, and SORTIV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function matout = tackon(mat1,mat2)
 if nargin ~= 2
   disp(['usage: matout = tackon(mat1,mat2)']);
   return
 end
 [typeone,rowone,colone,numone] = minfo(mat1);
 [typetwo,rowtwo,coltwo,numtwo] = minfo(mat2);
 if typeone ~= 'vary' | typetwo ~= 'vary'
   disp('TACKON is only valid with two VARYING matrices')
   return
 end
 if rowone ~= rowtwo | colone ~= coltwo
   error('matrices must be the same dimensions')
   return
 end
 indv = [mat1(1:numone,colone+1);mat2(1:numtwo,coltwo+1)];
 data = [mat1(1:numone*rowone,1:colone);mat2(1:numtwo*rowtwo,1:coltwo)];
 [nrd,ncd] = size(data);
 matout = vpck(data,indv);
%
%