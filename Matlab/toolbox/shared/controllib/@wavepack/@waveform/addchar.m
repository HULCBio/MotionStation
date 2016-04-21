function c = addchar(this,CharIdentifier,cd_class,cv_class)
%ADDCHAR  Adds characteristics to wave form.
 
%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:04 $
 
% Create @wavechar instance (container for characteristic data + view)
c = wavepack.wavechar;

% Initialize characteristic
c.Parent  = this;
c.Identifier = CharIdentifier; % needed, e.g., for step+hold+impulse

% Store Characteristic Data
AxGrid = this.Parent.AxesGrid;
for ct=length(this.Data):-1:1,
    cda(ct,1) = feval(cd_class);
    cva(ct,1) = feval(cv_class);
    % Generic @data init
    cda(ct).Parent = this.Data(ct);
    % Generic @view init (keep out of user-written INITIALIZE method)
    cva(ct).AxesGrid = AxGrid;
    cva(ct).Parent = this.View(ct);
    % @view-specific init
    cva(ct).initialize(getaxes(c));
end
c.Data = cda;
c.View = cva;

% Initialize visibility of characteristics' g-objects
refresh(c)
 
% Set default DataFcn and TipFcn
c.DataFcn = {@LocalUpdateData c};
addtip(c)

% Install generic @dataview listeners (don't make users do it)
generic_listeners(c);

% Listeners
L = [handle.listener(c, c.findprop('Visible'),'PropertyPostSet', @LocalVisible); ...
      handle.listener(cva,cva(1).findprop('Visible'),'PropertyPostSet',@LocalViewVisible)];
set(L,'CallbackTarget',c)
c.addlisteners(L);

% Append to characteristics list
this.Characteristics = [this.Characteristics;c];


%------------- Local Functions ---------------------------

function LocalUpdateData(c)
wf = c.Parent; % parent waveform
for ct=1:length(c.Data)
   % Propagate exceptions
   c.Data(ct).Exception = wf.Data(ct).Exception;
   if ~c.Data(ct).Exception
      update(c.Data(ct),wf)
   end
end

% ----------------------------------------------------------------------------%
% Purpose: Updates HG object visibility when visibility of 
%          particular View changes
% ----------------------------------------------------------------------------%
function LocalViewVisible(c, eventdata)
View = eventdata.AffectedObject;  % affected char. view
if isvisible(c) && isvisible(View)
   % Characteristic view is visible: refresh it
   View.refresh(refreshmask(c.Parent))
else
   View.refresh(false)
end
% Redraw
draw(c)


% ----------------------------------------------------------------------------%
% Purpose: Sets visibility of the overall @wavechar component.
% ----------------------------------------------------------------------------%
function LocalVisible(c, eventdata)
% Update visibility of characteristic's g-objects
refresh(c)
% Redraw
draw(c)
