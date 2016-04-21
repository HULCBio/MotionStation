function outputAbsoluteFilename = publish(file,options)
%PUBLISH   Run a script and save the results.
%   PUBLISH(CELLSCRIPT,FORMAT) publishes the script in the specified format.
%   FORMAT can be one of the following:
%
%      'html'  - HTML.
%      'doc'   - Microsoft Word (requires Microsoft Word).
%      'ppt'   - Microsoft PowerPoint (requires Microsoft PowerPoint).
%      'xml'   - An XML file that can be transformed with XSLT or other tools.
%      'latex' - LaTeX.  Also changes the imageFormat to 'epsc2'.
%
%   PUBLISH(SCRIPT,OPTIONS) provides a structure of options that may contain any
%   of the following fields (first choice listed is the default):
%
%       format: 'html' | 'doc' | 'ppt' | 'xml' | 'rpt' | 'latex'
%       stylesheet: '' | an XSL filename (ignored unless format = html or xml)
%       outputDir: '' (an html subfolder below the file) | full path
%       imageFormat: 'png' | any supported by PRINT or IMWRITE, depending on figureSnapMethod
%       figureSnapMethod: 'print' | 'getframe'
%       useNewFigure: true | false
%       maxHeight: [] | positive integer (pixels)
%       maxWidth: [] | positive integer (pixels)
%       showCode: true | false
%       evalCode: true | false
%       stopOnError: true | false
%       createThumbnail: true | false
%
%   When publishing to HTML, the default stylesheet stores the original code as
%   an HTML comment, even if "showcode = false".  Use GRABCODE to extract it.
%
%   See also GRABCODE.

% Matthew J. Simoneau, June 2002
% $Revision: 1.1.6.14 $  $Date: 2004/04/22 01:35:51 $
% Copyright 1984-2004 The MathWorks, Inc.

% This function requires Java.
if ~usejava('jvm')
   error('MATLAB:publish:NoJvm','PUBLISH requires Java.');
end

% Default to HTML publishing.
if (nargin < 2)
    options = 'html';
end

% If options is a simple string (format), convert to structure.
if ischar(options)
    t = options;
    options = struct;
    options.format = t;
end

% Supply default options for any that are missing.
if ~isfield(options,'format')
    options.format = 'html';
end
format = options.format;

if ~isfield(options,'stylesheet') || isempty(options.stylesheet)
    switch format
        case 'html'
            codepadDir = fileparts(which(mfilename));
            styleSheet = fullfile(codepadDir,'private','mxdom2simplehtml.xsl');
            options.stylesheet = styleSheet;
        case 'latex'
            codepadDir = fileparts(which(mfilename));
            styleSheet = fullfile(codepadDir,'private','mxdom2latex.xsl');
            options.stylesheet = styleSheet;
        otherwise
            options.stylesheet = '';
    end
end
switch format
   case 'latex'
      % Assume that the user wants EPS for LaTeX.
      options.imageFormat = 'epsc2';
   otherwise
      if ~isfield(options,'imageFormat')
         options.imageFormat = 'png';
      end
end
if ~isfield(options,'figureSnapMethod')
    options.figureSnapMethod = 'print';
end
if ~isfield(options,'useNewFigure')
    options.useNewFigure = true;
end
if ~isfield(options,'maxHeight')
    options.maxHeight = [];
end
if ~isfield(options,'maxWidth')
    options.maxWidth = [];
end
if ~isfield(options,'showCode')
    options.showCode = true;
end
if ~isfield(options,'evalCode')
    options.evalCode = true;
end
if ~isfield(options,'stopOnError')
    options.stopOnError = true;
end
if ~isfield(options,'createThumbnail')
    options.createThumbnail = true;
end

% Check format.
supportedFormats = {'html','doc','ppt','xml','rpt','latex'};
if isempty(strmatch(format,supportedFormats,'-exact'))
    error('MATLAB:publish:UnknownFormat','Unsupported format "%s".',format);
end

% Check stylesheet.
if ~isempty(options.stylesheet) && ~exist(options.stylesheet,'file')
    error( ...
        'MATLAB:publish:StylesheetNotFound', ...
        'The specified stylesheet, "%s", does not exist.', ...
        options.stylesheet)
end

% Read in source.
fullPathToScript = locateFile(file);
if isempty(fullPathToScript)
    error('MATLAB:publish:SourceNotFound','Cannot find "%s".',file);
end
code = file2char(fullPathToScript);
if ~isScript(code)
    error('MATLAB:publish:NotScript', ...
       '"%s" is a function.\nPUBLISH only works for scripts.', ...
       fullPathToScript);
end
[scriptDir,prefix] = fileparts(fullPathToScript);

% Determine publish location.
if isfield(options,'outputDir') && ~isempty(options.outputDir)
    outputDir = options.outputDir;
else
    outputDir = fullfile(scriptDir,'html');
end
switch format
    case 'latex'
        ext = 'tex';
    otherwise
        ext = format;
end
outputAbsoluteFilename = fullfile(outputDir,[prefix '.' ext]);

% Make sure we can write to this filename.  Create the directory, if needed.
message = prepareOutputLocation(outputAbsoluteFilename);
if ~isempty(message)
    error('MATLAB:publish:CannotWriteOutput',strrep(message,'\','\\'))
end

% Delete any existing images.  Use regexp to lessen the chance of false hits.
d = dir(fullfile(outputDir,[prefix '_*.' options.imageFormat]));
imagePattern = ['^' prefix '_\d{2,}.' options.imageFormat '$'];
[lastmsg,lastid]=lastwarn('');
for i = 1:length(d)
    if (regexp(d(i).name,imagePattern) == 1)
        toDelete = fullfile(outputDir,d(i).name);
        delete(toDelete)
        if ~isempty(lastwarn)
            error('MATLAB:publish:CannotWriteOutput', ...
                'Cannot delete "%s".',toDelete)
        end
    end
end
% Delete the thumbnail.
thumbnail = fullfile(outputDir,[prefix '.' options.imageFormat]);
if ~isempty(dir(thumbnail))
    delete(thumbnail)
    if ~isempty(lastwarn)
        error('MATLAB:publish:CannotWriteOutput', ...
            'Cannot delete "%s".',thumbnail)
    end
end
lastwarn(lastmsg,lastid);

% Convert the M-code to XML.
dom = m2mxdom(code);

% Add reference to original M-file.
newNode = dom.createElement('m-file');
newTextNode = dom.createTextNode(prefix);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);
newNode = dom.createElement('filename');
newTextNode = dom.createTextNode(fullPathToScript);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);

% Determine where to save image files.
switch format
    case {'doc','ppt'}
        % TODO: Delete temporary images.
        imageDir = tempdir;
    otherwise
        imageDir = outputDir;
end

% Creat images of TeX equations for non-TeX output.
if ~isequal(format,'latex')
    dom = createEquationImages(dom,imageDir,prefix);
end

% Evaluate each cell, snap the output, and store the results.
if options.evalCode
    dom = evalmxdom(dom,prefix,imageDir,options);
end
    
% Remove dispay code if we don't want it to show in the output document.
if ~options.showCode
    while true
        codeNodeList = dom.getElementsByTagName('mcode');
        if (codeNodeList.getLength == 0)
            break;
        end
        codeNode = codeNodeList.item(0);
        codeNode.getParentNode.removeChild(codeNode);
    end
    while true
        codeNodeList = dom.getElementsByTagName('mcode-xmlized');
        if (codeNodeList.getLength == 0)
            break;
        end
        codeNode = codeNodeList.item(0);
        codeNode.getParentNode.removeChild(codeNode);
    end
end

% Write to the output format.
switch format
    case 'xml'
        if isempty(options.stylesheet)
            xmlwrite(outputAbsoluteFilename,dom)
        else
            xslt(dom,options.stylesheet,outputAbsoluteFilename);
        end
        
    case {'html','latex'}
        xslt(dom,options.stylesheet,outputAbsoluteFilename);
        
    case 'doc'
        mxdom2word(dom,outputAbsoluteFilename);
        
    case 'ppt'
        mxdom2ppt(dom,outputAbsoluteFilename);
        
    case 'rpt'
        mxdom2rpt(dom,outputAbsoluteFilename);
        
end

%===============================================================================
% All these subfunctions are for equation handling.
%===============================================================================
function dom = createEquationImages(dom,outputDir,prefix)
% Render equations as images to be included in the document.

%TODO We need some hygene for equation images.
baseImageName = fullfile(outputDir,prefix);

% Loop over each equation.
equationList = dom.getElementsByTagName('equation');
for i = 1:getLength(equationList)
    equationNode = equationList.item(i-1);
    equationText = char(equationNode.getTextContent);
    fullFilename = [baseImageName '_' hashEquation(equationText) '.png'];
    % Check to see if this equation needs to be rendered.
    if ~isempty(dir(fullFilename))
        % We've already got it on disk.  Use it.
        swapTexForImg(dom,equationNode,outputDir,fullFilename)
    else
        % We need to render it.
        [x,texWarning] = renderTex(equationText);
        if isempty(texWarning)
            % Now shrink it down to get anti-aliasing.
            newSize = ceil(size(x)/2);
            x = make_thumbnail(x,newSize(1:2));
            % Rendering succeeded.  Write out the image and use it.
            imwrite(x,fullFilename)
            % Put a link to the image in the DOM.
            swapTexForImg(dom,equationNode,outputDir,fullFilename)
        else
            % Rendering failed.  Add error message.
            beep
            errorNode = dom.createElement('pre');
            errorNode.setAttribute('class','error')
            errorNode.appendChild(dom.createTextNode(texWarning));
            % Insert the error after the equation.  This would be easier if
            % there were an insertAfter node method.
            pNode = equationNode.getParentNode;
            if isempty(pNode.getNextSibling)
                pNode.getParentNode.appendChild(errorNode);
            else
                pNode.getParentNode.insertBefore(errorNode,pNode.getNextSibling);
            end
        end
    end
end

%===============================================================================
function swapTexForImg(dom,equationNode,outputDir,fullFilename)
% Swap the TeX equation for the IMG.
equationNode.removeChild(equationNode.getFirstChild);
imgNode = dom.createElement('img');
imgNode.setAttribute('src',strrep(fullFilename,[outputDir filesep],''));
equationNode.appendChild(imgNode);

%===============================================================================
function [x,texWarning] = renderTex(equationText)
% Create a figure for rendering the equation, if needed.
tag = ['helper figure for ' mfilename];
tempfigure = findall(0,'type','figure','tag',tag);
if isempty(tempfigure)
    figurePos = get(0,'ScreenSize');
    if ispc
       % Set it off-screen since we have to make it visible before printing.
       % Move it over and down plus a little bit to keep the edge from showing.
       figurePos(1:2) = figurePos(3:4)+100;
    end
    % Create a new figure.
    tempfigure = figure( ...
        'handlevisibility','off', ...
        'integerhandle','off', ...
        'visible','off', ...
        'paperpositionmode', 'auto', ...
        'color','w', ...
        'position',figurePos, ...
        'tag',tag);
    tempaxes = axes('position',[0 0 1 1], ...
        'parent',tempfigure, ...
        'xtick',[],'ytick',[], ...
        'xlim',[0 1],'ylim',[0 1], ...
        'visible','off');
    temptext = text('parent',tempaxes,'position',[.5 .5], ...
        'horizontalalignment','center','fontsize',22, ...
        'interpreter','latex');
else
    % Use existing figure.
    tempaxes = findobj(tempfigure,'type','axes');
    temptext = findobj(tempaxes,'type','text');
end

% Render and snap!
[lastMsg,lastId] = lastwarn('');
set(temptext,'string',equationText);
if ispc
   % The font metrics are not set properly unless the figure is visible.
   set(tempfigure,'Visible','on');
end
drawnow;
x = hardcopy(tempfigure,'-dzbuffer','-r0');
set(tempfigure,'Visible','off');
texWarning = lastwarn;
lastwarn(lastMsg,lastId)
set(temptext,'string','');

if isempty(texWarning)
    % Sometimes the first pixel isn't white.  Crop that out.
    x(1,:,:) = [];
    x(:,1,:) = [];
    % Crop out the rest of the whitespace border.
    [i,j] = find(sum(double(x),3)~=765);
    x = x(min(i):max(i),min(j):max(j),:);
    if isempty(x)
        % The image is empty.  Return something so IMWRITE doesn't complain.
        x = 255*ones(1,3,'uint8');
    end
end

%===============================================================================
%===============================================================================
