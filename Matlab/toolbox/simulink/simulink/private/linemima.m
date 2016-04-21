function [x_min,x_max,y_min,y_max,to_do,n_be,n_en]=linemima(layout, blklocs)
%LINEMIMA finds the minimum and maximum of the first cross.
%   LINEMIMA is a utility function, called by LINEEXT.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.14 $

[n_l, m_l] = size(layout);

block_n = [];
to_do = [];
for i = n_l-1 : -1 : 1
  [tmpx,tmpy] = blkxchk(layout(i:i+1,:),blklocs);
  if ~isempty(tmpx)
    to_do = [i to_do];
    cros_inf = tmpx;
    block_n  = tmpy;
  end; %if ~isempty
end; %for i=n_be : n_en-1
n_be = min(to_do);
n_en = max(to_do);

%cros_inf & block_n keeps the cross information of layout(n_be:n_be+1,:)

if isempty(block_n)
   x_min = max(blklocs(:,3));
   x_max = min(blklocs(:,1));
   y_min = max(blklocs(:,4));
   y_max = min(blklocs(:,2));
else
   x_min = min(find(blklocs(block_n, 1) == min(blklocs(block_n, 1))));
   x_max = max(find(blklocs(block_n, 3) == max(blklocs(block_n, 3))));
   y_min = min(find(blklocs(block_n, 2) == min(blklocs(block_n, 2))));
   y_max = max(find(blklocs(block_n, 4) == max(blklocs(block_n, 4))));
   x_min = blklocs(block_n(x_min),1);
   x_max = blklocs(block_n(x_max),3);
   y_min = blklocs(block_n(y_min),2);
   y_max = blklocs(block_n(y_max),4);
end;

%end of linemima
