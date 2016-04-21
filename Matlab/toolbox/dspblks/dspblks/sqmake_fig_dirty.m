function sqmake_fig_dirty(hFig)
% MAKE the figure dirty depending on the title of this fig.
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/25 22:04:17 $

  file_title = get(hFig,'Name');
  try
     SQDesignFile = strcmp(file_title(1:14),['SQ Design Tool']);     
  catch 
     % this code should never be executed. 
     SQDesignFile = 0;
     errordlg('This is not a valid SQDesign file');
     return
  end     

  file_already_dirty = strcmp(file_title(end-1),'*');
  if (SQDesignFile && ~file_already_dirty)
      file_title(end) ='*';
      file_title(end+1) =']';
      set(hFig,'Name',file_title);
  elseif (~SQDesignFile)
      % this code should never be executed. 
      errordlg('This is not a valid SQDesign file');
  %elseif  file_already_dirty then do nothing     
  end      

% [EOF]
