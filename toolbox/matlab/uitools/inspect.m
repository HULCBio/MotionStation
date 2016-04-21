function inspect(varargin)
%INSPECT Open the inspector and inspect object properties
%
%   INSPECT (h) edits all properties of the given object whose handle is h,
%   using a property-sheet-like interface.
%   INSPECT ([h1, h2]) edits both objects h1 and h2; any number of objects
%   can be edited this way.  If you edit two or more objects of different
%   types, the inspector might not be able to show any properties in common.
%   INSPECT with no argument launches a blank inspector window.
%
%   Note that "INSPECT h" edits the string 'h', not the object whose
%   handle is h.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $

% error out if there is insufficient java support on this platform
  error(javachk('jvm', 'The Property Inspector'));

  import com.mathworks.ide.inspector.Inspector;

switch nargin
    
    case 0
        % Show the inspector.
        Inspector.activateInspector;
        
    case 1
        obj = varargin{1};
        hdl = obj(ishandle(obj) & ~isjava(obj));
        if ~isempty(hdl)
            len = length(hdl);
            if len == 1
                obj = requestJavaAdapter(hdl);
                Inspector.inspectObject(obj);
            else
                obj = requestJavaAdapter(hdl);
                Inspector.inspectObjectArray(obj);
            end
            hobj = handle(hdl);
        
           % listen to when the object gets deleted and remove 
           % from inspector. A persistent variable is used since 
           % the inspector is a singleton. If we do go away from
           % a singleton then this will have to be stored elsewhere.
           persistent deleteListener;
           deleteListener = handle.listener(hobj, 'ObjectBeingDestroyed', ...
                                            {@objectRemoved, obj, Inspector.getInspector.getRegistry});
        
        else
            Inspector.inspectObject(obj);
        end
        
    otherwise
        % bug -- need to make java adapters for multiple arguments
        Inspector.inspectObjectArray(varargin);
        
end


function objectRemoved(hSrc, event, obj, objRegistry)
import com.mathworks.ide.inspector.Inspector;

objRegistry.setSelected({obj}, 0);
