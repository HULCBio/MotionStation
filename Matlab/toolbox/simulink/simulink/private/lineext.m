function layout = lineext(layout, blklocs, port_fm, port_to)
%LINEEXT adds more "turns" on a existing connections such that there is
%   no cross block on the route of the connection line.
%   LAYOUT = LINEEXT(LAYOUT, BLKLOCS, PORT_FM PORT_TO)
%   extends the original connection LAYOUT to the output LAYOUT
%   such that the connection will avoid to cross blocks indicated
%   in BLKLOCS. Each block location take a row, which is represented
%   by BLKLOCS=[min_x min_y max_x max_y]. PORT_FM and PORT_TO carry 
%   the information of the port orientation, from port number and 
%   total port number in the block.

%   Wes Wang 3/20/93
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

%The basic technique used in this function is to change
%the orientation of each processing segment to have
%direction of 0 or left to right ---> line. Then, use the
%same procedure for all segment check up.
%the direction of a line: 0> 1v 2< 3^

%disp(layout);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%legal input check                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin ~= 4
  error('Usage: LAYOUT=LINEEXT(LAYOUT, BLKLOCS, PORT_FM, PORT_TO)');
end;

[n_l,m_l] = size(layout); %n_l: number of point; m_l==2
if n_l < 2
  disp('There is no line segment available')
  disp('Error in calling linext')
  return;
end;
[n_b, m_b]= size(blklocs); %n_b: number of block; m_b==4
if n_b < 1
  %there is nothing we need to do
  return;
end;
if ((m_l ~= 2) | (m_b ~= 4) | (length(port_fm) ~= 3) | (length(port_to) ~= 3))
  disp('Illegal length of input variable')
end;

%get the cross points
[x_min,x_max,y_min,y_max,to_do,n_be,n_en]=linemima(layout,blklocs);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the iterative loop                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set an iterative flag
flag = zeros(n_l, 1);

while (~isempty(to_do) & n_l < 10)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % quit if there is block overlap                      %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if n_be == 1
      [tmp1, tmp2, tmp3, tmp4, tmp5] = linemima(layout(1:2,:),blklocs);
      if ~isempty(tmp5)
         if (((port_fm(1) == 0) & (tmp1 < layout(1,1)) & (tmp2 > layout(1, 1)))...
            |((port_fm(1) == 1) & (tmp3 < layout(1,2)) & (tmp4 > layout(1, 2)))...
            |((port_fm(1) == 2) & (tmp2 > layout(1,1)) & (tmp1 < layout(1, 1)))...
            |((port_fm(1) == 3) & (tmp4 > layout(1,2)) & (tmp3 < layout(1, 2))))
            disp('Block overlap, there is no way to avoid block crossing'); 
            return;
         end;
      end;
   end;
   if n_en == n_l - 1
      [tmp1, tmp2, tmp3, tmp4, tmp5] = linemima(layout(n_en:n_l,:),blklocs);
      if ~isempty(tmp5)
         if (((port_to(1) == 0) & (tmp1 < layout(n_l,1)) & (tmp2 > layout(n_l, 1)))...
            |((port_to(1) == 1) & (tmp3 < layout(n_l,2)) & (tmp4 > layout(n_l, 2)))...
            |((port_to(1) == 2) & (tmp2 > layout(n_l,1)) & (tmp1 < layout(n_l, 1)))...
            |((port_to(1) == 3) & (tmp4 > layout(n_l,2)) & (tmp3 < layout(n_l, 2))))
            disp('Block overlap, there is no way to avoid block crossing'); 
            return; 
         end;
      end;
   end;

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % logic search for straight condition      %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   straight = 0;
   if (n_be+1 == n_l) & (n_be == 1)
      straight = 1;
   elseif (n_be+1 == n_l) 
      if (max(abs(layout(n_be,:)-layout(n_be+1,:))) > ...
            4 * max(abs(layout(n_be,:)-layout(n_be-1,:))))
         straight = 1;
      end;
   elseif (n_be == 1) & (n_be + 2 >= n_l)
      if (max(abs(layout(n_be, :) - layout(n_be+1, :))) >...
            4 * max(abs(layout(n_be+1, :) - layout(n_be+2, :))))
         straight = 1;
      end;
   end;
   if straight
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % If there is no room for moving the existing line  %
      % around, take a hard turn to avoid the cross       %
      %                             _____                 %
      % in the case of brake to ___|     |_____           %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %make the line direction to be ---> direction 0
      direct = linedir(layout(n_be:n_be+1,:));
      if direct < 0
        %I am not taking care of randon direction now
        return;
      end;
      if (direct==1) | (direct==3)
         %switch x and y
         layout = fliplr(layout);
         layout(:,1) = -layout(:,1);
         blklocs(:,1:2) = fliplr(blklocs(:,1:2));
         blklocs(:,3:4) = fliplr(blklocs(:,3:4));
         blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
      end;

      if (direct==2) | (direct==1)
          %reverse direction
          layout = - layout;
          blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
          blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
      end;

%      if (direct == 2) | (direct == 3)
%        %reverse direction
%        layout(:,1) = 2000 - layout(:,1);
%        blklocs(:,[1 3]) = 2000 - blklocs(:,[1 3]);
%        blklocs(:,[1 3]) = fliplr(blklocs(:,[1 3]));
%      end;
%      if (direct == 1) | (direct == 3)
%        %swirch x and y
%        layout = fliplr(layout);
%        blklocs(:,1:2) = fliplr(blklocs(:,1:2));
%        blklocs(:,3:4) = fliplr(blklocs(:,3:4));
%      end;
      %now everyone has direction 0

      %calculate the minimum and maximum
      [x_min,x_max,y_min,y_max] = linemima(layout(n_be:n_be+1,:),blklocs);

      %make space for the new part
      layout(n_be+5:n_l+4,:) = layout(n_be+1:n_l,:);
      flag(n_be+5:n_l+4) = flag(n_be+1:n_l);
      flag(n_be:n_be+4) = flag(n_be:n_be+4)*0;
      n_l = n_l + 4;

      %make the layout extended
      layout(n_be+1,1) = min((layout(n_be,1)   + x_min) / 2, x_min - 10);
      layout(n_be+4,1) = max((layout(n_be+5,1) + x_max) / 2, x_max + 10);
      layout(n_be+1,2) = layout(n_be,2);
      layout(n_be+4,2) = layout(n_be+5,2);
      layout(n_be+2,1) = layout(n_be+1,1);
      layout(n_be+3,1) = layout(n_be+4,1);
      layout(n_be+2,2) = y_max + 10;
      layout(n_be+3,2) = y_max + 10;
      again = 1; %flag for do it agin
      odir = 0;  %flag for failed 
      addir = 0; %adding direction is right
      sudir = 0; %substracting direction is right

      again = 0;
      while again  <= 10
        again = again + 1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % go the upper direction                              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isempty(blkxchk(layout(n_be+1:n_be+2, :), blklocs))
          addir = 1;
          if isempty(blkxchk(layout(n_be+3:n_be+4, :), blklocs))
            [cros_inf, block_n] = blkxchk(layout(n_be+2:n_be+3, :), blklocs);
            if isempty(cros_inf)
              % done
              again = 11; odir = 0;
            else
              %lower the floor
              tmp_max = max(find(blklocs(block_n, 4) == max(blklocs(block_n, 4))));
              tmp_max = blklocs(tmp_max,4);
              layout(n_be+2,2) = tmp_max + 10 + abs(layout(n_be+2,1)-layout(n_be+3,1))/40;
              layout(n_be+3,2) = layout(n_be+2,2);             
            end;
          end;
        else
          again = 11;
          odir = 1;
        end;
      end;
      again = 1;
      if odir 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % go the down direction                              %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        odir = 0;
        layout(n_be+2, 2) = y_min - 10 - abs(layout(n_be+2,1)-layout(n_be+3,1))/40;;
        layout(n_be+3, 2) = layout(n_be+2, 2);
        again = 0;
        while again <= 10
          again = again + 1;
          if isempty(blkxchk(layout(n_be+1:n_be+2, :), blklocs))
            sudir = 1;
            if isempty(blkxchk(layout(n_be+3:n_be+4, :), blklocs))
              [cros_inf, block_n] = blkxchk(layout(n_be+2:n_be+3, :), blklocs);
              if isempty(cros_inf)
                % done
                again = 11; odir = 0;
              else
                %lower the floor
                tmp_min = min(find(blklocs(block_n, 2) == min(blklocs(block_n, 2))));
                tmp_min = blklocs(tmp_min, 2);
                layout(n_be+2,2) = tmp_min - 10 - abs(layout(n_be+2,1)-layout(n_be+3,1))/40;
                layout(n_be+3,2) = layout(n_be+2,2);           
              end;
            end;
          else
            again = 11;
            odir = 1;
          end;
        end;          
      end;
      if odir == 1
        if addir == 1
          layout(n_be+2,2) = y_max + 10 + abs(layout(n_be+2,1)-layout(n_be+3,1))/40;
          layout(n_be+3,2) = layout(n_be+2,2);
        elseif sudir == 1
          layout(n_be+2, 2) = y_min - 10 - abs(layout(n_be+2,1)-layout(n_be+3,1))/40;
          layout(n_be+3, 2) = layout(n_be+2, 2);
        else
          % Sorry, I cannot do anything better
          layout(n_be+1:n_l-4, :) = layout(n_be+5:n_l,:);
          layout(n_l-3:n_l, :) = [];
          flag(n_l-3:n_l) = [];
          n_l = 11; %set signal to stop.
        end;
      end;

      %back to the original direction
      if (direct == 2) | (direct == 1)
         layout  = -layout;
          blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
          blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
      end;

      if (direct == 1) | (direct == 3)
         %swirch x and y
         layout(:,1) = - layout(:,1);
         layout = fliplr(layout);
         blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
         blklocs(:,1:2) = fliplr(blklocs(:,1:2));
         blklocs(:,3:4) = fliplr(blklocs(:,3:4));
      end;
%      if (direct == 1) | (direct == 3)
%        %swirch x and y
%        layout = fliplr(layout);
%        blklocs(:,1:2) = fliplr(blklocs(:,1:2));
%        blklocs(:,3:4) = fliplr(blklocs(:,3:4));
%      end;
%      if (direct == 2) | (direct == 3)
%        %reverse direction
%        layout(:,1)  = 2000 - layout(:,1);
%        blklocs(:,[1 3]) = 2000 - blklocs(:,[1 3]);
%        blklocs(:,[1 3]) = fliplr(blklocs(:,[1 3]));
%      end;

   elseif (n_be > 1) & (n_be+1 < n_l) & (flag(n_be) < 1) %if straight
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %if the segment with cross is not the beginning      %
      %or the end of the the connection segments, then     %
      %go throught the following.                          %
      %                                                    %
      % -----|       ===>  ---------|   or   --|           %
      %      |-----                 |--        |---------- %
      %    (1)                 (2)              (3)        %
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      up = 1; dn = 1;

      %make layout(n_be-1:n_be,:) ---> direction
      direct = linedir(layout(n_be-1:n_be,:));
      if direct < 0
        %I am not taking care of randon direction now
        return;
      end;
      if (direct==1) | (direct==3)
         %switch x and y
         layout = fliplr(layout);
         layout(:,1) = -layout(:,1);
         blklocs(:,1:2) = fliplr(blklocs(:,1:2));
         blklocs(:,3:4) = fliplr(blklocs(:,3:4));
         blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
      end;

      if (direct==2) | (direct==1)
          %reverse direction
          layout = - layout;
          blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
          blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
      end;

%      if (direct == 2) | (direct == 3)
%        % reverse direction
%        layout(:,1) = 2000 - layout(:,1);
%        blklocs(:,[1 3]) = 2000 - blklocs(:,[1 3]);
%        blklocs(:,[1 3]) = fliplr(blklocs(:,[1 3]));
%      end;
%      if (direct == 1) | (direct == 3)
%        % switch x and y
%        layout = fliplr(layout);
%        blklocs(:,1:2) = fliplr(blklocs(:,1:2));
%        blklocs(:,3:4) = fliplr(blklocs(:,3:4));
%      end;
      
      while up
        % find the cross
        [x_min,x_max,y_min,y_max,test] = ...
          linemima(layout(n_be:n_be+1, :), blklocs);
        if isempty(test)
           dn = 0; % it is succesfull
           up = 0;
        else
           %move up to position (2)
           if isempty(blkxchk([layout(n_be-1,:);x_max+10, layout(n_be,2)],blklocs))
              if x_max < layout(n_be+1,1)
                 layout(n_be,1)   = x_max+10+abs(layout(n_be,2)-layout(n_be+1,2))/40;
                 layout(n_be+1,1) = layout(n_be,1);
              elseif n_be+1 ~= n_l
                 layout(n_be,1)   = x_max+10+abs(layout(n_be,2)-layout(n_be+1,2))/40;
                 layout(n_be+1,1) = layout(n_be,1);
              else
                 up = 0; % there is no way up
              end;
           else
              up =0;  %there is no way to go up
           end;
        end;
      end;
      while dn
        % find the cross
        [x_min,x_max,y_min,y_max,test] =...
          linemima(layout(n_be:n_be+1, :), blklocs);
        if isempty(test)
           dn = 0;
           up = 0;
        else
           %move down to position (3)
           if isempty(blkxchk([layout(n_be-1,:);x_min-10, layout(n_be,2)], blklocs))
              if x_max < layout(n_be+1,1)
                 layout(n_be,1)   = x_min - 10 - abs(layout(n_be,2)-layout(n_be+1,2))/40;
                 layout(n_be+1,1) = layout(n_be,1);
              elseif n_be+1 ~= n_l
                 layout(n_be,1)   = x_min - 10 - abs(layout(n_be,2)-layout(n_be+1,2))/40;
                 layout(n_be+1,1) = layout(n_be,1);
              else
                 dn = 0; % there is no way dn
              end;
           else
              dn =0;  %there is no way to go dn
              flag(n_be) = 1 + flag(n_be);
           end;
        end;
      end;

      %switch back to the direction
      if (direct == 2) | (direct == 1)
         layout  = -layout;
          blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
          blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
      end;

      if (direct == 1) | (direct == 3)
         %swirch x and y
         layout(:,1) = - layout(:,1);
         layout = fliplr(layout);
         blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
         blklocs(:,1:2) = fliplr(blklocs(:,1:2));
         blklocs(:,3:4) = fliplr(blklocs(:,3:4));
      end;
%      if (direct == 1) | (direct == 3)
%%        %swirch x and y
%        layout = fliplr(layout);
%        blklocs(:,1:2) = fliplr(blklocs(:,1:2));
%        blklocs(:,3:4) = fliplr(blklocs(:,3:4));
%      end;
%      if (direct == 2) | (direct == 3)
%        %reverse direction
%        layout(:,1) = 2000 - layout(:,1);
%        blklocs(:,[1 3]) = 2000 - blklocs(:,[1 3]);
%        blklocs(:,[1 3]) = fliplr(blklocs(:,[1 3]));
%      end;
   elseif flag(n_be) < 10
      %                                _______|
      % in the case of brake to ______|         seg1, seg2, seg3, seg4
      % all of the cases, brake layout(n_be:  n_be+1, :)
      % and                     layout(n_be+1:n_be+2, :)
      % except for the case of n_be+1 == n_en when the 
      % connection lines will be go a reverse way to match the requirement

      %in case of need to reverse
      revers = 0;
      if n_be+1 == n_l
        revers = 1;
        layout = flipud(layout);
        n_be = 1; n_en = 2;
      end;

      %make all of the begining line to be left-->right direction
      direct = linedir(layout(n_be:n_be+1,:));
      if direct < 0
        %I am not taking care of randon direction now
        return;
      end;

      if (direct==1) | (direct==3)
         %switch x and y
         layout = fliplr(layout);
         layout(:,1) = -layout(:,1);
         blklocs(:,1:2) = fliplr(blklocs(:,1:2));
         blklocs(:,3:4) = fliplr(blklocs(:,3:4));
         blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
      end;

      if (direct==2) | (direct==1)
          %reverse direction
          layout = - layout;
          blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
          blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
      end;

%      if (direct == 2) | (direct == 3)
%        %reverse direction
%        layout(:,1) = 2000 - layout(:,1);
%        blklocs(:,[1 3]) = 2000 - blklocs(:,[1 3]);
%        blklocs(:,[1 3]) = fliplr(blklocs(:,[1 3]));
%      end;
%      if (direct == 1) | (direct == 3)
%        %swirch x and y
%        layout = fliplr(layout);
%        blklocs(:,1:2) = fliplr(blklocs(:,1:2));
%        blklocs(:,3:4) = fliplr(blklocs(:,3:4));
%      end;
      %now everyone has direction 0      

      %calculate the minimum and maximum
      [x_min,x_max,y_min,y_max] = linemima(layout(n_be:n_be+1,:),blklocs);

      %direction of the second line
      direct2 = linedir(layout(n_be+1:n_be+2,:));
      %by our setup, direct2 should be either 1 or 3

      %make space for the new part, enlarge two points
      layout(n_be+3:n_l+2,:) = layout(n_be+1:n_l,:);
      flag(n_be+3:n_l+2) = flag(n_be+1:n_l);
      flag(n_be+1:n_be+2) = flag(n_be+1:n_be+2)*0;
      n_l = n_l + 2;

      %braking n_be:n_be+1 line
      layout(n_be + 1, 1) = min((layout(n_be, 1) + x_min)/2, x_min-10);
      layout(n_be + 2, 1) = layout(n_be, 1);
      if direct2 == 1
        layout(n_be + 3, 2) = max((layout(n_be+3, 2) + y_max)/2, y_max+10);
      else
        layout(n_be + 3, 2) = min((layout(n_be+3, 2) + y_min)/2, y_min-10);
      end;
      layout(n_be + 2, 1) = layout(n_be + 1, 1);
      layout(n_be + 2, 2) = layout(n_be + 3, 2);

      odir = 0;  %flag for failed 
      addir = 0; %first section is fixed
      sudir = 0; %second section is fixed
      thdir = 0; %third section is fixed
      frdir = 0; %fourth section is fixed
      again = 1; test = 0;
      while again & (test < 10)
        test = test + 1;
        if addir == 0 %seg1
          %Need to check up or fix
          [tmp_x_min,tmp_x_max,tmp_y_min,tmp_y_max,tmp_x] = ...
            linemima(layout(n_be:n_be+1,:),blklocs);
          addir = 1;
          if ~isempty(tmp_x)
            if tmp_x_max < x_min                    %not cross the old limit
              layout(n_be+1,1) = (x_min + tmp_x_max)/2;
              sudir = 0;                            %seg2 relocated
            elseif tmp_x_min > layout(n_be,1)       %not change the seg1 direction.
              layout(n_be+1,1) = min((layout(n_be,1) + tmp_x_min)/2, tmp_x_min - 10);
              thdir = 0; sudir = 0;                 %seg2 relocated; seg3 extended
            else
              %need to reduce the length of seg2
              odir = 1; addir = 0; sudir = 0; again = 0;
            end;
            layout(n_be+2,1) = layout(n_be+1,1);
          end;
        end;

        if sudir == 0 %seg2
          %Need to checkup or fix
          [tmp_x_min,tmp_x_max,tmp_y_min,tmp_y_max,tmp_x] = ...
            linemima(layout(n_be+1:n_be+2,:),blklocs);
          sudir = 1;
          if ~isempty(tmp_x)
            if (tmp_x_max < x_min)                      % still have space for pass
              layout(n_be + 2, 1) = (tmp_x_max + x_min)/2;
            elseif (tmp_y_min > y_max) & (direct2 == 1) % still have space for pass
              layout(n_be + 2, 2) = (tmp_y_min + y_max)/2;
              thdir = 0;                                % seg3 moved
              frdir = 0;                                % seg4 extended
            elseif (tmp_y_max < y_min) & (direct2 == 3) % still have space for pass
              layout(n_be + 2, 2) = (tmp_y_max + y_min)/2;
              thdir = 0;                                % seg3 moved
              frdir = 0;                                % seg4 extended
            elseif (tmp_x_min > layout(n_be, 1))        % horizontal move
              layout(n_be + 2, 1) = min((tmp_x_min + layout(n_be, 1))/2, tmp_x_min - 10);
              sudir = 0;                                % seg2 moved
              thdir = 0;                                % seg3 moved
            else
              %there is no way to move
              sudir = 0;
              odir = 1;
              again = 0;
            end;
          end;
          %adjust the points
          layout(n_be+3,2) = layout(n_be+2,2);
          layout(n_be+1,1) = layout(n_be+2,1);
        end;
        if thdir == 0
          %Need to checkup or fix
          [tmp_x_min,tmp_x_max,tmp_y_min,tmp_y_max,tmp_x] = ...
                linemima(layout(n_be+2:n_be+3,:),blklocs);
          thdir = 1;
          if ~isempty(tmp_x)
            if (tmp_x_max < x_min)
              layout(n_be + 2,1) = (tmp_x_max + x_min)/2;
              sudir = 0;
            elseif (tmp_y_max > y_max) & (tmp_y_max < layout(n_be+4,2)) & (direct2 == 1)
                                                        % still have space for pass
              layout(n_be + 3, 2) = max((tmp_x_max + layout(n_be+4,2))/2, tmp_x_max);
              sudir = 0; 
              thdir = 0;
            elseif (tmp_y_min < y_min) & (tmp_y_min > layout(n_be+4,2)) & (direct2 == 3)
                                                        % still have space for pass
              layout(n_be + 3, 2) = min((tmp_x_min+layout(n_be+4,2))/2, tmp_x_min-10);
              sudir = 0; 
              thdir = 0;
            elseif (tmp_y_min > layout(n_be+4, 2)) & (direct2 == 3)
              layout(n_be + 3, 2) = (tmp_y_min > layout(n_be+4, 2))/2;
            elseif (tmp_y_max < layout(n_be+4, 2)) & (direct2 == 13)
              layout(n_be + 3, 2) = (tmp_y_max > layout(n_be+4, 2))/2;
            else
              %there is no way to move
              sudir = 0;
              odir = 1;
              again = 0;
            end;
            layout(n_be + 2, 2) = layout(n_be + 3, 2);
            layout(n_be + 1, 1) = layout(n_be + 2, 1);
          end;
        end;
        if frdir == 0;
          %
          [tmp_x_min,tmp_x_max,tmp_y_min,tmp_y_max,tmp_x] = ...
                linemima(layout(n_be+3:n_be+4,:),blklocs);
          thdir = 1;
          if ~isempty(tmp_x)
            if (tmp_y_max < layout(n_be+4,2)) & (direct2 == 1)
              layout(n_be + 3, 2) = max((layout(n_be+4, 2) + tmp_y_max)/2, tmp_y_max + 10);
              thdir = 0;
            elseif (tmp_y_min > layout(n_be+4, 2)) & (direct2 == 3)
              layout(n_be + 3, 2) = min((layout(n_be+4, 2) + tmp_y_min)/2, tmp_y_min - 10);
              thdir = 0;
            else
              thdir = 0; odir = 0; %wait for next around
              again = 0;
            end;
            layout(n_be + 2, 2) = layout(n_be + 3, 2);
          end;
        end;
      end;

      %back to the original direction
      if (direct == 2) | (direct == 1)
         layout  = -layout;
          blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
          blklocs(:,[2,4]) = fliplr(-blklocs(:,[2,4]));
      end;

      if (direct == 1) | (direct == 3)
         %swirch x and y
         layout(:,1) = - layout(:,1);
         layout = fliplr(layout);
         blklocs(:,[1,3]) = fliplr(-blklocs(:,[1,3]));
         blklocs(:,1:2) = fliplr(blklocs(:,1:2));
         blklocs(:,3:4) = fliplr(blklocs(:,3:4));
      end;

%      if (direct == 1) | (direct == 3)
%        %swirch x and y
%        layout = fliplr(layout);
%        blklocs(:,1:2) = fliplr(blklocs(:,1:2));
%        blklocs(:,3:4) = fliplr(blklocs(:,3:4));
%      end;
%      if (direct == 2) | (direct == 3)
%        %reverse direction
%        layout(:,1)  = 2000 - layout(:,1);
%        blklocs(:,[1 3]) = 2000 - blklocs(:,[1 3]);
%        blklocs(:,[1 3]) = fliplr(blklocs(:,[1 3]));
%      end;

      if revers
        layout = flipud(layout);
        revers = 0;
      end;
   else
      n_l = 11; % I cannot do anything better
   end; %if straight

   %test if there is anything to be done
   [x_min,x_max,y_min,y_max,to_do,n_be,n_en]=...
        linemima(layout,blklocs);
end;  %while
%check if we could reduce some redundent segment

for j=1:3
  [n_l, m_l] = size(layout);
  if n_l > 5
     tmp = [];
     i = 1;
     while i < n_l - 3
       i = i+1;
       tmp(1,:) = layout(i-1,:);
       tmp(3,:) = layout(i+2,:);
       if rem(i,2) == 0
         tmp(2,2) = layout(i-1,2);
         tmp(2,1) = layout(i+2,1);
       else
         tmp(2,1) = layout(i-1,1);
         tmp(2,2) = layout(i+2,2);
       end;
       if isempty(blkxchk(tmp(1:2,:),blklocs))
          if isempty(blkxchk(tmp(2:3,:),blklocs))
             layout(i,:) = tmp(2,:);
             layout(i+1:i+2,:) = [];
             n_l = n_l - 2;
          end;
       end;
     end;
  end;
end;
%simplify: check if the lines can be simplified be combining some of them
