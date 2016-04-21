function schema
% Defines properties for @axesgroup superclass

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:17 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axesgroup');

% General
schema.prop(c,'AxesStyle','handle');              % Axes style parameters (@axesstyle)
schema.prop(c,'EventManager','handle');           % Event coordinator (@eventmgr object)
schema.prop(c,'Grid','on/off');                   % Grid state (on/off)
schema.prop(c,'GridFcn','MATLAB array');          % Grid function (built-in grid if empty)
schema.prop(c,'GridOptions','MATLAB array');      % Grid options (struct)
schema.prop(c,'LabelFcn','MATLAB callback');      % Label building function
p = schema.prop(c,'LayoutManager','on/off');      % Layout manager (on -> uses resize fcn)
p.FactoryValue = 'on';
p = schema.prop(c,'LimitManager','on/off');       % Enable state for limit manager
p.FactoryValue = 'on';
schema.prop(c,'LimitFcn','MATLAB callback');      % Limit picker (ViewChanged callback)
p = schema.prop(c,'NextPlot','string');           % Hold mode [add|replace]
p.FactoryValue = 'replace';     
schema.prop(c,'Parent','handle');                 % Parent figure
p = schema.prop(c,'Position','MATLAB array');     % Axes group position (in normalized units)
p.AccessFlags.Init = 'off';
schema.prop(c,'Size','MATLAB array');             % Size of axes grid
schema.prop(c,'Title','string');                  % Title string
schema.prop(c,'TitleStyle','handle');             % Title style (@labelstyle handle)
schema.prop(c,'UIContextMenu','handle');          % Right-click menu root
schema.prop(c,'Visible','on/off');                % Axis group visibility

% REVISIT: MATLAB array->string vector
% X axis
% Ncol := prod(Size([2 4]))
schema.prop(c,'XLabel','MATLAB array');           % X label (string or cell of length Size(4))
schema.prop(c,'XLabelStyle','handle');            % X label style (@labelstyle handle)
p = schema.prop(c,'XLimMode','MATLAB array');     % X limit mode [auto|manual]
% String vector of length the total number of columns in axis grid
p.SetFunction = @LocalXLimModeFilter;
p = schema.prop(c,'XLimSharing','string');        % X limit sharing [column|peer|all]
p.FactoryValue = 'column';
p = schema.prop(c,'XScale','MATLAB array');       % X axis scale (Ncol-by-1 string cell)
p.SetFunction = @LocalXScaleFilter;
p = schema.prop(c,'XUnits','MATLAB array');       % X units (string or cell of length Size(4))
p.SetFunction = @LocalXUnitFilter;
% RE: XUnits covers shared units such as time or frequency units. Use ColumnLabel 
%     to specify column-dependent units (e.g., input units)

% Y axis
% Nrow := prod(Size([2 4]))
schema.prop(c,'YLabel','MATLAB array');           % Y label (string or cell of length Size(3))
schema.prop(c,'YLabelStyle','handle');            % Y label style (@labelstyle handle)
p = schema.prop(c,'YLimMode','MATLAB array');     % Y limit mode [auto|manual]
% String vector of length the total number of rows in axis grid
p.SetFunction = @LocalYLimModeFilter;
p = schema.prop(c,'YLimSharing','string');        % Y limit sharing [row|peer|all]
p.FactoryValue = 'row';
schema.prop(c,'YNormalization','on/off');         % Y axis normalization
p = schema.prop(c,'YScale','MATLAB array');       % Y axis scale (Nrow-by-1 string cell)
p.SetFunction = @LocalYScaleFilter;
p = schema.prop(c,'YUnits','MATLAB array');       % Y units (string or cell of length Size(3))
p.SetFunction = @LocalYUnitFilter;
% RE: YUnits covers shared units such as mag or phase units. Use RowLabel 
%     to specify row-dependent units (e.g., output units)

% Private properties
p(1) = schema.prop(c,'Axes','MATLAB array');              % Nested @plotarray's
p(2) = schema.prop(c,'Axes2d','MATLAB array');            % Matrix of HG axes handles (virtual)
p(3) = schema.prop(c,'Axes4d','MATLAB array');            % 4D array of HG axes handles (virtual)
p(4) = schema.prop(c,'LimitListeners','handle vector');   % Listeners related to limit manager
p(5) = schema.prop(c,'Listeners','handle vector');        % Listeners
p(6) = schema.prop(c,'GridLines','handle vector');        % Grid lines
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');  

% Events
schema.event(c,'DataChanged');   % Change in data content (triggers redraw)
schema.event(c,'ViewChanged');   % Change in view content (triggers limit update)
schema.event(c,'PreLimitChanged');   % Issued prior to call to limit picker
schema.event(c,'PostLimitChanged');  % Change in axis limits or scales


%------------------ Local Functions ----------------------------------

function Value = LocalXLimModeFilter(this,Value)
% Correctly formats XlimMode settings
Size = this.Size;
if ~all(strcmpi(Value,'auto') | strcmpi(Value,'manual'))
   error('XLimMode must be set to ''auto'' or ''manual''.')
else
   [Value,BadInputFlag] = LocalFormat(Value,Size([2 4]));
   if BadInputFlag
      error('Unexpected length for XLimMode value.')
   end
   % Check compatibility with XLimSharing
   if (strcmp(this.XLimSharing,'all') & Size(2)*Size(4)>1 & ~isequal(Value{:})) | ...
         (strcmp(this.XLimSharing,'peer') & Size(2)>1 & ...
         ~isequal(Value,repmat(Value(1:Size(4)),[Size(2) 1])))
      error('XLimMode value is incompatible with XLimSharing settings.')
   end
end


function Value = LocalYLimModeFilter(this,Value)
% Correctly formats YlimMode settings
Size = this.Size;
if ~all(strcmpi(Value,'auto') | strcmpi(Value,'manual'))
   error('YLimMode must be set to ''auto'' or ''manual''.')
else
   [Value,BadInputFlag] = LocalFormat(Value,Size([1 3]));
   if BadInputFlag
       error('Unexpected length for YLimMode value.')
   end
   % Check compatibility with YLimSharing
   if (strcmp(this.YLimSharing,'all') & Size(1)*Size(3)>1 & ~isequal(Value{:})) | ...
         (strcmp(this.YLimSharing,'peer') & Size(1)>1 & ...
         ~isequal(Value,repmat(Value(1:Size(3)),[Size(1) 1])))
      error('YLimMode value is incompatible with YLimSharing settings.')
   end
end


function Value = LocalXScaleFilter(this,Value)
% Correctly formats XScale value
if ~all(strcmpi(Value,'linear') | strcmpi(Value,'log'))
   error('XScale must be set to ''linear'' or ''log''.')
else
   [Value,BadInputFlag] = LocalFormat(Value,this.Size(2:2:end));
   if BadInputFlag
      error('Unexpected length for XScale value.')
   end
end


function Value = LocalYScaleFilter(this,Value)
% Correctly formats YScale value
if ~all(strcmpi(Value,'linear') | strcmpi(Value,'log'))
   error('YScale must be set to ''linear'' or ''log''.')
else
   [Value,BadInputFlag] = LocalFormat(Value,this.Size(1:2:end));
   if BadInputFlag
      error('Unexpected length for YScale value.')
   end
end


function Value = LocalXUnitFilter(this,Value)
% Correctly formats XUnit settings (must be cell array of same length as subgrid col size)
Size = this.Size;
if Size(4)==1
   % No subgrid along column -> XUnit is a string
   if iscellstr(Value) & isequal(size(Value),[1 1])
      Value = Value{1};
   elseif ~ischar(Value)
      error('Bad value for XUnit property.')
   end
else
   % Multi-column subgrid: XUnit is a cell
   [Value,BadInputFlag] = LocalFormat(Value,Size(4));
   if BadInputFlag
      error('Unexpected length for XUnit value.')
   end
end


function Value = LocalYUnitFilter(this,Value)
% Correctly formats YUnit settings (must be cell array of same length as subgrid row size)
Size = this.Size;
if Size(3)==1 
   % No subgrid along column -> YUnit is a string
   if iscellstr(Value) & isequal(size(Value),[1 1])
      Value = Value{1};
   elseif ~ischar(Value) & ~isequal(Size,[2 1 1 1])
      error('Bad value for YUnit property.')
   end
else
   [Value,BadInputFlag] = LocalFormat(Value,Size(3));
   if BadInputFlag
      error('Unexpected length for YUnit value.')
   end
end


function [Value,BadInput] = LocalFormat(Value,Sizes)
% Format string input
BadInput = false;
Sizes = [Sizes 1];
if ischar(Value), 
   Value = {Value}; 
end
switch length(Value)
case 1
   Value = Value(ones(1,prod(Sizes)),1);
case Sizes(2)
   % Specified for subgrid
   Value = repmat(Value(:),[Sizes(1) 1]);
case prod(Sizes)
   % Fully specified
   Value = Value(:);
otherwise
   BadInput = true;
end
