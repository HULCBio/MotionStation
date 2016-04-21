function [layout] = autoline(blkname, fm_port, to_port, blklocs, orienta)
%AUTOLINE lays out lines "nicely" between two Simulink blocks.
%   AUTOLINE(BLKNAME, FM_PORT, TO_PORT) connects port FM_PORT to port 
%   TO_PORT in Simulink BLKNAME. FM_PORT has the format of blockname/port#. 
%   TO_PORT has the format of blockname/port#.
%   AUTOLINE(BLKNAME, FM_PORT, TO_PORT, BLKLOCS) connects port FM_PORT 
%   to port TO_PORT in Simulink BLKNAME with avoidance of the connection 
%   line across the blocks indicated in BLKLOC. BLKLOCS is a nx4 matrix
%   with every row of the matrix indicate the location of a block's 
%   up-left x-y and bottom-right x-y. 
%   AUTOLINE(BLKNAME, FM_PORT, TO_PORT, BLKLOCS, ORIENTA) connects
%   FM_PORT and TO_PORT with their orietation indicated in ORIENTA,
%   where the first element indicates the orietation of FM_PORT and 
%   the second element indicates the orientation of TO_PORT. orientation
%   is represented by 0,1,2,3, which indicate left-to-right, 
%   bottom-to-top, right-to-left, and top-to-bottom.
%   [LAYOUT] = AUTOLINE(...) outputs the suggested line layout vector with
%   every row of LAYOUT to be the x-y position.

%   Wes Wang 10-28-92
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.16 $

%disp(['From Port ' fm_port]);
%disp(['To Port   ' to_port]);
% assign default
if nargin < 3, error('not enough input arguments.'); end;
if nargin < 4,  blklocs = []; end;    %default don't care cross blocks
if nargin < 5,  orienta = [0 0]; end; %default left to right position

if isempty(blklocs) 
   blklocs=[0,0,0,0]; 
end;

%fprintf(blkname);fprintf(': ');fprintf(fm_port);fprintf('       ');fprintf(to_port);fprintf('\n');
% re-arrange parameters.
tmp = find(fm_port == '/');
tmp=max(tmp);
fm_block = [blkname '/' fm_port(1:tmp-1)];
fm_n = str2num(fm_port(tmp+1:length(fm_port)));
tmp = find(to_port == '/');
tmp=max(tmp);
to_block = [blkname '/' to_port(1:tmp-1)];
to_n = str2num(to_port(tmp+1:length(to_port)));
ons = ones(2,1);

% get all of positions
kkk = 0;
tmp = get_param(fm_block, 'outport');
while isempty(tmp) & (kkk <10)
   fm_block = [fm_block ' '];
   kkk = kkk+1;
   tmp = get_param(fm_block, 'outport');
end;
[noo,tmp1] = size(tmp);
layout = tmp(fm_n,:);
kkk = 0;
tmp = get_param(to_block, 'inport');
while isempty(tmp) & (kkk < 10)
   to_block = [to_block ' '];
   kkk = kkk+1;
   tmp = get_param(to_block, 'inport');
end;
[noi,tmp1] = size(tmp);
tmp = tmp(to_n,:);
layout=[layout; tmp];
%%%%%%%%%%%%%
%disp(fm_n);disp(layout);disp(to_n);disp(tmp);
fm_posit = get_param(fm_block, 'position');
to_posit = get_param(to_block, 'position');

% make all of the block as []>-------> position
% where the inport is at (0,0)
% match fm_posit, to_posit, layout, tmp, and blkname to the same
% and at the very end, make layout back.
x0 = layout(1,1);
y0 = layout(1,2);
z0 = orienta(1);

%for all of orientation:
layout(:,1) = layout(:,1) - x0;
layout(:,2) = layout(:,2) - y0;
blklocs(:,[1,3]) = blklocs(:,[1,3]) - x0;
blklocs(:,[2,4]) = blklocs(:,[2,4]) - y0;

fm_posit([1,3]) = fm_posit([1,3]) - x0;
fm_posit([2,4]) = fm_posit([2,4]) - y0;
to_posit([1,3]) = to_posit([1,3]) - x0;
to_posit([2,4]) = to_posit([2,4]) - y0;

if (z0==1) | (z0==3)
   %switch x and y
   layout = fliplr(layout);
   layout(:,1) = -layout(:,1);
   blklocs(:,1:2) = fliplr(blklocs(:,1:2));
   blklocs(:,3:4) = fliplr(blklocs(:,3:4));
   blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
   fm_posit(1:2) = fliplr(fm_posit(1:2));   
   fm_posit(3:4) = fliplr(fm_posit(3:4));   
   fm_posit([1,3]) = fliplr(-fm_posit([1,3]));
   to_posit(1:2) = fliplr(to_posit(1:2));   
   to_posit(3:4) = fliplr(to_posit(3:4));   
   to_posit([1,3]) = fliplr(-to_posit([1,3]));
end;

if (z0==2) | (z0==1)
   %reverse direction
   layout(:,1) = - layout(:,1);
   layout(:,2) = -layout(:,2);
   blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
   blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
   fm_posit([1,3]) = fliplr(-fm_posit([1,3]));
   fm_posit([2,4]) = fliplr(-fm_posit([2,4]));
   to_posit([1,3]) = fliplr(-to_posit([1,3]));
   to_posit([2,4]) = fliplr(-to_posit([2,4]));
end;

tmp = layout(2,:);

orienta(2) = rem(4+ orienta(2) - orienta(1), 4);
orienta(1) = 0;

% find the "best rout" regardless across block & line
if orienta(2) == 0
  if (layout(1,1)+5>=tmp(1)) & ~((abs(layout(1,1)-tmp(1))<20) & (abs(layout(1,2)-tmp(2))<20))
      % get around position
      %rout       []>-|
      %               |
      %   |-----------|
      %   |
      %   |->[]
      tmp1=max(fm_posit(4)+4*rem(fm_n-1,noo),to_posit(4)+4*rem(to_n-1,noo))+15;
      tmp2=min(fm_posit(2)-4*rem(fm_n-1,noo),to_posit(2)-4*rem(to_n-1,noo))-10;
      if fm_posit(4) < to_posit(2)  
        %below fm_block above to_block
        alpha = 2/3 - (noo-fm_n)/noo/3;
        layout(3:4,2) = ceil(to_posit(2)*(1-alpha) + fm_posit(4)*alpha) *ons;
        pos = [-1 1];
      elseif fm_posit(2) > to_posit(4)
        alpha = 1/3 + (fm_n-1)/noo/3;
        %below to_block above fm_block
        layout(3:4,2) = (fm_posit(2) *(1- alpha) + to_posit(4)*alpha) *ons;
        pos = [1 -1];
      else
        if (fm_n * to_n ) >= ((noo - fm_n + 1 ) * (noi - to_n + 1))
        %if max(tmp1-layout(1,2),tmp1-tmp(2))<max(layout(1,2)-tmp2,tmp(2)-tmp2) 
          % below both blocks
          layout(3:4,2) = tmp1 *ons;
          pos = [-1 -1];
        else
          % above both blocks
          layout(3:4,2) = tmp2 *ons;
          pos = [1 1];
        end;
      end;
      layout(2,2)   = layout(1,2);
      layout(5,2)   = tmp(2);
      layout(6,:)   = tmp;
      if ((layout(3,2)>layout(2,2))&(z0<2))|((layout(3,2)<layout(2,2))&(z0>=2))
        %going down
        layout(2:3,1) = (layout(1,1) + 7 + 4 * abs(rem(noo-fm_n,noo))) * ons;
      else
        %going up
        layout(2:3,1) = (layout(1,1) + 5 + 4 * rem(fm_n-1,noo)) * ons;
      end;
      if ((layout(4,2)>layout(5,2))&(z0<2))|((layout(4,2)<layout(5,2))&(z0>=2))
        %if layout(4,2) > layout(5,2) % the old one
        %going up
        layout(4:5,1) = (tmp(1) - 7 - 4 * abs(rem(noi - to_n, noi)))*ons;
      else
        %going down
        layout(4:5,1) = (tmp(1) - 5 - 4 * rem(to_n - 1, noi))*ons;
      end;
  else %straight position
      ons = [1;1];
      %rout  []>---|
      %            |
      %            |--------->[]
      layout(2,:)   = tmp;
      if layout(2,2) ~= layout(1,2)
         layout(2,2)   = layout(1,2);
         layout(3,2)   = tmp(2);
         layout(4,:)   = tmp;
         if ((layout(3,2)>layout(2,2))&(z0<2))|((layout(3,2)<layout(2,2))&(z0>=2))
            %going down
             alpha = 2/3 - (noo-fm_n)/noo/3;
         else
            %going up
             alpha = 1/3 + (fm_n-1)/noo/3;
         end;
         layout(2:3,1) = ceil(layout(1,1)*(1-alpha) + tmp(1)*alpha) * ons;
      end;
%      [tmp1,tmp2,tmp3,tmp4,tmp5] = linemima(layout(1:2,:),blklocs);
%      if ~isempty(tmp5)
%         alpha = 1/3 + (fm_n-1)/noo/3;
%         layout(2:3,1) = ceil(layout(1,1)*alpha + tmp1*(1-alpha)) * ons;
%      end;
  end;
  layout = lineext(layout, blklocs, [0, fm_n, noo], [0, to_n, noi]);
elseif orienta(2) == 1
  if (layout(1,1) < tmp(1,1)) & (layout(1,2) <= (tmp(1,2)-10))
     %rout     []--|   
     %             |   
     %             v   
     %            [ ]  
     %          (1)    
     layout(2,1) = tmp(1,1);
     layout(2,2) = layout(1,2);
     layout(3,:) = tmp(1,:);
  elseif  (layout(1,1) < tmp(1,1)) & (layout(1,2) > (tmp(1,2) - 10))
     %rout         |--|
     %             |  v 
     %             | [ ]
     %         []---
     %          (2)
     layout(2,1) = layout(1,1) + 10 + 4*rem(fm_n - 1, noo);
     layout(3,1) = layout(2,1);
     layout(2,2) = layout(1,2);
     layout(3,2) = tmp(1,2) - 10 - 4*rem(to_n - 1, noi);
     layout(4,2) = layout(3,2);
     layout(4,1) = tmp(1,1);
     layout(5,:) = tmp;
  elseif  layout(1,1) >= tmp(1,1) 
     %rout         []--|     |-----------|
     %          |------|     v           |
     %          v           [ ]          |
     %         [ ]                   []->|
     %           (3)             (4) 
     layout(2,1) = layout(1,1) + 15 + 4*rem(fm_n - 1, noo);
     layout(2,2) = layout(1,2);
     layout(3,1) = layout(2,1);
     layout(5,:) = tmp;
     layout(4,1) = layout(5,1);
     if fm_posit(4) < to_posit(2)
        layout(3,2) = (fm_posit(4) + to_posit(2)) / 2;
     else
        layout(3,2) = min((fm_posit(2) - 10 - 4*rem(fm_n - 1, noo)), (to_posit(2) - 10 - 4*rem(to_n - 1, noi)));
     end;
     layout(4,2) = layout(3,2);
  else
     disp('something wrong')
  end;
  layout = lineext(layout, blklocs, [0, fm_n, noo], [1, to_n, noi]);
elseif orienta(2) == 2
  ons = [1;1];
  %rout    []>-|         []                  |------|   
  %            |         []>---|       []>---|  []  |
  %            |  []<--| []    |                []<-|
  %   []<------|       |-------|                []
  %      (1)            (2)                 (3)
  if (layout(1,2)<to_posit(4))&(layout(1,2)>to_posit(2))
    %have to get around
    if fm_posit(3) > to_posit(3)
      % condition (2)
      if (fm_posit(4)-layout(1,2)) <= (layout(1,2) - fm_posit(2))
        %go from the bottom
        layout(3:4,2) = (fm_posit(4) + 10 + 4 * rem(fm_n-1,noo)) * ons;
      else
        % go from the top
        layout(3:4,2) = (fm_posit(2) - 10 - 4 * rem(fm_n-1,noo)) * ons;
      end;
    else
      % condition 3
      if (to_posit(4) - tmp(2)) <= (tmp(2) - to_posit(2))
        %go from the bottom
        layout(3:4,2) = (to_posit(4) + 10 + 4 * rem(to_n-1,noi)) * ons;
      else
        % go from the top
        layout(3:4,2) = (to_posit(2) - 10 - 4 * rem(to_n-1,noi)) * ons;
      end;
    end;
    layout(2,2)   = layout(1,2);
    layout(5,2)   = tmp(2);
    layout(6,:)   = tmp;
    if ((layout(3,2)>layout(2,2))&(z0<2))|((layout(3,2)<layout(2,2))&(z0>=2))
      % if layout(3,2) > layout(2,2) % the old one
      %going down
      layout(2:3,1) = (layout(1,1) + 10 + 4 * rem(noo-fm_n,noo)) * ons;
    else
      %going up
      layout(2:3,1) = (layout(1,1) + 10 + 4 * rem(fm_n-1,noo)) * ons;
    end;
    if ((layout(4,2)>layout(5,2))&(z0<2))|((layout(4,2)<layout(5,2))&(z0>=2))
      % if layout(4,2) > layout(5,2)
      %going up
      layout(4:5,1) = (tmp(1) + 10 + 4 * abs(rem(noi - to_n, noi)))*ons;
    else
      %going down
      layout(4:5,1) = (tmp(1) + 10 + 4 * rem(to_n - 1, noi))*ons;
    end;
  else
    layout(2,2)   = layout(1,2);
    layout(3,2)   = tmp(2);
    layout(4,:)   = tmp;
    if ((layout(3,2)>layout(2,2))&(z0<2))|((layout(3,2)<layout(2,2))&(z0>=2))
      % if layout(3,2) > layout(2,2)
      %going down
      tmp1 = layout(1,1)+rem(noo-fm_n,noo) * 4; %start point
      tmp2 = tmp(1)+rem(to_n-1,noi) * 4+7;     %end point
      layout(2:3,1)= ons * (max(tmp1, tmp2));
    else
      %going up
      tmp1 = layout(1,1)+rem(fm_n - 1, noo) * 4 + 10;
      tmp2 = tmp(1) + rem(noi-to_n,noi) * 4 + 10;
      layout(2:3,1) = ons * max(tmp1,tmp2);
    end;     %if ((layout(3,2)...))
  end;       %if (layout(1,2)...)
  layout = lineext(layout, blklocs, [0, fm_n, noo], [2, to_n, noi]);
elseif orienta(2) == 3
  if (layout(1,1) < tmp(1,1)) & (layout(1,2) >= (tmp(1,2)+10))
     %rout        [ ]
     %             ^   
     %             |   
     %     []------|
     %          (1)    
     layout(2,1) = tmp(1,1);
     layout(2,2) = layout(1,2);
     layout(3,:) = tmp(1,:);
  elseif  (layout(1,1) < tmp(1,1)) & (layout(1,2) < (tmp(1,2)+10))
     %rout   []--|
     %           |   [ ]
     %           |    ^
     %           |----|
     %          (2)
     layout(2,1) = layout(1,1) + 10 + 4*rem(fm_n - 1, noo);
     layout(3,1) = layout(2,1);
     layout(2,2) = layout(1,2);
     layout(3,2) = tmp(1,2) + 10 + 4*rem(to_n - 1, noi);
     layout(4,2) = layout(3,2);
     layout(4,1) = tmp(1,1);
     layout(5,:) = tmp;
  elseif  layout(1,1) >= tmp(1,1) 
     %rout     [ ]                   []--|  
     %          ^              [ ]       |
     %          |------|        ^        |
     %              []-|        |--------|
     %           (3)             (4) 
     layout(2,1) = layout(1,1) + 15 + 4*rem(fm_n - 1, noo);
     layout(2,2) = layout(1,2);
     layout(3,1) = layout(2,1);
     layout(5,:) = tmp;
     layout(4,1) = layout(5,1);
     if fm_posit(2) > to_posit(4)
        layout(3,2) = (fm_posit(2) + to_posit(4)) / 2;
     else
        layout(3,2) = max((fm_posit(4) + 15 + 4*rem(fm_n - 1, noo)), (to_posit(4) + 15 + 4*rem(to_n - 1, noi)));
     end;
     layout(4,2) = layout(3,2);
  else
     disp('something wrong in case 3')
  end;
  layout = lineext(layout, blklocs, [0, fm_n, noo], [3, to_n, noi]);
end;  

%check if we have the right result
[tmp(1) tmp(2)]=size(layout);
if tmp(1) <= 1
  disp(orienta);
  error('is a wrong orientation information. AUTOLINE does not support it');
end;

if (z0 == 2) | (z0 == 1)
    layout  = -layout;
end;

if (z0 == 1) | (z0 == 3)
    %swirch x and y
%    layout(:,2) = - layout(:,2);
    layout(:,1) = - layout(:,1);
    layout = fliplr(layout);
end;


layout(:,1) = layout(:,1) + x0;
layout(:,2) = layout(:,2) + y0;

tmp = find(layout<=0);
layout(tmp) = layout(tmp) - layout(tmp) + 5;
%add the line
add_line(blkname,layout);
%for i=1:length(layout)
%  llayout=[llayout layout(i,:)];
%end;
if nargout <= 0
  return;
end;
