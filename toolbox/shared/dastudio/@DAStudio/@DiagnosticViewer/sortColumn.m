function sortColumn(h, columnIndex)
%  SORTCOLUMN
%  sortColumn provides the functions for sorting 
%  a column of the diagnostic viewer  
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 

  
%  Here walk through all messages and save the info
%  in an array

  names = {};
  for i = 1:length(h.Messages)
    msg = h.Messages(i);
    name = find_string_to_sort(msg,columnIndex);
    names = [names name];
  end    
  
  % sort these indices
  [b indx] = sort(lower(names));
  % You may have to reverse your order of sorting
  % if the user clicks on the header twice
  tmp = h.reverseSort;
  if (h.reverseSort(columnIndex) > 0)
     indx = fliplr(indx);
     tmp(columnIndex) = -1.0;
  else
     tmp(columnIndex) = 1.0;
  end
  % Here make sure you set the reverseSort to be tmp
  h.reverseSort = tmp;
  % Here remember which row is selected you have to
  % set the same row as being selected afterwards
  row = h.rowSelected;
  newIndex = find(indx==row);
  % Here you rearrange the h.Messages 
  h.Messages = h.Messages(indx);
  % Let java reflect what is in m
  % Here set the selected row to be the same
  % as it was before you rearranged your rows
   h.synchronizeJavaViewer(newIndex);
  
% this is a helper function meant to find the appropriate string
% based on the column involved
function str2 = find_string_to_sort(msg,columnIndex)

c = msg.Contents;

switch(columnIndex)
 case 1, 
      str2 = cellstr(msg.Type);
 case 2,
      str2 = cellstr([c.Type ,'/', msg.Type]);
 case 3, str2 = cellstr(msg.sourceName);
 case 4, str2 = cellstr(msg.Component);
 case 5, str2 = cellstr(c.Summary);  
end
