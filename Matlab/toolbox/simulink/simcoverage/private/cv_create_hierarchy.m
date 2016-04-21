function cv_create_hierarchy(varargin)
%CV_CREATE_HIERARCHY Build the model hierarchy in the coverage tool.
%

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/03/23 02:59:38 $


switch(nargin),
case 1
	error('cv_create_hierarchy needs at least 2 arguments');

case 2
	modelCovId = varargin{1};
	modelHandle = varargin{2};

    rootHandles = cv_settings('findRoots',modelHandle);

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Make sure at least one root exists
    if isempty(rootHandles)
        set_param(modelHandle,'RecordCoverage','off');
        return;
    end
          
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Sort the root objects
    names = [];
    for h = rootHandles,
        names{end+1} = full_path_from_handle(h);
    end
    [sortedNames,sortIdx] = sort(names);
    rootHandles = rootHandles(sortIdx);

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Make sure the model tree is empty
    firstChild = cv('get',modelCovId,'modelcov.treeNode.child');
    if firstChild~=0, 
        errror('The model tree should be empty before building hierarchy');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Create the root handles 
    for h = rootHandles,
        create_branch_cv_objs(h,0,modelCovId);
    end
    
case 3
	subsysHandle= varargin{1};
	rootSlsfId= varargin{2};
	modelCovId= varargin{3};
    create_branch_cv_objs(subsysHandle,rootSlsfId,modelCovId);

    % Install ID if the top slsf is not the entire model
    if(subsysHandle ~= get_param(bdroot(subsysHandle),'Handle'))
        set_param(subsysHandle,'CoverageId',rootSlsfId);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FULL_PATH_FROM_HANDLE
%
% Get the full path from the Simulink handle


function name = full_path_from_handle(handle),
    
    name = get_param(handle,'Name');
    parent = get_param(handle,'Parent');
    if ischar(parent)
       name = [parent '/' name];
       return;
    end
    
    root = bdroot(handle);
    
    if(root==handle)
        return;
    end
    
    
    while(parent ~= root)
        name = [get_param(parent,'Name') '/' name];
        parent = get_param(parent,'Name');
    end
    
    name = [get_param(root,'Name') '/' name];
    


    