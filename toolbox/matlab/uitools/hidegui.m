function varargout=hidegui(varargin);
%HIDEGUI Hide/unhide GUI.
%   HIDEGUI hides the current figure from the command line.
%   HIDEGUI(state) sets the hidden state of the current figure (state
%                  can be 'on' or 'off' or 'callback').
%   state=HIDEGUI returns the hidden state of the current figure.
%   HIDEGUI(H,state) queries or sets the hidden state of object H.
%
%   This function provides an interface to the HandleVisibility
%   property, which determines when an object's handle appears in its
%   parent's list of children.  When an object's HandleVisibility is
%   'off', its handle never shows up in its parent's list of children,
%   and that object can not be found by functions which operate by
%   selecting objects from the object hierarchy, such as PLOT, CLOSE,
%   GCF, GCA, GCO, and FINDOBJ.  When an object's HandleVisibility is
%   'callback', its handle is visible during callbacks, but is hidden
%   from functions invoked from the command line, when no callbacks are
%   executing.  When HandleVisibility is 'on', handles are always
%   visible.
%
%   HandleVisibility supersedes NextPlot 'new', and provides more
%   protection for GUIs from inadvertent damage caused by the
%   execution of functions from the command line.  Although NextPlot
%   'new' protected figures from high-level graphics functions such as
%   PLOT which obeyed NextPlot, it did not prevent handles from being
%   returned by GCF, GCA, GCO, or FINDOBJ, or operated on by CLOSE or
%   CLOSE('all').
%
%   When using HIDEGUI or HandleVisibility during the creation of a
%   GUI, from a function that may be invoked from the command line,
%   remember that the GUI figure's handle will no longer appear in
%   the object hierarchy after that point.  For this reason it is
%   recommended to call HIDEGUI at the end of GUI creation, so that
%   any creation code which relies on functions such as GCF and GCA
%   can operate normally.


%   Damian Packer, Revised by Loren Dean
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.14 $ $Date: 2002/04/15 03:24:37 $

switch nargout,
  case 0,  
    error(nargchk(0,2,nargin));
    switch nargin,
      case 0,    
        set_handles = gcf;
        set_state=LocalGetSetState(set_handles);  
        
      case 1,
        if isstr(varargin{1}),
          set_handles=gcf;
          set_state=lower(varargin{1});          
          if ~strcmp(set_state, 'on') & ~strcmp(set_state,'off') & ...
             ~strcmp(set_state,'callback')
            error('state must be ''on'' or ''off'' or ''callback''');
          end
          
        elseif all(ishandle(varargin{1})),          
          set_handles = varargin{1};
          set_state=LocalGetSetState(set_handles);
          
        else,
          error('Unrecognized input argument for HIDEGUI.');
        end
        
      case 2,
        set_handles=varargin{1};      
        set_state=varargin{2};        
        if ~isstr(set_state) | ...
           (~strcmp(set_state, 'on') & ~strcmp(set_state,'off') & ...
           ~strcmp(set_state,'callback')),
          error('state must be ''on'' or ''off'' or ''callback'' for HIDEGUI');
        end % if
        
    end % switch nargin
    
    if iscell(set_state),
      set(set_handles, {'HandleVisibility'}, set_state);
    else,
      set(set_handles, 'HandleVisibility', set_state);
    end % if
  
  case 1,
    error(nargchk(0,1,nargin));
    if nargin==1,
      if ishandle(varargin{1})
        get_handles = varargin{1};
      else
        error('Invalid handles passed to HIDEGUI.');
      end
    else
      get_handles = gcf;
    end
  
    varargout{1} = get(get_handles,'HandleVisibility');
  
otherwise,
  error('Too many output arguments for HIDEGUI.');

end % switch


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetSetState %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function set_state=LocalGetSetState(Handles)
state=get(Handles,{'HandleVisibility'});
for lp=1:length(Handles),
  if strcmp(state{lp},'callback') | strcmp(state{lp},'off'),
    set_state{lp,1}='on';
  else,
    set_state{lp,1}='off';
  end
end  

