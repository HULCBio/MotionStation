function h=annotation(varargin)
%ANNOTATION creates an annotation object
%   ANNOTATION(ANNOTATIONTYPE) creates a default annotation of type
%   ANNOTATIONTYPE in the current figure.  ANNOTATIONTYPE may be one of the
%   following:
%       'rectangle'
%       'ellipse'
%       'textbox'
%       'line'
%       'arrow'
%       'doublearrow' = two headed arrow
%       'textarrow' = arrow with text at tail end
%
%   ANNOTATION('rectangle',POSITION) creates a rectangle annotation at the
%   position specified in normalized figure units by the vector POSITION
%   ANNOTATION('ellipse',POSITION) creates an ellise annotation at the
%   position specified in normalized figure units by the vector POSITION
%   ANNOTATION('textbox',POSITION) creates a textbox annotation at the
%   position specified in normalized figure units by the vector POSITION
%   ANNOTATION('line',X,Y) creates a line annotation with endpoints
%   specified in normalized figure coordinates by the vectors X and Y
%   ANNOTATION('arrow',X,Y) creates an arrow annotation with endpoints
%   specified in normalized figure coordinates by the vectors X and Y. X(1)
%   and Y(1) specify the position of the tail end of the arrow and X(2) and
%   Y(2) specify the position at the tip of the arrow head.
%   ANNOTATION('doublearrow',X,Y) creates a doublearrow annotation with
%   endpoints specified in normalized figure coordinates by the vectors X
%   and Y
%   ANNOTATION('textarrow',X,Y) creates a textarrow annotation with
%   endpoints specified in normalized figure coordinates by the vectors X
%   and Y. X(1) and Y(1) specify the position of the tail end of the arrow
%   and X(2) and Y(2) specify the position at the tip of the arrow head.
%
%   ANNOTATION(FIG,...) creates the annotation in the figure FIG
%
%   H=ANNOTATION(...) returns a handle to the annotation object
%
%   The arguments to ANNOTATION can be followed by parameter/value pairs to
%   specify additional properties of the annotation object. The X and Y or
%   POSITION arguments to ANNOTATION can be omitted entirely, and all
%   properties specified using parameter/value pairs.
%
%   Examples: rh=annotation('rectangle',[.1 .1 .3 .3]); 
%             ah=annotation('arrow',[.9 .5],[.9,.5],'Color','r');
%             th=annotation('textarrow',[.3,.6],[.7.4],'String','ABC');

%   Copyright 1984-2003 The MathWorks, Inc. 


[fig,varargin,nargs] = graph2dhelper('hgcheck','hg.figure',varargin{:});
atypes = {'arrow','doublearrow','line','textarrow','rectangle','ellipse','textbox','text'};
if isempty(fig)
    if ~ischar(varargin{1}) || isempty(find(strcmpi(varargin{1},atypes)));
        error('MATLAB:graph2d.bad argument','First argument must be a figure handle or valid annotation type');
    end
    fig = gcf;
elseif ~ischar(varargin{1}) || isempty(find(strcmpi(varargin{1},atypes)));
        error('MATLAB:graph2d.bad argument','Second argument must be a valid annotation type');
end
atype = lower(varargin{1});
varargin = varargin(2:length(varargin));
nargs = nargs-1;
aargs = {fig};
switch atype
    case 'arrow'
        aargs={aargs{:},'HeadStyle','vback2'};
        classname = 'arrow';
    case 'textarrow'
        aargs={aargs{:},'HeadStyle','vback2'};
        classname = 'textarrow';
    case 'doublearrow'
        aargs={aargs{:},'HeadStyle','vback2'};
        classname = 'doublearrow';
    case 'line'
        classname = 'line';
    case 'rectangle'
        classname = 'scriberect';
    case 'ellipse'
        classname = 'scribeellipse';
    case 'textbox'
        classname = 'textbox';
end

inpvp=false; % flag processing pv pairs
k=1; % current arg

% parse args
while k<=nargs
    if inpvp 
        % already in pvpairs
        aargs={aargs{:},varargin{k}};
    elseif isprop('scribe',classname,varargin{k})
        % start of pv pairs
        inpvp=true;
        aargs={aargs{:},varargin{k}};
    elseif k<=nargs-1 && isnumeric(varargin{k}) && isnumeric(varargin{k+1}) && ...
            length(varargin{k})==2 && length(varargin{k+1})==2 && ...
            any(strcmpi(atype,{'line','arrow','textarrow','doublearrow'}))
        if any(varargin{k}(:)<0) || any(varargin{k}(:)>1) || ...
                any(varargin{k+1}(:)<0) || any(varargin{k+1}(:)>1)
            error('MATLAB:graph2d:IllegalXYArguments','X and Y values must be between 0 and 1');
        end
        aargs={aargs{:},'X',varargin{k},'Y',varargin{k+1}};
        k=k+1;
    elseif k<=nargs && isnumeric(varargin{k}) && length(varargin{k})==4 && ...
            any(strcmpi(atype,{'textbox','rectangle','ellipse'}))
        if any(varargin{k}(:)<0) || any(varargin{k}(:)>1)
            error('MATLAB:graph2d:IllegalPositionArgument','position values must be between 0 and 1');
        end
        aargs={aargs{:},'Position',varargin{k}};
    else
        error('MATLAB:graph2d:BadArguments','unknown argument');
    end
    k=k+1;
end

% call constructor
if isappdata(fig,'scribeActive')
    % if plotedit is on, deselect everything
    deselectall(fig);
end

scribeax = getappdata(fig,'Scribe_ScribeOverlay');
if ~isempty(scribeax) && ishandle(scribeax)
  methods(handle(scribeax),'stackScribeLayersWithChild',double(scribeax),true);
end

switch atype
    case 'line'
        h=scribe.line(aargs{:});
    case 'arrow'
        h=scribe.arrow(aargs{:});
    case 'doublearrow'
        h=scribe.doublearrow(aargs{:});
    case 'textarrow'
        h=scribe.textarrow(aargs{:});
    case 'rectangle'
        h=scribe.scriberect(aargs{:});
    case 'ellipse'
        h=scribe.scribeellipse(aargs{:});
    case 'textbox'
        h=scribe.textbox(aargs{:});
    case 'text'
        h=scribe.text(aargs{:});
end
if ~isempty(h) && ishandle(h)
    h=double(h);
end