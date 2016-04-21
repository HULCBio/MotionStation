function varargout = cvmissingblks(rootBlk,ignoreConditions)
%CVMISSINGBLKS - Identify blocks within a model that require coverage
%                but are currently uninstrumented.
%
%   CVMISSINGBLKS(MODEL) - Display a message with that lists each block
%   within MODEL that semantically requires structural coverage but is
%   currently uninstrumented by the Simulink Model Coverage tool.
%
%   BLOCKS = CVMISSINGBLKS(MODEL) - Suppress the display and instead return
%   a vector of block handles that require coverage but are currently 
%   uninstrumented.

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/13 00:34:35 $



	if ischar(rootBlk)
		rootBlk = get_param(rootBlk,'Handle');
	end
	
	if nargin<2
	    ignoreConditions = 0;
	end
	
	
	blockInfo = cell(0,2);

    % ================================================
    % Blocks that always have structural coverage
    % ================================================
    
    alwaysReqDecisionCoverage = { ...
                        'Backlash', ...
                        'DeadZone', ...
                        };
                        

	for blkType = alwaysReqDecisionCoverage
		msg = sprintf(['The %s block incorporates control flow decisions that', ...
					   ' are not recorded in this release of the Model Coverage', ...
					   ' tool.'],blkType{1});
		blkH = find_matching_blocks(rootBlk,blkType{1});
		if ~isempty(blkH)
			blockInfo = [blockInfo; num2cell(blkH(:)) cellstr(char(ones(length(blkH),1)* msg))];
		end
	end
	
	
	   
    % ================================================
    % Blocks that have structural depending on use
    % ================================================
    
    % ModelReference
   	blkH = find_matching_blocks(rootBlk,'ModelReference');
	if ~isempty(blkH)
		msg = sprintf(['The Model Block incorporates the contents of a referenced model.', ...
					   '  The coverage tool is not able to record the behavior', ...
					   ' of blocks within the referenced model that may contain', ...
					   ' look-up tables, conditions, and decisions.']);
		blockInfo = [blockInfo; num2cell(blkH(:)) cellstr(char(ones(length(blkH),1)* msg))];
    end
    
    
    
    % Integrator
   	blkH = find_matching_blocks(rootBlk,'Integrator');
	if ~isempty(blkH)
	    hasLimit = strcmp(get_param(blkH,'LimitOutput'),'on');       
	    hasReset = ~strcmp(get_param(blkH,'ExternalReset'),'none');       
	   
	   	blks = blkH(hasLimit & ~hasReset);
	   	if ~isempty(blks)
			msg = sprintf(['This integrator block incorporates control flow decisions due', ...
						   ' to its limited output and is not recorded in this release of', ...
						   ' the Model Coverage tool.']);
			blockInfo = [blockInfo; num2cell(blks(:)) cellstr(char(ones(length(blks),1)* msg))];
		end
		
		                
	   	blks = blkH(hasLimit & hasReset);
	   	if ~isempty(blks)
			msg = sprintf(['This integrator block incorporates control flow decisions due', ...
						   ' to its limited output and external reset and its behavior is not ', ...
						   'recorded in this release of the Model Coverage tool.']);
			blockInfo = [blockInfo; num2cell(blks(:)) cellstr(char(ones(length(blks),1)* msg))];
		end
		
	                
	   	blks = blkH(~hasLimit & hasReset);
	   	if ~isempty(blks)
			msg = sprintf(['This integrator block incorporates control flow decisions due', ...
						   ' to its external reset and its behavior is not ', ...
						   'recorded in this release of the Model Coverage tool.'],blkType{1});
			blockInfo = [blockInfo; num2cell(blks(:)) cellstr(char(ones(length(blks),1)* msg))];
		end
		
	end
                
    
    if ~isempty(blockInfo)
        create_all_nags(blockInfo,rootBlk);
    end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND_MATCHING_BLOCKS - Search the model for all blocks of a certain
% type matching a specified condition.  The testFcn argument is optional 
% and should be a string that tests block properties and returns a logical
% array

function matchingBlocks = find_matching_blocks(rootH,typeStr,testFcn)

	if nargin<3
		testFcn = [];
	end
	
	% Get all the blocks with a particular 
	matchingBlocks = find_system(rootH,'FollowLinks', 'on', ...
                                    'LookUnderMasks', 'all', ...
                                    'BlockType',typeStr);
    
	if ~isempty(testFcn)
		blks = matchingBlocks;
		includeIdx = eval(testFcn);
		matchingBlocks = matchingBlocks(includeIdx);
	end
	
	
	
	

function [fullPath,name] = get_name_strings(blockH)
	name = get_param(blockH,'Name');
	fullPath = [get_param(blockH,'Parent') '/' name];



function create_all_nags(blockInfo,rootBlk)

	[rows,cols] = size(blockInfo);
	

    %
    % begin of process that may incur errors, warnings, etc.
    %
    slsfnagctlr('Clear', getfullname(rootBlk), 'Model Coverage Tool');

    % an error is detected
    for i=1:rows
    	[fullPath,name] = get_name_strings(blockInfo{i,1});
    	
        %
        % compose a NAG (example of a Parse Error)
        %
        nag                =  slsfnagctlr('NagTemplate');
        nag.blkHandles     = blockInfo{i,1};
        nag.type           = 'Warning';                  
        nag.msg.type       = 'Cov';                      
        nag.msg.details    = blockInfo{i,2}; 				
        nag.msg.summary    = 'Block not recorded';           
        nag.sourceFullName = fullPath;          
        nag.sourceName     = name;                    
        nag.component      = 'Simulink';                      

        slsfnagctlr('Push', nag);
    end;

    slsfnagctlr('View');
	