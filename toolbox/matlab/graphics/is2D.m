function [retval] = is2D(ax)
% Internal use only. This function may be removed in a future release.

% Copyright 2002-2003 The MathWorks, Inc.

%IS2D Return true if axes is 2-D

% For now, just consider x-y plots
ax_view = get(ax,'View');
if iscell(ax_view)
   for n = 1:length(ax_view)
      retval(n) = all(ax_view{n}==[0,90]);
   end
else
    retval = all(ax_view==[0,90]);
end
   

%--Uncomment this code for generic 2-D plot support--%

%test to see if viewing plane is parallel to major axis (x,y, or z)
%test1 = logical(sum(campos(ax)-camtarget(ax)==0)==2);
% 
% % test to see if upvector is orthogonal to primary axes
% if (test1)
%     cup = camup(ax);
%     I = find(( (campos(ax)-camtarget(ax)) ==0 )==1);
%     test2 = sum(cup(I)~=0)~=2;
%      
%     % test to see if projection is orthographic
%     if(test2)
%         retval = strcmpi(get(ax,'Projection'),'Orthographic');
%     end
% end


