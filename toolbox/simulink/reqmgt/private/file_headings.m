function [headings,levels] = file_headings(filePath)

% Copyright 2004 The MathWorks, Inc.

    persistent CachedHeadings;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The cached headings are stored in an Nx4 cell array:
    % CachedHeadings = { filePath1, timeStamp1, headings1, levels1
    %                    filePath2, timeStamp2, headings2, levels2,
    %                     ...                                      }
    
    ComApps = struct(    'word',        [] ...
                        ,'excel',       [] ...
                        ,'powerpoint',  []);
    
    try,
        fileInfo = dir(filePath);
    catch
        error(['Could not find "' filePath '"']);
    end
    
    timeStamp = datenum(fileInfo.date);
    
    % Check if the headings have been cached
    if isempty(CachedHeadings)
        cacheIdx = [];
    else
        % Just to a linear search for simplicity
        cacheIdx = find(strcmp(filePath,CachedHeadings(:,1)));
        
        % Compare file time stamps to determine if it was modified
        if ~isempty(cacheIdx)
            cachedTime = CachedHeadings{cacheIdx,2};
            if timeStamp>cachedTime
                CachedHeadings(cacheIdx,:) = [];
                cacheIdx = [];
            end
        end
    end
    
    if ~isempty(cacheIdx)
        headings = CachedHeadings{cacheIdx,3};    
        levels = CachedHeadings{cacheIdx,4};  
        return;  
    end

    [path,name,ext] = fileparts(filePath);

    if strcmp(lower(ext),'.doc')
    h = msgbox(sprintf('Reading file "%s".  Please wait.',filePath));
    else
        h = [];
    end

    [path,name,ext] = fileparts(filePath);
    headings = {};    
    levels = [];  
    
    try,
        switch(lower(ext)),
        case '.doc',
            prevErr = lasterr;
            try,
                ComApps = com_load_word(ComApps);
                comDocument = com_open_doc(ComApps,filePath);
                [headings,levels] = com_find_headings(comDocument);
                com_close_doc(comDocument);
                delete(ComApps.word);
            catch
                lasterr(prevErr);
                headings = [];
                levels = [];
            end
            
        case {'.htm','.html'}
            fid = fopen(filePath,'r');
            contents = char(fread(fid)');
            fclose(fid);
        
            % Link to named anchors or ids in the html    
            anchors = regexpi(contents,'<A[^>]*?name\s*?=\s*?"?(\w+)','tokens');
            namedIds = regexpi(contents,'<[^>]*?id\s*?=\s*?"?(\w+)','tokens');
            anchors = cat(1,anchors{:});
            namedIds = cat(1,namedIds{:});
            headings = [anchors ; namedIds];
            levels = [];
                       
            %pattern = '<[hH](\d)>.*?</[hH]\1>';
            %startL = 4;
            %endL = 5;
            %raw = regexp(contents,pattern,'match');
            %for i=1:length(raw)
            %    headings{i} = raw{i}((startL+1):(end-endL));
            %    levels(i) = sscanf(lower(raw{i}),'<h%d>');
            %end
    
        end
    catch
    end
    
    if ~isempty(h)
        delete(h);
    end
    
    % Cache the current headings for future use
    if ~isempty(headings) 
        if isempty(CachedHeadings)
            CachedHeadings = {filePath, timeStamp, headings, levels};
        else
            CachedHeadings(end+1,:) = {filePath, timeStamp, headings, levels};
        end
    end
    
    

function comDocument = com_open_doc(ComApps,filePath)
    comDocs = ComApps.word.Documents;
    comDocument = comDocs.Open(filePath, [], 1);

function com_close_doc(comDocument)
    comDocument.Close;

function [headings,levels] = com_find_headings(comDocument)
    comParagraphs = comDocument.Paragraphs;
    
    headings = {};
    levels = [];
    
    for i=1:(comParagraphs.Count)
        comParagraph = comParagraphs.Item(i);
        outlineLevel = comParagraph.OutlineLevel;
        if strcmp(outlineLevel,'wdOutlineLevelBodyText')
            level = -1;
        else
            level = sscanf(outlineLevel,'wdOutlineLevel%d');
        end
        
        if level>=0
            label = comParagraph.Range.Text;
            label(end) = []; % Remove CR
            headings{end+1} = label;
            levels(end+1) = level;
        end
    end


function ComApps = com_load_word(ComApps)
    if isempty(ComApps.word)
        ComApps.word = actxserver('WORD.Application');
    end
    
    

    