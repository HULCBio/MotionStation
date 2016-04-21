function selectListener(h)
%  SELECTLISTENER
%  This function is the listener for selecting messages
%  within the diagnostic viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
hRow = findprop(h, 'RowSelected');
h.hSingleClickListener = handle.listener(h, hRow, ...
                         'PropertyPostSet', {@click_broadcast,h});
 
function click_broadcast(obj, evd, h) 
row = h.rowSelected;
if (row > 0)
  javahandle = java(h.jDiagnosticViewerWindow);
  msg = h.Messages(row);
  c = msg.Contents;
  % Here we want to make sure java window is consistent with UDD
  row_java = javahandle.getSelectedRow;
  if (row_java ~= row)
    javahandle.setSelectedRow(row);
  end
  % Here we want to tranform this summary to 
  % find all html link within it
  if (c.HyperSearched == 0)
    c.Details = msg.findhtmllinks(c.Details);
    c.HyperSearched = 1;
  end
  % Here set the wrapping mode for your text area based on
  % the type of the message
  switch c.type,
   case {'Lex', 'Coder', 'Make'}, wrappingOn = 0;
   otherwise, wrappingOn = 1;
  end;
  javahandle.setWrappingOption(wrappingOn);
  % You also have to be careful to set the font differently 
  % in the text area for certain kinds of errors
  switch c.type,
   case {'Lex', 'Parse', 'Coder', 'Make', 'Build'},
    javahandle.setMonospacedFontForTextArea;
   otherwise, %do nothing;
  end;
  % This will set the TextArea in java which will populate both 
  % the fullPath and summary fields.
  javahandle.setTextArea(java(msg));
  %Dehilite all the previously hilited objects
  dehilitBlocks(h);
  % Here hilite the blocks
  if (~isempty(msg.AssocObjectNames))
    hiliteBlocks(h,msg.AssocObjectHandles);
  end;
  % Bring this window up front
  javahandle.toFront;
  % Give the focus back to the java window 
  javahandle.requestFocus;
end
%-----------------------------------------------------------------
 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:45 $



