function ylimconstr(this,varargin)
%YLIMCONSTR  Enforces constraints on Y limits.
%
%  Syntax is 
%     this.ylimconstr('Constr1',Value1,...)
%  where supported constraints include
%     * Symmetry: [{off}|on]
%     * MinExtent: vector [Ymin,Ymax] of Y limits
%     * MaxExtent: vector [Ymin,Ymax] of Y limits

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:32 $

% RE: Assumes limit manager is turned off
ax = getaxes(this);   % HG axes in use
[nr,nc] = size(ax);
YlimMode = this.AxesGrid.YLimMode(1:nr);
% Visible subgrid in autoY mode
vis = reshape(strcmp(get(ax,'Visible'),'on'),[nr nc]);     % 1 for visible axes
ax = ax(any(vis,2) & strcmp(YlimMode,'auto'),any(vis,1));  

% Peel off constraint list and enforce each constraint 
% along rows where YlimMode=auto
for ct=1:2:length(varargin)
   switch varargin{ct}
   case 'MinExtent'
      MinExtent = varargin{ct+1};
      for ctax=1:size(ax,1)
         Ylim = get(ax(ctax,1),'Ylim');
         Ylim(1) = min(Ylim(1),MinExtent(1));
         Ylim(2) = max(Ylim(2),MinExtent(2));
         set(ax(ctax,:),'Ylim',Ylim)
      end
   case 'MaxExtent'
      MaxExtent = varargin{ct+1};
      for ctax=1:size(ax,1)
         Ylim = get(ax(ctax,1),'Ylim');
         Ylim(1) = max(Ylim(1),MaxExtent(1));
         Ylim(2) = min(Ylim(2),MaxExtent(2));
         set(ax(ctax,:),'Ylim',Ylim)
      end
   case 'Symmetry'
      if strcmp(varargin{ct+1},'on')
         % Enforce Ylim(2)=-Ylim(1) 
         for ctax=1:size(ax,1)
            Ylim = get(ax(ctax,1),'Ylim');
            YlimMax = max(abs(Ylim));
            if abs(Ylim(1)+Ylim(2))>1e3*eps*YlimMax
               set(ax(ctax,:),'Ylim',[-YlimMax,YlimMax])
            end
         end
      end
   end
end


