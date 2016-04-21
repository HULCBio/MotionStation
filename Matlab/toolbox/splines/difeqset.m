echo off
%DIFEQSET Used in difeqdem.

%   Copyright 1987-2002 C. de Boor and The MathWorks, Inc.
%   latest change: December 25, 1989
%   cb : 9 may '95 (use .' instead of ')
%   cb : 20feb00 (adapt to new newknt)
%   $Revision: 1.14 $

   % We get a refined break sequence from current  z  via  newknt
   breaks = knt2brk(newknt(z,ninterv+1));
   knots = augknt(breaks,4,2);
   n = length(knots)-k;

   % ... and generate the corresponding set of collocation points.
   ninterv = length(breaks)-1;
   temp = (breaks(2:ninterv+1)+breaks(1:ninterv))/2;
   temp = temp([1 1],:) + gauss*diff(breaks);
   colpnts = temp(:).';
   points = [0,colpnts,1];

   % We use  spcol  to supply the matrix
   colmat = spcol(knots,k,sort([points points points]));

   % ... and use our current approximate solution  z  as the initial guess:
   intmat = colmat([2 1+[1:(n-2)]*3,1+(n-1)*3],:);
   y = spmak(knots,[0 fnval(z,colpnts) 0]/intmat.');

echo on
