function fonts = listfonts(handle)
%LISTFONTS Get list of available system fonts in cell array.
%   C = LISTFONTS returns list of available system fonts.
%
%   C = LISTFONTS(H) returns system fonts with object's FontName
%   sorted into the list.
%
%   See also UISETFONT.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/06/17 13:18:46 $

persistent systemfonts;
if nargin == 1
    try
        currentfont = {get(handle, 'FontName')};
    catch
        currentfont = {''};
    end
else
    currentfont = {''};
end

if isempty(systemfonts)
    if (ispc)
        try
            fonts = winqueryreg('name','HKEY_LOCAL_MACHINE',...
                'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts');
        catch
            try
                fonts = winqueryreg('name','HKEY_LOCAL_MACHINE',...
                    ['SOFTWARE\Microsoft\Windows\' ...
                        'CurrentVersion\Fonts']);
            catch
                fonts = {};
            end
        end
        cleanfonts = {};
        for n=1:length(fonts)
            subfonts = strread(fonts{n},'%s','delimiter','&');
            for m = 1:length(subfonts);
                font = subfonts{m};
                % strip out anything after '(', a digit, ' bold' or ' italic'
                font = strtok(font,'(');
                ind = find(font >= '0' & font <= '9');
                ind = [ind findstr(font,' Bold')];
                ind = [ind findstr(font,' Italic')];
                if ~isempty(ind)
                    font = font(1:min(ind)-1);
                end        
                % strip trailing spaces
                font = deblank(font);
                
                if ~isempty(font)
                    cleanfonts{end+1} = font;
                end
            end
        end
        fonts = cleanfonts';
    else
        perlCommand = 'perl';
        [dir, name] = fileparts(which(mfilename));
        [s, result] = unix([perlCommand ' ' fullfile(dir, 'private', 'listunixfonts.pl')]);
        if (s == 0 & ~isempty(result) & isempty(findstr(result,'Command not found')) & ...
                isempty(findstr(result,'unable to open display')))
            [font, rem] = strtok(result, char(10));
            fonts{1} = font;
            i = 1;
            while (~isempty(rem))
                i = i + 1;
                [font, rem] = strtok(rem, char(10));
                if (~isempty(rem))
                    fonts{i} = font;
                end
            end
        else
            fonts = {};
        end
        fonts = fonts';
    end
    
    % add postscipt fonts to the system fonts list. these font names are
    % defined in HG source code
    systemfonts = [fonts; 
        {
            'AvantGarde';
            'Bookman';
            'Courier';
            'Helvetica';
            'Helvetica-Narrow'; 
            'NewCenturySchoolBook';
            'Palatino';
            'Symbol';
            'Times';
            'ZapfChancery';
            'ZapfDingbats'; 
        }];
end

% add the current font to the system font list if it's there
if isempty(currentfont{1})
    fonts = systemfonts;
else
    fonts = [systemfonts; currentfont];
end

% return a sorted and unique font list to the user
[f,i] = unique(lower(fonts));
fonts = fonts(i);
