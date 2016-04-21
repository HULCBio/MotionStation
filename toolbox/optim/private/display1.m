function varargout = display1(flag,varargin)
% DISPLAY1 displays progress information during optimization.
%   FIGTR =  DISPLAY1('init',itbnd,tol,showstat,nbnds,x,g,l,u)
%   does the initialization of the windows.
%
%   DISPLAY1('progress',it,csnrm,val,pcgit,npcg,degen,bndfeas,...
%                     showstat,nbnds,x,g,l,u,figtr,posdef,linfeas)
%   displays the current values.
%
%	DISPLAY1('final',figtr,figps) displays end of optimization messages.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/02/01 22:09:22 $

switch flag
case 'progress'
   displayProgress(varargin{:});
case 'init'
   varargout{1} = displayInit(varargin{:});
case 'final'
   displayFinal(varargin{:});
otherwise
   error('optim:display1:InvalidFlag', ...
         'Invalid string used for FLAG argument to DISPLAY1.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayProgress(it,csnrm,val,pcgit,npcg,degen,bndfeas,...
   showstat,nbnds,x,g,l,u,figtr,posdef,linfeas)
%DISPLAYPROGRESS displays current values of several parameters.
%
%   DISPLAYPROGRESS(it,csnrm,val,pcgit,npcg,degen,bndfeas,...
%                     showstat,nbnds,x,g,l,u,figtr,posdef,linfeas)
%   displays current values of several parameters after the Progress
%   information window has already been created.
%


%
if nargin < 6, degen = -1; end
if nargin < 7, bndfeas = inf; end
if isempty(bndfeas), bndfeas = inf; end
if nargin < 15, posdef = []; end
if nargin < 16, linfeas = -1; end 
if isempty(linfeas), linfeas = -1; end
lastParam = [] ;
if degen >= 0
   lastParam = str2mat(lastParam, ...
      sprintf(' Degeneracy measure = %-6.2e',degen)); 
end
if bndfeas < inf
   lastParam = str2mat(lastParam, ...
      sprintf(' Feasibility wrt bounds = %-6.2e',bndfeas));
end
if posdef > 0
   lastParam = str2mat(lastParam, ...
      sprintf(' Curvature: Positive')) ;
elseif posdef <= 0
   lastParam = str2mat(lastParam, ...
      sprintf(' Curvature: Negative')) ;
end ;
if linfeas >= 0
   lastParam = str2mat(lastParam, ...
      sprintf(' Feasibility wrt linear equalities = %-6.2e',linfeas));
end ;
if ~isempty(lastParam)
   lastParam(1,:) = [] ; 
end 
figure(figtr) ;
ParamTitl = str2mat('', ...
   sprintf(' Iteration =  %-4.0f',it), ...
   sprintf(' First-order optimality accuracy = %-6.2e',csnrm), ...
   sprintf(' Objective function value =   %-12.10e',val), ...
   sprintf(' CG iterations  = %-5.0f',pcgit), ...
   sprintf(' Total CG iterations to date = %-7.0f',npcg), ...
   lastParam) ;
ParamTitlHndl = findobj(figtr,'type','uicontrol',...
   'Userdata','Report Progress') ;
set(ParamTitlHndl,'String',ParamTitl) ;
drawnow 

% Write the same thing to the log file
% temporarily disable this feature
if 0
   logfile = fopen('lsot.log','at') ;
   fprintf(logfile,'\n\n***********************************************************\n') ;
   fprintf(logfile,[ParamTitl';10*ones(1,size(ParamTitl,1))]) ;
   fclose(logfile) ;
end

if (showstat >=3 & nbnds)
   figure(figtr) ; 
   xtrack(x,g,l,u); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function figtr =  displayInit(itbnd,tol,showstat,nbnds,x,g,l,u)
%DISPLAYINIT Display initial parameter values. 
%
%   figtr =  DISPLAYINIT(itbnd,tol,showstat,nbnds,x,g,l,u)
%   sets the layout for LSOT Progress Information figure.
%


%
if (nbnds & showstat >= 3 )
   
   % Produce Large figure window
   
   figtr = findobj('Type','figure','Name','Progress Information') ;
   
   % Have to check if it has the right size, for that purpose see 
   % how many axes there are.
   if ~isempty(figtr) 
      axx = findobj(figtr,'type','axes') ;
      if sum(size(axx)) < 4 % is small
         close(figtr) ;
         figtr = [] ;
      end ;
   end ;
   
   if isempty(figtr)
      
      screensize = get(0,'ScreenSize') ;
      xpos = floor((screensize(3) - 950)/2) ;
      ypos = floor((screensize(4) - 520)/2) ;
      
      figtr=figure( ...
         'NumberTitle','off', ...        
         'Name', 'Progress Information', ...
         'position',[xpos ypos 950 520]);
      
      set(figtr,'DefaultAxesPosition',[.1 .45 .8 .5]) ;
      
      uicontrol(figtr,...
         'Style','frame',...
         'Units','normalized',...
         'Position',[.74 .04 .17 .22],...
         'Value',0,...
         'Userdata','LSOT frame');
      uicontrol(figtr,...
         'Style','text', ...
         'Units','normalized', ...
         'Position',[.75 .15 .15 .1], ...
         'Userdata','lsotlabel',...
         'String', 'RUNNING');
      uicontrol(figtr, ...
         'Style','pushbutton',...
         'Units','Normalized',...
         'Position',[.75 .05 .15 .1],...
         'String','STOP Execution',...
         'Userdata','stop button',...
         'Callback', ...
         'set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);') ;
      
      
      
      xtrack(x,g,l,u,'init');
      ParamTitlHdln = uicontrol( ...
         'HorizontalAlignment','left',...
         'Style','text', ...
         'Max',10,...
         'Units','normalized', ...
         'Position',[0.1 0.05 0.36 0.30], ...
         'UserData','Report Progress');
   %            'Position',[0.1 0.05 0.36 0.35], ...

   else
      
      figure(figtr) ;
      set(findobj(figtr,'Userdata','LSOT frame'),'Value',0) ;
      set(findobj(figtr,'Userdata','lsotlabel'),'String','RUNNING') ;
      set(findobj(figtr,'Userdata','stop button'), ...
         'String','STOP Execution',...
         'Callback', ...
         'set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);');
      ParamTitlHdln = findobj(figtr,'Userdata','Report Progress');
      
      % Erase the axes and start the plots again
      n = length(x) ;
      delete(findobj(figtr,'type','axes')) ;
      xtrack(x,g,l,u,'init') ;
   end ;
else
   
   % Produce small figure window
   
   figtr = findobj('Type','figure','Name','Progress Information') ;
   % Have to check if it has the right size, for that purpose see 
   % how many axes there are.
   if ~isempty(figtr) 
      axx = findobj(figtr,'type','axes') ;
      if sum(size(axx)) >= 4 % is big
         close(figtr) ;
         figtr = [] ;
      end ;
   end ;
   if isempty(figtr)
      % Have to create the whole figure
      
      screensize = get(0,'ScreenSize') ;
      xpos = floor((screensize(3) - 360)/2) ;
      ypos = floor((screensize(4) - 300)/2) ;
      
      figtr=figure( ...
         'NumberTitle','off', ...        
         'Name', 'Progress Information', ...
         'position',[xpos ypos 360 300]);
      
      
      uicontrol(figtr,...
         'Style','frame',...
         'Units','normalized',...
         'Position',[.25 .05 .5 .21],...
         'Value',0,...
         'Userdata','LSOT frame');
      uicontrol(figtr,...
         'Style','text', ...
         'Units','normalized', ...
         'Position',[.26 .16 .48 .1], ...
         'Userdata','lsotlabel',...
         'String', 'RUNNING');
      uicontrol(figtr, ...
         'Style','pushbutton',...
         'Units','Normalized',...
         'Position',[.26 .06 .48 .1],...
         'String','STOP Execution',...
         'Userdata','stop button',...
         'Callback','set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);') ;
      
      %   'HorizontalAlignment','left',...
      ParamTitlHdln = uicontrol( ...
         'Style','text',...
         'Max',10, ...
         'Units','normalized', ...
         'Position',[0 0.3 1 .7], ...
         'Background',[.0 .0 .0], ...
         'Foreground',[1 1 1],...
         'UserData','Report Progress');
      
   else
      figure(figtr) ;
      set(findobj(figtr,'Userdata','LSOT frame'),'Value',0) ;
      set(findobj(figtr,'Userdata','lsotlabel'),'String','RUNNING') ;
      set(findobj(figtr,'Userdata','stop button'),...
         'String','STOP Execution',...
         'Callback',...
         'set(findobj(gcf,''Userdata'',''LSOT frame''),''Value'',1);') ;
      ParamTitlHdln = findobj(figtr,'Userdata','Report Progress');
   end 
end
ParamTitl = str2mat([], ...
   sprintf(' Effective dimension of problem = %-4.0f', ...
   length(x)), ...
   sprintf(' Maximum number of iterations = %-4.0f', ...
   itbnd), ...
   sprintf(' Termination Tolerance =  %-6.2e',tol), ...
   sprintf(' Output display level =   %-4.0f',showstat)) ;
set(ParamTitlHdln,'String',ParamTitl) ;

% Create log file and write the same thing to it
% temporarily disable this feature
if 0
   logfile = fopen('lsot.log','wt') ;
   clk = clock ;
   fprintf(logfile,'** LSOT log file. Produced %d-%d-%d at %d:%d:%d \n\n',...
      clk(2:3),clk(1),clk(4:5),floor(clk(6))) ;
   fprintf(logfile,'***********************************************************') ;
   fprintf(logfile,'\n************************LSOT BEGINS************************') ;
   fprintf(logfile,'\n***********************************************************\n') ;
   fprintf(logfile,[ParamTitl';10*ones(1,size(ParamTitl,1))]) ;
   fclose(logfile) ;
end
drawnow ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayFinal(figtr,figps)
%DISPLAYFINAL Final output and cleanup.
%
%	DISPLAYFINAL(figtr,figps) displays end-of-the-line notification.
%


if nargin < 2, figps = [] ;
end ;

figtr = findobj('type','figure','Name','Progress Information') ;

if ~isempty(figtr)
   set(findobj(figtr,'Userdata','lsotlabel'),'String','DONE') ;
   
   callbackstr = ['figtr = findobj(''type'',''figure'',',...
         '''Name'',''Algorithm Performance Statistics'') ;', ...
         'figps = findobj(''type'',''figure'',',...
         '''Name'', ''Progress Information'') ;', ...
         'close([figtr, figps])'] ;
   
   set(findobj(figtr,'Userdata','stop button'),...
      'String','Close optimization windows',...
      'Callback',callbackstr) ;
   
end ;

% disable this feature
if 0
   logfile = fopen('lsot.log','at') ;
   fprintf(logfile,'\n***********************************************************\n') ;
   fprintf(logfile,'*************************LSOT ENDS*************************\n') ;
   fprintf(logfile,'***********************************************************') ;
end 

%['figtr = findobj(''type'',''figure'',''Name'', ''Algorithm Performance Statistics'') ;', ...
%                   'figps = findobj(''type'',''figure'',''Name'', ''Progress Information'') ;', ...
%                    'close([figtr, figps])']);




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
