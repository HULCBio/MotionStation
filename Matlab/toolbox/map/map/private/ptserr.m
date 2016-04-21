function [xi,yi] = ptserr(xi,yi,xa,ya,err)
% PTSERR removes floating point errors of xi and yi by setting them to
% x1 y1 values

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $ $Date: 2003/08/01 18:19:38 $

ni = length(xi);  na = length(xa);
Xi = reshape(reshape(repmat(xi,na,1),ni,na)',ni*na,1);
Yi = reshape(reshape(repmat(yi,na,1),ni,na)',ni*na,1);
Xa = repmat(xa,ni,1);
Ya = repmat(ya,ni,1);
ix = find( (abs(Xi-Xa)>0 & abs(Xi-Xa)<=err) );
iy = find( (abs(Yi-Ya)>0 & abs(Yi-Ya)<=err) );
xi(ceil(ix/na)) = Xa(ix);
yi(ceil(iy/na)) = Ya(iy);
