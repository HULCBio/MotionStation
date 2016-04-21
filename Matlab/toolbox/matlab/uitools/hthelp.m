function figout = hthelp(cmd,link)
%HTHELP Hypertext help utility for MATLAB help and HTML viewing.
%   FIG = HTHELP(FN) creates a hypertext help window and loads the
%   specified file (FN).  FN may be a MATLAB topic such as the name of
%   a toolbox, a MATLAB m-file name, or an HTML source file.  The source
%   file format is an extended subset of the HTML format.  HTHELP
%   displays the text and sets up hyper-links to other HTML documents or
%   to other portions of the displayed document.
% 
%   HTHELP by itself brings up the top level MATLAB help screen with
%   appropriate links to topics.
%
%   HTHELP('topic') brings up the Contents file for that 'topic' with
%   appropriate links to m-files.
%
%   HTHELP('m-file') brings up the help for that 'm-file' with 
%   appropriate links to related m-files.
%
%   HTHELP('HTML file name') loads the given HTML source file into the
%   HTHELP viewer window.
%
%   For a detailed description, run hthelp('hthelp')
%
%   This function is OBSOLETE and may be removed in future versions.

%   Paul Parker 7-12-94
%   Revised P. Barnard 12-28-94
%   Revised J. Wu 11-01-96
%   Revised K. Critz 6-18-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.44 $  $Date: 2002/04/15 03:24:27 $

% Commands: 
%  load {linkname}
%       loadstr {textstring}
%  scroll {line height} -- new screen pos taken from scroll bar.
%  prev {0}
%       cont {MATLAB Contents.m filename}
%       func {MATLAB M-filename}
%       resize {line height} -- new figure size taken from figure.

% Data storage:
% figure: tag='Hyper-Help Figure'
%    userdata=[number of pixels per smallest line
%        size of cache
%        reference time (6 long) 
%                         figure position rectangle (4 long)
%        LH's (DSN long)  (If determined yet...)
%        gap's (DSN long)]
%    fud grows when the text sizes are calculated the first time
% axes: tag='fn:filename' where filename is the filename
%    userdata=[maxypos 
%                         number of lines that fit in the screen
%                         time_last_used(1 long)
%        Documenttitle(string) ]
% text on objects: tag='link:marker' or 'toplink'
% 'PrevButton' (tag): userdata= str2mat matrix of references.
%            implemented as a stack.   (top= #1)

% Suggestions for improvement: when the document cache is full,
% right now figuring out which document to remove is an O(n) operation
% where n is the number of loaded documents.  (It uses a for-loop
% to get('userdata') for each document.)  This could be improved
% by keeping track explicitly of the order in which documents are acecssed
% but the most straight-forward approach to this would involve storing
% handles, which we're avoiding.

% Get the figure if it exists already.
hh=get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on');
fig=findobj(get(0,'children'),'flat','tag','Hyper-Help Figure');

% Set the frameheight (normalized coordinates).
%pbFrameHeight=0.05;
%pbStatBarHeight=0.05;
FrameHeight=30;
StatBarHeight=30;

if nargin==0
   % Enter HTHELP with the main menu.
   if isempty(fig)
      link=htpp('main');
      cmd='loadstr';
   else
      set(fig,'pointer','watch'); setstatus(fig,'Loading Home Page');
      drawnow;
      if ~isempty(findobj(get(fig,'children'),'flat','tag','fn:matlab_help'))
         link='matlab_help';
         cmd='load';
      else
         link=htpp('main');
         cmd='loadstr';
      end
   end
end

if nargin==1
   if ~isempty(fig)
      set(fig,'pointer','watch'); setstatus(fig,'Finding File');
      drawnow;
   end

   % Set the file separator depending on the platform.
   filesep = '/';
   c = computer;
   htmlext = '.html';
   if strcmp(c(1:2),'PC')
      filesep = '\';
      htmlext = '.html';
   end

   link=cmd;
   p=find(link=='.');
   if isempty(p) % if file has no '.'
      %look for LINK.html
      fn=which([link htmlext]);
      if ~isempty(fn) %if LINK.html found
         cmd='load';
         link=fn;         
      else %look for LINK/Contents.html
         fn=which(fullfile(link,['Contents' htmlext]));
         if ~isempty(fn) %if LINK/Contents.html found
            cmd='load';
            link=fn;            
         else %look for LINK/Contents.m
            fn=which(fullfile(link,'Contents.m'));
            if ~isempty(fn) %if LINK/Contents.m found
               cmd='func';
               link=fn;               
            else %look for LINK.m               
               fn=which([link '.m']);
               if ~isempty(fn) %if LINK.m found
                  cmd='func';
                  link=fn;                  
               else %There is nothing out there for us to find
                  fn='';
                  cmd='load';
               end %if LINK.m found
            end %if LINK/Contents.m found
         end %if LINK/Contents.html found
      end %if LINK.html found
   else %if there is a '.' in LINK
      p = max(p);  % Get the last '.'
      fn = which(link);
      if isempty(fn)
         cmd='load';
      elseif ((link(p+1) == 'm') & (length(link) == p+1))  % if file is '.m' file
         link=fn;
         if p > 8
            if strcmp(link(p-8:p),'Contents.')
               cmd = 'cont';
            else
               cmd = 'func';
             end
         else
            cmd = 'func';
         end
      else
         cmd='load';
         link=fn;
      end
   end   
end

% Check to see if any pre-processing needs to be done.
if (cmd(1:4)=='cont') | (cmd(1:4)=='func')
   if ~isempty(fig), 
      set(fig,'pointer','watch'); 
      setstatus(fig,'Parsing File'); drawnow;
   end
   % Pre-process a table-of-contents (Contents.m) file or a function (m-file).
   link=htpp(cmd,link);
   cmd='loadstr';
end

if strcmp(cmd,'load') | strcmp(cmd,'loadstr')
   % Here, we've been asked to display a section of hyperhelp.
   % We have several levels of caching to speed things up:
   % First, the figure is cached.  (If it already exists, don't remake.)
   % Then, we see if the requested document is already loaded.
   % If so, don't bother reloading it, just stuff the present
   % Document into the cache.
   endstat='';  % Status when we're all done.

   % A little preliminary stuff
   if ~isstr(link),
    error('linkname must be a string.')
   end

   % Start loading stuff.
   makenewfig=1;
   loaddoc=1;

   nexttext = '';
   if strcmp(cmd,'loadstr')
      p=find(link=='|');
      nexttext=link(p(1)+1:length(link));
      link=link(1:p(1)-1);
   end
   p=find(link=='#');
   if ~isempty(p)
      fn=link(1:p(1)-1);
      startlink=link(p(1)+1:length(link));
   else
      fn=link(1:length(link));
      startlink='';
   end

   % Find the full path to the file if it hasn't already been done.
   % This will be generally true if we have been called from a text link callback
   % and this is not HTML which has automatically been derived from an m-file.
   % Also, don't find the full path if this is the main MATLAB help text that
   % has been cached.
   if nargin==2 & strcmp(cmd,'load') & ~strcmp(fn,'matlab_help')
      fn=which(fn);
   end

   if ~isempty(fig)
     % Prep the old figure.
     fig=fig(1);

     % Put up a watch cursor as fast as possible.
     set(fig,'pointer','watch');

     fud=get(fig,'userdata');
           figure(fig);
     % Hide the existing axes set (cache the document)
     % This is the cache monitor!
     % We count documents, and if the cache is full, kill the oldest.
     ax=gca;
     if strcmp(get(ax,'tag'),'fn:Not a File')
      % This was an error screen, don't cache it.
          delete(ax);
     else
      allax=findobj(get(fig,'children'),'flat','type','axes');
      if length(allax) >= fud(2)
       % The cache is full.  Erase the oldest.
       timestamp=zeros(size(allax));
       for a=1:length(allax)
        taud=get(allax(a),'userdata');
        timestamp(a)=taud(3);
       end
       [jnk,die]=min(timestamp);
       delete(allax(die));
      end
      % Put a timestamp on this axis.
      aud=get(ax,'userdata');
      aud(3)=etime(clock, fud(3:8) );
      set(ax,'userdata',aud);
      set(get(ax,'children'),'visible','off');
     end
     makenewfig=0;

     % Now that we've got the old figure waiting, let's see
     % if our document is loaded anywhere.
     tag=['fn:' fn];
     fnax=findobj(get(fig,'children'),'flat','tag',tag);
     if isempty(startlink)
      tag='toplink';
     else
      tag=['link:' startlink];
     end
     linkobj=findobj(fnax,'tag',tag);
     if ~isempty(linkobj)
       linkobj=linkobj(1);
       ax=get(linkobj(1),'parent');
       % Our document has been cached.  Let's load it up.
       aud=get(ax,'userdata');
                   ln = length(find(aud~=0));
       set(fig,'name',char(aud(4:ln)));
                   axes(ax);
                   vsld = findobj(fig,'tag','vertsld');
                   set(vsld,'userdata',1.0);
       set(get(ax,'children'),'visible','on');
                   axpos=get(ax,'Position');
                   figpos=get(fig,'Position');
                   pos=[0.03*figpos(3) ...
                        (figpos(4)-FrameHeight)-axpos(4) ...
                        axpos(3:4)];
                   set(ax,'Position',pos);
       pos=get(linkobj,'position');
       wanty=pos(2);
       loaddoc=0;  % Continue to end where we place ourselves on the
             % axis properly.

           end
   end

   if loaddoc
    % Some generally useful variables.
    BackgroundColor=[1 1 1];
    ForegroundColor=[0 0 0];
          % Choose the correct HTHELP screen size from the screen size.
          scrsz=get(0,'screensize');
          Position=[288 250 576 600];
          if scrsz(3)<=(Position(1)+Position(3)) | ...
             scrsz(4)<=(Position(2)+Position(4))
             Position=[25 50 576 600];
             if scrsz(4)<=(Position(2)+Position(4))
                Position(4)=scrsz(4) - Position(2) - 10;
             end
          end

          comp=computer;
    if makenewfig
      % Define default position
                  bias = [0 1 1 0];  % Bias for UIs.
                  if strcmp(comp(1:2),'PC'), bias = zeros(1,4); end
      mCharacterWidth = 7;
      fud=[0 20 clock Position]; % Default document cache limit is 20
      fig = figure('NumberTitle','off','Units','pixels', ...
        'tag','Hyper-Help Figure','HandleVisibility','off',...
        'InvertHardcopy','off',...
        'pointer','watch',...
        'resize','on', ...
        'DefaultTextVerticalAlignment','top',...
        'userdata',fud,'nextplot','add',...
        'Pos',Position,'MenuBar','none', ...
        'Color',BackgroundColor,'Visible','off');
     
     pause on
      % Button's & such.
      UIPos=[0 Position(4)-FrameHeight Position(3) FrameHeight] + bias;
      uicontrol(fig,'Style','frame','tag','UICFrame',...
        'Units','pixels','Position',UIPos);
      wid=0.15;
      spc=0.025;
      xpos=spc;
      % Home Button
      UIPos=[xpos*Position(3) Position(4)-FrameHeight+5 ...
                         wid*Position(3) FrameHeight-8 ];
      uicontrol(fig,'Style','pushbutton','String','Home', ...
                          'Units','pixels', 'Position',UIPos,...
                          'Enable','off', ...
                    'tag','HomeButton',...
                                'callback','hthelp;');
      xpos=xpos+wid+spc;
      % Previous Button
      UIPos=[xpos*Position(3) Position(4)-FrameHeight+5 ...
                         wid*Position(3) FrameHeight-8];
      uicontrol(fig,'Style','pushbutton','String','Previous', ...
                          'Units','pixels', 'Position',UIPos,...
                          'Enable','off', ...
                    'tag','PrevButton' );

      % Done Button (on right side).
      xpos=1-wid-spc; 
      UIPos=[xpos*Position(3) Position(4)-FrameHeight+5 ...
                         wid*Position(3) FrameHeight-8];
      uicontrol(fig,'Style','pushbutton','String','Done','tag','DoneButton',...
              'Units','pixels', 'Position',UIPos,...
              'Callback','set(gcbf,''visible'',''off'');' );
      xpos=xpos+wid+spc;

                  % Status bar on the bottom of figure.
      UIPos=[0 0 Position(3) StatBarHeight] + bias + [0 -1 0 1];
      uicontrol(fig,'Style','frame','tag','UICStatFrame',...
        'Units','pixels', 'Position',UIPos);
      % Status Bar text...
      UIPos=[0.1 5 0.8 StatBarHeight-8] .* [Position(3) 1 Position(3) 1];
      uicontrol(fig,'style','text','String','Initializing', ...
              'tag','Status', ...
              'HorizontalAlignment','Center', ...
              'Units','pixels', 'Position',UIPos);

                  % Set all of these objects' units to normalized except vert. slider.
      %pb set(get(fig,'Children'),'Unit','norm');

                  % Vertical slider (on right side).
                  wid=16/Position(3); % 16 pixel wide scroll bar.
                  UIPos=[(Position(3)-16) ...
                         StatBarHeight ...
                         16 ...
                         (Position(4)-FrameHeight-StatBarHeight)] + ...
                         bias;
                  vsld=uicontrol(fig,'Style','slider',...
                                     'units','pixels',...
                                     'position',UIPos,...
                                     'value',1,...
                                     'tag','vertsld',...
                                     'BackgroundColor',[1 1 1]);

                  % Set the position for the axes.
                  Position=[0.03*Position(3) StatBarHeight ...
                            0.94*Position(3) Position(4)-FrameHeight-StatBarHeight] + [0 0 0 1];
          else
                  % Set the position for the axes.
                  % Grab the figure size from the userdata.
                  fud=get(fig,'userdata');
                  figpos=fud(9:12);
                  Position=[0.03*Position(3),...
                            figpos(4)+StatBarHeight-Position(4),...
                            0.94*Position(3),...
                            (Position(4)-FrameHeight-StatBarHeight)]...
                           + [0 0 0 1];

                  % Find the handle for the vertical slider.
                  vsld = findobj(fig,'tag','vertsld');

    end  % Make new figure.

    % Create new axes for the new document.
    ax=axes('visible','on','color','none',...
        'xcolor',BackgroundColor,'XTickLabel','','XTick',[],...
        'ycolor',BackgroundColor,'YTickLabel','','YTick',[],...
        'TickLength',[0 0],...
        'units','pixel','nextplot','add',...
      'position',Position,...
      'xlim',[0 100],'ylim',[0 100],...
      'ydir','reverse','clipping','on');
   
    basefontname='Helvetica';
    basefontsize=12;
    % Define starting font characteristics.
    fontname=basefontname;
    fontsize=basefontsize;
    fontangle='normal';
    fontweight='normal';
    %pb relfontsize=[2.75 2 1.58 1.25 1];
    relfontsize=[4 3 2 1];
    DSN=length(relfontsize);  % Default Size Number

    % See if text sizes have been calculated yet.
    if length(fud)>12
       % If they have, just get the data back.
       LH=fud(13:(12+DSN));
       gap=fud((13+DSN):(12+2*DSN));
    else
       % Put up some sample text of various sizes to figure out spacings.
       % tic
       LH=zeros(size(relfontsize));
       gap=LH;
       for ts=DSN:-1:1;
                % Note that the following eqn. is not the same as the one later on.
                % This is because we want to use multiples of the smalles font size
                % for the spacing.  This prevents lines from getting cut in half
                % by the figure edge.
                fs=basefontsize + 2*relfontsize(ts);
                h1=text('Position',[0 0],'string','Test',...
                        'VerticalAlignment','Top','FontSize',fs);    
                siz=extent(h1);
                if ts==DSN
                   LH(ts)=1.1*siz(4);
                   set(h1,'units','pixel');  % Store off the number of
                   siz=extent(h1);           % pixels per smallest line
                   fud(1)=1.1*siz(4);        % height.
                   set(h1,'units','data');
                else
                   LH(ts)=ceil((1.1*siz(4))/LH(DSN))*LH(DSN);
                end
                delete(h1);
       end
       % Store it, so we don't have to do this again.
       fud=[fud LH gap];
       set(fig,'userdata',fud);
    end

    pLH=LH(DSN);  % Present Line Height
          % Set the axis limits to hold an integer
          % number of text lines and set the default text properties.
          set(ax,'ylim',[0 floor(100/pLH)*pLH],...
              'DefaultTextColor',ForegroundColor,...
              'DefaultTextFontName',fontname,...
              'DefaultTextFontSize',fontsize,...
              'DefaultTextFontAngle',fontangle,...
              'DefaultTextFontWeight',fontweight,...
              'DefaultTextClipping','off',...
              'DefaultTextInterpreter','none',...
              'DefaultLineClipping','off');
          set(vsld,'callback',['hthelp(''scroll'',' num2str(pLH) ');']); % Set up scroll clbck. 
    set(fig,'visible','on',...
                  'WindowButtonMotionFcn',['hthelp(''resize'',' num2str(pLH) ');']);

    % Here, we load the file, and figure out which part of it we want
    % to use.   We also look for a figure title.
    % We clip it at <TITLE> markers -- only display the section
    % surrounding the link we're interested in.
          setstatus(fig,'Loading Text'); drawnow;

    thisfn=fn;

    % Open the file and load/parse/place text on screen
    TextString = loadhtml(cmd,fn,startlink,nexttext,fig,ax,LH,comp);
    % Set up the Userdata for the axis to identify it.  The first two items are
    % the maximum value of ypos and the total number of lines on the screen.
    % The remaining Userdata items are the time of creation, and the title of
    % the section (set in the MEX file).
    fud=get(fig,'userdata');
    reltime=etime(clock,fud(3:8));
          pos=get(fig,'position');
          aud=get(ax,'userdata');
    aud=[aud(1)        floor((pos(4)-FrameHeight-StatBarHeight)/fud(1)) ...
               real(reltime) aud(4:length(aud))];
    set(ax,'userdata',aud);
   
    % Done loading the string!
    % Find the y-position we want.
    wanty=0;
    if ~isempty(startlink)
     tag=['link:' startlink];
     linkobj=findobj(get(gca,'children'),'flat','tag',tag);
     if ~isempty(linkobj)
      pos=get(linkobj,'position');
      wanty=pos(2);
     end
    end
   end  % the load-doc test.

   % Now let's move to the correct part of the axis.
   aud=get(ax,'userdata');
   maxypos=aud(1);
   ylim=get(ax,'ylim');
   ylim=ylim-ylim(1);  % Start at top.
   ylim=ylim+wanty;    % Then, move down to the correct reference location.
   set(vsld,'value',1-wanty/maxypos); % Set vert slider there too.
   set(vsld,'userdata',1-wanty/maxypos);
   set(ax,'ylim',ylim);

   % If there is only one page of text displayed, then turn off
   % the slider.
   if maxypos <= (ylim(2)-ylim(1))
      set(vsld,'visible','off');
   else
      set(vsld,'visible','on');
   end

   % Now let's set up the "Home" button.
   % (If we are not already home)
   home=findobj(fig,'tag','HomeButton');
   if ~strcmp(cmd,'home')
      set(home,'Enable','on');
   else
      set(home,'Enable','off');
   end

   % Now we deal with the "Prev" button.
   % We take whatever's in the userdata, and make that the
   % callback.  Then we put our thing in the userdata.
   prev=findobj(fig,'tag','PrevButton');
   pud=get(prev,'userdata');
   if ~isempty(pud)
     set(prev,'Enable','on','callback','hthelp(''prev'',0);');
     pud=str2mat(link,pud);  % Add this link to the list.
     npud=size(pud,1);
     % We limit the size of the pud stack to 30.
     if npud>30
      pud(31:npud,:)=[];
     end
   else
     set(prev,'Enable','off');
     pud=link;
   end
   set(prev,'userdata',pud);

   setstatus(fig,endstat); drawnow;

   set(fig,'pointer','arrow');

elseif strcmp(cmd,'resize')
% Check to see if the window has been resized.  If it has been, than the axis may
% need to be shifted so that the complete figure responds correctly to the user
% resize commands.  This option gets a callback every time the mouse is moved over
   % the figure window.
   if ~isempty(fig)
      comp = computer;
      bias = [0 1 1 2];  % Bias for UIs.
      if strcmp(comp(1:2),'PC'), bias = [0 -1 0 2]; end
      fud=get(fig,'userdata');
      prevpos=fud(9:12);
      Position=get(fig,'position');
      set(fig,'userdata',[fud(1:8) Position fud(13:length(fud))]);

 % Check to see if the window size has changed.  If so, resize the UI controls.
 % Unfortunately we can't do the Top button bar because they may write over
      % the text on the figure.  Plus, it takes a lot of time.
      if any(prevpos(3:4)~=Position(3:4))
         uic=findobj(fig,'tag','UICFrame');
         uicpos=get(uic,'pos');
         uicpos=[0 Position(4)-FrameHeight Position(3) FrameHeight] + bias;
         set(uic,'position',uicpos);

         wid=0.15;
         spc=0.025;
         xpos=spc;
         uic=findobj(fig,'tag','HomeButton');
         uicpos=get(uic,'pos');
         uicpos=[xpos*Position(3) Position(4)-FrameHeight+5 ...
                         wid*Position(3) FrameHeight-8 ];
         set(uic,'position',uicpos);

         xpos=xpos+wid+spc;
         uic=findobj(fig,'tag','PrevButton');
         uicpos=get(uic,'pos');
         uicpos=[xpos*Position(3) Position(4)-FrameHeight+5 ...
                         wid*Position(3) FrameHeight-8];
         set(uic,'position',uicpos);

         xpos=1-wid-spc; 
         uic=findobj(fig,'tag','DoneButton');
         uicpos=get(uic,'pos');
         uicpos=[xpos*Position(3) Position(4)-FrameHeight+5 ...
                         wid*Position(3) FrameHeight-8];
         set(uic,'position',uicpos);

         uic=findobj(fig,'tag','vertsld');
         uicpos=get(uic,'pos');
         uicpos=[(Position(3)-16) StatBarHeight 16 (Position(4)-FrameHeight-StatBarHeight)] + ...
                bias;
         set(uic,'position',uicpos);

         uic=findobj(fig,'tag','UICStatFrame');
         uicpos=get(uic,'pos');
         uicpos=[0 0 Position(3) StatBarHeight] + bias + [0 -1 0 1];
         set(uic,'position',uicpos);

         uic=findobj(fig,'tag','Status');
         uicpos=get(uic,'pos');
         uicpos=[0.1 5 0.8 StatBarHeight-8] .* [Position(3) 1 Position(3) 1];
         set(uic,'position',uicpos);

         % Set the units per screen.
         ax=gca;
         aud=get(ax,'userdata');
         aud(2) = floor((Position(4)-FrameHeight-StatBarHeight)/fud(1));
         set(ax,'userdata',aud);

         % One example of resizing the button bar is left here for future reference.
         % uic=findobj(fig,'tag','UICFrame');
         % uicpos=get(uic,'pos');
         % fhgt=uicpos(4)*prevpos(4)/pos(4);
         % uicpos=[uicpos(1) (pos(4)-prevpos(4)*(1-uicpos(2)))/pos(4) ...
         %         uicpos(3) fhgt];
         % set(uic,'position',uicpos);

      end

      % Check to see if the window size has changed in such a way that the axis needs
      % to be shifted.
      pos=Position;
      if (prevpos(2)~=pos(2)) & any(prevpos(3:4)~=pos(3:4))
         % The lower left corner of the figure window has moved, so we need to shift
         % the axis back to its previous position w.r.t. the screen.
         axpos=get(ax,'position');
         set(ax,'position',[axpos(1),...
                axpos(2)-(pos(2)-prevpos(2)),...
                axpos(3), axpos(4)]);

         % Reset the thumb position to the top of the screen.
         vsld=findobj(fig,'tag','vertsld');
         vsldval=get(vsld,'value');
         maxypos=aud(1);
         totpixels = fud(1)*round(maxypos / link);
         set(vsld,'value',(vsldval + ...
             (prevpos(4)-FrameHeight-StatBarHeight - pos(4))/totpixels));

      elseif (prevpos(2)==pos(2)) & (prevpos(4)~=pos(4))
         % The top edge of the figure has moved.
         axpos=get(ax,'position');
         set(ax,'position',[axpos(1),...
                axpos(2)-(prevpos(4)-pos(4)),...
                axpos(3), axpos(4)]);

      end % end if

   end % end if

elseif strcmp(cmd,'prev')
   % Bring up the previous help thing.
   % The previous button maintains a stack of link-addresses in its
   % userdata, stored as a string-matrix.  pud(1,:) is the presently
   % displayed one.   pud(2,:) is what it jumps to.
   if isempty(fig)
     error('Cannot jump to previous: No Hyper Help Figure available.');
     return;
   end
   fig=fig(1);
   if strcmp(get(fig,'visible'),'off')
    % If it's invisible, then just show it!
    set(fig,'visible','on');
   else
    % Otherwise, bring up the previous.
    prev=findobj(fig,'tag','PrevButton');
    pud=get(prev,'userdata');
    npud=size(pud,1);
    if npud<2
       setstatus('Error: No Previous available.'); drawnow;
    else
       call=deblank(pud(2,:)); 
       pud=pud(3:npud,:);   % Pop the top two off the stack.
       set(prev,'userdata',pud);

             % When we call it, it will put call back
             % onto the pud stack -- which is why we
             % lopped it off.
             if ~isempty(findstr(call,'|<ti'))
                % Load up a previous string of .html.
                hthelp('loadstr',call);
             else
                % This is a file to load up.
                hthelp('load',call);
             end
    end

          % Set the vertical slider to initialized value.
          set(findobj(fig,'tag','vertsld'),'userdata',1.0);

   end

elseif strcmp(cmd,'scroll')
   % Let's scroll...  First, find our figure.
   if isempty(fig)
     error('Cannot scroll: No Hyper Help Figure available.');
     return;
   end
   fig=fig(1);
   ax=gca;
   aud=get(ax,'userdata');
   maxypos=aud(1);
   nlineperscreen=aud(2);
   totlines = round(maxypos / link);
   ylim=get(ax,'ylim');
   if diff(ylim) > maxypos
      % It all fits.  Stop worrying.
      ylim=ylim-ylim(1);
   end

   % Set the top of the screen to the thumb position.
   vsld=findobj(fig,'tag','vertsld');
   prevvsldval=get(vsld,'userdata');
   if isempty(prevvsldval), prevvsldval = 1.0; end

   vsldval=get(vsld,'value');
   valdiff=prevvsldval - vsldval;
   % Window is designed to capture jumps by 1/10 and 1/9.  The VAX
   % currently jumps by 1/9 and other platforms by 1/10.  When the VAX
   % jump interval is corrected, the upper limit can be moved back to
   % 0.103 (ie.  3/1000 above the threshold)
   if (abs(valdiff) > 0.097 & abs(valdiff) < 0.114),
      % Move down 0.9*one screen.
      ylim=ylim+round(0.9*nlineperscreen)*link*sign(valdiff);
      if ylim(2) > maxypos,
         pos=round(totlines-nlineperscreen)*link; 
         ylim=[pos pos+diff(ylim)];
      elseif ylim(1) < 0,
         ylim=ylim-ylim(1);
      end

      % Set the slider to the new position.
      set(vsld,'value',min(max((1-(ylim(1)/(maxypos-nlineperscreen*link))),0),1));

   else
      % Reverse the sign on the scroll bar
      % value and convert to data units.
      % ('link' contains smallest line height)
      pos=round((1-vsldval)*(totlines-nlineperscreen))*link; 
      ylim=[pos pos+diff(ylim)];

   end

   % However the slider was moved, save off the value of it.
   set(vsld,'userdata',get(vsld,'value'));

   set(ax,'ylim',ylim);

else
   error('Unrecognized command.');
end 

set(0,'showhiddenhandles',hh);

if nargout > 0
   figout=fig;
end
