function hyperlink(h,type, vargin)
%  HYPERLINK
%  This function will open a hyperlink
%  for the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%  $Revision: 1.1.6.2 $ 


  switch type,
   case 'id',
    txt = vargin;        % remove beginning 
    [s,e] = regexp(txt,'\d+');
    id1 = 0;
    id2 = 0;
    id3 = 0;
    if(length(s)>=1)
      id1 = str2num(txt(s(1):e(1)));
    end
    if (length(s)>=2)
      id2 = str2num(txt(s(2):e(2)));
    end
    if (length(s)>=3)
      id3 = str2num(txt(s(3):e(3)));
    end
    sf('Open', id1,id2,id3);
   case 'txt',
    t = vargin;
    
    if (t(1) == '"'),
        t(t=='"') = '''';
    end
    if (exist(t) == 7),
       % curDir = pwd;
       % cd (t);
       % cmd = ['cmd /c start',10];
       % dos(cmd);
       % cd(curDir);
       error('Should not be in txt hyperlinking');
    else
        edit(t);
    end;   
    
   case 'dir',
    t = vargin;
    
    if (t(1) == '"'),
        t(t=='"') = '''';
    end
    
        curDir = pwd;
        cd (t);
   
    if ispc,
        cmd = ['cmd /c start',10];
    elseif isunix,
      cmd = ['xterm &'];
    else
      return;
    end;   
    dos(cmd);
    cd(curDir);
    
   case 'mdl',
    txt = vargin;
    %txt([1 end]) = [];  % remove quotes
    % This entity may already be deleted watch out
    try,
      blockH = get_param(txt, 'handle');
    catch,
      disp('Error in hyperlink, Entity not found');
      return;
    end;
    if (ishandle(blockH))
      if strcmp(get_param(blockH,'Type'),'block') & ...
              ~strcmp(get_param(blockH,'iotype'),'none')
          bd = bdroot(blockH);
          iomanager('Create',bd);
          iomanager('SelectObject',blockH);
      else
        open_block_and_parent_l(h,blockH);
      end
    else
      disp('Invalid Handle Error')
    end
  
  case 'bus',
   txt = vargin;
   try
     buseditor('Create', txt)
   end
  end %end switch
%--------------------------------------------------

%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:38 $
function open_block_and_parent_l(h,blockH),
%
% Open block and parent
%
  dehilitBlocks(h);
  switch get_param(blockH, 'Type'),
   case 'block',
    parentH = get_param(blockH,'Parent');
    % Check if block still exists (not in undo stack only)
    checkBlks = find_system(parentH, 'SearchDepth', 1, ...
                            'FollowLinks', 'on', ...
                            'LookUnderMasks', 'on', ...
                            'Handle', blockH);
    if ~isempty(checkBlks)
      deselect_all_blocks_in_l(parentH);
      hiliteBlocks(h, blockH)
      set_param(blockH,'Selected','on'); 
    end
   case 'block_diagram', open_system(blockH);
   otherwise,
  end;
%-------------------------------------------------------------------------
function deselect_all_blocks_in_l(sysH),
%
%
%
  selectedBlocks = find_system(sysH, 'SearchDepth', 1, 'Selected', 'on');
  for i = 1:length(selectedBlocks), 
    set_param(selectedBlocks{i},'Selected','off'); 
  end;

