function [pictureList, codeOutput, errorStatus] = takepicture( ...
    fileName, baseImageName, imageCount, imHeight, imWidth, method, imageType)
%TAKEPICTURE	Run file, take snapshot, save image
%   TAKEPICTURE(fileName, baseImageName, imageCount, imHeight, imWidth, method, imageType)
%
% INPUTS:
%   fileName - either a file name or a cell array of code to evaluate
%   baseImageName - the root to save all images, something like D:\Work\html\foo
%   imageCount - the number of images created so far
%     If imageCount is empty, save one image at most with the name fileName.
%   imHeight - restrict images to this height ([] means don't adjust)
%   imWidth - restrict images to this width ([] means don't adjust)
%   method - use this to capture the figures, like "print" or "getframe"
%   imageType - the image file format, like 'png'.
%
% OUTPUTS:
%   pictureList - the images this code created
%   codeOutput - the commaind line spew
%   errorStatus - did the code error?
%
%   See also PUBLISH, SNAPSHOT.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/12/24 19:12:01 $

% Ned Gulley, Feb 2001

% TODO: Now that we have SNAPSHOT, move this back into private.

% Argument parsing.
if nargin < 4
    imHeight = [];
end
if nargin < 5
    imWidth = [];
end
if nargin < 6
    method = 'print';
end
if nargin < 7
    imageType = 'png';
end

% Initialize some variables.
hasSimulink = ~isempty(which('find_system'));
pictureList = {};
systemsToSnap = {};

% Capture information about current figures and systems
oldFigures = captureFigures;
if hasSimulink
    oldOpenSystems = find_system('open','on');
end

% Run the code
warnState = warning;
warning off backtrace
try
    if iscell(fileName)
        codeOutput = evalc('evalin(''base'',[fileName{:}])');
    else
        codeOutput = evalc('evalin(''base'',fileName)');
    end
    errorStatus = false;
catch
    disp('Error while eval''ing code.')
    disp(' ')
    disp(strvcat(fileName))
    disp(' ')
    disp(lasterr)
    beep
    codeOutput = lasterr;
    errorStatus = true;
end
drawnow
warning(warnState);

% Compare the original state to the new state to get a list of
% figures and systems that need snapping
figuresToSnap = compareFigures(oldFigures);
if hasSimulink
    % Detect if there are any newly opened systems to capture.
    systemsToSnap = setdiff(find_system('open','on'),oldOpenSystems);
    % TODO: Detect changed systems also, not just newly opened ones.
end

% If just snapshotting this file, we want exactly one image taken.
if isempty(imageCount)
    if isempty(systemsToSnap)
        if isempty(figuresToSnap)
            % Nothing to snap.
        else
            % Only figures, use the first one.
            figuresToSnap = figuresToSnap(1);
        end
    else
        % Favor models over figures.  We've got at least one Simulink model, so
        % just use the first one and ignore the figures (if any).
        systemsToSnap = systemsToSnap(1);
        figuresToSnap = [];
    end
end

if hasSimulink
    % Take a snapshot of each system.
    for systemNumber = 1:length(systemsToSnap)
        s = systemsToSnap{systemNumber};
        imgFileName = getImageName(baseImageName,pictureList,imageType,imageCount);
        switch imageType
            case {'tiff','jpeg','png','hdf','pcx','xwd','ras','pbm','pgm','ppm','pnm'}
                % Print system as a bitmap file (.bmp).
                tempBmp = [tempname '.bmp'];
                open_system(s)
                % Screen capture looks better but is only available on the PC.
                if ispc
                    print(['-s' s],'-dbitmap',tempBmp);
                else
                    po = get_param(s,'PaperOrientation');
                    set_param(s,'PaperOrientation','portrait')
                    print(['-s' s],'-dbmp16m',tempBmp);
                    set_param(s,'PaperOrientation',po)
                end
                % Convert temporary bitmap to fileType.
                [myFrame.cdata,myFrame.colormap] = imread(tempBmp);
                delete(tempBmp);
                writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);
                % Add to list.
                pictureList{end+1} = imgFileName;
                
            case {'ps','psc','ps2','psc2','eps','epsc','eps2','epsc2'}
                po = get_param(s,'PaperOrientation');
                set_param(s,'PaperOrientation','portrait')
                print(['-s' s],['-d' imageType],imgFileName);
                set_param(s,'PaperOrientation',po)
                pictureList{end+1} = imgFileName;

            otherwise
                error('MATLAB:takepicture', ...
                    'The "%s" format is not supported for Simulink diagrams.', ...
                    imageType);
        end
    end
end

% Take a snapsot of the each changed figure.
for figuresToSnapCount = 1:length(figuresToSnap)
    f = figuresToSnap(figuresToSnapCount);
    imgFileName = getImageName(baseImageName,pictureList,imageType,imageCount);
    switch method
        case 'getframe'
            set(0,'ShowHiddenHandles','on');
            figure(f);
            set(0,'ShowHiddenHandles','off');
            myFrame = getframe(f);
            writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);
            pictureList{end+1} = imgFileName;
            
        case 'print'
            params = {'PaperPositionMode','InvertHardcopy'};
            tempValues = {'auto','off'};
            origValues = get(f,params);
            set(f,params,tempValues);
            print(f,['-d' imageType],'-r0',imgFileName);
            set(f,params,origValues);
            if ~isempty(imHeight) || ~isempty(imWidth)
                [myFrame.cdata,myFrame.colormap] = imread(imgFileName);
                writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);
            end
            pictureList{end+1} = imgFileName;

        case 'antialiased'
            params = {'PaperPositionMode','InvertHardcopy'};
            tempValues = {'auto','off'};
            origValues = get(f,params);
            tempPng = [tempname '.png'];
            set(f,params,tempValues);
            print(f,'-dpng',tempPng);
            set(f,params,origValues);
            [myFrame.cdata,myFrame.colormap] = imread(tempPng);
            delete(tempPng);

            % We printed it large so we can resize it back down and it will be
            % anti-aliased.
            x = myFrame.cdata;
            map = myFrame.colormap;

            [height,width,null] = size(x);
            if ~isempty(map)
                % Convert indexed images to RGB before resizing.
                x = ind2rgb(x,map);
                map = [];
            end
            % Compute how much we should scale it back down.
            imWidth = get(f,'position')*[0;0;1;0];
            height = height*(imWidth/width);
            if isequal(class(x),'double')
                x = uint8(floor(x*255));
            end
            x = make_thumbnail(x,floor([height imWidth]));

            myFrame.cdata = x;
            myFrame.map = map;

            writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);
            pictureList{end+1} = imgFileName;

        otherwise
            % We should never get here.
            error('MATLAB:takepicture:NoMethod','Unknown method "%s".',method)
            
    end

end

%===============================================================================
function imgFileName = getImageName(baseImageName,pictureList,imageType,imageCount)
if isempty(imageCount)
    % Coming from SNAPSHOT.
    imgFileName = sprintf('%s.%s',baseImageName,imageType);
else
    % Coming from EVALMXDOM.
    imgFileName = sprintf('%s_%02.f.%s', ...
        baseImageName,length(pictureList)+1+imageCount,imageType);
end

%===============================================================================
function writeImage(imgFileName,imageType,myFrame,imHeight,imWidth)

x = myFrame.cdata;
map = myFrame.colormap;

[height,width,null] = size(x);
if ~isempty(imHeight) && (height > imHeight) || ...
        ~isempty(imWidth) && (width > imWidth)
    if ~isempty(map)
        % Convert indexed images to RGB before resizing.
        x = ind2rgb(x,map);
        map = [];
    end
    if ~isempty(imHeight) && (height > imHeight)
        width = width*(imHeight/height);
        height = imHeight;
    end
    if ~isempty(imWidth) && (width > imWidth)
        height = height*(imWidth/width);
        width = imWidth;
    end
    if isequal(class(x),'double')
        x = uint8(floor(x*255));
    end
    x = make_thumbnail(x,floor([height width]));
end

% TODO: RGB2IND is in Image Processing.  Not sure what to do about it.
% if isempty(map) && ~isequal('imageType','jpg')
%     % Dither cdata down to 256 colors for better file size.
%     if min(x(:)) == max(x(:))
%         % See geck 128252.
%         [x,map] = rgb2ind(x,256,'nodither');
%     else
%         [x,map] = rgb2ind(x,256);
%     end
% end

if isempty(map)
    imwrite(x,imgFileName,imageType);
else
    imwrite(x,map,imgFileName,imageType);
end
