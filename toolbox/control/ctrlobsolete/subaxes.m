function [SubAxes,OtherAxes,NumDeleted] = subaxes(p,m,position,fig,offset)
%SUBAXES Create axes in tiled positions.
%       [SubAxes,OtherAxes,NumDeleted] = SUBAXES(P,M,Position,FIG,Offset) divides 
%       the normalized Position of FIG window into a P-by-M matrix of small axes 
%       and returns the axes handles in a vector.  The axes are ordered by column.
%       OtherAxes is a vector of the other axes in the figure and NumDeleted
%       is the number of axes deleted by SUBAXES.
%
%       The optional arguments Position and FIG have defaults of newfig and  
%       get(FIG,'DefaultAxesPosition') respectively.  Offset is the fraction
%       by which the axes are inset from their outer edge.  By default, Offset
%       is [0.01 0.01]; the 1st element is horizontal offset, the 2nd is vertical.
%       If p=1, then Offset(2)=0; if m=1, Offset(1)=0.  Thus subaxes(1,1) yields
%       an axes in the same position as axes would.
%
%       If a set of sub-axes exists in the same position of the same
%       dimension, SUBAXES will return the handles to those axes.  
%       It will not delete the old axes and create new ones.
%
%       On the other hand, SUBAXES will delete axes which intersect Position,
%       but it will not delete a (single) axes exactly at Position.
%
%       Note: Assumes all axes units are normalized
%             Creates axes with Box properties set to on
%             Tries to do be intelligent about X/YTickLabelMode

%       Author(s): A. Potvin, 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:17 $

% Define optional arguments if not supplied
ni = nargin;
error(nargchk(2,5,ni))
if ni<5,
   offset = [0.01 0.01];
elseif length(offset)==1,
   offset = [offset offset];
end
if ni<4,
   fig = newfig;
end
% Reset figure and delete its Children if NextPlot is replace
if strcmp(get(fig,'NextPlot'),'replace'),
   delete(get(fig,'Children'))
   reset(fig)
end
if ni<3,
   position = get(fig,'DefaultAxesPosition');
end

% REVISIT: May someday be able to specify axes Parent on creation
if get(0,'CurrentFigure')~=fig,
   figure(fig)
end

% Define some default axes parameters properties that response plots may change
Box = 'on';
if (p>1) | (m>4),
   XTickLabelMode = 'manual';
else
   XTickLabelMode = 'auto';
end
if (m>1) | (p>4),
   YTickLabelMode = 'manual';
else
   YTickLabelMode = 'auto';
end

% Override offset for m or p of 1
if p==1,
   offset(2) = 0;
end
if m==1,
   offset(1) = 0;
end

% Get handles to all axes in the figure unless figure NextPlot is new
if strcmp(get(fig,'NextPlot'),'new'),
   AllAxes = [];
else
   AllAxes = findobj(fig,'Type','axes');
end
% Get positions of AllAxes in normalized coordinates. Put into matrix Position
laa = length(AllAxes);
Position = zeros(laa,4);
for i=1:laa,
   % Assumes all axes units are normalized
   Position(i,:) = get(AllAxes(i),'Position');
end

% Create axes or return handle to existing axes
ax = zeros(p,m);
SWH = position(3:4)./[m p];
inset = offset.*SWH;
AWH = (1-2*offset).*SWH;
for i=1:p,
   for j=1:m,
      % Define AxesPos as function of i and j and position
      AxesLL = position(1:2) +[j-1 p-i].*SWH +inset;
      AxesPos = [AxesLL AWH];

      % Check for existence of axes in the correct position
      if laa>0,
         ind = find(all((AxesPos(ones(1,laa),:)==Position)'));
         if isempty(ind),
            % None found so make a new axes
            MakeNew = 1;
         else
            % Found (at least) one
            MakeNew = 0;

            % Choose the first one
            ind = ind(1);
            ax(i,j) = AllAxes(ind);

            % Remove row in AllAxes and position and decrement laa
            AllAxes(ind) = [];
            Position(ind,:) = [];
            laa = laa-1;
         end
      else
         % No other axes, so make a new axes
         MakeNew = 1;
      end

      if MakeNew,
         % Create axes
         ax(i,j) = axes('Unit','norm','Position',AxesPos,'Box',Box, ...
          'XTickLabelMode',XTickLabelMode,'YTickLabelMode',YTickLabelMode);
      end % if
   end % for j
end % for i
SubAxes = ax(:);
set(SubAxes,'Visible','on')

% Now delete any remaining axes that intersect position
if laa~=0,
   NotIntersect = (  position(1) > Position(:,1) + Position(:,3)) | ...
                  (Position(:,1) > position(1) + position(3)) | ...
                  (  position(2) > Position(:,2) + Position(:,4)) | ...
                  (Position(:,2) > position(2) + position(4) );
   % But don't delete axes that exactly matches position
   ind = find(all((position(ones(1,laa),:)==Position)'));
   if ~isempty(ind),
      NotIntersect(ind(1)) = 1;
   end
   delete(AllAxes(~NotIntersect))
   OtherAxes = AllAxes(NotIntersect);
   NumDeleted = sum(~NotIntersect);
else
   OtherAxes = [];
   NumDeleted = 0;
end

% end subaxes
