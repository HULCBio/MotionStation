function varargout=propedit(h,varargin)
%PROPEDIT  Graphical property editor
%   PROPEDIT edits all properties of any selected HG object through the
%   use of a graphical interface.  PROPEDIT(HandleList) edits the
%   properties for the object(s) in HandleList.  If HandleList is omitted,
%   the property editor will edit the current figure.
%
%   Launching the property editor will enable plot editing for the figure.
%
%   See also PLOTEDIT

%   Karl Critz
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.127.4.9 $ $Date: 2004/04/10 23:34:19 $

%  PROPEDIT(HandleList,'-noselect') will not put selection handles around
%   the objects or update the SCRIBE internal list of selected handles.  Be
%   careful using this - it is really only intended to be used if you have already
%   used SCRIBE to select the object.
%
%  PROPEDIT(HandleList,'-noopen') will not force the property editor to open.
%   If the property editor has not been opened yet or is invisible, it will
%   not pop open.
%
%  PROPEDIT(HandleList,'-tTABNAME') will open the property editor to the
%   requested tab.  Note that TABNAME is case sensitive and may be affected by
%   internationalization.
%
%  PROPEDIT(HandleList,'v6') will open the property editor window used in
%  versions 6 and earlier.  You may use other arguments after the v6
%  argument, e.g. PROPEDIT(HandleList,'v6','-noselect').
%
%  WARNSTR = PROPEDIT(...) will return warning messages as a string instead of
%   calling the warning command.

v6 = nargin > 1 && isa(varargin{1},'char') && strcmpi(varargin{1},'v6');

noOpen=any(strcmpi(varargin,'-noopen'));

noSelect=any(strcmpi(varargin,'-noselect'));

matchedTab = strmatch('-t',varargin);
if length(matchedTab)>0
    tabName=varargin{matchedTab(1)};
    tabName=tabName(3:end);
else
    tabName='';
end

if ~v6 && (feature ('JavaFigures') ~= 0)

  % if using the new property editor make sure a figure exists
  % and that currentFigure is properly initialized.
  if nargin == 0, 
    h = gcf;
  end
  h=unique(double(h(ishandle(h))));
  currentFigure = ancestor(h(1),'figure');
  if isempty(currentFigure),
    currentFigure = gcf;
  end

else

  if nargin<1
    h=get(0,'currentfigure');
    if isempty(h)
      h=0;
      currentFigure = [];
    else
      currentFigure = h;
    end
  else
    currentFigure = get (0, 'currentfigure');
    h=unique(double(h(ishandle(h))));
  end
end

if ~isempty(h)
    if ~usejava('mwt')
        % no java, use r11 prop edit
        r11propedit(h,noOpen,noSelect);
    else
        % otherwise use
        if ~isempty(currentFigure)
            prevCursor = get(currentFigure, 'pointer');
            set(currentFigure,'pointer','watch')
        end
        a = requestJavaAdapter(h);
        com.mathworks.ide.inspector.Inspector.inspectIfOpen(a);
        if v6 || feature ('JavaFigures') == 0
            % no java figures
            if ~noOpen || ...
                    (com.mathworks.page.propertyeditor.PropertyEditor.isActive)
                % if already active or ok to open property editor.
                if ~noSelect && any (h ~= 0),
                    deselectall(currentFigure);
                    selectobject(h);
                end
                com.mathworks.page.propertyeditor.PropertyEditor.edit(h,...
                    ~noSelect, ~noOpen, tabName);
            end
        else
            % java figures
            if ~noSelect && any (h ~= 0),
              selectobject (h,'replace'); 
            end
            if ~noOpen
                props = propertyeditor (currentFigure, 'show');
                if ~isempty (a)
                    % props.setObject (a);
                    if iscell (a)
                        a = [a{:}];
                        awtinvoke (props, 'setObjects', a);
                    else
                        awtinvoke (props, 'setObject(Ljava/lang/Object;)', a);
                    end
                    drawnow
                end
            end
        end
        if ~isempty(currentFigure) & ...
                ishandle(currentFigure) & ...
                strcmp(get(currentFigure,'Pointer'),'watch')
            %if another application has changed the pointer, don't reset
            set(currentFigure,'pointer',prevCursor)
        end
    end
    warnStr='';
else
    warnStr='No valid objects passed to propedit';
end

if nargout>0
    varargout{1}=warnStr;
elseif ~isempty(warnStr)
    warning(warnStr);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r11propedit(h,noOpen,noSelect)

if ~noSelect
    jpropeditutils('jselect',h);
end

h=h(1); %panels can't handle multi-select
if ~noOpen
    switch get(h,'type')
        case 'line'
            scribelinedlg(scribehandle(getorcreateobj(h)));
        case 'axes'
            scribeaxesdlg(scribehandle(getorcreateobj(h)));
        case 'text'
            scribetextdlg(scribehandle(getorcreateobj(h)));
        otherwise
            %do nothing - no M property editor available
            warning('Unable to start Property Editor since Java is not enabled.');
    end
end
