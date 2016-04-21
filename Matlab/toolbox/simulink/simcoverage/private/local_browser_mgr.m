function varargout = local_browser_mgr(method,varargin)
%LOCAL_BROWSER_MGR - Manage instantiating a web browser 
%for the coverage tool.
%

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

    persistent hBrowser;
    
    if nargin<1
        method = 'get';
    end
    
    switch(method)
    case 'get'
        varargout{1} = hBrowser;
    case 'displayFile'
        filePath = varargin{1};
        url = ['file:///' filePath];
        
        if ~isempty(hBrowser)
            % Use a try-catch in case the browser was closed
            try,
                valid = hBrowser.isValid;
                if ~valid
                    hBrowser = [];
                end
            catch,
                hBrowser = [];
            end
        end
        
        if isempty(hBrowser)
            [status,hBrowser,loc] = web(url, '-new');
        else
            try,
                hBrowser.setCurrentLocation(url);
            catch,
                    hBrowser = [];
            end
        end

        if nargout>0
            varargout{1} = hBrowser;
        end
    case 'jump2anchor'
        if ~isempty(hBrowser)
            currloc = hBrowser.getCurrentLocation;
            locRoot = strtok(currloc,'#');
            hBrowser.setCurrentLocation([locRoot '#' name]);
        end
    case 'rootCovFile'
        if ~isempty(hBrowser)
            currFileLoc = char(hBrowser.getCurrentLocation);
            currFileLoc = strtok(currFileLoc,'#');
            baseFileName = strrep(currFileLoc,'file://localhost//','');
            if (~isempty(findstr(baseFileName,'_main.html')))
                baseFileName = find_base_contents_name(baseFileName);
            end
            varargout{1} = baseFileName;
        else
            varargout{1} = [];
        end
        
    otherwise
        error('Unrecognized method');
    end
    
    
function mainTarget = find_base_contents_name(topFileLoc)

    % Return empty if nothing is found
    mainTarget = '';

    % Strip off the browser specific location info
    topFileLoc = strtok(topFileLoc,'#');
    topFileLoc = strrep(topFileLoc,'file://localhost//','');

    fid = fopen( topFileLoc, 'r');
    
    strLine = fgetl(fid);
    while( isempty(strLine) | strLine ~= -1)
        if(~isempty(strLine) & findstr(strLine,'<frame name="mainFrame" src="'))
            startIdx = findstr( strLine, 'src="') + 5;
            mainTarget = strtok(strLine(startIdx:end),'"');  
            break; 
        end
        strLine = fgetl(fid);
    end
        
    if isempty(mainTarget)
        mainTarget = topFileLoc;
    end



    