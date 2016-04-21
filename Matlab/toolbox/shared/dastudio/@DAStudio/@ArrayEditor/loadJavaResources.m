function loadJavaResources(h)
%  LOADJAVARESOURCES
%  This function will load the java resources
%  for the Array Editor
%  Copyright 1990-2004 The MathWorks, Inc.
  
import com.mathworks.toolbox.dastudio.arrayEditor.*;

%If java is not engaged engage it

if ( h.javaEngaged == 1)
  if (h.javaAllocated == 0)
    % Here make the actual Java object 
    hjava = java(h);
    win = com.mathworks.toolbox.dastudio.arrayEditor.DAArrayEditor(hjava);
    % Here set the appropriate field within the UDD object
    % to let it know it is associated with this Java object 
    h.jArrayEditorWindow= handle(win);     
    % Here mark the java as being engaged   
    h.javaAllocated = 1;
  else 
    error('First Unload your existing java resources before loading new ones '); 
  end;
end;
