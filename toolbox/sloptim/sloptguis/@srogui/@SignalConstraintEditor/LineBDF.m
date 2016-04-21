function LineBDF(this,Phase,varargin)
% LineBDF is the PTB Blockset LineButtonDownFcn.
%       
%   Author(s): Kamesh Subbarao
%   Copyright 1990-2004 The MathWorks, Inc.
persistent wbfs idx BoundType BoundX Xrange Transaction

c = this.Constraint;
Figure = this.Parent;
ax = getaxes(this.Axes);

switch Phase
   case 'start'
      % Button Down Callback, Start
      BoundType = varargin{1};
      BoundX = sprintf('%sX',BoundType);
      BoundY = sprintf('%sY',BoundType);
      newpt = get(ax,'Currentpoint');
      
      % Locate modified constraint 
      [junk,idx] = min(abs(newpt(1,1)-c.(BoundX)(:,1)));
      if idx==1 % no op
         return
      end
      
      % Get vertices of edges (A,B) and (C,D) involved in motion
      xA = c.(BoundX)(idx-1,1);  yA = c.(BoundY)(idx-1,1);
      xB = c.(BoundX)(idx-1,2);  yB = c.(BoundY)(idx-1,2);
      xC = c.(BoundX)(idx,1);    yC = c.(BoundY)(idx,1);
      xD = c.(BoundX)(idx,2);    yD = c.(BoundY)(idx,2);
      
      % Beware of xD>>Xlim(2) (can block left move due to threshold
      % in getVertexMotionConstraint)
      Xlim = get(ax,'Xlim');
      if xD>Xlim(2)
         xD = Xlim(2);
         yD = interp1(c.(BoundX)(idx,:),c.(BoundY)(idx,:),xD);
      end
      
      % Determine range of allowable X motion
      Xrange = [xA,xD];
      x0 = c.(BoundX)(idx,1);
      dx = max(abs(Xrange-x0));
      if strcmp(BoundType(1),'L')
         % Use top vertex to determine vertex motion constraints
         y0 = max(yB,yC);
      else
         y0 = min(yB,yC);
      end
      % Find constraints tmin<=t<=tmax on edge motion x=x0+t
      trange = [...
         getVertexMotionConstraint(c,x0,y0,dx,0,BoundType,Xrange);...
         getEdgeMotionConstraint(c,xA,yA,xB,yB,dx,0,BoundType,Xrange);...
         getEdgeMotionConstraint(c,xD,yD,xC,yC,dx,0,BoundType,Xrange)];
      Xrange = x0 + dx * [max(trange(:,1)),min(trange(:,2))];
      
      % Take over window button functions
      wbfs = get(Figure,{'WindowButtonUpFcn','WindowButtonMotionFcn'});
      set(Figure,'Pointer','left',...
         'WindowButtonUpFcn',{@LocalBDF  this 'finish'},...
         'WindowButtonMotionFcn',{@LocalBDF this 'move'});

      % Start transaction
      Transaction = ctrluis.transaction(c,'Name','Horizontal Move',...
         'OperationStore','on','InverseOperationStore','on','Compression','on');

   case 'move'
      % Mouse Motion Callback
      newpt = get(ax,'CurrentPoint');         % Get Current point
      xnew = min(max(newpt(1),Xrange(1)),Xrange(2));
      c.(BoundX)(idx-1,2) = xnew;
      c.(BoundX)(idx,1) = xnew;
      % Refresh plot
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
%%%%%%%%%%%
% LOCALBDF
%%%%%%%%%%%
function LocalBDF(evsrc,evdata,this,Phase)
LineBDF(this,Phase)