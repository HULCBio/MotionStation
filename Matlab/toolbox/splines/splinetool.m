function splinetool(x,y)
%SPLINETOOL Spline approximation experimentation tool (GUI).
%
%   SPLINETOOL prompts you for some data sites and data values to fit and
%   lets you do this in various ways.
%   One of the choices is to provide your own data, in which case both
%   the sites and values can be expressions that evaluate to vectors required 
%   to be of the same length > 1.
%   You can also specify the values by providing the name of a function whose 
%   values at the sites are to be used as data values.
%   You can also provide the name of an M-file (like 'titanium') whose 
%   two-argument output provides numerical values for sites and values.
%   The other choices provide specific sample sites and values to illustrate 
%   various aspects of the GUI.
%
%   SPLINETOOL(X,Y) uses the input data sites X and data values Y, and these
%   must be numerical vectors of the same length > 1. The data sites need not
%   be distinct nor ordered.
%
%   Example:
%      x = linspace(1,pi,101); y = cos(x)+(rand(size(x))-.5)/10;
%      splinetool(x,y)
%   might start an interesting experimentation with noisy data.
%
%   See also CSAPI, CSAPS, SPAPS, SPAP2, SPAPI.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.38 $  $Date: 2003/04/25 21:12:41 $

updated = '15feb03'; testing = 0;
abouttext = {'Spline Toolbox 3.2'; ...
            'Copyright 1987-2003 C. de Boor and The MathWorks, Inc.'};

if nargin<1  % import data

   action = 'start';

else
   if ischar(x)
      action = x;  hand = get(gcbf,'Userdata');
      if isstruct(hand)&&isfield(hand,'currentline')
         hc = hand.currentline; % make available, for use with changes
      end

   else % check and sort the given data
      [x,y] = chckxy(x,y);
      xname = 'x'; yname = 'y';
      isf = 0;
      action = 'start';
   end
end

switch action

case 'add_item'    % add an item

   switch get(hand.data_etc,'Value')
   case 1
      [xx,yy] = ask_for_add(hand);
      x = get(hand.dataline,'Xdata');
      if xx<x(1)||xx>x(end)
         warndlg(['For simplicity, the Spline Tool will let you only', ...
	           ' add interior data sites.'], ...
             'The end data sites are forever','modal')
      elseif get(hand.method,'Value')==4&&~isempty(find(x==xx))
         warndlg(['Since SPAPI would interpret repeated data sites',...
          ' as a request for osculatory interpolation, the Spline Tool',...
	  ' won''t let you create repeated data sites now.'], ...
	  'Repeated data sites', 'modal');
      else
         set(hand.undo,'Enable','on')
         insert_and_mark(x,get(hand.dataline,'Ydata'),xx,yy,hand)
         undoud = get(hand.undo,'Userdata');
         undoud.lineud = get(hand.nameline,'Userdata');
         set(hand.undo,'Userdata',undoud);

         get_approx(hand)
      end
      if isequal(get(hand.undo,'Enable'),'off')
         V = get(hand.params(1,3),'Value');
         set(hand.params(2,3),'String',x(V))
         if isequal(get(hand.params(2,5),'Visible'),'on')
            y = get(hand.dataline,'Ydata');
            set(hand.params(2,5),'String',y(V))
         end
      end

   case 2
      switch get(hand.method,'Value')
      case 3
         xx = ask_for_add(hand);
         lineud = get(hand.nameline,'Userdata');
         [lineud.knots,i] = sort([lineud.knots,xx]);
         placed = find(i==length(lineud.knots));
         if placed==1||placed==length(lineud.knots)
            warndlg('The Spline Tool will only let you add interior knots.',...
                'The end knots are forever','modal')
            lineud.knots(placed)=[];
            set(hand.nameline,'Userdata',lineud)
            set(hand.params(2,4),'String', ...
            lineud.knots(get(hand.params(1,4),'Value')))

         else
            set(hand.params(1,4),'String',lineud.knots(:),'Value', placed)
            lineud = update(hand,'knots',lineud);
            lineud.kc(end+1) = ...
                  addchange(hc,['knots = sort([knots,',num2str(xx,15),']);',...
                  ' %% you added a knot']);
            set(hand.nameline,'Userdata',lineud)
            % update knots display
	    set(hand.buttonm,'Visible','on')
            markb(hand), set_bdisplay(lineud.knots,hand)

            get_approx(hand)
         end
      end %switch get(hand.method,'Value')
   case 3

   end %switch get(hand.data_etc,'Value')

case 'align'  % make sure the left and right data list are aligned
   % at present, this serves no function, but sits here in case clicking 
   % anywhere on a list box activates a callback
   tag = get(gcbo,'Tag');
   if tag(5)=='l', j=3; else j=5; end
   set(hand.params(1,8-j),'Value',get(hand.params(1,j),'Value'))

case 'axesclick'  % action when the axes is clicked

   % protect against clicks on Print Figure window:
   if isempty(hand), return, end
   % only react here to LEFT clicks
   tmp = get(hand.figure,'SelectionType');
   if tmp(1)=='n'

      % get the location of the latest click in data coordinates:
      clickp = get(hand.Axes(1),'CurrentPoint');

      switch get(hand.data_etc,'Value')
      case {1,3} % highlight the nearest data point
         highlightn(clickp,hand)

      case 2
         switch get(hand.method,'Value')
         case {1,3,4}

            % find the nearest break
            breaks = str2num(get(hand.params(1,4),'String'));
            [ignored,V]=min(abs(breaks(:)-repmat(clickp(1),length(breaks),1)));
            if get(hand.params(1,4),'Value')~=V
               set(hand.params(1,4),'Value',V), markb(hand)
            end
         case 2
            highlightn(clickp,hand)

         end %switch get(hand.method,'Value')

      end %switch get(hand.data_etc,'Value')
   end %if tmp(1)=='n'

case 'change_name' % change the name of the current spline

   names = get_names(get(hand.list_names,'String'));
   V = get(hand.list_names,'Value');
   oldname = names(V,:);  oldname = oldname(6:end);
   answer = inputdlg('Give a (valid MATLAB variable) name for the current spline:',...
    'Please provide a new name for the current spline ...', 1,...
     {deblank(oldname)});
   if isempty(answer)||strcmp(answer{:},oldname), return, end
   name = full_name(answer{1},hand);
   hand.name = name; hand.dbname = deblank(name);
   set(hand.figure,'Userdata',hand)
   if get(hand.ask_show,'Value')==1
      names(V,:) = ['v || ',name];
   else
      names(V,:) = ['  || ',name];
   end
   set(hand.list_names,'String',{names})
   lineud = update(hand,'fit');
   if isfield(lineud,'kc')
      lineud.kc(end+1) = addchange(hc, ...
           [hand.dbname,' = ',deblank(oldname),'; %% you changed the name']);
   end
   lineud.bottom = [' ',hand.dbname, ...
                   lineud.bottom(findstr(' =',lineud.bottom(1:14)):end)];
   set(hand.bottomlinetext, 'String',lineud.bottom)
   set(hand.nameline,'Tag',name,'Userdata',lineud)
   set_view_label(name,hand)
   if names(V,1)=='v'
      legend(hand.Axes(1),'off'), set_legend(hand,hand.Axes(1))
   end

case 'change_order' % call_back from the order selector in approximation field

   M = get(hand.method,'Value');
   switch M

   case 2 % we are smoothing, hence now must change the edit fields
      set_edits(2,2,hand)

   case {3,4}
      lineud = update(hand,'knots');
      lineud.k = get(hand.order,'Value');
      if M==3  % we are doing least-squares
         lineud.knots = augknt(lineud.knots,lineud.k);
         lineud.kc(end+1) = ...
               addchange(hc,['knots = augknt(knots,',num2str(lineud.k),');',...
                  ' %% you changed the order']);
      else     % we are doing interpolation
         [lineud.knots,lineud.k] = aptknt(get(hand.dataline,'Xdata'),lineud.k);
      end
      if get(hand.data_etc,'Value')==2  %  need to update the knot display
         set(hand.params(1,4),'String',lineud.knots(:),'Value',1+lineud.k)
         markb(hand), set_bdisplay(lineud.knots,hand)
      end
      set(hand.nameline,'Userdata',lineud)

   end %switch M

   get_approx(hand)

case {'close','exit','finish','quit'} % terminate splinetool

   answer = questdlg('Do you really want to quit the SPLINE TOOL?', ...
                     'Do you want to quit?','OK','Cancel','OK');
   if isempty(answer)||answer(1)=='C', return, end
   splinetool 'closefile'

case 'closefile' % close splinetool without further ado

   delete(findobj('Tag','Spline Tool Example Message Box'))
   delete(findobj(allchild(0),'name','Spline Tool'))

case 'data_etc'  % callback from 'data_etc' to set up for present edit choice

   if nargin>1  hand = y; end
   % start clean
   set([reshape(hand.params(:,3:5),15,1); hand.buttonm; hand.piecem; ...
        hand.piecetext; ...
        hand.highlightxy;hand.highlightb;hand.breaks(:);hand.rep_knot(:); ...
        hand.add_item(:);hand.del_item(:)], 'Visible','off')
   set(hand.breaks(:),'Userdata','off')
   set(hand.undo,'Enable','off')

   switch get(hand.data_etc,'Value')
   case 1  % turn on the data display
      set(hand.add_item,'Label','&Add Point ...','Visible','on')
      set(hand.del_item,'Label','&Delete Point','Visible','on')
      set(get(hand.Axes(1),'Children'),'UIContextMenu',hand.context)
      x = get(hand.dataline,'Xdata');
      set(hand.params(1,3),'String',x, ...
         'Visible','on', ...
         'Backgroundcolor',[1 1 1], ...
         'Callback','splinetool ''highlightxy''', ...
         'TooltipString', ...
        'mark a point, for editing below (same as leftclick on point in graph)')
      set(hand.params(2,3),'String',x(1),'Visible','on')
      set(hand.params([3 5],3), 'Visible','on')
      set(hand.params(4,3),'Visible','on','Value',0)
      if ~get(hand.params(4,3),'Value')
        set(hand.params(4,3),'String',(x(end)-x(1))/(10*length(x)))
      end

      y = get(hand.dataline,'Ydata');
      if get(hand.dataline,'Userdata')
         set(hand.params(1,5),'String',y,'Visible','on', ...
            'Backgroundcolor',.9*[1 1 1], ...
            'Callback','splinetool ''highlightxy''', ...
            'TooltipString','')
      else
         set(hand.params(1,5),'String',y, 'Visible','on', ...
            'Backgroundcolor',[1 1 1], ...
            'Callback','splinetool ''highlightxy''', ...
            'TooltipString', ...
        'mark a point, for editing below (same as leftclick on point in graph)')
         set(hand.params(2,5),'String',y(1),'Visible','on')
         set(hand.params([3 5],5), 'Visible','on')
         set(hand.params(4,5),'Visible','on','Value',0)
         if ~get(hand.params(4,5),'Value')
           set(hand.params(4,5),'String',(max(y)-min(y))/(10*length(y)))
         end
      end %if get(hand.dataline,'Userdata')
      set(hand.highlightxy,'Visible','on')
      markxy(hand) % also sets the editclkr field

   case 2
      M = get(hand.method,'Value');
      switch M
      case 1   % turn on the breaks display on the middle
         set(get(hand.Axes(1),'Children'),'UIContextMenu',[])
         lineud = get(hand.nameline,'Userdata');
         breaks = fnbrk(lineud.cs,'breaks');
         set(hand.params(1,4),'String',breaks(:), ...
         'Visible','on', ...
         'TooltipString','mark a break', ...
         'Callback','splinetool ''highlightb''')
         set_bdisplay(breaks,hand), markb(hand)
         set(hand.highlightb,'Visible','on')

      case 2   % turn on the sites/weight display
         set(get(hand.Axes(1),'Children'),'UIContextMenu',[])
         set(hand.params(1,3),'String',get(hand.dataline,'Xdata'), ...
            'Visible','on', ...
            'Backgroundcolor',.9*[1 1 1], ...
            'Callback','splinetool ''highlightxy''', ...
            'TooltipString','')
         lineud = get(hand.nameline,'Userdata');
         set(hand.params(1,5),'String',lineud.w(:), ...
            'Visible','on', ...
            'Enable','on', ...
            'Backgroundcolor',[1 1 1], ...
            'Callback','splinetool ''highlightw''', ...
            'TooltipString','mark a weight, for editing below')
         set(hand.params(2,5),'String',lineud.w(1),'Visible','on')
         set([hand.highlightxy;hand.params([3 5],5)], ...
            'Visible','on')
         set(hand.params(4,5),'Visible','on','Value',0,'String',.1)

         markxy(hand)

      case {3,4}  % turn on the knots display in the middle
         lineud = get(hand.nameline,'Userdata');
         knots = fnbrk(lineud.cs,'knots'); npk = length(knots);
         set(hand.params(1,4),'String',knots(:), ...
            'Visible','on', ...
            'TooltipString', ...
            'mark a knot, for editing below (same as a leftclick in graph)',...
            'Callback','splinetool ''highlightb''', ...
            'Value',1+lineud.k)
         markb(hand), set_bdisplay(knots,hand)
         if M==3
            set(get(hand.Axes(1),'Children'),'UIContextMenu',hand.context)
            set(hand.add_item,'Label','&Add Knot','Visible','on')
            set(hand.del_item,'Label','&Delete Knot','Visible','on')
            set(hand.rep_knot,'Visible','on')
                % show the newknt button and piecem window
            set([hand.piecem,hand.piecetext],'Visible','on')
	    if npk>2*lineud.k %  if there are interior knots ...
               set(hand.buttonm,'Visible','on')
	    end
         end
         set([hand.highlightb;hand.params([2,3,5],4)],'Visible','on')
         set(hand.params(4,4),'Visible','on','Value',0)
         if ~get(hand.params(4,4),'Value')
            set(hand.params(4,4), ...
             'String',(knots(end)-knots(1))/(10*length(knots)))
         end

      end %switch M

   case 3 %  so far, these concern a weight display

      set(get(hand.Axes(1),'Children'),'UIContextMenu',[])
      set(hand.params(1,3),'String',get(hand.dataline,'Xdata'), ...
         'Visible','on', ...
         'Backgroundcolor',.9*[1 1 1], ...
         'Callback','splinetool ''highlightxy''', ...
         'TooltipString','')
      lineud = get(hand.nameline,'Userdata');
      set([hand.highlightxy; hand.params([2 3 5],5)], 'Visible','on')
      set(hand.params(4,5),'Visible','on','Value',0,'String',.1)

      switch get(hand.method,'Value')

      case 2 % turn on the sites/jump in weights display
         tols = lineud.tol;
         if length(tols)==1
            nx = length(get(hand.dataline,'Xdata'));
            tols = [tols,ones(1,nx-1)];
            lineud.tol = tols;
            lineud.tc(1) = addchange(hand.currentline, ...
                     ['dlam = [1,zeros(1,',num2str(nx-2),')];',...
               ' %% roughness weight starts off uniform']);
            set(hand.nameline,'Userdata',lineud)
         end
         tols = [tols(2),diff(tols(2:end)),NaN];

         set(hand.params(1,5),'String',tols, ...
            'Visible','on', ...
            'Enable','on', ...
            'Backgroundcolor',[1 1 1], ...
            'Callback','splinetool ''highlightw''', ...
            'TooltipString', ...
                ['mark a jump in roughness weight, for editing below'])

      case 3 % turn on the sites/weight display
         set(hand.params(1,5),'String',lineud.w(:), ...
            'Visible','on', ...
            'Enable','on', ...
            'Backgroundcolor',[1 1 1], ...
            'Callback','splinetool ''highlightw''', ...
            'TooltipString','mark a weight, for editing below')
      end %switch get(hand.method,'Value')

      markxy(hand) % also sets the editclkr field

   end %switch get(hand.data_etc,'Value')

case 'del' % delete the current spline

   % the Value in list_names points to the current spline in that list
   listud = get(hand.list_names,'Userdata');
   V = get(hand.list_names,'Value');
   names = get_names(get(hand.list_names,'String'));

   % if this is the first or second time this session that the user deletes
   % the only spline, issue a warning, with a chance to cancel.
   if size(names,1)==1&&hand.freshstart 
      hand.freshstart = hand.freshstart-1;
      answer = questdlg(['Do you really want to delete the one remaining',...
                        ' approximation and start from scratch,',...
	                ' with the original data?'], ...
                     'Do you want to start from scratch?','OK','Cancel','OK');
      if isempty(answer)||answer(1)=='C', return, end
   end
   delete(listud.handles(V))
   listud.length = listud.length-1;
   listud.handles(V) = [];
   set(hand.list_names, ...
       'String',{names([1:V-1 V+1:end],:)}, ...
       'Value',max(1,min(V,listud.length)), ...
       'Userdata',listud);
   hand = set_current(hand);
   set_displays(hand)
   set_legend(hand,hand.Axes(1))

case 'del_item'    % delete the current item

   switch get(hand.data_etc,'Value')
   case 1
      V = get(hand.params(1,3),'Value');
      x = get(hand.dataline,'Xdata');
      if V==1||V==length(x)
         warndlg(['The Spline Tool won''t let you delete the extreme data',...
	          ' points.'], 'For simplicity, ...')
         return
      end %if V==1||V==length(x)

      y = get(hand.dataline,'Ydata'); x(V) = []; y(V) = [];

         % record the commands that effect the change:
      sV = num2str(V);
      cindex = addchange(hc, ['x(',sV,') = []; y(', ...
                        sV,') = []; %% you deleted a data point']);

      set(hand.params(1,3),'Value',min(V,length(x)))
      set(hand.params(1,5),'Value',min(V,length(y)));
      set(hand.undo,'Enable','on')
      set_data(hand,x,y)
      undoud = get(hand.undo,'Userdata');
      undoud.lineud = get(hand.nameline,'Userdata');
      set(hand.undo,'Userdata',undoud);
      lineud = get(hand.nameline,'Userdata');
         % update the weights, if any, and update data field
      if isfield(lineud,'w')
         if length(lineud.wc)==1 % we are using a standard weight;
             % simply let method 2 or 3 start the weight again
            lineud = rmfield(lineud,'w'); lineud.wc=[];
         else % we delete the corresponding weight
            lineud.w(V) = [];
            lineud.wc(end+1) = addchange(hc,['weights(',sV,')=[];', ...
              '%% delete the corresponding error weight entry']);
         end
      end
      if isfield(lineud,'tc')  % we have roughness weights in place
         temp = diff(lineud.tol(V:V+1));
         if temp
            lineud.tol(V) = temp/2;
         end
         lineud.tol(V+1) = [];
         lineud.tc(end+1) = addchange(hc,[...
            'if dlam(',sV,')\n',...
            '   dlam(',sV,'-1) = dlam(',sV,'-1) + dlam(',sV,')/2;\n',...
            '   dlam(',sV,'+1) = dlam(',sV,'+1) + dlam(',sV,')/2;\n',...
            'end, dlam(',sV,') = [];', ...
            '%% distribute the corresponding jump in the roughness', ...
            '  weight']);
      end
      if lineud.method==4
         lineud = rmfield(lineud,'knots'); lineud.kc = [];
      end
      lineud.dc(end+1) = cindex;
      set(hand.nameline,'Userdata',lineud);
      set(hand.data_etc,'Userdata',cindex);
      get_approx(hand)
      set(hand.highlightxy,'Xdata',[get(hand.highlightxy,'Xdata'),x(V)], ...
                           'Ydata',[get(hand.highlightxy,'Ydata'),y(V)])
   case 2
      V = get(hand.params(1,4),'Value');
      lineud = get(hand.nameline,'Userdata'); npk = length(lineud.knots);
      if V<=lineud.k||V>npk-lineud.k
         warndlg('The Spline Tool won''t let you delete an end knot.', ...
	          'The end knots are forever')
      else
         lineud.knots(V)=[];
         lineud = update(hand,'knots',lineud);
         lineud.kc(end+1) = addchange(hc, ['knots(',num2str(V),') = [];',...
                ' %% you deleted a knot']);

         tmp = get(hand.params(1,4),'String'); tmp(V,:)=[];
         set(hand.params(1,4),'String',tmp)
         set(hand.params(1,4),'Value',min(V,npk-lineud.k));
         set(hand.nameline,'Userdata',lineud)
	 if length(lineud.knots)<=2*lineud.k
	    set(hand.buttonm,'Visible','off')
	 end
         markb(hand), set_bdisplay(lineud.knots,hand)

         get_approx(hand)

      end

   end %switch get(hand.data_etc,'Value')

case 'export_data'

   xname = 'x'; yname = 'y'; accepted = 0;
   while ~accepted
      answer = inputdlg({...
       sprintf(['To copy the current data to the base workspace,\n', ...
        'give a name for the data sites:']),...
        '... and a name for the data values:'},...
        'Copy data to workspace', 1,{xname;yname});
      if ~isempty(answer)
         okx = okvar(answer{1}); oky = okvar(answer{2});
         if okx, xname = answer{1}; end
         if oky, yname = answer{2}; end
         if okx&&oky, accepted = 1; end
      else, break
      end
   end

   if accepted
      assignin('base',xname, get(hand.dataline','Xdata'));
      assignin('base',yname, get(hand.dataline','Ydata'));
      fprintf(['Splinetool GUI created the variables ',xname,', ',yname, ...
               ' in the current workspace.\n'])

   %      workspace -refresh
   %      % needed now to make certain the workspace browser gets updated,
   %      % but this may be fixed soon.
   end

case 'export_spline'

   % namewob = hand.name; namewob(find(namewob==' '))=[];
   namewob = hand.dbname;
   accepted = 0;
   while ~accepted
      answer = inputdlg(sprintf(...
               ['To copy the current spline to the base workspace,\n', ...
               'give a name for the spline:']), ...
               'Copy spline to workspace',1,{namewob});
      if isempty(answer), return, end
      if okvar(answer{1}), namewob = answer{1}; accepted = 1; end
   end

   lineud = get(hand.nameline,'Userdata');
   assignin('base',answer{1}, lineud.cs)
   fprintf(['Splinetool GUI created the variable ',answer{1},...
            ' in the current workspace.\n'])

case 'ginputmove'
   pt = get(gca,'CurrentPoint');
   xlim = get(gca,'Xlim');
   if xlim(1)<=pt(1,1) && pt(1,1)<=xlim(2)
      set(hand(1),'String',pt(1,1))
      if length(hand)>1, set(hand(2),'String',pt(1,2)), end
   end

case 'ginputdone'
    set(gcbf,'WindowButtonMotionFcn','','WindowButtonDownFcn','',...
         'Pointer','arrow');

case 'help'
   titlestring = ['Explanation: ',y];
   switch y

   case 'about the GUI'
      mess =...
      {'';['The GUI is meant for experimentation with some basic spline',...
       ' approximation methods: interpolation, smoothing, and least-',...
       'squares.'];
       ['To the left of the graph, there are three blocks:'];
       ['The TOPmost block manages the various spline approximations:',...
       ' start a new one, replicate or delete the current one',...
       ' or change its name, choose which one to be current and',...
       ' whether it is to be shown in the graph.'];
       ['The MIDDLE one is for choosing the method and its parameters.', ...
       ' It also may let you look at the 1st/2nd derivatives of',...
       ' the current approximation at the interval endpoints.'];
       ['The THIRD block is for listing and modifying the data, breaks,',...
       ' knots, and weights. Additional editing is provided by',...
       ' right-clicking on the graph.']
       ['An optional second graph, showing either the first or the second', ...
       ' derivative or else the error of the',...
       ' current approximation, is managed from the View Menu.'];
       ['The ''Bottomline'' shows the spline toolbox command that generated',...
       ' the current approximation.'];
       ['All technical terms used in the GUI are defined in the', ...
       ' Explanations, accessible from the Help Menu.'];
       [repmat('     ',1,11), '(as of ' updated,')']};

   case 'cubic spline interpolation'
      mess = concat(spterms(y), ...
    {'Click on the popuplist below the Methods popuplist to see the many end conditions available here.';
 'They are further explained elsewhere in these Explanations.';
  ['A good example to try them out on is the default for choosing one''s',...
  ' own data.']});

   case 'endconditions' % end conditions
   mess = ...
   {['A good example for comparing the various endconditions is provided',...
     ' by the default choice, x = linspace(0,2*pi,31), y = cos, when',...
     ' choosing your own data.']};

   case 'Customized'
   mess = ...
   {'At each end, one may specify the first or the second derivative.'};

   case 'least squares'
   mess = concat(spterms(y), ...
    {['In SPAP2, hence in this GUI, the default for the weight vector',...
   '  w  is  ones(size(x)) .']}); 

   case 'cubic smoothing spline'
      mess = concat(spterms(y), ...
  {'';['In this GUI, the default value for the weight  w  in the error',...
  ' measure is the one used in SPAPS; it makes the error measure the',...
  ' trapezoidal rule approximation to  integral (y(t) - s(t))^2 dt .']; 
['Since it is usually hard to specify  p , the GUI provides',...
' Reinsch''s alternative of specifying a TOLERANCE tol,',...
' in which case  s  minimizes the roughness measure subject to having',...
' the error measure <= tol.']});

   case 'quintic smoothing spline'
      mess = {...
   ['The QUINTIC smoothing spline differs from the cubic smoothing spline',...
   ' only in that its roughness measure involves the 3rd rather than the',...
   ' 2nd derivative. Correspondingly, it is a spline of order 6 rather than',...
   ' of order 4.'];'';...
   ['In the Spline Toolbox, the quintic smoothing spline is provided by',...
   ' the command  spaps . The level of desired smoothness is specified',...
   ' indirectly, by specifying a certain tolerance, and the command',...
   ' returns the smoothest spline within that tolerance of the given data.']};

   case 'weight in roughness measure'
      mess = ...
  {'The roughness of a cubic spline  f  is measured here by the number';''; ...
  '              integral  lambda(t) [(D^2 f)(t)]^2 dt';'';...
  ['with  lambda  a piecewise constant function with breaks at the data',...
  ' sites (and nowhere else). The default for  lambda  is the constant',...
  ' function, 1 .']; ...
  ['To specify  lambda , provide, for  i=2:n,  its value  lam(i-1)  on the', ...
  ' interval  (x_{i-1} .. x_i). In calling on csaps, this is done by', ...
  ' giving the input  p  as the n-vector [smoothing parameter, lam], while',...
  ' for spaps, one gives the input  tol  as the n-vector ',...
  ' [tolerance, lam].']; ...
  ['Since  lambda  typically has only very few jumps, I have chosen to',...
 ' let you specify  lambda  in the GUI  by providing  dlam := diff([0,lam])',...
  ' (a vector with mostly zero entries), from which I then recover lam', ...
  ' as cumsum(dlam).'];'';
  ['All that changes here for a QUINTIC spline is that its third rather',...
  ' than its second derivative appears in the roughness measure.', ...
  ' In other words, the quintic smoothing spline favors a slowly varying',...
  ' second derivative, while the cubic smoothing spline favors a',...
  ' slowly varying first derivative.']};

   case 'spline'
   mess = concat(spterms(y), ...
     {'';['In this GUI, a SPLINE of ORDER  k  with KNOT SEQUENCE'];
      [' t = ( t(1),...,t(n+k) ) is any weighted sum of the  n '];
      ['  B-splines  B( . | t(i:i+k) ) , i=1:n .'];
      '';
      'A spline written as such a weighted sum is said to be in B-FORM.'}); 

   case 'about'
      titlestring = 'About the Spline Toolbox';
      mess = abouttext;

   otherwise
      mess = spterms(y);
   end %switch y

   msgbox(mess,titlestring)

case 'highlightb'
      markb(hand)

case 'highlightw'   % mark a weight (and the corresponding point)

      V = get(hand.params(1,5),'Value'); set(hand.params(1,3),'Value',V);
      markxy(hand)
      tmp = get(hand.params(1,5),'String');
      set(hand.params(2,5),'String',tmp(V,:))

case 'highlightxy' % highight the marked item
      markxy(hand)

case 'increment'   % convert expression to a value, checking validity

   tag = get(gcbo,'Tag');
   j = find('telmr'==tag(end));
   output = convert(hand.params(4,j),0);
   if ischar(output)
      set(hand.params(4,j),'String', ...
         shortstr(abs(eval(get(hand.params(2,j),'String')))/10,1))
      return
   else
       set(hand.params(4,j),'String',shortstr(output,1),'Value',1)
   end

case 'labels'  % change Xlabel and/or Ylabel

   reset_labels(hand,[]);

case 'make_current'
   hand = set_current(hand);
   set_displays(hand)
   for j=1:2, set_tools(hand,j,get(hand.tool(j),'Checked')), end

case 'method' % set things up for a particular method

   method(hand)

case 'move_item'     % move an item to the position suggested by its editbox

   switch get(hand.data_etc,'Value')
   case 1
      move_point(hand)
   case 2
      switch get(hand.method,'Value')
      case 2
        change_weight(hand)
      case {3,4}
        if ~move_knot(hand), return, end
        get_approx(hand)
      end % switch get(hand.method,'Value')
   case 3
      switch get(hand.method,'Value')
      case 2
        get_approx(hand)
      case 3
        change_weight(hand)
      end %switch get(hand.method,'Value')
   end %switch get(hand.data_etc,'Value')

case 'new' % start a new spline fit, using the not-a-knot end conditions

   new(hand);

case 'newknt' % redo the knot sequence according to the current approximation

   get_approx(hand)

case 'parameters'     % change to the newly specified parameters

   parameters(hand)

case 'pieces' % use the number of pieces specified

   get_approx(hand)

case 'pm'  % one of the increment/decrement guys has been clicked

   handle = gcbo; tag = get(handle,'Tag');
   % find out whether to increment or decrement, ...
   pm = '+';  if tag(1)=='m', pm = '-'; end

   % ... then change the numerical value of its edit field accordingly ...
   j = find('telmr'==tag(end));
   set(hand.params(2,j),'String', eval([get(hand.params(2,j),'String'),pm, ...
      get(hand.params(4,j),'String')]));

   % ... and invoke its callback
   eval(get(hand.params(2,j),'Callback'))

case 'print_graph'  % preserve current graphs as separate figure

   printfig = figure('Toolbar','figure',...
    'numbertitle','off',  ...
    'toolbar','figure', ...
    'HandleVisibility','off', ...
    'name',['Spline Tool graph (at ',showtime,')']);
   curcontext = get(hand.Axes(1),'UIContextMenu');
   set(get(hand.Axes(1),'Children'),'UIContextMenu',[])
   copyobj(hand.Axes(1), printfig);
   set(get(hand.Axes(1),'Children'),'UIContextMenu',curcontext)
   if any(get(hand.viewmenu,'Userdata'))
      set(findobj(printfig,'Tag','Axes1'), ...
        'ButtonDownFcn','', ...
        'Position',[ 0.1300    0.4900    0.7750    0.4650], ...
        'UIContextMenu',[])
      copyobj(hand.Axes(2),printfig);
      set(findobj(printfig,'Tag','Axes2'), ...
        'ButtonDownFcn','', ...
        'Position',[ 0.1300    0.1300    0.7750    0.3100])
   else
      set(findobj(printfig,'Tag','Axes1'), ...
       'ButtonDownFcn','', ...
       'Position',[ 0.1300    0.2600    0.7750    0.6950], ...
       'UIContextMenu',[])
   end
   set_legend(hand,findobj(printfig,'Tag','Axes1'))

case 'rep' % start a new spline as a replica of the current spline

   % set up a new line as current line, updating the list
   oldnameline = hand.nameline;
   [currentname, hand.nameline] = add_to_list(hand);
   dboldname = hand.dbname; hand.name = currentname;
   hand.dbname = deblank(currentname); set(gcbf,'Userdata',hand)

   % copy the stuff from the old current line to the new line
   lineud = get(oldnameline,'Userdata');
   if lineud.method==3|| ...
      (lineud.method==4&&isfield(lineud,'kc'))
                     % put latest fit into knot calculations, just in case
      lineud = update(hand,'fit',lineud);
      lineud.kc(end+1) = addchange(hc, ...
                          [hand.dbname,' = ',dboldname,'; ', ...
                         '%% replicate the current approximation']);
   end
      % change the bottom line to the new name (looks strange if most recent
      %    fit used newknt )
   lineud.bottom = [' ', hand.dbname, ...
                    lineud.bottom(findstr(' =',lineud.bottom(1:14)):end)];
   set(hand.bottomlinetext, 'String',lineud.bottom)
   set(hand.nameline, ...
      'Xdata',get(oldnameline,'Xdata'),...
      'Ydata',get(oldnameline,'Ydata'),...
      'Userdata',lineud);

   % no need to update endconds, model, rest of display, except for
   set_view_label(currentname,hand)
   set_legend(hand,hand.Axes(1))
  
case 'rep_knot' % replicate the marked knot

   switch get(hand.method,'Value')
   case 3
      V = get(hand.params(1,4),'Value');
      lineud = get(hand.nameline,'Userdata');
      index = find(lineud.knots==lineud.knots(V));
      if length(index)>=lineud.k
         warndlg(['There is no point in having knots of multiplicity',...
                   ' greater than the order of the spline.']), return
      end
      lineud.knots = lineud.knots([1:V,V:end]);
      lineud = update(hand,'knots',lineud);
      sV = num2str(V);
      lineud.kc(end+1) = addchange(hc, ...
                     ['knots = knots([1:',sV,',',sV,':end]);', ...
            ' %% you replicated a knot']);
      set(hand.nameline,'Userdata',lineud)
      set(hand.params(1,4),'String',lineud.knots(:), 'Value', V+1 )
      % update knots display
      markb(hand), set_bdisplay(lineud.knots,hand)

      get_approx(hand)

   end %switch get(hand.method,'Value')

case 'restart'

   switch get(gcbo,'Tag')
   case 'restart'
      answer = questdlg('Do you really want to restart the SPLINE TOOL?', ...
                     'Do you want to restart?','OK','Cancel','OK');
   case 'import_data'
      answer = questdlg(['Do you really want to delete the current ',...
            'approximation(s) and to start fresh, with new data?'], ...
                     'Do you want to start fresh?','OK','Cancel','OK');
   end
   if isempty(answer)||answer(1)=='C', return, end
   splinetool('closefile')
   splinetool

case 'save2mfile'

      % check whether any of the visible fits involves edited data or user-
      % supplied knots or weights
   names = get_names(get(hand.list_names,'String'));
   listud = get(hand.list_names,'Userdata');
   datachanged = 0; othermanual = 0;
   vv = find(names(:,1)=='v').';
   for v=vv
     lineud = get(listud.handles(v),'Userdata');
     if lineud.dc(end)~=0, datachanged = 1; end
     if (isfield(lineud,'kc')&&length(lineud.kc))|| ...
        (isfield(lineud,'tc')&&length(lineud.tc)>1)|| ...
        (isfield(lineud,'wc')&&length(lineud.wc)>1)
        othermanual = 1; end
   end

      % get a file name
   mfname = ''; coru = ''; curdir = pwd;
   if ~(curdir(end)==filesep), curdir = [curdir filesep]; end
   getfiletitle = 'Choose a Name for the M-File';
   while isempty(coru)
      [mfname,pn] = uiputfile([curdir mfname], getfiletitle);
      if isequal(mfname,0)||isequal(pn,0)
           % the user hit Cancel, so give up on this
         return
      else
         checked = 0;
         if length(mfname)>2&&isequal(mfname(end-1:end),'.m') 
            % strip off terminal .m
            mfname(end-1:end) = []; checked = 1; end
         if isvarname(mfname) % if a valid name, check whether it is taken
            fullfilename = [pn mfname,'.m'];
            if ~exist(fullfilename, 'file')
	       coru = 'cre';
            else
	       if checked
	          anss = 'Yes';
               else	
                  anss = questdlg(['The M-file  ',fullfilename, ...
                   '  already exists. Ok to overwrite?'], ...
                     'M-file already exists ...', 'No','Yes','No');
	       end
               if isequal(anss,'Yes')
	          coru = 'upd';
	       end
            end
         else
	    temp = errordlg(['The filename, ',mfname, ...
	         ', you chose is not valid.'], 'Try again ...');
            getfiletitle = 'Choose  V A L I D  MATLAB Name for the M-File';
	    waitfor(temp)
         end
      end
   end

      % start the file
   [mfid,mess] = fopen(fullfilename,'w+');
   if mfid==-1
      errordlg(sprintf('Error trying to write to %s:\n%n',fullfilename,mess),...
               'Error saving M-file','modal')
      return
   end

      % depending on whether or not changed data are involved, ...
   if datachanged, z = '0'; else, z = ''; end
   fprintf(mfid,['function ',mfname,'(x',z,',y',z,')\n', ...
    '%%', upper(mfname),'  Reconstruct figure in SPLINETOOL.\n%%\n',...
    '%%   ',upper(mfname),'(X',z,',Y',z,') creates a plot, similar ',...
                    'to the plot in SPLINETOOL,\n', ...
   '%%   using the data that you provide as input.\n',...
   '%%   You can apply this function to the same data you used with\n',...
   '%%   SPLINETOOL or with different data. You may want to edit the\n',...
   '%%   function to customize the code or even this help message.\n']);
   if datachanged||othermanual
      fprintf(mfid,['%%\n',...
   '%%   Because of data-dependent changes, this may not work for data\n',...
   '%%   sites other than the ones used in SPLINETOOL when this M-file\n',...
   '%%   was written.\n']);
   end
      % append the help

   if get(hand.dataline,'Userdata')
      fprintf(mfid, ['%%\n', ...
      '%%   SPLINETOOL was told to use the data values \n', ...
      '%%      y',z,' = feval(''',get(get(hand.Axes(1),'Ylabel'),'String'),...
                                                           ''',x',z,');\n',...
      '%%   for the given data sites x',z,...
                                    '. You may wish to do the same here.\n']);
   end

      % now start by plotting the data.

   V = get(hand.list_names,'Value');
   fprintf(mfid, ['\n%%   Make sure the data are in rows ...\n', ...
                   'x',z,' = x',z,'(:).''; y',z,' = y',z,'(:).'';\n', ...
                  '%% ... and start by plotting the data specific to the ', ...
                  'highlighted spline fit.\n\n']);
   if datachanged % we need to generate them
      fprintf(mfid,['x = x',z,'; y = y',z,';\n']);
         % get lineud.dc for current line
      lineud = get(listud.handles(V),'Userdata');
      changes = get(hc,'Userdata');
      for j=2:length(lineud.dc)
         fprintf(mfid,[changes{lineud.dc(j)},'\n']);
      end
   end

    % get ready to check on whether there is a second graph:
   viewud = get(hand.viewmenu,'Userdata'); ip = find(viewud==1); plotV = 1;

   if ~isempty(ip) % start first axes, dimensions almost those in SPLINETOOL
      fprintf(mfid,['firstbox = [0.1300  0.4900  0.7750  0.4850];\n',...
      'subplot(''Position'',firstbox)\n']);
   end
   fprintf(mfid, ['plot(x,y,''ok''), hold on\nnames={''data''};\n']);
      % also set the axes labels
   fprintf(mfid, ['ylabel(''', ...
       strrep(get(get(hand.Axes(1),'Ylabel'),'String'),'\','\\'),''')\n']);
   if isempty(ip) % there is no second graph, hence
      fprintf(mfid, ['xlabel(''', ...
       strrep(get(get(hand.Axes(1),'Xlabel'),'String'),'\','\\'),''')\n']);
   else           % suppress also the tick marks on the first graph
      fprintf(mfid,['xtick = get(gca,''Xtick'');\nset(gca,''xtick'',[])\n']);
   end

   switch length(vv)
   case 0
      fprintf(mfid,['\n%%  None of the fits you thought fit to print. \n\n']);
      % we still may have to compute the current fit, though:
      if ~isempty(ip), vv = [V]; plotV=0; end
   case 1
      fprintf(mfid,['\n%%   Now generate and plot the fit.\n\n']);
   otherwise
      fprintf(mfid,['\n%%   Now generate and plot the ', ...
                 num2str(length(vv)),' fits.\n\n']);
   end

      % loop over fits shown in graph, generating and plotting them, by
      % first concatenating all relevant change commands

   for v=vv
      lineud = get(listud.handles(v),'Userdata');
      if datachanged % we have to start with the original data
         fprintf(mfid, ['x = x0; y = y0;\n']);
      end
         % prepare optional arguments, if any
      setknots = 0; setweights = 0; settols = 0;
      switch lineud.method
      case 1
      case 2
         if ~isempty(findstr( '= cs',lineud.bottom(4:16) ))||...
            (isfield(lineud,'wc')&&length(lineud.wc)>1)
            setweights = 1;
         end
         if isfield(lineud,'tc')&&length(lineud.tc)>1, settols = 1; end
      case 3
         if isfield(lineud,'wc')&&length(lineud.wc)>1, setweights = 1; end
         if isfield(lineud,'kc')&&length(lineud.kc)>0, setknots = 1; end
      case 4
         if isfield(lineud,'kc')&&length(lineud.kc)>0, setknots = 1; end
      end
      ic = [];
      if isfield(lineud,'dc'),  ic = [ic,lineud.dc(2:end)]; end
      if setknots,              ic = [ic,lineud.kc]; end
      if setweights,            ic = [ic,lineud.wc]; end
      if settols,               ic = [ic,lineud.tc]; end

      changes = get(hc,'Userdata');
      for j=sort(ic)
         fprintf(mfid,[changes{j},'\n']);
      end

      bottom = lineud.bottom(2:end);
         % if there are no previous commands or if the last operation had to do 
         % with knots or weights, then we still have to construct the spline fit
      if isempty(ic)||~(setknots||setweights||settols)||...
         (setknots&& ...
            ~(isempty(findstr('\nknots =',changes{lineud.kc(end)}))&&...
              isempty(findstr('\nknots(', changes{lineud.kc(end)}))))||...
         (setweights&& ...
            ~(isempty(findstr('\nweights =',changes{lineud.wc(end)}))&&...
              isempty(findstr('\nweights(', changes{lineud.wc(end)}))))||...
         (settols&& ...
            ~(isempty(findstr('\ndlam =',changes{lineud.tc(end)}))&&...
              isempty(findstr('\ndlam(',changes{lineud.tc(end)}))))
	 fprintf(mfid, [overlong(strrep(bottom,'%','%%')),'\n']);
      end

         % get the name of the spline fit
      name = bottom(1:(findstr(' =', bottom(1:12))-1));
         % add the name to the list to be used in the legend
      if v~=V||plotV
        fprintf(mfid, ['names{end+1} = ''',strrep(name,'_','\\_'),'''; ']);
      end
         % plot the spline fit, making certain to highlight the current one
      if v==V
         if plotV
            fprintf(mfid, ['fnplt(',name,',''','-',''',2)\n\n\n']); end

      % if there is a second figure, plot it now since we have the data
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  code insert
   if ~isempty(ip)
           %start second axes, dimensions exactly those in SPLINETOOL
      addon = '\n\n'; if V~=vv(end)
         addon = [' now, while we have the data current',addon];
      end
      fprintf(mfid, ...
       ['%%   Plot the second graph from SPLINETOOL',addon, ...
        'subplot(''Position'',[ 0.1300  0.1300  0.7750  0.3100])\n']);

      lineud = get(hand.nameline,'Userdata');
      switch ip
      case 1
         fprintf(mfid,['fnplt(fnder(',hand.dbname,'),2)\n']);
      case 2
         fprintf(mfid,['fnplt(fnder(',hand.dbname,',2),2)\n']);
      case 3
         fprintf(mfid, ['plot(xtick([1 end]),zeros(1,2),',...
            '''Linewidth'',2,''Color'',repmat(.6,1,3))\nhold on\n']);
         if get(hand.dataline,'Userdata') % if we compare against a given f
            fprintf(mfid, ['%% we are comparing the approximation,', ...
            ' not with the data,\n%% but with a given function\n',...
            'xy = fnplt(',hand.dbname,');\nplot(xy(1,:),feval(''', ...
            get(get(hand.Axes(1),'Ylabel'),'String'),''',xy(1,:))', ...
                '-xy(2,:),''Linewidth'',2)\n']);
         else
            fprintf(mfid,['plot(x,y-fnval(',hand.dbname, ...
                                         ',x),''Linewidth'',2)\n']);
         end
         fprintf(mfid,'hold off\n');
      end %switch ip
      fprintf(mfid, ['ylabel(''', ...
          strrep(get(get(hand.Axes(2),'Ylabel'),'String'),'\','\\'),''')\n', ...
                     'xlabel(''', ...
          strrep(get(get(hand.Axes(2),'Xlabel'),'String'),'\','\\'),''')\n', ...
        '\n\n%%   Return to plotting the first graph\n', ...
        'subplot(''Position'', firstbox)\n\n\n']);
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  end code insert
      else
         fprintf(mfid, ['fnplt(',name,...
                ',''',get(listud.handles(v),'linestyle'),'k'')\n\n\n']);
      end
   end

      % also put in the legend
   fprintf(mfid, ['legend(names{:})\nhold off\n', ...
                 'set(gcf,''NextPlot'',''replace'')\n']);

      % finish the m-file and close it.
   fclose(mfid);
   fprintf(['Splinetool GUI ',coru,'ated the M-file  ',mfname,...
                '  in the directory ',strrep(pn(1:end-1),'\','\\'),'\n']);

case 'start'

   running = findobj(allchild(0),'name','Spline Tool');
   if ~isempty(running)
      ignore = 1;
      if nargin
         answer = questdlg(['Do you really want to restart the SPLINE TOOL',...
             ' with new data?'], ...
	     'Do you want to restart?','OK','Cancel','OK');
         if isequal(answer,'OK'), splinetool 'closefile', ignore = 0; end
      end
      if ignore, figure(running), return, end
   end

   load splinetool

   % the basic figure
   hand.figure = figure('Colormap',mat0, ...
	'FileName','splinetool.m', ...
	'PaperUnits','normalized', ...
        'PaperPosition',[.25 .10 .6 .75], ...
        'Units','normalized', ...
        'Position',[.25 .10 .6 .75], ...
     'numbertitle','off', ...
     'IntegerHandle','off',...
     'name','Spline Tool', ...
	'Tag','splinetoolfig', ...
        'doublebuffer','on', ...
        'DeleteFcn','splinetool ''closefile''', ...
     'Menubar','none', ...
	'ToolBar','none');

   if nargin<1 % if there are no data yet, ask for some:
      
      set_up_menu
   else

      set(hand.figure,'Visible','off')
      hand.xynames = {x,xname,y,yname,isf};
      splinetool('startfinish',hand)
   end

case 'startcont'

   cf = hand{1}; handles = hand{2};
   hand = struct('figure',cf);
   messtitle = 'The point of this example: ';
   isf = 0; errortit = 'Error in input to the SPLINE TOOL';
   try
         % now call on my own version of the menu command
          %'Specify an m-file that provides the data', ...
       % Note that any error now, in whatever function is being called,
       % such as ask_for_data with the possibility of incorrrect function
       % or M-file names being supplied, will result in the immediate
       % termination, with the only comment the ones, if any, in the catch
       % phase.
       switch y
       case 1 % user provides data
          [x,y,xname,yname,isf] = ask_for_data;
       case 3 % noisy values of a smooth function
          x = linspace(0,2*pi,101); y = sin(x)+(rand(size(x))-.5)*.2;
	  hand.messh = ...
	  {{'The error in the spline fits is computed by comparison with';...
	    'the values of the sine function';...
	    '(rather than with the given data values).'}, ...
            messtitle, 'non-modal'};
        xname = 'x= linspace(0,2*pi,101)'; yname = 'sin'; isf = 2;
       case 4 % sin(x) on [0 .. pi/2]
          x = linspace(0,pi/2,31); y = sin(x);
          xname = 'x = linspace(0,pi/2,31)'; yname = 'sin'; isf = 2;
          hand.messh = ...
	  {{'Experiment with the various end conditions in';...
	    'Cubic Spline Interpolation. Be sure to compare';...
	    '''natural'' with ''clamped'' and ''not-a-knot''.';...
	    'For clamping, note that slope of sin at right end is 0.'}, ...
            messtitle, 'non-modal'};
       case 5 % census data, taken from the matlab demo CENSUS
	  load census
          x = cdate; y = pop;
          xname = 'year'; yname = 'population';
          hand.messh = ...
	  {{'This standard MATLAB data set describes the United States';...
	    'population as a function of time. After you have constructed';...
	    'a satisfactory spline approximation to this data set,';...
	    'export it to the workspace in order to evaluate it';...
	    'at the current year and so to wonder whether such';...
	    'extrapolation is sensible.'}, ...
            messtitle, 'non-modal'};
       case 6 % Richard Tapia's drag race data;
              % try to estimate the initial acceleration
          x = [ 0.000 0.857 2.142 3.074 3.862 4.4052 4.544];
          y = [ 0 60 330 660 1000 1254 1320];
          xname = 'time in seconds'; yname = 'distance in feet';
          hand.messh = ...
          {{'Estimate the initial acceleration.'; ...
            'One way: use a clamped cubic spline'; ...
            'and take the initial speed to be 0.'}, ...
            messtitle, 'non-modal'};
       case 7 % move knots to improve an interpolant
          [x,y] = titanium; pick =  [1 5 11 21 27 29 31 33 35 40 45 49];
          x = x(pick); y = y(pick);
	  xname = 'temperature'; yname = 'titanium property';
	  hand.messh = ...
	  {{'Spline Interpolation (rather than Cubic Spline Interpolation)';...
	    'on these data does not do a very good job.';...
	    'Try moving the third and the last interior knots a little bit';...
	    'to straighten out the interpolant.'}, ...
            messtitle, 'non-modal'};

       otherwise
          [x,y] = titanium; xname = 'temperature'; yname = 'titanium property';
          hand.messh = ...
	  {{'Because of the sharp peak, this data set has become a';...
	    'standard challenge to those who would want a satisfactory';...
         'least squares approximation for it with just 5 interior knots.'}, ...
            messtitle, 'non-modal'};
       end %switch menu'Choose some data to work on with the';
    catch
       cf = findobj(allchild(0),'name','Spline Tool');
       if ~isempty(cf)
          errordlg({['Something went wrong during input, as indicated', ...
	            ' by the following error message:'];lasterr},errortit)
          close(cf)
       end
       return
    end %try

    if ~exist('x','var')
       errordlg('Data sites are not defined.',errortit), return, end
    if ~exist('y','var')
       errordlg('Data values are not defined.',errortit), return, end
    if length(x)~=length(y)
      errordlg('Sites and values must be vectors of the same length',errortit)
       return
    end

    if isf<0 % the user hit Cancel (in case 1), so we try again
       set(cf,'Userdata',{cf,handles})
    else % if nothing went wrong, remove the menu and go to finish
       delete(handles)
       set(hand.figure,'Visible','off')
       hand.xynames = {x,xname,y,yname,isf};
       splinetool('startfinish',hand)
    end

case 'startfinish' % finish the rest of the gui figure:

   hand = y; 
   [x,xname,y,yname,isf] = deal(hand.xynames{:});
   hand = rmfield(hand,'xynames');

   backgrey = repmat(0.752941176470588,1,3);
   breakcolor =  backgrey*.8; % would have liked just backgrey
   currentcolor = [0 0 1];
   highcolor =  [1 1 1];
   framecolor = get(hand.figure,'Color');
   units = 'normalized';

    %  make up your own menubar items:
    h1 = uimenu(hand.figure,'Label','&File','Tag','file');
    h2 = uimenu(h1,'Label','&Restart', ...
         'Callback','splinetool ''restart''', ...
         'Tag','restart');
    h2 = uimenu(h1,'Label','&Import Data ...', ...
         'Callback','splinetool ''restart''', ...
         'Separator','on',...
         'Tag','import_data');
    h2 = uimenu(h1,'Label','Export &Data ...', ...
         'Callback','splinetool ''export_data''', ...
         'Separator','on',...
         'Tag','export_data');
    h2 = uimenu(h1,'Label','Export &Spline ...', ...
         'Callback','splinetool ''export_spline''', ...
         'Tag','export_spline');
    h2 = uimenu(h1,'Label','Save &M-file ...', ...
         'Callback','splinetool ''save2mfile''', ...
         'Tag','save2mfile');
    h2 = uimenu(h1,'Label','&Print to Figure', ...
         'Callback','splinetool ''print_graph''', ...
         'Separator','on',...
         'Tag','print_graph');
    h2 = uimenu(h1,'Label','&Close', 'Callback', 'splinetool ''finish''', ...
         'Separator','on',...
         'Tag','exit');
    h1 =  uimenu(hand.figure,'Label','&Edit',...
         'Tag','editmenu');
    hand.editmenu = h1;
    hand.undo = uimenu(h1,'Label','&Undo','Userdata',[], 'Enable','off' ,...
                   'Callback','splinetool ''undo''','Tag','undo');
    hand.add_item = uimenu(h1,'Label','&Add', ...
         'Callback', 'splinetool ''add_item''', ...
         'Tag','add_item');
    hand.rep_knot = uimenu(h1,'Label','&Replicate Knot', ...
                   'Callback','splinetool ''rep_knot''','Tag','rep_knot');
    hand.del_item = uimenu(h1,'Label','&Delete', ...
         'Callback','splinetool ''del_item''',...
         'Tag','del_item');
    hlab = uimenu(h1,'Label','&Labels ...', 'Callback', ...
                     'splinetool ''labels''', 'Tag','labels');
    viewud = [0 0 0];
    h1 = uimenu(hand.figure,'Label','&View','Userdata',viewud, ...
                   'Tag','viewmenu');
    hand.view(1) = uimenu(h1,'Label','Show &1st Derivative', ...
                                    'Callback','splinetool ''view''', ...
                    'Tag','1view');
    hand.view(2) = uimenu(h1,'Label','Show &2nd Derivative', ...
                                    'Callback','splinetool ''view''', ...
                    'Tag','2view');
    hand.view(3) = uimenu(h1,'Label','Show &Error', ...
                                    'Callback','splinetool ''view''', ...
                    'Tag','3view');
    hand.viewmenu = h1;
    h1 = uimenu(hand.figure,'Label','&Tools', 'Tag','toolmenu');
    hand.tool(1) = uimenu(h1,'Label','Show &Grid', ...
                                    'Callback','splinetool ''tool''', ...
                    'Tag','1tool');
    hand.tool(2) = uimenu(h1,'Label','Show &Legend', ...
                                    'Callback','splinetool ''tool''', ...
		    'Checked','on', 'Tag','2tool');
    hand.toolmenu = h1;
    h1 = uimenu(hand.figure,'Label','&Help');
    h2 = uimenu(h1,'Label','Splinetool &Help', ...
                           'Callback','doc splines/splinetool');
    h2 = uimenu(h1,'Label','Quick &Overview',...
                             'Callback','splinetool(''help'',''about the GUI'')');
    h2 = uimenu(h1,'Label','&Explanation of Terms','Tag','help');
    h3 = uimenu(h2,'Label','&B-spline',...
                                'Callback','splinetool(''help'',''B-spline'')');
    h3 = uimenu(h2,'Label','B&asic interval',...
                           'Callback','splinetool(''help'',''basic interval'')');
   h3 = uimenu(h2,'Label','B&reaks','Callback','splinetool(''help'',''breaks'')');
    h3 = uimenu(h2,'Label','&Error', 'Callback', ...
                         'splinetool(''help'',''error'')');
     h3 =  uimenu(h2,'Label','&Forms');
     h4 = uimenu(h3,'Label','&B-form', ...
                                    'Callback','splinetool(''help'',''B-form'')');
     h4 = uimenu(h3,'Label','&ppform', ...
                                    'Callback','splinetool(''help'',''ppform'')');
    h3 =  uimenu(h2,'Label','&Interpolation');
     h4 = uimenu(h3,'Label','&Cubic Spline Interpolation', ...
               'Callback','splinetool(''help'',''cubic spline interpolation'')');
     h4 = uimenu(h3,'Label','&End Conditions');
      uimenu(h4,'Label','&remark', ...
                             'Callback','splinetool(''help'',''endconditions'')')
      uimenu(h4,'Label','&not-a-knot', ...
                                'Callback','splinetool(''help'',''not-a-knot'')')
      uimenu(h4,'Label','&clamped or complete', ...
                                    'Callback','splinetool(''help'',''clamped'')')
      uimenu(h4,'Label','&second', ...
                                    'Callback','splinetool(''help'',''second'')')
      uimenu(h4,'Label','&periodic', ...
                                   'Callback','splinetool(''help'',''periodic'')')
      uimenu(h4,'Label','&variational or ''natural''', ...
                               'Callback','splinetool(''help'',''variational'')')
      uimenu(h4,'Label','&Lagrange', ...
                                   'Callback','splinetool(''help'',''Lagrange'')')
      uimenu(h4,'Label','''C&ustomized''', ...
                                 'Callback','splinetool(''help'',''Customized'')')
     h4 = uimenu(h3,'Label','&Spline Interpolation', ...
               'Callback','splinetool(''help'',''spline interpolation'')');

    h3 = uimenu(h2,'Label','&Knots');
     uimenu(h3,'Label','&End Knots', ...
                                'Callback','splinetool(''help'',''end knots'')')
     uimenu(h3,'Label','&Interior Knots',...
                           'Callback','splinetool(''help'',''interior knots'')')
    h4 = uimenu(h3,'Label','&Knots','Callback','splinetool(''help'',''knots'')');
    h3 = uimenu(h2,'Label','&Least-Squares', ...
                           'Callback','splinetool(''help'',''least squares'')');

      uimenu(h2,'Label','&Order', 'Callback','splinetool(''help'',''order'')')
    h3 = uimenu(h2,'Label','&Schoenberg-Whitney Conditions', ...
         'Callback','splinetool(''help'',''Schoenberg-Whitney conditions'')');

    h3 = uimenu(h2,'Label','Sites and &Values', ....
                        'Callback','splinetool(''help'',''sites_etc'')');
    h3 =  uimenu(h2,'Label','S&moothing');
      uimenu(h3,'Label','&Cubic Smoothing Spline', 'Callback', ...
                             'splinetool(''help'',''cubic smoothing spline'')')
      uimenu(h3,'Label','&Quintic Smoothing Spline', 'Callback', ...
                            'splinetool(''help'',''quintic smoothing spline'')')
      uimenu(h3,'Label','&Error', 'Callback', ...
                         'splinetool(''help'',''error'')')
      uimenu(h3,'Label','&Roughness Measure', 'Callback', ...
                         'splinetool(''help'',''roughness measure'')')
      uimenu(h3,'Label','&Weight in Roughness Measure', 'Callback', ...
                         'splinetool(''help'',''weight in roughness measure'')')
   h3 = uimenu(h2,'Label','S&pline','Callback','splinetool(''help'',''spline'')');
    h2 = uimenu(h1,'Label','&Spline Toolbox Help', ...
                           'Separator','on', ...
                           'Callback','doc splines/');
    h2 = uimenu(h1,'Label','S&pline Toolbox', ...
                              'Callback','helpwin(''splines'')');
    h2 = uimenu(h1,'Label','&Demos', ...
                           'Callback','demo toolbox spline');
    h2 = uimenu(h1,'Label','&About',...
                           'Separator','on', ...
                           'Callback','splinetool(''help'',''about'')');

   % also provide a context menu, to be active in data mode, and to provide
   % the same capability as the edit commands
   hand.context = uicontextmenu('Parent',hand.figure, ...
              'Position',[.35 .46], ...
              'Tag','context');
     hand.add_item(2) = copyobj(hand.add_item, hand.context);
     hand.rep_knot(2) = copyobj(hand.rep_knot, hand.context);
     hand.del_item(2) = copyobj(hand.del_item, hand.context);


   mat2 = [       0         0    1.0000
                  0    0.5000         0
             1.0000         0         0
                  0    0.7500    0.7500
             0.7500         0    0.7500
             0.7500    0.7500         0
             0.2500    0.2500    0.2500];
   xaxes = .35; dxaxes = .63;

   %%%%%%%%%%%%%%%%%%%%% the axes on which to draw derivatives and such
   hand.Axes(2) = axes('Parent',hand.figure, ...
   	'CameraUpVector',[0 1 0], ...
   	'CameraUpVectorMode','manual', ...
   	'Color',highcolor, ...
   	'ColorOrder', mat2, ...
   	'Position',[xaxes .11 dxaxes .316], ...
        'Visible','off', ...
   	'Tag','Axes2', ...
        'Fontsize',8, ...
	'Box','on', ...
        'ButtonDownFcn','splinetool ''axesclick''', ...
   	'XColor',[0 0 0], ...
   	'YColor',[0 0 0], ...
   	'ZColor',[0 0 0]);
         xlabel(xname), ylabel('')

   hand.zeroline = line('Xdata',[NaN NaN],'Ydata',[0 0], ...
        'Linewidth',1.5, ...
        'Color',breakcolor, ...
        'Visible','off', ...
        'Tag','zeroline');
   hand.viewline = line('Xdata',NaN,'Ydata',NaN, ...
        'Color',currentcolor, ...
        'Linewidth',2, ...
        'erasemode','normal', ...
        'Tag','viewline');
    % put break/knot lines (also) on second graphic
   hand.breaks(2) = line('Xdata',NaN, 'Ydata',NaN,...
              'Linewidth',1.5, ...
              'erasemode','normal', ...
              'Color',breakcolor, ...
              'visible','off', ...
              'Userdata','off', ...
              'ButtonDownFcn', 'splinetool ''axesclick''', ...
              'Tag','breaks');

   %%%%%%%%%%%%%%%%%%%%% axes on which to draw data and approximations
   hand.Axes(1) = axes('Parent',hand.figure, ...
   	'CameraUpVector',[0 1 0], ...
        'CameraUpVectorMode','manual', ...
   	'Color',highcolor, ...
   	'ColorOrder', mat2, ...
        'Units', units, ...
   	'Position',[xaxes 0.47 dxaxes 0.497], ...
   	'Tag','Axes1', ...
        'Fontsize',8, ...
	'Box','on', ...
        'ButtonDownFcn','splinetool ''axesclick''', ...
        'UIContextMenu',hand.context, ...
   	'XColor',[0 0 0], ...
   	'YColor',[0 0 0], ...
   	'ZColor',[0 0 0]);
        xlabel(xname), ylabel(yname)

   %%%%%%%%%%%%%%%%%%  set up bottom line for showing toolbox commands used:
   hand.bottomlinetext = uicontrol('Parent',hand.figure, ...
   	'BackgroundColor',highcolor, ...
   	'ListboxTop',0, ...
   	'Units',units, ...
   	'Position',[.124 .003 .876 .046], ...
   	'Style','text', ...
        'HorizontalAlignment','left', ...
        'TooltipString', 'shows toolbox command used', ...
   	'Tag','bottomlinetext');

   uicontrol('Parent',hand.figure, ...
      'BackgroundColor',framecolor, ...
      'ListboxTop',0, ...
      'Units',units, ...
      'Position',[.014 .023 .10 .026], ...
      'String',' Bottomline:', ...
      'Style','text')

   %  %%%%%%%%%%%%%%%%%%%%%%%%%%%  the spline/name manager
        mmpos = [.015 .77-.007, .101, .18]; marg = .008;
   uicontrol('Parent',hand.figure, ...
        'BackgroundColor',framecolor, ...
        'Units',units, ...
        'Position',[mmpos(1:2)-marg,.25+2*marg,mmpos(4)+3.5*marg], ...
        'Style','frame', ...
        'Tag','nameframe')
   uicontrol('Parent',hand.figure, ...
        'BackgroundColor',framecolor, ...
         'Units',units, ...
         'Position',[mmpos(1)+.005, mmpos(2)+mmpos(4),.19, 4*marg], ...
         'HorizontalAlignment','left', ...
         'String','List of approximations', ...
         'Style','text')

   sl = .032; rw = .15;
   lnpx = rw-sl; lnpy = mmpos(2); wc = .09; ww = lnpx-mmpos(1);
        wh = .045; ph = 3*wh;
   hand.ask_show = uicontrol('Parent',hand.figure, ...
   	'ListboxTop',0, ...
   	'Units',units, ...
   	'Position',[lnpx+.002 lnpy rw wh], ...
   	'Style','checkbox', ...
        'String','shown in graph', ...
        'Callback', 'splinetool ''toggle_show''', ...
        'TooltipString', 'Show current spline in graph?', ...
   	'Tag','ask_show');

   % list of names
   listud.handles = []; listud.length=0; listud.untitleds=0;
   hand.list_names = uicontrol('Parent',hand.figure, ...
   	'BackgroundColor',highcolor, ...
   	'Units',units, ...
   	'Position',[lnpx lnpy+wh rw ph], ...
   	'String',{''}, ...
   	'Style','listbox', ...
   	'Tag','list_names', ...
        'Callback','splinetool ''make_current''', ...
        'TooltipString', 'choose the current spline', ...
        'Userdata',listud, ...
   	'Value',1);
        %'Fontname','FixedWidth', ...
        %'Fontsize',6,...
     %%%%%%%%%%%%%  Pushbutton NEW : start another curve with the default fit
   h1 = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
   	'ListboxTop',0, ...
   	'Position',[mmpos(1),mmpos(2)+3*wh,ww wh], ...
   	'String','New', ...
        'TooltipString', 'start a new spline, with the original data', ...
        'Callback','splinetool ''new''', ...
   	'Tag','Pushnew');
     %%%%%%%%%%%%%  Pushbutton REP : start another curve, a copy of current one
   h1 = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
   	'ListboxTop',0, ...
   	'Position',[mmpos(1),mmpos(2)+2*wh,ww wh], ...
   	'String','Replicate', ...
        'TooltipString', 'replicate the current spline and data', ...
        'Callback','splinetool ''rep''', ...
   	'Tag','Pushrep');
     %%%%%%%%%%%%%  Pushbutton DEL : delete the current curve
   h1 = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
   	'ListboxTop',0, ...
   	'Position',[mmpos(1),mmpos(2)+wh,ww wh], ...
   	'String','Delete', ...
        'TooltipString', 'delete the current spline', ...
        'Callback','splinetool ''del''', ...
   	'Tag','Pushdel');
     %%%%%%%%%%%%%  Pushbutton RENAME : rename current spline
  hand.ask_name = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
   	'Position',[mmpos(1),mmpos(2),ww wh], ...
        'String','Rename ...', ...
        'Callback', 'splinetool ''change_name''', ...
        'TooltipString', 'change the name of the current spline', ...
   	'Tag','ask_name');

  %%%%%%%%%%%%%%%%%%%%%%%%%%%  the method manager
   topy = mmpos(2)-.07; edy = .0013; wh = .036;
   mpx = mmpos(1); mpy = topy-wh; mw=.25;
   bottomy = mpy-4*(wh+edy)-.03;
   uicontrol('Parent',hand.figure, ...
        'BackgroundColor',framecolor, ...
        'Units',units, ...
        'Position',[[mpx,bottomy]-marg,mw+2*marg,topy-bottomy+3.5*marg], ...
        'Style','frame', ...
        'Tag','nameframe')
  uicontrol('Parent',hand.figure, ...
        'BackgroundColor',framecolor, ...
         'Units',units, ...
         'Position',[mmpos(1)+.005, topy,.19, 4*marg], ...
         'HorizontalAlignment','left', ...
         'String','Approximation method', ...
         'Style','text')
  hand.method = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
   	'BackgroundColor',highcolor, ...
   	'ListboxTop',0, ...
   	'Position',[mpx mpy mw wh], ...
   	'HorizontalAlignment','center', ...
   	'Style','popupmenu', ...
    	'String',{'Cubic Spline Interpolation';
                  'Smoothing Spline';
                  'Least-Squares Approximation';
                  'Spline Interpolation'}, ...
        'Callback','splinetool ''method''', ...
        'TooltipString', 'choose a method', ...
   	'Tag','method', ...
        'Interruptible','off', ...
        'Enable', 'on', ...
   	'Value',1);

   %%%%%%%%%%%%%%%%%%%%%%%%%  additional parameters
        ew = .12;
   hand.endtext = uicontrol('Parent',hand.figure, ...
        'Style','text', ...
   	'Units',units, ...
   	'Position',[mpx mpy-wh-4*edy-.007 ew wh], ...
   	'BackgroundColor',framecolor, ...
        'String','End conditions:', ...
   	'Tag','endtext')   ;
        %'FontName','CourierNew', ...
        %'Fontsize',8, ...

                 %%%%%%%%%%%  ... for cubic spline interpolation
   hand.endconds = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
   	'BackgroundColor',highcolor, ...
   	'ListboxTop',0, ...
   	'Position',[mpx+(mw-ew) mpy-wh-4*edy ew wh], ...
   	'String',{'not-a-knot';'clamped';'complete';'second';'periodic'; ...
                     'variational';'''natural''';'Lagrange';'Custom'}, ...
   	'Style','popupmenu', ...
        'Callback','splinetool ''parameters''', ...
        'TooltipString', 'choose end conditions', ...
           'Visible','off', ...
   	'Tag','endconds', ...
   	'Value',1);

                 %%%%%%%%%%%  ... for everything else, we have order
    endpos = get(hand.endconds,'Position');
    currlist = {'1';'2';'3';'4';'5';'6';'7';'8';'9';'10';'11';'12';'13';'14'};
    hand.order = uicontrol('Parent',hand.figure, ...
         'BackgroundColor',highcolor, ...
         'Units',units, ...
         'Position',get(hand.endconds,'Position'), ...
         'HorizontalAlignment','center',...
         'Style','popupmenu',...
         'String',currlist, ...
         'Callback','splinetool ''change_order''', ...
         'Userdata',currlist, ...
         'Value',4, ...
         'TooltipString','choose the order', ...
         'Visible','off','Tag','order');

              %%%%  set up the the remaining parameter display
     centerx = mpx+mw/2;  wid = mw/2;

     %%%%%%%%%%%%  left end toggle
   hand.partext(1,1) = uicontrol('Parent',hand.figure, ...
        'Units',units, ...
        'BackgroundColor',framecolor, ...
        'Position',[centerx-wid bottomy+3*(wh+edy)-.015 wid-.001 wh], ...
        'Style','text', ...
        'Visible','on', ...
        'String','left end');
   hand.partext(2,1) = copyobj(hand.partext(1,1),hand.figure);
   set(hand.partext(2,1), ...
        'Position',[centerx-wid bottomy+2*(wh+edy) wid-.001 wh], ...
        'Visible','off', ...
        'String','parameter')
   hand.params(1,1) = uicontrol('Parent',hand.figure, ...
        'Units',units, ...
        'ListboxTop',0, ...
        'Position',get(hand.partext(2,1),'Position'), ...
        'Userdata','pushend', ...
        'Tag','pushbuttonleft', ...
        'String','1st deriv.', ...
        'Callback', 'splinetool(''toggle_ends'',''left'')', ...
        'Value',1);
   hand.params(2:5,1) = ...
         clickable([centerx-wid,bottomy], wid, 'left','parameters','endconds');

     %%%%%%%%%%%%  rite end toggle
   hand.partext(1,2) = copyobj(hand.partext(1,1),hand.figure);
   set(hand.partext(1,2), ...
        'Position',[centerx+.001 bottomy+3*(wh+edy)-.015 wid-.001 wh], ...
        'String','right end')
   hand.partext(2,2) = copyobj(hand.partext(1,2),hand.figure);
   set(hand.partext(2,2), ...
        'Position',[centerx+.001 bottomy+2*(wh+edy) wid-.001 wh], ...
        'String','tolerance')
   hand.params(1,2) = copyobj(hand.params(1,1),hand.figure);
      set(hand.params(1,2), ...
        'Position',get(hand.partext(2,2),'Position'), ...
        'String','1st deriv.', ...
        'Callback', 'splinetool(''toggle_ends'',''rite'')', ...
        'Tag','pushbuttonrite')
   hand.params(2:5,2) = ...
            clickable([centerx,bottomy], wid, 'rite','parameters','endconds');
   set(hand.params(2:5,1:2),'Enable','off')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   popup re lists
   dkpx = mmpos(1); dkpy = .111; dkw=.125; dkh = .265;
   datatop = dkpy+dkh+.01+wh;
   databottom = dkpy+wh-(2*wh+.002);
   uicontrol('Parent',hand.figure, ...
        'BackgroundColor',framecolor, ...
        'Units',units,'Position', ...
        [[dkpx,databottom]-marg,2*(dkw+marg),(datatop-databottom)+3.5*marg], ...
        'Style','frame', ...
        'Tag','nameframe')
   uicontrol('Parent',hand.figure, ...
        'BackgroundColor',framecolor, ...
         'Units',units, ...
         'Position',[dkpx+.005, datatop,.25, 4*marg], ...
         'String','Data, breaks/knots, weights, ...', ...
         'HorizontalAlignment','left', ...
         'Style','text')


   hand.data_etc = uicontrol('Parent',hand.figure, ...
   	'Units',units, ...
        'Position',[dkpx dkpy+dkh+.01 2*dkw wh], ...
   	'BackgroundColor',highcolor, ...
   	'ListboxTop',0, ...
   	'HorizontalAlignment','left', ...
   	'Style','popupmenu', ...
        'Callback','splinetool ''data_etc''', ...
   	'Tag','data_etc', ...
        'Interruptible','off', ...
        'Enable', 'on', ...
   	'Value',1);
        %'Fontname','FixedWidth', ...
        %'FontUnits','Normalized','FontSize',.01, ...

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% also make the three lists and their
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% clickable and edit field, but keep
    %%%%%%%%%%%%%%%%%%%%%%%%%% them all invisible, to be turned on as needed

   poss = 'lmr'; shift = [0 0 1]*dkw;

   for j=3:5
      hand.params(1,j) = uicontrol('Parent',hand.figure, ...
         	'Units',units, ...
         	'BackgroundColor','w', ...
         	'Position',[dkpx+shift(j-2),dkpy+wh, dkw, dkh-wh], ...
         	'String',[], ...
         	'Style','listbox', ...
         	'Tag',['list',poss(j-2)], ...
              'Enable','on', ...
              'Visible','off', ...
              'Value',1);
	      %  'CallBack','splinetool ''align''', ...

      % put a clickable underneath:
      hand.params(2:5,j) = ...
                 clickable([dkpx+shift(j-2),databottom],dkw,...
                        ['clk',poss(j-2)],'move_item','listlmr');

      if j==4  % also provide a button to the right of the top:
         hand.buttonm = uicontrol('Parent',hand.figure, ...
           'Units',units, 'Position', ...
                [dkpx+shift(j-2)+dkw+.02,dkpy+dkh-wh-.001, .083, wh], ...
           'String','adjust', ...
           'Callback','splinetool ''newknt''', ...
           'TooltipString',...
	     'sometimes, this improves the interior knot distribution',...
           'Tag','buttonm', ...
           'Visible','off');
               % ... and show the number of pieces in an edit box:
         hand.piecem = uicontrol('Parent',hand.figure, ...
           'Backgroundcolor',highcolor, ...
           'Units',units, 'Position', ...
                   [dkpx+shift(j-2)+dkw+.028,databottom, .075, wh], ...
           'Style','edit', ...
           'String',' ', ...
           'Callback','splinetool ''pieces''', ...
           'TooltipString','choose the number of pol.pieces to use',...
           'Tag','piecem', ...
           'Visible','off');
               % ... and label that edit box:
          hand.piecetext = uicontrol('Parent',hand.figure, ...
           'BackgroundColor',framecolor, ...
           'Units',units, 'Position', ...
                get(hand.piecem,'Position')+[0,wh,0,0], ...
           'Style','text', ...
           'String','# pieces', ...
           'Tag','piecetext', ...
           'Visible','off');
         %% also remove the callback
	 % set(hand.params(1,4),'CallBack',[]) 
      end

   end %for j=3:5

   hand.highlightxy = line('Xdata',NaN, 'Ydata',NaN,...
              'Marker','o','Linestyle','none',...
              'Linewidth',3, ...
              'erasemode','normal', ...
              'Color','r', ...
              'Visible','off', ...
              'Tag','highlightxy');

   hand.breaks(1) = copyobj(hand.breaks(2),hand.Axes(1));
   hand.highlightb = line('Xdata',NaN, 'Ydata',NaN,...
              'Linewidth',2, ...
              'erasemode','normal', ...
              'Color','r', ...
              'visible','off', ...
              'Tag','highlightb');

   % set up the dataline and data display
   hand.dataline = line('Xdata',NaN,'Ydata',NaN,...
              'erasemode','normal', ...
              'Marker','o','Linestyle','none',...
              'ButtonDownFcn', 'splinetool ''axesclick''', ...
              'Userdata',isf, ...
              'Tag','dataline');
   set(hand.highlightxy,'Userdata',[x(:).'; y(:).'])

   hand.currentline = line('Xdata',NaN,'Ydata',NaN, ...
                 'linewidth',2, ...
                 'erasemode','normal', ...
                 'Color',currentcolor, ...
                 'ButtonDownFcn', 'splinetool ''axesclick''', ...
                 'Tag','currentline');
   
   hand = new(hand);
   hand.freshstart = 2; % needed when user deletes the only approximation
   view(hand.view(3),3,hand)
   set(hand.currentline,'Userdata',{}); % initialize changes array

   if testing, set(hand.figure, 'Userdata',hand)
   else set(hand.figure, 'HandleVisibility','callback','Userdata',hand)
   end

   set(hand.figure,'Visible','on')

   % if any data provided a special message, show it now:
   if isfield(hand,'messh')
      temp = msgbox(hand.messh{1},hand.messh{2},hand.messh{3});
      set(temp,'Tag','Spline Tool Example Message Box')
   end

case 'toggle_ends'  % toggle the left/rite endcondition button

   if strcmp(y,'left'), j=1; else j=2; end
   toggle_ends(j,hand);

case 'toggle_show'  % toggle whether the current spline is plotted

   C = get(hand.list_names,'Value');
   names = get_names(get(hand.list_names,'String'));
   if get(hand.ask_show,'Value')==0  % need to turn off the plotting
      set([hand.currentline,hand.nameline],'Visible','off')
      names(C,1) = ' ';
   else     % need to turn on the plotting
      set([hand.currentline,hand.nameline],'Visible','on')
      names(C,1) = 'v';
   end

   set(hand.list_names,'String',{names})
   set_legend(hand,hand.Axes(1))

case 'tool'

   clicked = gcbo;
   tag = get(clicked,'Tag'); ip = eval(tag(1));
   if isequal(get(hand.tool(ip),'Checked'),'on')
      set_tools(hand,ip,'off')
   else
      set_tools(hand,ip,'on')
   end

case 'undo'       % undo the most recent change, so far only in data

   set(hand.undo,'Enable','off')
   undoud = get(hand.undo,'Userdata');
   if isfield(undoud,'lineud')
      set(hand.nameline,'Userdata',undoud.lineud)
   end
   set_data(hand,undoud.xy(1,:),undoud.xy(2,:))
   get_approx(hand)

case 'view'

   clicked = gcbo;
   tag = get(clicked,'Tag'); ip = eval(tag(1));
   view(clicked,ip,hand)

otherwise
   errordlg(['You provided just one input argument, the string ''',x,...
             '''. If you supply input to SPLINETOOL, then it must be ', ...
	     'two vectors (of the same length).'], ...
               'Wrong input!','modal')
end % switch action

function [index,changes] = addchange(hc, string, concat)
%ADDCHANGE append the STRING to cell array of changes

changes = get(hc,'Userdata');
if nargin>2
   changes{end} = overlong([changes{end},string]);
else
   changes{end+1} = overlong(string);
end
set(hc,'Userdata',changes)
index = length(changes);

function [name,handle] = add_to_list(hand,name)
%ADD_TO_LIST Add name to list of splines, marking it shown and current.
% If no name is given, take the next default one.

listud = get(hand.list_names,'Userdata');
names = get_names(get(hand.list_names,'String'));
if isempty(names), listud.untitleds = 1; end

if nargin<2  % make up a name
   while 1
      name = ['spline',num2str(listud.untitleds),'   '];
      if listud.untitleds>9, name = name(1:10); end
      listud.untitleds = listud.untitleds+1;
      if isempty(findobj('Tag',name)), break, end
   end
else % make sure the name is new and is exactly 10 characters long
   name = full_name(name,hand);
end

names = [names;['v || ',name]];
listud.length = listud.length+1;

  % generate a new line, with its linestyle
styles = {'-';'--';':';'-.'}; nstyles = length(styles);
handle = line('Xdata',NaN, 'Ydata',NaN, ...
   'Parent',hand.Axes(1), ...
   'linestyle', styles{nstyles-rem(listud.length,nstyles)}, ...
   'erasemode','normal', ...
   'ButtonDownFcn', 'splinetool ''axesclick''', ...
   'Tag',name);
listud.handles = [listud.handles;handle];

  % save the updated userdata listud:
set(hand.list_names,'String', {names}, ...
    'Value', listud.length, ...
    'Userdata',listud);

  %  ... and set the line as showing in the graph:
set(hand.ask_show,'Value',1), set(hand.currentline,'Visible','on')

function [xx,yy] = ask_for_add(hand)
%ASK_FOR_ADD

switch get(gcbo,'Tag')
case 'add_item'
   [xx,yy] = ginput(hand);
case 'mov_item'
   [xx,yy] = get(hand.Axes(1),'CurrentPoint');
end % switch get(gcbo,'Tag')

if nargin>0&&get(hand.dataline,'Userdata')
   yy = given(xx,hand);
end

function [x,y,xname,yname,isf] = ask_for_data
%ASK_FOR_DATA
% will return negative ISF in case user hits Cancel

answer = inputdlg({['Give a value or an expression for the data sites (',...
      'or the name of a function, like titanium, whose output, [x,y], ',...
      'provides both data sites and data values, in which case you can ',...
      'ignore the request for data values below):'], ...
      ['Give a corresponding label for the x-axis (default is data',...
      ' sites expression)'], ...
  ['Give a value or an expression for the corresponding data values (',...
  'or the name of a function whose values at the data sites are to be ',...
  'used as data values):'], ...
  ['Give a corresponding label for the y-axis (default is data values',...
  ' expression)']},...
  'Please provide data', 1, ...
   {'linspace(0,2*pi,31)','','cos',''},'on');
if ~isempty(answer)&&~isempty(answer{1})
   xname = answer{1}; yname = answer{3};
   % check out the answers. Lack of knowledge restricts me to merely check
   % whether (a) x is a function, in which case I expect it to return both
   % x and y.
   if any(0+xname<48) % looks like a formula
      x = evalin('base',xname);
   else
      a = evalin('base',['which(''',xname,''');']);
      if length(a)>1&&isequal(lower(a(end-1:end)),'.m')
                             % this is the name of an m-file, let's hope it
                             % supplies both x and y
         [x,y] = evalin('base',xname);
         xname = 'x'; yname = 'y';
      else
         x = evalin('base',xname);
      end
   end

   isf = 0;
   if ~exist('y','var')
      if any(0+yname<48) % looks like a formula
         y = evalin('base',yname);
      else
         switch get_isf(yname,x)
         case {1,2}, y = feval(yname,x);
         case 0,     y = evalin('base',yname);
         otherwise
	    error(['The string, ''',yname,''', specified for y is the', ...
          ' name of an M-file or built-in function that is unsuitable', ...
          ' for providing data values for the given data sites.'])
         end
      end %if any(0+yname<48) % looks like a formula
   end %if ~exist('y','var')

   % check that x is nondecreasing
   [x,y] = chckxy(x,y);

   if length(answer{2}>0), xname = answer{2}; end
   if ~isf&&length(answer{4}>0), yname = answer{4}; end
else   % take default data, but with  isf < 0
   isf = -1;
   [x,y] = titanium; xname = 'temperature'; yname = 'titanium property';
end %if ~isempty(answer)

function bad_edit(editfield,lasterr)
%BAD_EDIT report failure of change in edit field

warndlg({'Evaluation of the expression you entered:';...
          ['''',get(editfield,'String'),''''];...
          'produced the following error message:';'';lasterr}, ...
            'Unusable expression supplied ...','modal')

function change_weight(hand)
%CHANGE_WEIGHT

V = get(hand.params(1,5),'Value'); lineud = get(hand.nameline,'Userdata');
output = convert(hand.params(2,5),lineud.w(V));
if ischar(output), return
else, w = output;
end

negs = find(w<0);
if ~isempty(negs)
   ermsg = ...
       warndlg(['The Spline Tool won''t let you use negative weights, so', ...
                 ' has changed negative value(s) to zero.'], ...
		 'For simplicity, ...','modal');
   % In anticipation of the next error message, ...
   set(ermsg,'Position',get(ermsg,'Position')+[0,60,0,0])
   w(negs) = 0;
end

if length(w)>1
   items = min(length(w),length(lineud.w)+1-V);
   lineud.w(V-1+(1:items)) = reshape(w(1:items),1,items);
else
   lineud.w(V) = w; items = 1;
end

  %check that there are still at least two positive weights
if length(find(lineud.w>0))<2
   warndlg({['The new weight setting would leave you with at most one',...
             ' positive weight.']}, ...
            'There must be at least two positive weights ...','modal')
   return
end
lineud.wc(end+1) = addchange(hand.currentline, ...
                '%% then you changed some error weights');
lineud.wc(end+1) = addchange(hand.currentline, ...
                       ['r=[',num2str(V-1+(1:items)),'];\n', ...
                 'weights(r) = [',num2str(lineud.w(V-1+(1:items)),15),'];']);

set(hand.nameline,'Userdata',lineud)
set(hand.params(1,5),'String',lineud.w(:));
set(hand.params(2,5),'String',lineud.w(V))

get_approx(hand)

function [x,y] = chckxy(x,y)
%CHCKXY check the given data

x = x(:).'; y = y(:).';
if length(x)~=length(y)
   error('SPLINES:SPLINETOOL:sitesdontmatchvalues',...
   ['The number ',num2str(length(x)),' of data sites should match',...
          ' the number ',num2str(length(y)),' of data values.'])
end

nfins = find(sum(~isfinite([x;y])));
if ~isempty(nfins)
   x(nfins) = []; y(nfins) = [];
   temp = warndlg(...
    'The Spline Tool ignored all data points that contain NaNs or Infs', ...
    'Your data was modified ...');
   waitfor(temp)
end

% make sure data are real:
if ~all(isreal(x))||~all(isreal(y))
   x = real(x); y = real(y);
   temp = warndlg(...
      'The Spline Tool ignored the imaginary part of any data.', ...
      'Your data was modified ...');
   waitfor(temp)
end

% make sure data sites are nondecreasing:
dx = diff(x);
if any(dx<0), [x,index] = sort(x); dx = diff(x); y = y(index); end

if ~any(dx)
   error('SPLINES:SPLINETOOL:onlyonesite',...
   'There should be at least two distinct data sites.')
end

function h = clickable(corner,ewid,id,ecall,userdata)
%CLICKABLE a setup for editing and repeatedly incrementing

% be sure to make id exactly 4 characters long

units = 'normalized';
if nargin<5, userdata==[]; end
edy = .0016; wh = .036; lx = .018; h = zeros(4,1);
h(1) = uicontrol('Parent',gcf, ...
	'Units',units, ...
	'BackgroundColor',[1 1 1], ...
	'ListboxTop',0, ...
	'Position',[corner(1) corner(2)+wh+3*edy ewid wh], ...
     'Userdata',userdata,...
	'Style','edit', ...
        'HorizontalAlignment','left', ...
     'Callback',['splinetool ''',ecall,''''], ...
     'TooltipString', 'change the current value', ...
	'Tag',['edit',id]);
     % much prefer the following triple to a slider
h(2)= uicontrol('Parent',gcf, ...
     'Units',units, ...
     'Position',[corner(1), corner(2),lx,wh], ...
        'Userdata',userdata,...
     'Style','pushbutton', ...
     'String','-', ...
     'TooltipString','decrease above value by increment', ...
     'Callback','splinetool ''pm''',...
     'Tag',['minus',id]);
h(3) = uicontrol('Parent',gcf, ...
     'Units',units, ...
     'Backgroundcolor',[1 1 1], ...
     'Position',[corner(1)+lx,corner(2),ewid-2*lx,wh], ...
     'Userdata',userdata,...
     'Style','edit', ...
     'HorizontalAlignment','left', ...
     'String','.1', ...
     'TooltipString','increment (changeable)', ...
     'Callback','splinetool ''increment''', ...
     'Tag',['increment',id]);
h(4)  = uicontrol('Parent',gcf, ...
     'Units',units, ...
     'Position',[corner(1)+ewid-lx,corner(2),lx,wh], ...
     'Userdata',userdata,...
     'Style','pushbutton', ...
     'String','+', ...
     'TooltipString','increase above value by increment', ...
     'Callback','splinetool ''pm''',...
     'Tag',['plus',id]) ;

function mess = concat(mess1,mess2)
%CONCAT  two cell arrays containing strings

mess = cell(length(mess1)+length(mess2),1);
[mess{:}] = deal(mess1{:},mess2{:}); 

function output = convert(editfield,oldval,cuttoone)
%CONVERT evaluate the string at editfield if possible

string = get(editfield,'String');
lastwarn(''), warning off
try
   output = eval(string);
catch
   output = lasterr;
end
lastw = lastwarn;
if ~isempty(lastw), output = lastw; end

if nargin>1
   if ischar(output)
      bad_edit(editfield,output)
      set(editfield,'String',oldval)
   else
      if ~all(isfinite(output))
         output = 'No NaNs or Infs, please.';
         bad_edit(editfield,output)
         set(editfield,'String',oldval)
      end
      if nargin==3
         output = output(1);
      end
   end
end

function flashedit(fieldhand)
%FLASHEDIT flash the edit field
temp = get(fieldhand,'Backgroundcolor');
set(fieldhand,'Backgroundcolor',.7*[1,1,1]), pause(.1)
set(fieldhand,'Backgroundcolor',temp)

function name = full_name(name,hand)
%FULL_NAME make name exactly 10 characters long, without any embedded blanks
%  and with its deblanked version a valid MATLAB variable name

name = deblank(name);
if ~isvarname(name)
   warndlg({['The name ''',name,''' is not a valid MATLAB variable name.']},...
             'Choose another name, please ...','modal')
   % recover the current name and return it
   name = hand.name; return
end

lname = length(name);
if lname>10      % truncate the name
   name = name(1:10);
   warndlg('The Spline Tool can handle only names of up to 10 characters.', ...
            'Sorry, ...', 'modal')
elseif lname<10  % pad the name with blanks
   name = [name,repmat(' ',1,10-lname)];
end
if ~isempty(findobj('Tag',name))
   warndlg({['The name ''',name,''' is already in use.']}, ...
             'Choose another name, please ...','modal')
   % recover the current name and return it
   name = hand.name;
end

function get_approx(hand)
%GET_APPROX    compute the current spline

  % pick up the userdata of the current line
lineud = get(hand.nameline,'Userdata');

  % get the data
x = get(hand.dataline,'Xdata');
y = get(hand.dataline,'Ydata');

lineud.method = get(hand.method,'Value');
switch lineud.method
case 1
   % pick up what end condition was chosen.
   V = get(hand.endconds,'Value');

   lineud.endconds(1) = V;

   if any([2 3 4 9]==V)  % pick up the numerical endcondition information

      tag = get(gcbo,'Tag'); j = 1; if tag(end)=='e', j=2; end
      if isfield(lineud,'valconds')
         output = convert(hand.params(2,j),lineud.valconds(j));
      else
         output = convert(hand.params(2,j));
      end
      if ischar(output)
         return
      else
         lineud.valconds(j) = output(1);
         lineud.valconds(3-j) = convert(hand.params(2,3-j));
      end
   end

   switch V
   case 1 %  'not-a-knot'
      lineud.cs = csapi(x,y);
   case {2,3} %  'clamped', 'complete'
      lineud.cs = csape(x,[lineud.valconds(1),y,lineud.valconds(2)],'complete');
      lineud.bottom = [' ',hand.dbname,' = ', ...
       sprintf('csape(x,[%g,y,%g],''complete'');',lineud.valconds), ...
         ' % same as  ', ...
       sprintf('spline(x,[%g,y,%g])',lineud.valconds)];
   case 4 %  'second'
      lineud.cs = csape(x,[lineud.valconds(1),y,lineud.valconds(2)],'second');
      lineud.bottom = [' ',hand.dbname,' = ', ...
       sprintf('csape(x,[%g,y,%g],''second'');',lineud.valconds), ...
         ' % same as  ', ...
       sprintf('csape(x,[%g,y,%g],[2,2])',lineud.valconds)];
   case 5 %  'periodic'
      lineud.cs = csape(x,y,'periodic');
   case {6,7} %  'variational', ''natural''
      lineud.cs = csape(x,y,'variational');
   case 8 %  'Lagrange'
      lineud.cs = csape(x,y);
   case 9 %  'custom'
      tmp = get(hand.params(1,1),'String'); l = str2num(tmp(1));
      tmp = get(hand.params(1,2),'String'); r = str2num(tmp(1));
      lineud.cs = csape(x,[lineud.valconds(1),y,lineud.valconds(2)],[l,r]);
      lineud.endconds([2 3]) = [l,r];
      lineud.bottom = [' ',hand.dbname,' = ', ...
       sprintf('csape(x,[%g,y,%g],[%g,%g]);',lineud.valconds,l,r), ...
       ' % possibly different end conditions', ...
         ' are specified at the two endpoints.'];
   end %switch V

case 2 % combine both cubic and quintic smoothing spline.

   % Decide on whether to use csaps or spaps; it will depend on how we got here.
   % If the smoothing parameter was reset, we use
   %    csaps for order 4,  spaps for order 6
   % If the smoothing tolerance was reset, we use spaps
   % If a datum was added, deleted, or changed, or a weight was changed,
   %           we use the previously used one.
   % But, to begin with, we use   csaps(x,y,[],[],w)

   tag = get(gcbo,'Tag');  % find out what button was pushed

      % the default weights are the trapezoidal weights (as in spaps)
   trapweights = 0;
   if ~isfield(lineud,'w')||any(tag=='_')||isequal(tag(end-3:end),'clkl')
      trapweights = 1;
      dx = diff(x); lineud.w = ([dx 0]+[0 dx])/2; lineud.wc = [];
      lineud.wc(1) = addchange(hand.currentline, ...
                   ['dx = diff(x);\nweights = ([dx 0]+[0 dx])/2;', ...
                   ' %% start off with the trapezoidal error weights']);
   end

   if ~strcmp(tag,'method') % find out what call was previously made
      whichcall = lineud.bottom(findstr(' = ',lineud.bottom(1:14))+[3:4]);
   end

   switch tag

   case {'method','undo'} % we start from scratch

      lineud.par = -1; whichcall = 'cs'; lineud.tol = 0;

   case {'minusleft','editleft','plusleft'}% we specified the smoothing par ...

      output = convert(hand.params(2,1),shortstr(lineud.par),1);
      if ischar(output), return
      else % make sure this value is in the interval [0 .. 1]
         lineud.par = max(0,min(1,output));
      end

      switch get(hand.order,'Value')
      case 1
         whichcall = 'cs';
      case 2
         whichcall = 'sp';
            % we must translate the parameter into a rho or tol
         if lineud.par==1
            lineud.tol(1) = 0;
         elseif lineud.par==0
            lineud.tol(1) = sum((lineud.w).*(y.*y));
         else
            lineud.tol(1) = lineud.par/(lineud.par-1);
         end
      end

   case {'add_item','del_item', 'minusclkl','editclkl','plusclkl'}

      % lineud.tol(2:end) = [];

   case {'minusclkr','editclkr','plusclkr'}

      if get(hand.data_etc,'Value')==3
                    % we must update the add'l part of tolerance
         V = get(hand.params(1,5),'Value');
         if V==length(x) % attempt to change the NaN entry
             set(hand.params(2,5),'String',NaN)
             warndlg('Cannot change the last entry in this column', ...
                      'Error when modifying diff(roughness weights)','modal')
             return
         end
         output = convert(hand.params(2,5));
         if ischar(output)
            bad_edit(hand.params(2,5),output)
            temp = get(hand.params(1,5),'String');
            set(hand.params(2,5),'String',eval(temp(V,:)))
            return
         else  % check that this new jump value is ok; if it is less than
               % the previous value, it may have to be raised
            if length(output)>1 % make sure that output is a scalar
	       output = output(1); 
	       set(hand.params(2,5),'String',output)
	    end
	    change = output - lineud.tol(V+1);
            if V>1  change = change + lineud.tol(V); end
            if change<0
               [changed,ich] = max([change, (1e-10)-min(lineud.tol(V+1:end))]);
                      % note the positive lower bound (1e-10) imposed on lambda
               if ich>1
	          if (changed-change)>abs(output)*1e-4
                     warndlg(['In order to keep the roughness weight posi',...
                     'tive, the Spline Tool had to change the jump, ', ...
		     num2str(output), ', you proposed, to ',...
		     num2str(output+changed-change),' .'],'Sorry, ...','modal')
		  end  
		  % modify output now, since it may end up in that M-file
	          output = output+changed-change; change = changed;
               end
            end
            lineud.tc(end+1) = addchange(hand.currentline, ...
                       ['dlam(',num2str(V),') = ',num2str(output,15),';',...
                     ' %% then you changed some roughness weight']);
            lineud.tol(V+1:end) = lineud.tol(V+1:end)+change;
            set(hand.params(1,5),'String', ...
                 [lineud.tol(2), diff(lineud.tol(2:end)),NaN])
         end

      end

   case {'minusrite','editrite','plusrite'} % the tolerance was modified

      output = convert(hand.params(2,2),lineud.tol(1),1);
      if ischar(output), return
      else, lineud.tol(1) = output;
      end

      % for the time being, do not allow explicit specification of rho
      if lineud.tol(1) < 0
         lineud.tol(1) = 0; set(hand.params(2,2),'String','0');
         warndlg({['The Spline Tool won''t deal with a negative value',...
	            ' for the tolerance.'];...
               '';['(A negative value of the tolerance would be taken', ...
               ' by SPAPS as specification of its smoothing parameter.)']},...
               'For simplicity, ...','modal')
      end

      whichcall = 'sp';

   case 'order'

      if get(hand.order,'Value')==2, whichcall = 'sp'; end

   otherwise
      errordlg(['In smoothing, we have not yet covered the button:', ...
                 tag], 'We must work harder!','modal')
   end %switch tag

   switch whichcall

   case 'cs'
      [lineud.cs,p_used] =  ...
            csaps(x,y,[lineud.par,lineud.tol(2:end)],[],lineud.w);
      lineud.tol(1) = sum((lineud.w).*((y-fnval(lineud.cs,x)).^2));
      parinfo = num2str(lineud.par,12);  dlaminfo = '';
      moreparinfo = ...
           ' %   csaps is used to enforce specified smoothing parameter;';
      if lineud.par<0
         moreparinfo = ' %  csaps chooses the smoothing parameter;';
      end
      lineud.par = p_used;
      if trapweights
         weightinfo = ' error weights are those for trapezoidal rule;';
      else
         weightinfo = ' weights as listed in Data display on left;';
      end
      if isfield(lineud,'tc')&&length(lineud.tc)>1
         parinfo = ['[',parinfo,',cumsum(dlam)]',];
         dlaminfo = [' dlam are the jumps in roughness weight',...
                       ' as shown in Data display on left;'];
      end
      lineud.bottom = [' ',hand.dbname,' = csaps(x,y,',parinfo, ...
                       ', [], weights);', moreparinfo,weightinfo,dlaminfo];

   case 'sp'

      maintext = ' % spaps is used to enforce specified tolerance;';
      tolinfo = num2str(lineud.tol(1),12);

      lineud.bottom = [];
      lastwarn(''), warning('off','SPLINES:SPAPS:toltoolow')
      switch get(hand.order,'Value')
      case 1
         minfo = '';
         [lineud.cs,ignored,rho] = spaps(x,y,lineud.tol,lineud.w);
         if isfinite(rho), lineud.par = rho/(1+rho);
         else, lineud.par = 1; end
      case 2
         minfo = ',3';
         if length(x)<3
            errordlg(['A 6th order smoothing spline requires',...
                   ' at least 3 data points.'])
         else
	    [lineud.cs,ignored,rho] = spaps(x,y,lineud.tol,lineud.w,3);
            if isfinite(rho), lineud.par = rho/(1+rho);
            else, lineud.par = 1; end
         end

         if isequal(tag(end-3:end),'left') % we must update lineud.tol, and the text
            lineud.tol(1) = sum((lineud.w).*((y-fnval(lineud.cs,x)).^2));
            maintext = ...
              ' % spaps is used to enforce specified smoothing parameter;';
         end
      end %switch get(hand.order,'Value')
      lastw = lastwarn; warning('on','SPLINES:SPAPS:toltoolow')
      if ~isempty(lastw)
         warndlg(['The specified tolerance could not be met, due', ...
	       ' to the fact that there are data points with the same', ...
	       ' site but different values.'], ...
               'Cannot meet tolerance ...','modal')
         lineud.tol(1) = sum((lineud.w).*((y-fnval(lineud.cs,x)).^2));
      end

      if isempty(lineud.bottom)
         lastinfo = ' ';
         if length(lineud.tol)>1
            tolinfo = ['[',tolinfo,',cumsum(dlam)]'];
            lastinfo = [' dlam are the jumps in roughness weight',...
                       ' shown in Data display on left;'];
         end
         if isfield(lineud,'wc')&&length(lineud.wc)>1
            tolinfo = [tolinfo,',weights'];
            lastinfo = [' weights as shown in Data display on left;',lastinfo];
         end
         lineud.bottom = [' ',hand.dbname,' = spaps(x,y,',tolinfo,minfo,');',...
         maintext, lastinfo];
      end
   otherwise
      errordlg(['In smoothing, we have not yet covered the call:', ...
                 whichcall], 'We must work harder!','modal')
   end %switch whichcall

case 3  % least-squares approximation

   www = ''; if isfield(lineud,'w')&&any(lineud.w~=1), www = ', weights'; end
   moved = 0;
   tag = get(gcbo,'Tag');  % find out what button was pushed
   switch tag
   case {'method' , 'order' , ...
        'minusclkl','editclkl','plusclkl','minusclkr','editclkr','plusclkr',...
        'add_item','rep_knot','del_item','undo', ...
        'minusclkm','editclkm','plusclkm'}

      if ~isfield(lineud,'w')
         lineud.w = ones(size(x)); lineud.wc = [];
         lineud.wc(1) = addchange(hand.currentline, ...
                           ['weights = ones(size(x));',...
              ' %% start off with uniform error weights']);
      end

      if ~isfield(lineud,'knots')
         % we've just switched into l2; start with no interior knots
         lineud.k = min(4,length(x)); strk = num2str(lineud.k);
         lineud.bottom =  ...
         [' ',hand.dbname,' = spap2(1,',...
          strk,',x,y',www,'); % we are starting off with the least squares',...
         ' polynomial approximation of order ',strk];
         lineud.knots = augknt(x([1 end]),lineud.k);
         lineud.kc = [];
         set(hand.order,'Value',lineud.k)
      else
         moved = 1;
         lineud = update(hand,'knots',lineud);
         lineud.bottom = [' ',hand.dbname,' = spap2(knots,', ...
                           num2str(lineud.k),',x,y',www,');', ...
                          '% least-squares approximation'];
      end

   case 'buttonm'  % we are to get a new set of knots via newknt

        lineud.knots = newknt(lineud.cs);
        lineud = update(hand,'fit',lineud);
        lineud.kc(end+1) = addchange(hand.currentline, ...
                  ['knots = newknt(',hand.dbname,'); ', ...
              '%% you used newknt for a possibly better knot distribution ...']);
        set(hand.params(1,4),'String',lineud.knots(:))
        markb(hand), set_bdisplay(lineud.knots,hand)
        lineud.bottom = [' ',hand.dbname,' = spap2(newknt(',...
                          hand.dbname,'), ',...
                         num2str(lineud.k),',x,y',www,');',...
                         '% use of newknt for possible improvement of knot',...
                         ' distribution'];
        lineud.kc(end+1) = addchange(hand.currentline, ...
                        [hand.dbname,' = spap2(knots, ',...
                         num2str(lineud.k),',x,y',www,');', ...
             ' %% ... in the least-squares approximation computed now']);
        moved = 1;

   case 'piecem' % we are to choose knots for a given number of pieces

      lineud.knots = eval(get(hand.piecem,'String'));
      lineud.kc= [];
      moved = 1;

   otherwise
    errordlg(['In least-squares, we have not yet covered the button:', tag], ...
               'We must work harder!','modal')
   end %switch tag

   if moved
      lastwarn(''), warning off
      try
         newcs = spap2(lineud.knots,lineud.k,x,y,lineud.w);
      catch
         newcs = lasterr;
      end
      lastw = lastwarn;
      if ~isempty(lastw)
         errordlg({['Foiled attempt to use too large a number of pieces', ...
                   ' for the given data'];...
                   ['and order, as indicated by the following warning ',...
                    '(from SPAP2):'];'';lastw},'Bad order','modal')
      end
      if ischar(newcs)
         switch tag
         case 'order'
            lineud.k = fnbrk(lineud.cs,'order');
            set(hand.order,'Value',lineud.k)
            errmss = ['Foiled attempt to use too high an order for', ...
                      ' the given knots and data,'];
         case 'del_item'
            errmss = ['Deletion of that data point forced a change in the ',...
                      'knot sequence. You can undo this change by clicking ',...
                      'on Edit -> Undo. The change had to be made ',...
                      'since, otherwise, there would have been trouble,'];
            lineud.cs = spap2(1,lineud.k,x,y,lineud.w);
            lineud.knots = fnbrk(lineud.cs,'knots');
            lineud.bottom = [' ',hand.dbname,' = spap2(1,',num2str(lineud.k),...
                ',x,y',www,');% deletion of data point forced return to ',...
                'default knot choice'];
            lineud.kc = [];
          %  lineud.kc(end+1) = addchange(hand.currentline, ...
          %     ['knots = augknt(knots([1 end],fnbrk(',hand.dbname, ...
          %      ',''order'')));']);
         otherwise
            errmss = ['Foiled attempt to use a knot sequence that fails to',...
                  ' satisfy the Schoenberg-Whitney conditions of the', ...
                  ' given order wrto any subset of the data sites,'];
            lineud.knots = fnbrk(lineud.cs,'knots');
         end
         errordlg({'';[errmss, ...
                 ' as indicated by the following warning or error:'];'';...
                 newcs},'Bad move...','modal')
         set(hand.params(1,4),'String',lineud.knots(:),'Value',1+lineud.k)
         markb(hand), set_bdisplay(lineud.knots,hand)
      else
         lineud.cs = newcs;
         if length(lineud.knots)==1 % we only specified the number of pieces
            lineud.bottom = [' ',hand.dbname,...
                            ' = spap2(',num2str(lineud.knots),',',...
                            num2str(lineud.k),',x,y',www,');', ...
                            '% you only specified the number of pieces'];
            lineud.knots = fnbrk(newcs,'knots');
	    if length(lineud.knots)>2*lineud.k
	       set(hand.buttonm,'Visible','on')
	    else
	       set(hand.buttonm,'Visible','off')
	    end
            set(hand.params(1,4),'String',lineud.knots(:))
            markb(hand), set_bdisplay(lineud.knots,hand)
         end
      end
   else
      lineud.cs = spap2(lineud.knots,lineud.k,x,y);
   end

   % set the number of pieces in the piecem display
   set(hand.piecem,'String',length(find(diff(lineud.knots))>0))

case 4  % spline interpolation

   moved = 0;
   if ~isfield(lineud,'knots')
      % we've just switched into spline interpolation;
      %  start with the default knot choice
      lineud.bottom =  ...
      [' ',hand.dbname,' = spapi(4,x,y);', ...
      ' % we are starting off with the cubic spline interpolant,', ...
      ' with knots supplied by aptknt(x,4)'];
      lineud.knots = aptknt(x,4);
      lineud.kc = [];
      lineud.k = length(lineud.knots) - length(x);
      set(hand.order,'Value',lineud.k)
      set(hand.params(1,4),'String',lineud.knots(:),'Value',1+lineud.k)
      markb(hand)
   else
      switch get(gcbo,'Tag')
      case {'order','method','add_item','del_item'}
         [lineud.knots, lineud.k] = aptknt(x,lineud.k);
         strk = num2str(get(hand.order,'Value'));
         lineud.bottom = [' ',hand.dbname,' = spapi(',strk,',x,y);', ...
                       ' % use knots supplied by aptknt(x,',strk,')'];
         set(hand.order,'Value',lineud.k)
      otherwise
         moved = 1;
         lineud.bottom = [' ',hand.dbname,' = spapi(knots,x,y);', ...
         ' % use knots as shown in the Data display to the left'];
      end
   end

   if moved
      lastwarn(''), warning off
      try
         newcs = spapi(lineud.knots,x,y);
      catch
         newcs = lasterr;
      end
      % lastw = lastwarn; if ~isempty(lastw), newcs = lasterr; end
      lastw = lastwarn; if ~isempty(lastw), newcs = lastwarn; end
      if ischar(newcs)
          errordlg({['Foiled attempt to use a knot sequence that violates',...
                  ' the Schoenberg-Whitney conditions wrto the data sites,',...
                  ' as indicated by the following warning or error:'];'';...
                  newcs },'Bad move...','modal')
         lineud.knots = fnbrk(lineud.cs,'knots');
         set(hand.params(1,4),'String',lineud.knots(:))
         markb(hand)
      else
         lineud.cs = newcs;
      end
   else
      lineud.cs = spapi(lineud.knots,x,y);
   end
end %switch lineud.method

currentplot = fnplt(lineud.cs);
set(hand.currentline, ...
   'Xdata',currentplot(1,:),'Ydata',currentplot(2,:))
  % generate the first two derivatives and their end values
lineud.dcs = fnder(lineud.cs);
lineud.ddcs = fnder(lineud.dcs);
ends = fnbrk(lineud.cs,'interval');
lineud.ends = [fnval(lineud.dcs,ends);fnval(lineud.ddcs,ends)];
set(hand.nameline, ...
    'Xdata',currentplot(1,:), 'Ydata',currentplot(2,:), ...
    'Userdata',lineud);

  % also take care of second view
set_view(hand), set_view_label(hand.name,hand)

set_displays(hand)

function isf = get_isf(yname,x)
%GET_ISF check whether yname is a legal function, returning
%        1   for an m-file, -1 if it doesn't work for function values from x
%        2   for a built-in function, -2 if it doesn't work
%        0   otherwise

if ~isvarname(yname), isf = 0; return, end

b = which(yname);
if length(b)>1&&b(end-1)=='.'&&(b(end)=='m'||b(end)=='M')
                     % this is the name of an m-file; let's hope it
                     % supplies y for given x.
   isf = 1;
else
   if length(b)>7&&isequal(b(1:8),'built-in')
               % it is a built-in function, of one variable I hope
      isf = 2;
   else
      isf = 0;
   end
end

if isf
   try
      feval(yname,x);
   catch
      isf = -isf;
   end
end

function names = get_names(cnames)
%GET_NAMES  temporary way for recovering the names

if length(cnames{1})==0
   names = [];
else
   for j=size(cnames,1):-1:1, names(j,:) = cnames{j}; end
end

function [x,y] = ginput(hand)
%GINPUT local version of ginput, to display coordinates

  % set up things
if get(hand.data_etc,'Value')==1
   hands = hand.params(2,[3 5]);
else
   hands = hand.params(2,4);
end
cf = hand.figure;
savehand = hand; % temporarily use the figure's userdata to store the handle
               % of the edit window(s) that should show the currentpoint coords
state = uisuspend(cf);
set(cf,'Backingstore','off', 'Userdata', hands, ...
        'WindowButtonMotionFcn','splinetool(''ginputmove'')',...
        'WindowButtonDownFcn','splinetool(''ginputdone'')', ...
        'Pointer','fullcrosshair')

while ishandle(cf)
   if isequal(get(cf,'Pointer'),'arrow')
      x = eval(get(hands(1),'String'));
      if length(hands)>1
         y = eval(get(hands(2),'String'));
      else y = 0; end
      set(cf,'Userdata',savehand)
      uirestore(state)
      return
    end
   pause(.001)
end

function values = given(x,hand)
%GIVEN   evaluate the given function

values = feval(get(get(hand.Axes(1),'Ylabel'),'String'),x);

function highlightn(clickp,hand)
%HIGHLIGHTN  highlight the point nearest CLICKP

  % find the nearest data point
x = get(hand.dataline,'Xdata'); y = get(hand.dataline,'Ydata');
  % since the user only sees the window as is, the data point
  % closest to the clicked point should be determined in the
  % physical coordinates rather than those of the data.
[ignored,V] = ...
 min((([x(:) y(:)]-repmat(clickp(1,1:2),length(x),1)).^2)*...
            reshape(([2 1]./diff(reshape(axis,2,2))).^2,2,1));
if get(hand.params(1,3),'Value')~=V || length(get(hand.highlightxy,'Xdata'))>1
   set(hand.params(1,3),'Value',V), markxy(hand)
end

function insert_and_mark(x,y,xx,yy,hand)
%INSERT_AND_MARK

[x,i] = sort([x xx]); tmp = [y yy]; y = tmp(i);

   % record the change operation in changes
ii = find(diff(i)<0); if isempty(ii), ii = length(x)+1; end
si = num2str(ii);
change = ['x = [x(1:',si,'-1),',num2str(xx,15),',x(',si,':end)]; ', ...
          'y = [y(1:',si,'-1),',num2str(yy,15),',y(',si,':end)];'];
if isequal(get(gcbo,'Tag'),'add_item')
   cindex = addchange(hand.currentline,[change, ...
          ' %% you added a data point']);
else
     % we supplied earlier the first part of this change, and now finish it.
   cindex = addchange(hand.currentline,[change, ...
          ' %% you moved a data point'],'concat');
end

  % make the added point the current one
V = find(i==length(x));
set(hand.params(1,3),'Value',V);

   % adjust the weights, if any
lineud = get(hand.nameline,'Userdata');
if isequal(get(gcbo,'Tag'),'add_item')
   if isfield(lineud,'w')
      if length(lineud.wc)==1 % we are using a standard weight;
          % simply let method 2 or 3 start the weight again
         lineud = rmfield(lineud,'w'); lineud.wc=[];
      else % we make up the corresponding weight
         lineud.w = ...
            [lineud.w(1:ii-1),(lineud.w(ii-1)+lineud.w(ii))/2,lineud.w(ii:end)];
         lineud.wc(end+1) = addchange(hand.currentline, ...
           ['weights = [weights(1:',si,'-1),(weights(',si,'-1)+weights(',si, ...
            '))/2,weights(',si,':end)];', ...
                    '%% invent the corresponding error weight entry']);
      end
   end
   if isfield(lineud,'tc')  % we have roughness weights in place
      lineud.tol = [lineud.tol(1:ii-1),(lineud.tol(ii-1)+lineud.tol(ii))/2, ...
                                                         lineud.tol(ii:end)];
      lineud.tc(end+1) = addchange(hand.currentline, ...
           ['dlam = [dlam(1:',si,'-1),0,dlam(',si,':end)];', ...
            '%% insert a zero jump for the roughness weight']);
   end
else
   if isfield(lineud,'w'), lineud = rmfield(lineud,'w'); lineud.wc = []; end
   if isfield(lineud,'tol'), lineud.tol(2:end)=[]; lineud.tolc = []; end
end
   % re-initialize the knots if necessary
if lineud.method==4
   lineud = rmfield(lineud,'knots'); lineud.kc = [];
end
   % also augment the data changes vector
lineud.dc(end+1) = cindex;
set(hand.nameline,'Userdata',lineud);
set(hand.data_etc,'Userdata',cindex);

set_data(hand,x,y)
markxy(hand)

function markb(hand)
%MARKB highlight the marked break

V = get(hand.params(1,4),'Value');

breaks = get(hand.params(1,4),'String');
ylim = get(hand.Axes(1),'Ylim');

% flash the edit field if pertinent
tag = get(gcbo,'Tag'); lineud = get(hand.nameline,'Userdata');
if length(tag)==5&&tag(5)=='m'&&isfield(lineud,'k')&&...
   V>lineud.k&&V<=length(lineud.knots)-lineud.k
   flashedit(hand.params(2,4)), end

set(hand.params(2,4),'String',breaks(V,:))
breaks = str2num(breaks);
set(hand.highlightb, 'Xdata', breaks([V V]), 'Ydata', ylim);

function markxy(hand)
%MARKXY highlight the marked data point

tag = get(gcbo,'Tag');
if length(tag)==5&&tag(5)=='r'
   listt = hand.params(1,5); listu = hand.params(1,3);
else
   listt = hand.params(1,3); listu = hand.params(1,5);
end

if length(tag)==5
   switch tag(5)
   case 'l', temp1 = 3;
   case 'r', temp1 = 5;
   end
   if exist('temp1','var'), flashedit(hand.params(2,temp1)),end
end

V = get(listt,'Value'); set(listu,'Value',V);
set(listu,'ListboxTop', get(listt,'ListboxTop'));
x = get(hand.dataline,'Xdata');  y = get(hand.dataline,'Ydata');
set(hand.highlightxy, 'Xdata',x(V), 'Ydata',y(V))

   % also update the edit fields
tmp = get(hand.params(1,3),'String'); set(hand.params(2,3),'String',tmp(V,:))
tmp = get(hand.params(1,5),'String'); set(hand.params(2,5),'String',tmp(V,:))


function menu(varargin)
%MENU my own much more pliable version of MATLAB's menu command

% cf = gcf; depth = .9; width = .6; margo2 = (1-width)/2; inter = .01;
cf = gcf; depth = .8; width = .4; margo2 = (1-width)/2; inter = .01;
bh = min(.09,(depth/nargin)-inter); handles = zeros(1,nargin);

nt = 0;
for j=1:nargin
   handles(j) = uicontrol('Parent',cf, ...
            'Units','normalized', ...
            'Position',[margo2, .98-j*(bh+inter), width, bh], ...
            'String',varargin{j}, ...
            'Callback', ['splinetool(''startcont'',',num2str(j-nt),')']);
   if iscell(varargin{j}) % make it a text box
      nt = nt+1;
      set(handles(j),'Style','text', ...
                     'BackgroundColor',get(cf,'Color'))
   else                   % make it a button
      set(handles(j), ...
            'Callback', ['splinetool(''startcont'',',num2str(j-nt),')']);
   end
end

set(cf,'Userdata',{cf,handles})

function method(hand)
%METHOD

M = get(hand.method,'Value');
if M==2 % initialize the order display
   set(hand.order,'Value',1)
end
lineud = get(hand.nameline,'Userdata');
if ~isfield(lineud,'method')     %isempty(lineud)
   M0 = 0;
else
   M0 = lineud.method;
end

if M==4 % average repeated data sites if user okays it
   x = get(hand.dataline,'Xdata');
   if ~all(diff(x))
      answer = questdlg(['Since SPAPI would interpret repeated data sites',...
          ' as a request for osculatory interpolation, the Spline Tool',...
	  ' is now going to average data points with the same site.'], ...
	  'Repeated data sites', 'OK','Cancel','OK');
      if isempty(answer)||answer(1)=='C'
         set(hand.method,'Value',M0); return
      end

      currentx = x(get(hand.params(1,3),'Value'));
      [x,y] = chckxywp(x,get(hand.dataline,'Ydata'));
      set(hand.params(1,3),'Value',find(x==currentx));
      % record the change operation in changes
      change = ['[x,y] = chckxywp(x,y);'];
      cindex = addchange(hand.currentline,[change, ...
          ' %% you averaged data points with the same site']);
      if isfield(lineud,'w'), lineud = rmfield(lineud,'w'); lineud.wc = []; end
      if isfield(lineud,'tol'), lineud.tol(2:end)=[]; lineud.tolc = []; end
      lineud.dc(end+1) = cindex;
      set(hand.nameline,'Userdata',lineud);
      set(hand.data_etc,'Userdata',cindex);

      set_data(hand,x,y)
      markxy(hand)

   end
end

if M~=M0, set_edits(M0,M,hand), end

parameters(hand)

function moved = move_knot(hand)
%MOVE_KNOT

moved = 0;

V = get(hand.params(1,4),'Value'); lineud = get(hand.nameline,'Userdata');
if V<=lineud.k || V>length(lineud.knots)-lineud.k
   warndlg('The Spline Tool will only let you modify an interior knot.', ...
            'The end knots are forever','modal')
   set(hand.params(2,4),'String',lineud.knots(V))
   return
end

output = convert(hand.params(2,4),lineud.knots(V),1);
if ischar(output), return
else, knot = output;
end

  % make sure this knot is still interior
if lineud.knots(1)>=knot || lineud.knots(end)<=knot
   warndlg(['The Spline Tool won''t let you move a knot outside the basic', ...
           ' interval.'], 'The knot must remain interior.','modal')
   return
end

lineud = update(hand,'knots');
lineud.knots(V) = []; sV = num2str(V);
[lineud.knots,i] = sort([lineud.knots, knot]);
set(hand.params(1,4),'Value',find(i==length(lineud.knots)), ...
                     'String',lineud.knots(:))
lineud.kc(end+1) = addchange(hand.currentline, ...
    ['knots(',sV,')=[]; knots = sort([knots,',num2str(knot,15),']);', ...
                                         '%% you replaced a knot']);
set(hand.nameline,'Userdata',lineud)

markb(hand), set_bdisplay(lineud.knots,hand)
moved = 1;

function move_point(hand)
%MOVE_POINT % replace the current point by the point specified in the edit

x = get(hand.dataline,'Xdata');
V = get(hand.params(1,3),'Value');
output = convert(hand.params(2,3),x(V),1);
if ischar(output), return
else, xx = output;
end
if (V==1&&x(1)~=xx)||(V==length(x)&&x(end)~=xx)
   warndlg('The Spline Tool won''t let you change the extreme data sites.', ...
            'For simplicity, ...','modal')
elseif xx<x(1)||xx>x(end)
   warndlg(['The Spline Tool won''t let you move data sites beyond the', ...
            ' extreme ones.'],'For simplicity, ...','modal')
elseif get(hand.method,'Value')==4&&~isempty(find(x==xx))
   warndlg(['Since SPAPI would interpret repeated data sites',...
          ' as a request for osculatory interpolation, the Spline Tool',...
	  ' won''t let you create repeated data sites now.'], ...
	  'Repeated data sites', 'modal');
else

   %% tell user, if needed, that a move will reset all weights
   lineud = get(hand.nameline,'Userdata');
   if ~isfield(lineud, 'nowarn')&& ...
      ((isfield(lineud,'wc')&&length(lineud.wc)>1)||...
       (isfield(lineud,'tc')&&length(lineud.tc)>1))
      switch questdlg(...
         {'Moving a point will reset all weights to their defaults values.'; ...
          'Do you still want to go ahead with this move?'}, ...
          'Since you have changed some weights manually ...', ...
          'No','Yes','Don''t ask again','No');
      case 'No'
         warndlg('ok')
      case 'Yes'
      otherwise
         lineud.nowarn = 1; set(hand.nameline,'Userdata',lineud)
      end
   end

   x(V)=[]; y = get(hand.dataline,'Ydata'); yold = y(V); y(V) = [];
   if get(hand.dataline,'Userdata')
      yy = given(xx,hand);
   else
      output = convert(hand.params(2,5),yold,1);
      if ischar(output), return
      else, yy = output;
      end
   end

     % record the deletion in changes:
   sV = num2str(V);
   addchange(hand.currentline, ['x(',sV,')=[]; y(',sV,')=[];']);

   insert_and_mark(x,y,xx,yy,hand)
   get_approx(hand)

end

function name = mydeblank(name)
%MYDEBLANK  since matlab's DEBLANK only removes trailing blanks ...

name(find(name==' ')) = [];

function hand = new(hand)
%NEW start off a new function

[hand.name, hand.nameline] = add_to_list(hand);
hand.dbname = deblank(hand.name);
set(hand.figure,'Userdata',hand)
xy = get(hand.highlightxy,'Userdata');
set(hand.dataline,'Xdata',xy(1,:),'Ydata',xy(2,:));
set(hand.params(1,3),'Value',1)
lineud.dc = 0;
set(hand.nameline,'Userdata',lineud)
set(hand.data_etc,'Userdata',0)

set([hand.method,hand.endconds],'Value',1)
method(hand)

set_legend(hand,hand.Axes(1))

function ok = okvar(varname)
%OKVAR Is VARNAME legal? Is it ok to overwrite it in base workspace?

   % check whether VARNAME is a legal variable name.
   if ~isvarname(varname)
      uiwait(errordlg(sprintf(['The proposed string\n''',varname, ...
             '''\n is not a legal variable name.']),'Error','modal'))
      ok = 0; return
   end

   ok = 1;
   if evalin('base',['exist(''',varname,''',''var'')'])
      answer = questdlg({'Ok to overwrite the variable';''; ...
                        ['     ',varname];'';'in the base workspace?';''}, ...
               'This variable already exists ...','No','Yes','No');
      if isempty(answer)||answer(1)=='N', ok = 0;
      end
   end

function string = overlong(string)
%OVERLONG insert linebreak and percents appropriately into overlong lines

t = findstr('%',string);
if ~isempty(t)
   z = '\n%% ';
   % separate the part before, to be appended later
   codestuff = string(1:t(1)-1); string = string(t(1):end);
else
   z = '...\n   ';
end
a = 0;
while length(string)-a>78
   t = findstr(' ',string(a+(1:78))); a = a + t(end);
   string = [string(1:a),z,string(a+1:end)];
end
if exist('codestuff','var')&&~isempty(codestuff)
   z = ':'; if isequal(string(end),'.'), z = ''; end
   string = [string,z,'\n',overlong(codestuff)];
end

function parameters(hand)
%PARAMETERS

switch get(hand.method,'Value')
case 1

   % (re?)-enable the edit pushbuttons
   set(hand.params(1,1:2),'Enable','on')

   % pick up what end condition was chosen.
   V = get(hand.endconds,'Value');
   lineud = get(hand.nameline,'Userdata');
   lineud.endconds(1) = V;

   % for some of these, we need some data input before we can proceed
      set(hand.params(2:5,1:2),'Enable','off')
      if any([2 3 4 9]==V)
           % then we must turn on the clickable stuff, and ask for input
         set(hand.params(2:5,1:2),'Enable','on')

         switch V

         case {2,3}
           if isequal(get(hand.params(1,1),'String'),'2nd deriv.'),
              toggle_ends(1,hand); end
           if isequal(get(hand.params(1,2),'String'),'2nd deriv.'),
              toggle_ends(2,hand); end
         case 4
           if isequal(get(hand.params(1,1),'String'),'1st deriv.'),
              toggle_ends(1,hand); end
           if isequal(get(hand.params(1,2),'String'),'1st deriv.'),
              toggle_ends(2,hand); end
         end % switch V
      end

      % store endcondition details in lineud
   switch V
   case 1 %  'not-a-knot'
      lineud.endconds([2 3]) = [0 0];
      lineud.bottom = [' ',hand.dbname,' = csapi(x,y);', ...
         ' % same as csape(x,y,''not-a-knot'') or spline(x,y)'];
   case {2,3} %  'clamped', 'complete'
      lineud.endconds([2 3]) = [1 1];
   case 4 %  'second'
      lineud.endconds([2 3]) = [2 2];
   case 5 %  'periodic'
      lineud.endconds([2 3]) = [0 0];
      lineud.bottom = [' ',hand.dbname,' = csape(x,y,''periodic'');'];
   case {6,7} %  'variational', ''natural''
      lineud.endconds([2 3]) = [2 2];
      lineud.valconds = [0 0];
      lineud.bottom = [' ',hand.dbname,' = csape(x,y,''variational'');', ...
         ' % same as csape(x,[0,y,0],[2 2]), or csaps(x,y,1)', ...
         ', i.e., set end second derivative to 0'];
   case 8 %  'Lagrange'
      lineud.endconds([2 3]) = [0 0];
      lineud.bottom = [' ',hand.dbname,' = csape(x,y);',...
         ' % the default for  csape, i.e.,',...
         ' supply endslopes by local cubic interpolation'];
   case 9 %  'custom'
       % everything about it possibly changes with endcond input
   end %switch V

   set(hand.nameline,'Userdata',lineud)

case 2
   % all is done directly in get_approx

case {3,4}
   % nothing so far

end %switch get(hand.method,'Value')

get_approx(hand)

function reset_labels(hand,answer)
%RESET_LABELS

fory = hand.Axes(1); forx = hand.Axes(2);
tmp = get(forx,'Visible'); if tmp(2)=='f', forx = fory; end

if isempty(answer) % ask for labels
   answer = inputdlg({['Give the x-label'], ...
               ['Give the y-label; if the y-label is the name of',...
                ' an m-file or a built-in function, that function',...
                ' will be compared against in the error calculation.']}, ...
                'Please provide labels', 1, ...
                {get(get(forx,'Xlabel'),'String');
                 get(get(fory,'Ylabel'),'String')},'on');
end
if ~isempty(answer)
   set(get(forx,'Xlabel'),'String', ...
                  strrep(strrep(answer{1},'\',''),'_','\_'))
   set(get(fory,'Ylabel'),'String', ...
                  strrep(strrep(answer{2},'\',''),'_','\_'))
   
   % If the new y-label is the name of an m-file or a built-in function,
   % it will be used in the error calculation to provide the exact values.
   set(hand.dataline,'Userdata', ...
             max(0,get_isf(answer{2},get(hand.dataline,'Xdata'))));
   temp = get(hand.viewmenu,'Userdata');
   if temp(3), set_view(hand), end % if the error is on view, update it now
end

function segsout = segplot(s,arg2,arg3)
%SEGPLOT plot a collection of segments
%
%        segsout = segplot(s,arg2,arg3)
%
%  returns the appropriate sequences  SEGSOUT(1,:) and  SEGSOUT(2,:)
% (containing the segment endpoints properly interspersed with NaN's)
% so that PLOT(SEGSOUT(1,:),SEGSOUT(2,:)) plots the straight-line
% segment(s) with endpoints  (S(1,:),S(2,:))  and  (S(d+1,:),S(d+2,:)) ,
% with S of size  [2*d,:].
%
%  If there is no output argument, the segment(s) will be plotted in
% the current figure (and nothing will be returned),
% using the linestyle and linewidth optionally specified by ARG2 and ARG3
% as a string and a number, respectively.

% cb dec96, mar97, apr99; DIRFIELD is a good test for it.

[twod,n] = size(s); d = twod/2;
if d<2, error('SPLINES:SPLINETOOL:wronginput',...
  'the input must be of size (2d)-by-n with d>1.'), end
if d>2, s = s([1 2 d+1 d+2],:); end

tmp = [s; repmat(NaN,1,n)];
segs = [reshape(tmp([1 3 5],:),1,3*n);
        reshape(tmp([2 4 5],:),1,3*n)];

if nargout==0
   symbol=[]; linewidth=[];
   for j=2:nargin
      eval(['arg = arg',num2str(j),';'])
      if ischar(arg), symbol=arg;
      else
         [ignore,d]=size(arg);
         if ignore~=1
	    error('SPLINES:SPLINETOOL:wronginarg',...
	    ['arg',num2str(j),' is incorrect.'])
         else
            linewidth = arg;
         end
      end
   end
   if isempty(symbol) symbol='-'; end
   if isempty(linewidth) linewidth=1; end
   plot(segs(1,:),segs(2,:),symbol,'linewidth',linewidth)
   % plot(s([1 3],:), s([2 4],:),symbol,'linewidth',linewidth)
   % would also work, without all that extra NaN, but is noticeably slower.
else
   segsout = segs;
end

function set_bdisplay(breaks,hand)
%SET_BDISPLAY

if nargin==2
   lp1 = length(breaks);
   for j=1:2
      ylim = get(hand.Axes(j),'Ylim');
      xy = segplot([breaks;repmat(ylim(1),1,lp1); ...
                    breaks;repmat(ylim(2),1,lp1)]);
      set(hand.breaks(j),'Xdata', xy(1,:),'Ydata', xy(2,:),'Visible','on', ...
                         'Userdata','on');
   end
   if ~any(get(hand.viewmenu,'Userdata'))
      set(hand.breaks(2),'Visible','off')
   end
else % refresh the knot/break lines in second graph
   n = size(get(breaks.breaks(2),'Ydata'),2)/3;
   ylim = get(breaks.Axes(2),'Ylim');
   set(breaks.breaks(2),'Ydata',...
      reshape([repmat(ylim(:),1,n);repmat(NaN,1,n)],1,3*n))
end

function hand = set_current(hand)
%SET_CURRENT update the current setting according to the present value
%   of Value in list_names . If STRING is empty, start with the default.

names = get_names(get(hand.list_names,'String'));

if ~length(names)
   hand = new(hand);
else % make the V-th guy the current one
   V = get(hand.list_names,'Value');
   name = names(V,:); view = name(1); name = name(6:end);
   listud = get(hand.list_names,'Userdata');
   nameline = listud.handles(V);
   set(hand.currentline, ...
      'Xdata',get(nameline,'Xdata'), ...
      'Ydata',get(nameline,'Ydata'));
   hand.name = name; hand.dbname = deblank(name);
   if view=='v'
      set(hand.ask_show,'Value',1)
      set(hand.currentline,'Visible','on')
   else
      set(hand.ask_show,'Value',0)
      set(hand.currentline,'Visible','off')
   end
      % change to the former dataset if different from present one
   lineud = get(nameline,'Userdata');
   temp = find(lineud.dc==get(hand.data_etc,'Userdata'));
   if isempty(temp)
      xy = get(hand.highlightxy,'Userdata');
      x = xy(1,:); y = xy(2,:); temp = 1;
   elseif temp<length(lineud.dc)
      x = get(hand.dataline,'Xdata');
      y = get(hand.dataline,'Ydata');
   end
   if exist('y','var')
      changes = get(hand.currentline,'Userdata');
      for j=temp+1:length(lineud.dc)
        change = changes{lineud.dc(j)}; rets = findstr('\n',change);
        while length(rets)>1
           change(rets(end)+[-3:1])=[]; rets(end) = [];
        end
        eval(change(findstr('\n',change)+2:end));
      end
      set(hand.params(1,3),'Value',1)
      set_data(hand,x,y), markxy(hand)
      set(hand.data_etc,'Userdata',lineud.dc(end))
   end
   hand.nameline = nameline; set(gcbf,'Userdata',hand)
   set_view(hand), set_view_label(hand.name,hand)
end

function set_data(hand,x,y)
%SET_DATA  (re)set the data

  % If undo button is on, preserve current data in undoud
if isequal(get(hand.undo,'Enable'),'on')
   undoud.xy = [get(hand.dataline,'Xdata');get(hand.dataline,'Ydata')];
   set(hand.undo,'Userdata',undoud)
end

set(hand.dataline,'Xdata',x(:),'Ydata',y(:))
hxlabel = get(hand.Axes(2),'Xlabel');
if isempty(get(hxlabel,'Userdata'))
   set(hxlabel,'Userdata',1, ...
   'String',[get(hxlabel,'String'),'  (modified data)'])
   if ~any(get(hand.viewmenu,'Userdata'))
      set(get(hand.Axes(1),'Xlabel'),'String', ...
      get(hxlabel,'String'))
   end
end
set(hand.params(1,3),'String',x(:))
set(hand.params(1,5),'String',y(:))
markxy(hand)

function set_displays(hand)
%SET_DISPLAYS updates model, endconditions, bottomline, data/breaks, etc

  %  extract all the line detail from nameline
lineud = get(hand.nameline,'Userdata');

  %  Set the bottom line:
set(hand.bottomlinetext, 'String',lineud.bottom)

  %  reset the edit fields according to the current method
M = get(hand.method,'Value');
M0 = lineud.method;
    % what should happen next depends on how we got here
tag = get(gcbo,'Tag');
if ~isempty(tag)&&(strcmp(tag,'list_names')||strcmp(tag,'Pushdel'))
   % either list_names or pushdel was clicked, hence  M  is actually the old
   % method and M0 is the new, hence we switch them now:
   M0 = M; M = lineud.method;
      % we are switching back to an old approx, hence must update the displays
      % concerning order and knots
   switch M
   case 2
      set(hand.order,'Value',max(1,fnbrk(lineud.cs,'order')/2-1))
      % This fails to recover the fact that smoothing order was 3 in case
      % the smoothing spline is of order < 6, e.g., if P was 0.
   case {3,4}
      set(hand.order,'Value',lineud.k)
      if get(hand.data_etc,'Value')==2 % must also update the knot display
         set(hand.params(1,4),'String',lineud.knots(:), ...
         'Value',lineud.k+1)
         markb(hand), set_bdisplay(lineud.knots,hand)
      end
   end
end
if M~=M0
   set(hand.method,'Value',M);
   set_edits(M0,M,hand)
end

  % fill editleft/rite etc appropriately
switch M
case 1   %  Set the end conditions:

      % initialize 'String' and 'Userdata' for editleft and editrite to contain
      % slope and second derivative of the current spline, toggling these only
      % when the endconds is 2

   set(hand.endconds, 'Value',lineud.endconds(1) )

   for j=1:2
      if lineud.endconds(j+1)<1  % make edit and incrementers inactive
         enable = 'off'; disable = 'on';
      else
         enable = 'on'; disable = 'off';
      end
      set(hand.params(2,j), ...
         'Enable',enable, ...
         'String',lineud.ends(1,j),...
         'CreateFcn',num2str(lineud.ends(2,j)));
      set(hand.params(1,j), ...
         'String','1st deriv.');
      if lineud.endconds(j+1)==2, enable = toggle_ends(j,hand); end
      if enable(2) == 'n'
         set(hand.params(4,j),'Enable',enable, 'String',...
         shortstr(abs(eval(get(hand.params(2,j),'String')))/10,1))
      else
         set(hand.params(4,j),'Enable',enable,'String',0)
      end
      set(hand.params([3 5],j),'Enable',enable)
   end

case 2 % set parameter and tolerance
   set(hand.params(2,1),'String',shortstr(lineud.par))
   if ~get(hand.params(4,1),'Value')
      increm = min(lineud.par, 1-lineud.par)/10;
      if ~increm, increm = .01; end
      set(hand.params(4,1),'String',shortstr(increm,1))
   end
   set(hand.params(2,2),'String',shortstr(lineud.tol(1)))
   if ~get(hand.params(4,2),'Value')
      increm = lineud.tol(1)/10;
      if ~increm, increm = .01; end
      set(hand.params(4,2),'String',shortstr(increm,1))
   end

case {3,4}
   for j=1:2
      set(hand.params(2,j),'String',lineud.ends(1,j),...
                        'CreateFcn',num2str(lineud.ends(2,j)))
   end
   set(hand.params(4,1:2),'String',0)
   set(hand.params(1,1:2),'String','1st deriv.')

end %switch M

function set_edits(M0,M,hand)
%SET_EDITS  set up the fields for the viewing and editing of params and data

% Here, M0 is the previously used method, and M is the current method.
% Start by trying to define the labels in the popup in dependence on the
% gui's window size.

tmp = get(hand.figure,'Position'); dkw = fix(tmp(3)*20);

sitesvals =    '  sites   and   values';
breakshead =   '  breaks  ';
knotshead =    '  knots  ';
% sitesweights = '  sites   and   error weights';
sitesweights = '               error weights';
%sitesjumps =   '  sites   and  roughness weight';
sitesjumps =   '    jumps in roughness weight';

  %  start with clean slate
set([hand.endconds; hand.partext(:); hand.params(1,:).'],'Visible','off')

set(hand.endtext,'String','Order:')

switch M
case 1 % cubic spline interpolation

   set(hand.order, 'Visible','off')
   set([hand.endconds,hand.params(1,:),hand.partext(1,:)],'Visible','on')
   set(hand.endtext,'String','End conditions:')

   set(hand.params(2,1:2),'Enable','on')
    %  also indicate that increment fields have not yet been edited,
    %  by setting their 'Value' to 0
   set(hand.params(4,1:2),'Value',0)

   % also choose the menu for data_etc and start it off with Value 1
   set(hand.data_etc, ...
      'Value',1, ...
      'String',{sitesvals; breakshead}, ...
      'TooltipString', 'work with data or breaks')

case 2 % smoothing spline

   set(hand.order,'String',{'4';'6'},'Visible','on')
   set(hand.partext(2,:),'Visible','on')
   set(hand.params(1:5,1:2),'Enable','on')
     %%%%%%%%%%%%  clickables
   set(hand.params(2:5,1:2),'Enable','on')
   set(hand.params(4,1:2),'Value',0)

   % also choose the menu for data_etc and start it off with Value 1
   set(hand.data_etc, ...
      'Value',1, ...
      'String',{sitesvals; sitesweights; sitesjumps}, ...
      'TooltipString', 'work with data or weights')

case {3,4} %  least-squares approximation  and spline interpolation

   % start off with a clean slate concerning knots (unless we are returning
   % to a previous approximation)
   lineud = get(hand.nameline,'Userdata');
   if isfield(lineud,'knots')&&~strcmp(get(gcbo,'Tag'),'list_names')
      set(hand.nameline,'Userdata',rmfield(lineud,'knots'))
   end

   if isfield(lineud,'k'),k=lineud.k; else, k=4; end
   set(hand.order,'String',get(hand.order,'Userdata'),'Value',k,'Visible','on')
   set([hand.partext(1,:),hand.params(1,1:2)],'Visible','on')
   set(hand.params(2:5,1:2),'Enable','off')
   set(hand.params(1,1:2),'Enable','on')

   % also choose the menu for data_etc and start it off with Value 1
   if M==3
      set(hand.data_etc, 'Value',1, ...
      'String',{sitesvals;knotshead;sitesweights}, ...
      'TooltipString', 'work with data,  knots, or weights')
   else
      set(hand.data_etc, 'Value',1, ...
      'String',{sitesvals;knotshead}, ...
      'TooltipString', 'work with data or knots')
   end

end % switch M

splinetool('data_etc',hand)

function set_legend(hand,ax)
%SET_LEGEND (re)generate the legend

if isequal(get(hand.tool(2),'Checked'),'off'), return, end

  % get the list of visible handles
names = get_names(get(hand.list_names,'String'));
listud = get(hand.list_names,'Userdata'); handles = listud.handles;
  % the following complication is needed when set_legend is used for printing
tmp = hand.currentline; handles(get(hand.list_names,'Value')) = tmp(1);
listshown = find(names(:,1)=='v');
handles = handles(listshown);
names = ['data      ';names(listshown,6:end)];
   % need to prevent Latex interpretation of underscore
names = strrep(cellstr(names),'_','\_');

legend(ax,[findobj(hand.figure,'Tag','dataline');handles], names, 0);

function set_tools(hand,ip,onoff)
%SET_TOOLS
set(hand.tool(ip),'Checked',onoff)
switch ip
case 1, for j=1:2,grid(hand.Axes(j),onoff),end
case 2, if length(onoff)==3, legend(hand.Axes(1),'off')
        else,                set_legend(hand,hand.Axes(1))
        end
end

function set_up_menu
%SET_UP_MENU

menu({'Choose some data to work on with the';
              ' SPLINE TOOL:'}, ...
    'Provide your own data or an m-file that does', ...
     {'';'The following data sets illustrate various';
      'aspects of spline fitting.'}, ...
    'Titanium heat data', ...
    'Noisy values of a smooth function', ...
    'The function sin(x) on [0 .. pi/2]', ...
    'Census data', ...
    'Richard Tapia''s drag race data', ...
    'Improve shape of interpolant by moving knots');

function set_view(hand)
%SET_VIEW   update the view graph

viewud = get(hand.viewmenu,'Userdata');

ip = find(viewud==1);
if ~isempty(ip)
   lineud = get(hand.nameline,'Userdata');
   switch ip
   case 1
      xy = fnplt(lineud.dcs);
      set(hand.viewline,'Xdata',xy(1,:),'Ydata',xy(2,:))
   case 2
      xy = fnplt(lineud.ddcs);
      set(hand.viewline,'Xdata',xy(1,:),'Ydata',xy(2,:))
   case 3
      if get(hand.dataline,'Userdata')
         xx = get(hand.nameline,'Xdata');
         set(hand.viewline,'Xdata', xx, ...
          'Ydata', given(xx,hand)-get(hand.nameline,'Ydata'))
      else
         x = get(hand.dataline,'Xdata');
         y = get(hand.dataline,'Ydata');
         set(hand.viewline,'Xdata',x,'Ydata',y-fnval(lineud.cs,x));
      end
      tmp = get(hand.Axes(2),'Xtick');
      set(hand.zeroline,'Xdata',tmp([1 end]))
   end %switch ip
   if strcmp(get(hand.breaks(2),'Userdata'),'on');
      set(hand.breaks(2),'Visible','off')
      set_bdisplay(hand), set(hand.breaks(2),'Visible','on')
   end
end

function set_view_label(name,hand)
%SET_VIEW_LABEL update Ylabel in second axes to given name

if any(get(hand.viewmenu,'Userdata'))
   hylabel = get(hand.Axes(2),'Ylabel');
   tmp = get(hylabel,'String'); findstr(' ',tmp);
   set(hylabel,'String', ...
               [tmp(1:ans(end)),strrep(deblank(name),'_','\_')])
end

function output = shortstr(varargin)
%SHORTSTR formated string

if nargin<2, varargin{2} = '%-0.5g'; end
output = num2str(varargin{:});

function out = showtime
%SHOWTIME provide current time in the form the string hh:mm:ss

c = clock;
zm = ''; if c(5)<10, zm = '0'; end
ss = round(c(end));
zs = ''; if ss<10, zs = '0'; end

out = [num2str(c(4)),':',zm,num2str(c(5)),':',zs,num2str(ss)];

function enable = toggle_ends(j,hand)
%TOGGLE_ENDS toggle between 1st and 2nd derivative value display

pushbutton = hand.params(1,j);
tmp = get(pushbutton,'String');
if tmp(1)=='1'
   deriv=2; set(pushbutton,'String','2nd deriv.');
else
   deriv=1; set(pushbutton,'String','1st deriv.');
end
h = hand.params(2,j);
enable = 'off';
if get(hand.method,'Value')==1
   V = get(hand.endconds,'Value');
   if(deriv==1&&(V==2||V==3))||(deriv==2&&V==4)||V==9
      enable = 'on';
   end
end
other = get(h,'CreateFcn'); ither = get(h,'String');
set(h,'String',other,'CreateFcn',ither,'Enable',enable)

function lineud = update(hand, part, lineud)
%UPDATE make sure that changes has the latest on PART

if nargin<3, lineud = get(hand.nameline,'Userdata'); end

changes = get(hand.currentline,'Userdata');

switch part(1)

case 'f'
   if ~isfield(lineud,'kc')||~length(lineud.kc)
      lineud.kc(1) = addchange(hand.currentline, ...
                         strrep(lineud.bottom(2:end),'%','%%'));
   elseif ~isempty(findstr('\nknots =',changes{lineud.kc(end)}))||...
          ~isempty(findstr('\nknots(',changes{lineud.kc(end)}))
      lineud.kc(end+1) = addchange(hand.currentline, ...
                         strrep(lineud.bottom(2:end),'%','%%'));
   end

case 'k'
   if ~isfield(lineud,'kc')||~length(lineud.kc)
      [lineud.kc(1),changes] = addchange(hand.currentline, ...
                      strrep(lineud.bottom(2:end),'%','%%'));
   end
   if isempty(findstr('\nknots =',changes{lineud.kc(end)}))&&...
      isempty(findstr('\nknots(',changes{lineud.kc(end)}))
            lineud.kc(end+1) = addchange(hand.currentline, ...
            ['knots = fnbrk(', ...
              lineud.bottom(2:(findstr(' =',lineud.bottom(1:13))-1)), ...
             ',''knots''); %% extract knots from current approximation']);
   end

case 'w'
otherwise
   error('SPLINES:SPLINETOOL:impossible',...
   'We should not have reached this point! Notify carl@deboor.de ')
end


function view(clicked, ip, hand)
%VIEW

set(hand.zeroline,'Visible','off')
viewud = get(hand.viewmenu,'Userdata');
Axes1 = hand.Axes(1); Axes2 = hand.Axes(2);
if viewud(ip)==1  % turn off the view
   set(clicked,'Checked','off')
   set(get(Axes1,'Xlabel'),'String',get(get(Axes2,'Xlabel'),'String'))
   set(Axes1,'Xticklabel', get(Axes2,'Xticklabel'))
   set([Axes2;allchild(Axes2)],'Visible','off')
   viewud(ip)=0;
else
   set(clicked,'Checked','on')
   otherv = find(viewud==1);
   if isempty(otherv) % turn on the view
      set([Axes2,hand.viewline],'Visible','on')
      set(get(Axes1,'Xlabel'),'String',[])
      set(Axes1,'Xticklabel',[])
   else  % toggle the label currently shown
      viewud([ip,otherv])=[1 0];
      set(hand.view(otherv),'Checked','off')
   end

   % viewud(ip)=1; ufname = strrep(deblank(hand.dbname),'_','\_');
   viewud(ip)=1; ufname = strrep(hand.dbname,'_','\_');
   switch ip
   case 1
      set(get(Axes2,'Ylabel'),'String',['1st deriv. of ', ufname])
   case 2
      set(get(Axes2,'Ylabel'),'String',['2nd deriv. of ', ufname])
   case 3
      set(get(Axes2,'Ylabel'),'String',['error in ', ufname])
      set(hand.zeroline,'Visible','on')
   end %switch ip
end %if viewud(ip)==1
set(hand.viewmenu,'Userdata',viewud);
set_view(hand)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   the end
