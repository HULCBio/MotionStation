function vqmake_fig_dirty(hFig)
% MAKE the figure dirty depending on the title of this fig.
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:18:00 $

  file_title = get(hFig,'Name');
  ud=get(hFig,'UserData');
  tool_str = 'VQ Design Tool';
  error_prompt = 'This is not a valid VQ Design file';
  try
     QDesignFile = strcmp(file_title(1:14),tool_str);     
  catch 
     % this code should never be executed. 
     QDesignFile = 0;
     errordlg(error_prompt);
     return
  end     

  file_already_dirty = strcmp(file_title(end-1),'*');
  if (QDesignFile && ~file_already_dirty)
      file_title(end) ='*';
      file_title(end+1) =']';
      set(hFig,'Name',file_title);
  elseif (~QDesignFile)
      % this code should never be executed. 
      errordlg(error_prompt);
  %elseif  file_already_dirty then do nothing     
  end      

% [EOF]
