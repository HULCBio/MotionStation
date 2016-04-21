function drawconstr(this)
% DRAWCONSTR draws the constraints.

%   Author(s): Kamesh Subbarao, P. Gahinet
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:44:42 $
%   Copyright 1990-2004 The MathWorks, Inc.
c = this.Constraint;  % constraint data
ax = getaxes(this.Axes);

% Geometry
xlim = get(ax,'XLim');
ylim = get(ax,'YLim');
ht = diff(ylim)/30; % patch height

% Draw lower bounds
nlb = size(c.LowerBoundX,1);
% Extend last bound up to Xlim(2)
[c.LowerBoundX,c.LowerBoundY] = ...
   localExtrapolate(c.LowerBoundX,c.LowerBoundY,xlim);
lby = c.LowerBoundY;
% Draw lines 
localCreateObjects(this,nlb,'LowerBound');
for ct = 1:nlb
   x = c.LowerBoundX(ct,:);
   y = lby(ct,:); 
   % Line
   if ct==1
      yp = NaN;
   else
      yp = lby(ct-1,2);
   end
   set(this.LowerBound(ct).Line,'Xdata',x([1 1]),'Ydata',[yp lby(ct,1)])
   % Patch
   set(this.LowerBound(ct).Surf,'Xdata',x([1 2 2 1]),'Ydata',[y,y([2 1])-ht],...
      'Zdata',zeros(1,4),'FaceColor',[c.LowerBoundWeight(ct) 0 0])
end

% Draw lower bounds
nub = size(c.UpperBoundX,1);
% Extend last bound up to Xlim(2)
[c.UpperBoundX,c.UpperBoundY] = ...
   localExtrapolate(c.UpperBoundX,c.UpperBoundY,xlim);
uby = c.UpperBoundY;
% Draw lines and patches
localCreateObjects(this,nub,'UpperBound');
for ct = 1:nub
   x = c.UpperBoundX(ct,:);
   y = uby(ct,:);
   % Line
   if ct==1
      yp = NaN;
   else
      yp = uby(ct-1,2);
   end
   set(this.UpperBound(ct).Line,'Xdata',x([1 1]),'Ydata',[yp uby(ct,1)])
   % Patch
   set(this.UpperBound(ct).Surf,'Xdata',x([1 2 2 1]),'Ydata',[y,y([2 1])+ht],...
      'Zdata',zeros(1,4),'FaceColor',[c.UpperBoundWeight(ct) 0 0])
end

%--------------- Local Functions -----------------------------

function localCreateObjects(this,nobj,BoundType);
% Adjusts the number of objects
s = this.(BoundType);
ax = getaxes(this.Axes);
ns = length(s);
if ns~=nobj,
   if ns>nobj
      delete(cat(1,s(nobj+1:ns).Surf,s(nobj+1:ns).Line))
      s = s(1:nobj,:);
   elseif ns<nobj
      for ct=nobj:-1:ns+1
         % Create surface
         surf = patch('Parent',ax,'EdgeColor','black','LineStyle','-',...
            'ButtonDownFcn',{@LocalSurfBDF,this,BoundType});
         % Context menu
         uic = uicontextmenu('Parent',this.Parent);
         uimenu(uic,'Label',xlate('&Split'),'Callback',{@LocalSplitConstr,this,BoundType,surf});
         uimenu(uic,'Label',xlate('&Edit...'),'CallBack',{@LocalEditConstraint,this,BoundType,surf});
         uimenu(uic,'Label',xlate('&Delete'),'CallBack',{@LocalDeleteConstraint,this,BoundType,surf});
         set(surf,'UIContextMenu',uic)
         % Create line and patch
         s(ct,1).Surf = surf;
         s(ct,1).Line = line('Parent',ax,'LineStyle','-','Color','black',...
            'ButtonDownFcn',{@LocalLineBDF,this,BoundType});
      end
   end
   this.(BoundType) = s;
end


function [lbx,lby] = localExtrapolate(lbx,lby,Xlim,AutoX)
% Adjust asymptote extent to fill available X range
nseg = size(lbx,1);
if lbx(nseg,2)<Xlim(2)
   slope = diff(lby(nseg,:))/diff(lbx(nseg,:));
   lbx(nseg,2) = Xlim(2);
   lby(nseg,2) = lby(nseg,1) + slope * (Xlim(2)-lbx(nseg,1));
end


function LocalLineBDF(eventsrc,eventdata,this,BoundType)
% Set Button down function for the line.
LineBDF(this,'start',BoundType);


function LocalSurfBDF(eventsrc,eventdata,this,BoundType)
% Button down function for the surface.
SType = get(this.Parent,'SelectionType');
if ~strcmp(SType,'alt')
   idx = find(eventsrc == [this.(BoundType).Surf]);
   if strcmp(SType,'open')
      this.editconstr(BoundType,idx)
   else
      SurfBDF(this,'start',BoundType,idx)
   end
end


function LocalSplitConstr(eventsrc,eventdata,this,BoundType,SelectedObj)
% Split Constraints
idx = find(SelectedObj == [this.(BoundType).Surf]);
if ~isempty(idx)
   % Start transaction
   Transaction = ctrluis.transaction(this.Constraint,'Name','Split Constraint',...
      'OperationStore','on','InverseOperationStore','on');
   % Split consraint
   MousePos = get(getaxes(this),'CurrentPoint');
   this.Constraint.split(BoundType,idx,MousePos(1))
   % Commit and stack transaction
   commit(Transaction)
   this.Recorder.pushundo(Transaction)
   % Update display
   drawconstr(this)
end


function LocalEditConstraint(eventsrc,eventdata,this,BoundType,SelectedObj)
% Edit Constraints
idx = find(SelectedObj == [this.(BoundType).Surf]);
this.editconstr(BoundType,idx)


function LocalDeleteConstraint(eventsrc,eventdata,this,BoundType,SelectedObj)
% Delete Constraint
hSurf = [this.(BoundType).Surf];
idx = find(SelectedObj == hSurf);
if ~isempty(idx)
   if idx==length(hSurf)
      errordlg('Cannot delete rightmost constraint.','Delete Error','modal')
   else
      % Start transaction
      Transaction = ctrluis.transaction(this.Constraint,'Name','Delete Constraint',...
         'OperationStore','on','InverseOperationStore','on');
      % Delete consraint
      this.Constraint.dispose(BoundType,idx)
      % Commit and stack transaction
      commit(Transaction)
      this.Recorder.pushundo(Transaction)
      % Update display
      update(this)
   end
end
