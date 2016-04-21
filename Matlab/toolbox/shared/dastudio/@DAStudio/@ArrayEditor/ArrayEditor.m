function h = ArrayEditor(value_in)
%  ARRAYEDITOR
%  This is the constructor for the 
%  Array Editor
%  Copyright 1990-2004 The MathWorks, Inc.
  
 rt = DAStudio.Root;
 h = DAStudio.ArrayEditor;
 % Here load the appropriate listeners for these properites
 h.visibleListener;
 h.value = value_in; 
 %Here initialize appropriate fields
 connect(rt,h,'down');
