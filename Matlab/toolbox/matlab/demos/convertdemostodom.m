function doms=convertdemostodom
%CONVERTDEMOSTODOM returns the contents of all demos.m files as DOMs.
%   This file is a helper function used by the Help Browser's Demo tab.
%
%   It is unsupported and will be removed in the future.

% Matthew J. Simoneau
% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $  $Date: 2004/04/10 23:24:28 $

% FINDDEMO returns all the contents of legacy demos.m files.
[toolboxDemos,blocksetDemos]=finddemo;

demos=[toolboxDemos blocksetDemos];

doms=[];
% Create a DOM for each structure from a demos.m file.
for i=1:length(demos)
    % Create the root of the DOM.
    dom = com.mathworks.xml.XMLUtils.createDocument('demos');
    rootNode = dom.getDocumentElement;
    
    % Add the toolbox/blockset descriptive information.
    prodName = demos(i).Name;
    addParamValue(rootNode,'name',prodName);
    addParamValue(rootNode,'type',demos(i).Type);
    addParamValue(rootNode,'description',cellToHtml(prodName, demos(i).Help));
    if (i > length(toolboxDemos))
        icon='$toolbox/matlab/icons/simulinkicon.gif';
    else
        icon='$toolbox/matlab/icons/matlabicon.gif';
    end
    addParamValue(rootNode,'icon',icon);
    
    baseNode=rootNode;
    
    % Add the information for each demo.
    for demoItem=1:length(demos(i).DemoList)
        name=demos(i).DemoList{demoItem};
        name=deblank(fliplr(deblank(fliplr(name))));
        callback=demos(i).FcnList{demoItem};
        if ~isempty(callback)
            demoItemNode=dom.createElement('demoitem');
            baseNode.appendChild(demoItemNode);            
            addParamValue(demoItemNode,'label',name);
            addParamValue(demoItemNode,'callback',callback);
        else
            % Probably a section title.  Ignore.
        end
    end
    doms=[doms dom];
end

%===============================================================================
function addParamValue(node,param,value)
dom=node.getOwnerDocument;
paramNode=dom.createElement(param);
paramNode.appendChild(dom.createTextNode(value));
node.appendChild(paramNode);

%===============================================================================
function c=cellToHtml(prodName, c)
c=deblank(c);
header=sprintf('<title>%s Demos</title><h1>%s Demos</h1>', prodName, prodName);
inList=0;
for i=1:length(c);
    line=c{i};
    line=strrep(line,'>','&gt;');
    line=strrep(line,'<','&lt;');

    line=fliplr(deblank(fliplr(line)));
    if isempty(line)
        line=sprintf('</p>\n<p>');
    else
        line=[line ' '];
    end
    if (line(1)=='*' || line(1)=='|' || line(1)=='-')
        if inList
            line=sprintf('<li>%s</li>\n',line(2:end));
        else
            line=sprintf('<ul><li>%s</li>\n',line(2:end));
            inList=1;
        end
    elseif inList
        line=sprintf('</ul>\n%s',line);
        inList=0;
    end
    c{i}=line;
end
c=[header sprintf('<p>%s</p>\n',[c{:}])];
