function [textout,report] = sldiagnostics(sys, varargin)
%SLDIAGNOSTICS Count blocks, Sizes, time,memory used in compiling model.
%
%   SLDIAGNOSTICS(SYS) counts the block types in the model or
%   subsystem of a model and gives a textual report on the amount
%   of time and memory each phase of preparation of the root model
%   use before a run.  The model does not have to be currently 
%   loaded as long as it is on the MATLAB path.   To see memory usage,
%   you must run MATLAB with the -check_malloc flag.  This can be done  
%   on Windows platforms by selecting Start, then Run... and typing
%   matlab.exe -check_malloc in the command field. On Unix platforms 
%   activate memory tracking  with:  'matlab -check_malloc'.
%
%   SLDIAGNOSTICS(SYS,OPTIONS) performs each operation listed in
%   OPTIONS, which can be 'CountBlocks', 'CountSF', 'CompileStats', 
%   'Sizes', 'Verbose', or 'All', as follows:  
%
%   'All'         - performs all diagnostics
%  
%   'CountBlocks' - returns a textual report giving the number of
%                   unique block and mask types found in a system.
%                   The system does not have to be currently loaded 
%                   as long as it is on the MATLAB path.  The search
%                   looks into masked subsystems to any search depth.
%                   Can also return a data structure in the second
%                   return value.
%
%   'CountSF'     - returns a textual report giving the number of
%                   Stateflow objects of each type. Can also return
%                   a data structure in the second return value.
%
%   'CompileStats'- returns a textual report of the time and 
%                   additional memory used for each compilation 
%                   phase of MDL.  Running this before running the 
%                   model for the first time will show higher memory 
%                   usage; subsequent compilestats runs return a lower 
%                   amount of differential memory usage for MDL.
%
%                   The compiled statics (CStat's) are displayed for
%                   each of the significant stage of Simulink block
%                   diagram compilation. This information is typically
%                   provided to the MathWorks when helping customers
%                   troubleshoot model compilation speed and/or memory
%                   issues. Items like the computed memory usage let 
%                   us see how much memory a particular stage of model
%                   compilation is taking.
%                  
%   'Sizes'       - returns a textual report of the number of states, 
%                   inputs, outputs, sampletimes, and a flag indicating
%                   direct feedthrough.  Can also return a data 
%                   structure in the second return value.
%
%   'Libs'       - returns a textual report of libraries referenced in MDL.
%
%   'Verbose'     - outputs to the command window during the compilestats 
%                   run then produces a text output.  This is useful in 
%                   diagnosing the compilation itself if it takes an 
%                   unreasonable amount of time to return or if it hangs.
%
%   [TXTRPT, SRPT] = SLDIAGNOSTICS(MDL,'CountBlocks') produces both a 
%   textual report and a structure array with fields 'ismask', 'type', 
%   and 'count' for the block count calculation.  The block count 
%   gives the number of each unique type of block or mask found in 
%   a system.  The system does not have to be currently loaded as 
%   long as it is on the MATLAB path.  The search continues into 
%   masked subsystems to any search depth.  Special accounting is used
%   for Stateflow and Embedded MATLAB blocks.
%
%   See also FIND_SYSTEM, GET_PARAM
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.8.2.3 $  $Date: 2004/04/15 00:49:26 $


% --- determine the action(s) specified

  if nargin == 1
    doCountBlocks  = true;
    doCountSF      = true;
    doCompileStats = true;
    doReportSizes  = true;
    doCountLibs    = true;
    verboseStats   = false;
  else
    msg = ['OPTION must be string ''CountBlocks'', ''CountSF'', ' ...
           '''CompileStats'', ''Sizes'', ''Libs'',''Verbose'' or ''All'''];
    doCountBlocks  = false;
    doCountSF      = false;
    doCompileStats = false;
    doReportSizes  = false;
    doCountLibs    = false;
    verboseStats   = false;
    for k=1:length(varargin)
      if ischar(varargin{k})
        switch lower(varargin{k})
         case 'countblocks'
          doCountBlocks  = true;
         case 'countsf'
          doCountSF      = true;
         case 'compilestats'
          doCompileStats = true;
         case 'verbose'
          doCompileStats = true;
          verboseStats   = true;
         case 'sizes'
          doReportSizes  = true;
         case 'libs'
          doCountLibs    = true;
         case 'all'
          doCountBlocks  = true;
          doCountSF      = true;
          doCompileStats = true;
          doReportSizes  = true;
          doCountLibs    = true;
         otherwise
          error('Simulink:sldiagnostics:UnknownCommandOption1', ...
              ['Unknown command option ''' varargin{k}, '''.  ', msg]);
        end
      else
        error('Simulink:sldiagnostics:UnknownCommandOption2', '%s', msg);
      end
    end
  end

  % --- find the model to work on, load it if it is not loaded
  
  checkopen(sys);
  mdl = bdroot(sys);
  
  % --- Initialize outputs
  
  textout  = '';

  report   = [];
  blockrpt = [];
  sfrpt    = [];
  sizerpt  = [];
  librpt   = [];

  if ( ~doCountBlocks && ~doReportSizes && ~doCountLibs && ~doCountSF) ...
          && (nargout > 1)
    error('Simulink:sldiagnostics:StructureOutputNotValid', ...
        ['Report structure output only valid for', ...
        ' ''CountBlocks'', ''CountSF'', ''Sizes'', ''Libs'', or ''All'''] );
  end

  
  % ==== Process commands
  
  
  if doCountBlocks,  %----------------------------------------------------
    
    % --- get the raw list of blocks then get unique lists
    
    s = find_system(sys, 'FollowLinks','on','LookUnderMasks','all');
    
    total       = length(s) - 1;
    sBlockTypes = get_param(s(2:end),'BlockType');
    blockTypes  = unique(sBlockTypes);
    sMaskTypes  = get_param(s(2:end),'MaskType');
    maskTypes   = unique(sMaskTypes);
    if strcmp(maskTypes{1}, ''),
        maskTypes = maskTypes(2:end);
    end
    
    % --- build the empty report structure
    
    numMaskTypes = length(maskTypes);
    numRecs      = 1 + length(blockTypes) + numMaskTypes;
    rptStruct    = struct('isMask',[],'type',[],'count',[]);
    blockrpt     = repmat( rptStruct, numRecs, 1 );
    
    % --- get info for each unique block and mask type found in the model
    
    ssLocIdx     = [];
    sfcnLocIdx   = [];
    sfLocIdx     = [];
    
    blockrpt(1).isMask = 0;
    blockrpt(1).type   = [ sys, ' Total blocks' ];
    maxNameWidth       = length( blockrpt(1).type );
    
    for k=1:length(blockTypes)
        blockrpt(k+1).isMask = 0;
        
        blockrpt(k+1).type   = blockTypes{k};
        maxNameWidth         = max( length(blockTypes{k})+1, maxNameWidth );
        
        isOfBlockType        = strcmp( sBlockTypes, blockTypes{k} );
        blockrpt(k+1).count  = sum( isOfBlockType );

        if isempty(ssLocIdx) && strcmp(blockTypes{k},'SubSystem'),
            ssLocIdx = k+1;
        end
        if isempty(sfcnLocIdx) && strcmp(blockTypes{k}, 'S-Function'),
            sfcnLocIdx = k+1;
        end
    end

    b = k+1;
    
    for k=1:numMaskTypes
        blockrpt(b+k).isMask = 1;
        
        blockrpt(b+k).type   = maskTypes{k};
        maxNameWidth         = max( length(maskTypes{k})+1, maxNameWidth);
        
        isOfMaskType         = strcmp( sMaskTypes, maskTypes{k} );
        blockrpt(b+k).count  = sum( isOfMaskType );

        % --- Special case for the 'Stateflow' mask type
        
        if strcmp(maskTypes{k}, 'Stateflow'),
            blockrpt(b+k).isMask       = 0;
            sfLocIdx                   = b+k;
            numSF                      = blockrpt(sfLocIdx).count;
            
            % --- SubSystem and S-Function counts exist and have some SF
            blockrpt(ssLocIdx).count   = blockrpt(ssLocIdx).count - numSF;
            blockrpt(sfcnLocIdx).count = blockrpt(sfcnLocIdx).count - numSF;
            total = total - numSF;
            
            % --- find any Stateflow blocks that are eML blocks
            sfBlkList = find_system(sys, ...
                'FollowLinks','on', ...
                'LookUnderMasks','all', ...
                'MaskType', 'Stateflow');
            numEml = sum(locIsEml(get_param(sfBlkList,'handle')));
            
            blockrpt(sfLocIdx).count = numSF - numEml;
        end
            
    end

    % --- If present, insert Stateflow and eML blocks into the count at 
    %     the right spot(s)
    
    if ~isempty(sfLocIdx),
        blockIdx    = 2:b;
        
        % --- add eML blocks here
        
        if exist('numEml','var') && numEml > 0
            emlStruct = blockrpt(sfLocIdx); % clone
            emlStruct.type  = 'EmbeddedMATLABFunction';
            emlStruct.count = numEml;
            blockBlks   = [blockrpt(blockIdx); blockrpt(sfLocIdx); emlStruct];
        else
            blockBlks   = [blockrpt(blockIdx); blockrpt(sfLocIdx)];
        end
        
        % --- clean up list with a re-sort, put masks at the end
        
        [dummy,idx] = sort( { blockBlks.type } );
        maskIdx     = (b+1):(sfLocIdx-1);
        if sfLocIdx < length(blockrpt),
            maskIdx = [ maskIdx, (sfLocIdx+1):length(blockrpt) ];
        end
        blockrpt    = [ blockrpt(1); blockBlks(idx); blockrpt(maskIdx) ];
    end

    % --- Set total count
    %     Stateflow blocks are made of S-fcn + SubSystem, 
    %     don't count them multiple times
    
    blockrpt(1).count = total;
    
    % --- Output conversion for text
    
    line = sprintf( ...
        ['Finished counting blocks in ''', sys,'''.\n', ...
        'Found ', sprintf('%d',total), ' blocks.']);
    line = sprintf('%s\n\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n\n',line,...
        'NOTE: an ''M'' next to a block type indicates that it is a  ',...
        '      masked SubSystem or a masked S-Function and is        ',...
        '      included in the total block count under the           ',...
        '      SubSystem and S-Function block totals already.        ',...
        '      Embedded MATLAB and Stateflow blocks are subtracted   ',...
        '      from the SubSystem and S-function totals, but not the ',...
        '      support blocks inside Embedded MATLAB.                ');
    
    % --- text version of output
    
    textout = cell(numRecs+1,1);
    textout{1} = sprintf('%s\n', line);
    
    fmtStr = [ '%1s %', sprintf('%d',maxNameWidth+2), 's : %5d\n' ];
    NoteChars = ' M';
    for k = 1:length(blockrpt),
        if blockrpt(k).count > 0,
            maskNote     = NoteChars(1+blockrpt(k).isMask);
            textout{k+1} = sprintf( fmtStr, maskNote, ...
                blockrpt(k).type, blockrpt(k).count);
        end
    end
    
    textout = [textout{:}];
    
  end

  
  if doCountSF,  %--------------------------------------------------------
    
    % --- Report all the Stateflow sizes
    
    find_system(sys, 'FollowLinks','on','LookUnderMasks','all');
    
    % Don't count EmlChart objects as Stateflow, they are Simulink Blocks
    sfStuffList = {'Chart', 'GroupedState', 'State', 'Box', ...
                   'EMFunction', 'EMChart', 'Function', 'LinkChart', ...
                   'TruthTable', 'Note', 'Transition', 'Junction', ...
                   'Event', 'Data', 'Target', 'Machine'};
    numItems    = length(sfStuffList);
    kg          = strmatch( 'GroupedState', sfStuffList, 'exact' );

    rt = sfroot;
    m  = rt.find('-isa', 'Stateflow.Machine', '-and', 'Name', mdl);
    sfrpt = struct('class', [], 'count', []);
    sfrpt = repmat(sfrpt, numItems, 1);
    
    groupedCount = 0;
        
    for k = 1:numItems,
      if ishandle(m),
          Hobjs = findDeep(m, sfStuffList{k});
          count = length(Hobjs);
      else
          count = 0;
      end

      if strcmp(sfStuffList{k}, 'State'),
        % --- Count grouped states separately
        for j = 1:count,
          if get(Hobjs(j), 'IsGrouped'),
            groupedCount = groupedCount + 1;
          end
        end
        count = count - groupedCount;

        sfrpt(kg).class = sfStuffList{kg};
        sfrpt(kg).count = groupedCount;

        sfobjtxt{kg} = sprintf('%25s : %4d', sfStuffList{kg}, groupedCount);
      end
      
      sfrpt(k).class = sfStuffList{k};
      sfrpt(k).count = count;

      sfobjtxt{k} = sprintf('%25s : %4d', sfStuffList{k}, count);
      
    end  

    sftextout = sprintf('\n---------- Stateflow Count --------');
    sftextout = sprintf('%s\n%s\n', sftextout, sfobjtxt{:});
    sftextout = sprintf('%s--------- End Stateflow Count ------\n',sftextout);
    
    textout = [textout, sftextout];
  end
  
  
  if doReportSizes,  %----------------------------------------------------
      
      % --- get the model sizes

      [r, stats] = evalc([get_param(mdl,'Name'),'([],[],[],0)']);
      tmpstr={'Number of continuous states:',...
          '  Number of discrete states:',...
          '          Number of outputs:',...
          '           Number of inputs:',...
          'Flag for direct feedthrough:',...
          '     Number of sample times:'};
      
      textout=sprintf('%s\n\n---------model sizes-------------',textout);

      NumContStates  = stats(1);
      NumDiscStates  = stats(2);
      NumOutputs     = stats(3);
      NumInputs      = stats(4);
      DirFeedthrough = stats(6);
      NumSampleTimes = stats(7);

      textout=sprintf('%s\n%s\t\t%d',textout,char(tmpstr(1)),NumContStates);
      textout=sprintf('%s\n%s\t\t%d',textout,char(tmpstr(2)),NumDiscStates);
      textout=sprintf('%s\n%s\t\t%d',textout,char(tmpstr(3)),NumOutputs);
      textout=sprintf('%s\n%s\t\t%d',textout,char(tmpstr(4)),NumInputs);
      textout=sprintf('%s\n%s\t\t%d',textout,char(tmpstr(5)),DirFeedthrough);
      textout=sprintf('%s\n%s\t\t%d',textout,char(tmpstr(6)),NumSampleTimes);
      textout=sprintf('%s\n---------end model sizes----------\n',textout);
      sizerpt=struct('NumContStates',  NumContStates,  ...
                     'NumDiscStates',  NumDiscStates,  ...
                     'NumOutputs',     NumOutputs,     ...
                     'NumInputs',      NumInputs,      ...
                     'DirFeedthrough', DirFeedthrough, ...
                     'NumSampleTimes', NumSampleTimes);
  end

  
  if doCountLibs,  %------------------------------------------------------
      
      % --- Count unique library links

      s = libinfo(mdl);
      tmp1 = cell(length(s),1);
      
      if ~isempty(s)
          for i=1:length(s)
              tmp1{i} = s(i).Library;
          end
          if ischar(tmp1)
              textout = sprintf('%s\n%s\n', textout, tmp1);
              sunique{1} = tmp1;
          else
              sunique = unique(tmp1);
              textout = sprintf('%s\n----------Unique library links--------',textout);
              textout = sprintf('%s\n%s\n',textout,sunique{:});
              textout = sprintf('%s-------End unique library links-------\n',textout);
          end
          librpt = struct('libs', sunique);
      end
  end
 
  
  if doCompileStats,  %---------------------------------------------------
    
    % --- Compile block diagram with compilestats turned on
    
    try
        scsOriginal = get_param(mdl,'DisplayCompileStats');
        set_param( mdl, 'DisplayCompileStats', 'on' );
        if verboseStats
            stats = [ ...
                evalc( 'feval(mdl,[],[],[],''compile'');' ), ...
                evalc( 'feval(mdl,[],[],[],''term'');' ) ]
        else
            stats = [ ...
                evalc( 'feval(mdl,[],[],[],''compile'');' ), ...
                evalc( 'feval(mdl,[],[],[],''term'');' ) ];
        end
        set_param( mdl, 'DisplayCompileStats', scsOriginal );
    catch
        actualLastErr = lasterr;
        if ~strcmp(get_param(mdl,'SimulationStatus'),'stopped')
            try
               eval( 'feval(mdl,[],[],[],''term'');');
            catch
            end
        end
        error('Simulink:sldiagnostics:ErrorFoundDuringCompileStats', ...
            ['sldiagnostics was unable to gather compilestats due ', ...
            'to this error: ', actualLastErr ] );

    end
    
    % --- 'stats' is a text stream: convert to lines of text
        
    if isempty(textout)
      textout = stats;
    else
      textout = sprintf('%s\n%s\n%s', textout,...
                        '---* Compilation Statistics *---',...
                        stats);
    end        
  end
  
  
  % --- figure out which item(s) to output -------------------------------
 
  if (~isempty(blockrpt) + ~isempty(sfrpt) + ...
      ~isempty(sizerpt) + ~isempty(librpt)) >= 2
    
     % --- have 2 or more report items
     
     if ~isempty(blockrpt)
       report.blocks = blockrpt;
     end
     if ~isempty(sizerpt)
       report.sizes = sizerpt;
     end
     if ~isempty(librpt)
       report.links = librpt;
     end
     if ~isempty(sfrpt)
       report.stateflow = sfrpt;
     end
  else
    
     % --- only have 1 report item, don't make a structure
     
     if ~isempty(librpt)
       report = librpt;
     elseif ~isempty(sfrpt)
       textout = sftextout;
       report = sfrpt;
     elseif ~isempty(sizerpt)
       report = sizerpt;
     else
       report = blockrpt;
     end
 end

%endfunction sldiagnostics


%=========================================================================
function isloaded = checkopen(sys)
% Checks if a model is open or if the input name is actually a subsystem
% or a block in a model.  If the name is a model and it is not loaded,
% go ahead and load it.
   
  % --- Check the easy case that the arg is for something already loaded

  try
      bdroot(sys);
      isloaded = true;
      return;
  catch
      mdl = sys;
      isloaded = false;
  end

  % --- If the easy case didn't work, keep going
   
  if ~isloaded,
      if exist(mdl) == 4,
          w = warning('off');
          load_system(mdl);
          isloaded = true;
          warning(w);
      else
          error('Simulink:sldiagnostics:CannotFindModelOrSystem', ...
              ['The model or system ''%s'' cannot be found. You must ',...
              'cd to the model''s directory, put its directory on ', ...
              'the matlabpath, or open the model before using it ',...
              'with sldiagnostics.'], sys);
      end
  end

%endfunction checkopen


%=========================================================================
function result = locIsEml(handleList)
%ISEML True if the block is an eML block 

% --- Qualify argument

argMsg = 'Input must be an array of handles, either numeric or cells';

if nargin ~= 1 
  error('Simulink:sldiagnostics:isEmlArgumentRequired', '%s', argMsg);
end

if iscell(handleList)
    blockHandle = [handleList{:}];
else
    blockHandle = handleList;
end

if ~isnumeric(blockHandle) || sum(~ishandle(blockHandle)) > 0
  error('Simulink:sldiagnostics:isEmlHandleRequired', '%s', argMsg);
end


% --- See if arguments are handles to Embedded MATLAB Function blocks

try
  result = zeros(size(blockHandle));
  for k = 1:length(blockHandle)
      chartId = sf('Private','block2chart', blockHandle(k));
      result(k) = double(~isempty(sf('find', chartId, 'chart.type', 2)));
  end
catch
    error('Simulink:sldiagnostics:isEmlFindFailed', '%s', ...
        'Embedded MATLAB Find operation failed');
end

%endfunction isEml

%[EOF] sldiagnostics.m
