function [sx,sy] = wp1dcoor(x,y,axe,in4)
%WP1DCOOR Wavelet packets 1-D coordinates.
%   Write function used by DYNVTOOL.
%   [SX,SY] = WP1DCOOR(X,Y,AXE,IN4)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

% Tagged object.
%---------------
tag_img_cfs = 'Img_WPCfs';
tag_nodlab  = 'Pop_NodLab';

sx = sprintf('X = %7.2f',x);
sy = sprintf('Y = %7.2f',y);
if axe==in4
   img = findobj(in4,'type','image','tag',tag_img_cfs);
   if ~isempty(img)
       typelab = get(findobj(get(in4,'parent'),'tag',tag_nodlab),'Value');
       us      = get(img,'Userdata');
       k = find(us(:,3)<y & us(:,4)>y);
       if length(k)==1
          if typelab==1
             sy = ['Pack : (' sprintf('%.0f',us(k,1)) ','     ...
                              sprintf('%.0f',us(k,2)) ')'];
          else
             sy = ['Pack : ' sprintf('%.0f',depo2ind(2,us(k,1:2)))];
          end
       end
    end
end
