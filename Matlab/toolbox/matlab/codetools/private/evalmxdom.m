function dom = evalmxdom(dom,imagePrefix,outputDir,options)
%EVALMXDOM   Evaluate cellscript Document Object Model, generating inline images.
%   dom = evaldom(dom,imagePrefix,outputDir,options)
%   imagePrefix is the prefix that will be used for the image files.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.9 $  $Date: 2003/11/10 13:37:36 $

% Ned Gulley, 5 Mar 2001

baseImageName = fullfile(outputDir,imagePrefix);

if options.useNewFigure
    myFigure = figure('color','white');
end

allPictures = {};
cellList = dom.getElementsByTagName('cell');
for n = 1:cellList.getLength
    
    mcodeList = cellList.item(n-1).getElementsByTagName('mcode');
    if (mcodeList.getLength > 0) && (mcodeList.item(0).getLength > 0)
        mcode = char(mcodeList.item(0).getFirstChild.getData);
    else
        mcode = '';
    end
    
    % Run the code, capture the output, and save the graphics files.
    [pictureList, mcodeOutput, isError] = takepicture( ...
        {mcode}, baseImageName, length(allPictures), ...
        options.maxHeight, options.maxWidth, options.figureSnapMethod, ...
        options.imageFormat);
    
    for pictureNumber = 1:length(pictureList)
        % Insert an image tag into the DOM
        imgNode = dom.createElement('img');
        [null,name,ext] = fileparts(pictureList{pictureNumber});
        imgNode.setAttribute('src',[name ext]);
        cellList.item(n-1).appendChild(imgNode);
    end

    allPictures = [allPictures pictureList];
    
    if ~isempty(mcodeOutput),
        % Insert an mcodeoutput tag into the DOM
        mcodeOutputNode = dom.createElement('mcodeoutput');
        mcodeOutputTextNode = dom.createTextNode(mcodeOutput);
        mcodeOutputNode.appendChild(mcodeOutputTextNode);
        cellList.item(n-1).appendChild(mcodeOutputNode);
    end
    
    if isError && options.stopOnError
        break
    end
end

if options.useNewFigure
    close(myFigure(ishandle(myFigure)))
end

if options.createThumbnail && ~isempty(allPictures)
    switch options.imageFormat
        case {'png','jpeg','tiff','gif','bmp','hdf','pcx','xwd','ico','cur','ras','pbm','pgm','ppm'}
            X = imread(allPictures{end});
            % Hardwire image height in pixels
            imHeight = 64;
            [ht,wid,null] = size(X);
            X = make_thumbnail(X,round(imHeight*[1 wid/ht]));
            imgFilename = [baseImageName '.png'];
            imwrite(X,imgFilename)
    end
end
