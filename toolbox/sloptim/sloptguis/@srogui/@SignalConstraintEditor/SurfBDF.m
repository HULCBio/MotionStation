function SurfBDF(this,Phase,varargin)
% SurfBDF is the PTB Blockset SurfaceButtonDownFcn.
%   MMODE Type of motion
%        'vertical'  Move segment in up/down mode (clicked in middle)
%        'freeright' Move right side of segment (clicked at right edge)
%        'freeleft'  Move left side of segment (clicked at left edge)

%   Author(s): Kamesh Subbarao
%   Copyright 1990-2004 The MathWorks, Inc.
persistent wbfs idx Mode BoundType BoundX BoundY Xoffset Yoffset Transaction
persistent Y0ptr Yidx dYbnds
persistent xA yA xD yD MovedVertex

c = this.Constraint;
Figure = this.Parent;
ax = getaxes(this.Axes);

switch Phase
    case 'start'         
       %---Button Down Callback, Start
       BoundType = varargin{1};
       BoundX = sprintf('%sX',BoundType);
       BoundY = sprintf('%sY',BoundType);
       idx = varargin{2};
       Nbnd = size(c.(BoundX),1);
       % Locate modified constraint
       initpt = get(ax,'Currentpoint');
       Xidx = c.(BoundX)(idx,:);
       Yidx = c.(BoundY)(idx,:);
       % Hot region for grabbing the end points
       Xlim = get(ax,'XLim');
       if idx==Nbnd
          dXtip = min(0.025*diff(Xlim),0.2*(Xlim(2)-Xidx(1)));
       else
          dXtip = min(0.025*diff(Xlim),0.2*diff(Xidx));
       end
       % Determine motion type
       if initpt(1)<Xidx(1)+dXtip
          % Moving left vertex
          Mode = 'free';
          Xoffset = Xidx(1)-initpt(1,1);
          Yoffset = Yidx(1)-initpt(1,2);
          if idx==1
             Pointer = 'top';
             xA = c.(BoundX)(1,1);  yA = c.(BoundY)(1,1);
          else
             Pointer = 'fleur';
             xA = c.(BoundX)(idx-1,1);  yA = c.(BoundY)(idx-1,1);
          end
          xD =  c.(BoundX)(idx,2);  yD =  c.(BoundY)(idx,2);
          MovedVertex = 1;
          % Start transaction
          Transaction = ctrluis.transaction(c,'Name','Move Vertex',...
             'OperationStore','on','InverseOperationStore','on','Compression','on');

       elseif idx<Nbnd && initpt(1)>Xidx(2)-dXtip
          % Moving right vertex
          % RE: Do not allow free motion of last vertex because it is 
          %     virtual (edge stretches to the right to fill X range)
          Mode = 'free';
          Pointer = 'fleur';
          Xoffset = Xidx(2)-initpt(1,1);
          Yoffset = Yidx(2)-initpt(1,2);
          xA = c.(BoundX)(idx,1);  yA = c.(BoundY)(idx,1);
          xD = c.(BoundX)(idx+1,2);  yD = c.(BoundY)(idx+1,2);
          %           if idx==Nbnd
          %              Pointer = 'top';
          %              xD = c.(BoundX)(idx,2);    yD = c.(BoundY)(idx,2);
          MovedVertex = 2;
          Transaction = ctrluis.transaction(c,'Name','Move Vertex',...
             'OperationStore','on','InverseOperationStore','on','Compression','on');

       else
          Pointer = 'top';   
          Mode = 'vertical';
          dYbnds = getYMotionConstraint(c,BoundType,idx);
          Y0ptr = initpt(1,2);
           % Start transaction
          Transaction = ctrluis.transaction(c,'Name','Vertical Move',...
             'OperationStore','on','InverseOperationStore','on','Compression','on');
      end
       
      % Take over window button functions
      wbfs = get(Figure,{'WindowButtonUpFcn','WindowButtonMotionFcn'});
      set(Figure,'Pointer',Pointer,...
         'WindowButtonUpFcn',@(src,data) SurfBDF(this,'finish'),...
         'WindowButtonMotionFcn',@(src,data) SurfBDF(this,'move'));
        
    case 'move'
        %--- Mouse Motion Callback
        newpt = get(ax,'CurrentPoint'); % current point
        if strcmp(Mode,'vertical')
           % Vertical motion
           dY = newpt(1,2)-Y0ptr; % unconstrained mouse displacement
           dY = max(dYbnds(1),min(dYbnds(2),dY));
           c.(BoundY)(idx,:) = Yidx + dY;
        else
           % Free end point motion
           % New x,y position of moved point
           xnew0 = newpt(1,1) + Xoffset;
           ynew0 =  newpt(1,2) + Yoffset;
           % Get max displacement TMAX along direction 
           % current pos. -> mouse pos.
           [xnew,ynew,tmax] = getMaxDisplacement(...
              c,BoundType,idx,MovedVertex,xA,yA,xD,yD,xnew0,ynew0);
           % If TMAX=0, get max tangential displacement along
           % contact edge
           if tmax==0
              % Project (XNEW0,YNEW0) onto contact edge
              [xnew,ynew] = projectDisplacement(...
                 c,BoundType,idx,MovedVertex,xnew0,ynew0);
              [xnew,ynew] = getMaxDisplacement(...
                 c,BoundType,idx,MovedVertex,xA,yA,xD,yD,xnew,ynew);
           end
           % Update constraint data
           if MovedVertex==1
              c.(BoundX)(idx,1) = xnew;
              c.(BoundY)(idx,1) = ynew;
              if idx>1
                 c.(BoundX)(idx-1,2) = xnew;
              end
           else
              c.(BoundX)(idx,2) = xnew;
              c.(BoundY)(idx,2) = ynew;
              c.(BoundX)(idx+1,1) = xnew;
           end
        end
        % Update plot
        drawconstr(this)
        
   case 'finish'
      % Button Up Callback
      % Delete empty sections
      cleanup(c,BoundType,0.0025*diff(get(ax,'Xlim')))
      % Commit and stack transaction
      commit(Transaction)
      this.Recorder.pushundo(Transaction)
      Transaction = [];   % release persistent object
      % Update plot
      % RE: Triggers limit update + constraint redraw 
      this.Axes.send('ViewChanged')
      % Restore figure settings
      set(Figure,'Pointer','arrow','WindowButtonUpFcn',wbfs{1},...
         'WindowButtonMotionFcn',wbfs{2})
end

%------------------ Local Functions ---------------------------------

function [xnew,ynew,tmax] = getMaxDisplacement(c,BoundType,idx,MovedVertex,xA,yA,xD,yD,xnew,ynew)
% Calculate max displacement t in [0,1] for moved vertex
Xrange = [xA,xD];
BoundX = sprintf('%sX',BoundType);
BoundY = sprintf('%sY',BoundType);
AsymptoteFlag = (idx==size(c.(BoundX),1));
if MovedVertex==1
   % Moving left vertex C
   if idx==1
      xB = xA;   yB = yA;
      xC = c.(BoundX)(1,1);  yC = c.(BoundY)(1,1);
      xnew = xC; % no lateral motion for end points
   else
      xB = c.(BoundX)(idx-1,2);  yB = c.(BoundY)(idx-1,2);
      xC = c.(BoundX)(idx,1);  yC = c.(BoundY)(idx,1);
   end
   x0 = xC;        y0 = yC;
   dxC = xnew-xC;  dyC = ynew-yC; 
   dxB = dxC;      dyB = 0;
else
   % Moving right vertex B
   if idx==size(c.(BoundX),1)
      xB = c.(BoundX)(idx,2);  yB = c.(BoundY)(idx,2);
      xC = xD;  yC = yD;
      xnew = xB;  % no lateral motion for end points
   else
      xB = c.(BoundX)(idx,2);  yB = c.(BoundY)(idx,2);
      xC = c.(BoundX)(idx+1,1);  yC = c.(BoundY)(idx+1,1);
   end     
   x0 = xB;        y0 = yB;
   dxB = xnew-xB;  dyB = ynew-yB; 
   dxC = dxB;      dyC = 0;
end

% Find constraints on motion (compute bounds tmin,tmax on
% displacement M+t*dM of critical vertices (M = B,C)
% RE: Not enough to look at the B vertex if yC<yB and C is being moved
%     (assuming Type=lower). Indeed C may jump above B and become the 
%     constraining vertex
trange = [...
   getVertexMotionConstraint(c,xB,yB,dxB,dyB,BoundType,Xrange);...
   getVertexMotionConstraint(c,xC,yC,dxC,dyC,BoundType,Xrange);...
   getEdgeMotionConstraint(c,xA,yA,xB,yB,dxB,dyB,BoundType,Xrange);...
   getEdgeMotionConstraint(c,xD,yD,xC,yC,dxC,dyC,BoundType,Xrange)];
if AsymptoteFlag
   % Add constraint that asymptote should never cross
   trange = [trange ; ...
      getAsymtoteConstraint(c,BoundType,MovedVertex,ynew-y0)];
end

% Determine achievable point closest to mouse position
tmax = min(1,min(trange(:,2)));
xnew = x0 + tmax * (xnew-x0);
ynew = y0 + tmax * (ynew-y0);


%-----------------------

function [xnew,ynew] = projectDisplacement(...
   c,BoundType,idx,MovedVertex,xnew,ynew)
% Projects mouse position onto opposing edge in contact 
% with moved vertex
switch BoundType
   case 'LowerBound'
      % Constraint on asymptote direction
      xV = c.LowerBoundX(idx,MovedVertex);
      yV = c.LowerBoundY(idx,MovedVertex);
      if (idx==size(c.LowerBoundX,1))
         % Moved vertex belongs to asymptote. Determine if restriction
         % on asymptote direction is active
         ubDir = [diff(c.UpperBoundX(end,:)) ; diff(c.UpperBoundY(end,:))];
         lbDir = [diff(c.LowerBoundX(end,:)) ; diff(c.LowerBoundY(end,:))];
         if abs(ubDir'*lbDir)>(1-sqrt(eps))*norm(ubDir)*norm(lbDir)
            % Limit vertical direction of motion
            a = lbDir(2)/lbDir(1);
            b = yV-a*xV;
            if MovedVertex==1
               ynew = max(ynew,a*xnew+b);
            else
               ynew = min(ynew,a*xnew+b);
            end
         end
      end

      % Find opposing edge and project (xnew,ynew) onto the supporting line
      idxE = max([1 find(c.UpperBoundX(:,1)<=xV,1,'last')]);
      a = diff(c.UpperBoundY(idxE,:))/diff(c.UpperBoundX(idxE,:));
      b = c.UpperBoundY(idxE,1) - a*c.UpperBoundX(idxE,1);
      yproj = a*xnew + b;
      ynew = min(ynew,yproj-sqrt(eps)*abs(yproj));

   case 'UpperBound'
      % Constraint on asymptote direction
      xV = c.UpperBoundX(idx,MovedVertex);
      yV = c.UpperBoundY(idx,MovedVertex);
      if (idx==size(c.UpperBoundX,1))
         % Moved vertex belongs to asymptote. Determine if restriction
         % on asymptote direction is active
         ubDir = [diff(c.UpperBoundX(end,:)) ; diff(c.UpperBoundY(end,:))];
         lbDir = [diff(c.LowerBoundX(end,:)) ; diff(c.LowerBoundY(end,:))];
         if abs(ubDir'*lbDir)>(1-sqrt(eps))*norm(ubDir)*norm(lbDir)
            % Limit vertical direction of motion
            a = ubDir(2)/ubDir(1);
            b = yV-a*xV;
            if MovedVertex==1
               ynew = min(ynew,a*xnew+b);
            else
               ynew = max(ynew,a*xnew+b);
            end
         end
      end

      % Find opposing edge and project (xnew,ynew) onto the supporting line
      idxE = max([1 find(c.LowerBoundX(:,1)<=xV,1,'last')]);
      a = diff(c.LowerBoundY(idxE,:))/diff(c.LowerBoundX(idxE,:));
      b = c.LowerBoundY(idxE,1) - a*c.LowerBoundX(idxE,1);
      yproj = a*xnew + b;
      ynew = max(ynew,yproj+sqrt(eps)*abs(yproj));

end
