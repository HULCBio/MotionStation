function varargout = teapotdemo(varargin)
%TEAPOTDEMO A demo that uses the famous Newell teapot
%  to demonstrate MATLAB graphics features. The teapot
%  is defined by 32 bicubic bezier patches. The
%  patches can be tesselated to surfaces at a wide
%  range of resolutions. The resulting surfaces can
%  be rendered with a variety of properties and
%  effects.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 03:35:34 $

    if nargin == 0  % LAUNCH GUI
        
        fig = figure(openfig(mfilename,'reuse'));
        
        % Generate a structure of handles to pass to callbacks, and store it. 
        handles = guihandles(fig);
        guidata(fig, handles);
        
        if nargout > 0
            varargout{1} = fig;
        end
        
        daspect([1 1 1]);
        xlim([-4 4]);
        ylim([-3 3]);
        axis vis3d off;
        view(3);

        light('Position',[ 0.25 -0.433  -0.866],'Style','infinite');
        light('Position',[-0.433 0.25 0.866],'Style','infinite');
        colormap autumn;
        
        % create teapot  
        s=struct('resolution',12,'colorby','z','lidoffset',0,'bottom',1);
        p = teapot(12,'z',0,1);
        set(p,'UserData',s);
        
        % make it look nice
        set(p,'EdgeColor',[0 0 0],'LineStyle','none','FaceColor','interp');
        
        lighting gouraud;

        set(gcf,'UserData',p);
        
        elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
        
            try
                if (nargout)
                    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
                else
                    feval(varargin{:}); % FEVAL switchyard
                end
            catch
                disp(lasterr);
            end     
        end

function runcmd(cmd)
    eval(cmd);
    cw=findobj('Tag','minicmdwin');
    set(cw,'String',cmd);    

function rebuildteapot()
    cr = sprintf('\n');
    p=get(gcf,'UserData');
    s=get(p,'UserData');
    cmdStr=['p = get(gcf,''UserData'');',cr, ...
                  'teapot(', ...
                  num2str(s.resolution), ...
                  ',''', ...
                  s.colorby,...
                  ''',', ...
                  num2str(s.lidoffset), ...
                  ',', ...
                  num2str(s.bottom), ...
                  ',p);'];
    runcmd(cmdStr);

% --------------------------------------------------------------------
function varargout = lightingmenu_Callback(h, eventdata, handles, varargin)
    n=get(h,'value');
    cmddata={'flat' 'gouraud' 'phong'};
    runcmd(['lighting ' cmddata{n} ';']);
    
% --------------------------------------------------------------------
function varargout = colormapmenu_Callback(h, eventdata, handles, varargin)
    n=get(h,'value');
    cmddata={'autumn' 'copper' 'hsv' 'winter'};
    runcmd(['colormap ' cmddata{n} ';']);

% --------------------------------------------------------------------
function varargout = materialmenu_Callback(h, eventdata, handles, varargin)
    n=get(h,'value');
    cmddata={'default' 'shiny' 'dull' 'metal'};
    runcmd(['material ' cmddata{n} ';']); 

% --------------------------------------------------------------------
function varargout = renderstylemenu_Callback(h, eventdata, handles, varargin)
    n=get(h,'value');
    fmtData = {
        { '.', 'none', 'none' };
        { 'none', '-', 'none' };
        { 'none', 'none', 'interp' }
    };
    
    runcmd2 = sprintf('p = get(gcf,''UserData'');\nset(p,''Marker'',''%s'')\nset(p,''LineStyle'',''%s'')\nset(p,''FaceColor'',''%s'')\n',...
        fmtData{n}{:});
    runcmd(runcmd2);
    
% --------------------------------------------------------------------
function varargout = colorbymenu_Callback(h, eventdata, handles, varargin)
    n=get(h,'value');    
    p=get(gcf,'UserData');
    s=get(p,'UserData');
    cmddata={'none' 'x' 'y' 'z' 'u' 'v' 'index'};
    s.colorby=cmddata{n};
    set(p,'UserData',s);
    if n==1 
        set(p,'FaceColor','none');
    else
        set(p,'FaceColor','interp');
    end
    rebuildteapot;

% --------------------------------------------------------------------
function varargout = transparentbutton_Callback(h, eventdata, handles, varargin)
    if get(h,'value') == 1 
        runcmd('alpha(0.5);');
    else
        runcmd('alpha(1);');
    end        

% --------------------------------------------------------------------
function varargout = infobutton_Callback(h, eventdata, handles, varargin)
    helpwin(mfilename);    

% --------------------------------------------------------------------
function varargout = closebutton_Callback(h, eventdata, handles, varargin)
    close(gcf)

% --------------------------------------------------------------------
function varargout = edgebutton_Callback(h, eventdata, handles, varargin)
    
    if get(h,'value') == 0
        runcmd('p = get(gcf,''UserData''); set(p,''LineStyle'',''none'');');
    else
        runcmd('p = get(gcf,''UserData''); set(p,''LineStyle'',''-'');');
    end        
    
% --------------------------------------------------------------------
function varargout = bottombutton_Callback(h, eventdata, handles, varargin)
    p=get(gcf,'UserData');
    s=get(p,'UserData');    
    if get(h,'value') == 1
        s.bottom=1;
    else
        s.bottom=0;
    end        
    set(p,'UserData',s);
    rebuildteapot;
    
% --------------------------------------------------------------------
function varargout = resolutionslider_Callback(h, eventdata, handles, varargin)
    res = get(h,'value');
    p=get(gcf,'UserData');
    s=get(p,'UserData');
    s.resolution=round(res);
    set(p,'UserData',s);
    rebuildteapot;

% --------------------------------------------------------------------
function varargout = lidoffsetslider_Callback(h, eventdata, handles, varargin)
    res = get(h,'value');
    p=get(gcf,'UserData');
    s=get(p,'UserData');
    s.lidoffset=round(res);
    set(p,'UserData',s);
    rebuildteapot;


% --------------------------------------------------------------------
% End of GUIDE generated code
%

% This is the function that actually creates the teapot
function pout=teapot(n,colorBy,lidoffset,bottom,pin)
%TEAPOT(N,COLORBY) Generates a surface representation of the infamous Newell teapot.
%  Each bezier patch is tesselated at NxN resolution. COLORBY controls how the 
%  surface's colors are generated:
%       x      the X coordinates are used
%       y      the Y coordinates are used
%       z      the Z coordinates are used
%       y      the U parameter values are used
%       v      the V parameter values are used
%       index  the INDEX of the patch is used
%       none   no colors are generated

    % figure out the default values for all of the args
    if nargin<1
        n=12;
    end
    if nargin<2
        colorBy='none';
    end
    if nargin<3
        lidoffset=0;
    end
    if nargin<4
        bottom=1;
    end
    
    % Get the teapot coords from the local functions below.
    verts = teapotVertices;
    quads = teapotControlPoints;

    % Vertices 204-269 define the lid. The lidoffset arg can
    % be used to move them along the Z axis.
    if lidoffset > 0
        verts(204:269,3) = verts(204:269,3) + lidoffset;
    end
    
    % The last 4 quads are the optional bottom. Strip them
    % off if the bottom flag is false.
    if bottom==0
        quads=quads(:,:,1:28);
    end
    
    pv = [];
    pf = [];
    pc = [];
    % loop over the patches, creating (n-1)*(n-1) quads on the surface
    for i=1:size(quads,3)
        % extract the control points for this bezier patch
        points=verts(quads(:,:,i),:);
        % rip the vertices into X, Y, and Z components
        x=points(:,1);
        y=points(:,2);
        z=points(:,3);

        % use evalCubicBezierPatch to generate quadrilaterals
        [f v c] = evalCubicBezierPatch(n,x,y,z,i,colorBy);
        
        % append these quads to the list
        numv = size(pv,1);
        pv = [pv; v];
        pf = [pf; f+numv];
        pc = [pc; c];
    end

    % Create a patch containing all of the quads
    if nargin<5
        pout = patch('faces', pf, 'vertices', pv);
        p = pout;
    else
        set(pin,'faces',pf,'vertices',pv);
        p = pin;
    end

    % Add vertex colors if desired
    if strcmp(colorBy,'none')
        set(p, 'facecolor', [.5 .5 .5]);
    else        
        set(p,'FaceVertexCData',pc);
    end

% These are the control points for the bezier patches.
function verts = teapotVertices()
        verts = [  1.4     0.     2.4     ;
                   1.4    -0.784  2.4     ;
                   0.784  -1.4    2.4     ;
                   0.     -1.4    2.4     ;
                   1.3375  0.     2.53125 ;
                   1.3375 -0.749  2.53125 ;
                   0.749  -1.3375 2.53125 ;
                   0.     -1.3375 2.53125 ;
                   1.4375  0.     2.53125 ;
                   1.4375 -0.805  2.53125 ;
                   0.805  -1.4375 2.53125 ;
                   0.     -1.4375 2.53125 ;     
                   1.5     0.     2.4     ;
                   1.5    -0.84   2.4     ;
                   0.84   -1.5    2.4     ;
                   0.     -1.5    2.4     ;
                  -0.784  -1.4    2.4     ;
                  -1.4    -0.784  2.4     ;
                  -1.4     0.     2.4     ;
                  -0.749  -1.3375 2.53125 ;
                  -1.3375 -0.749  2.53125 ;
                  -1.3375  0.0    2.53125 ;
                  -0.805  -1.4375 2.53125 ;
                  -1.4375 -0.805  2.53125 ;
                  -1.4375  0.0    2.53125 ;
                  -0.84   -1.5    2.4     ;
                  -1.5    -0.84   2.4     ;
                  -1.5     0.     2.4     ;
                  -1.4     0.784  2.4     ;
                  -0.784   1.4    2.4     ;
                   0.      1.4    2.4     ;
                  -1.3375  0.749  2.53125 ;
                  -0.749   1.3375 2.53125 ;
                   0.      1.3375 2.53125 ;
                  -1.4375  0.805  2.53125 ;
                  -0.805   1.4375 2.53125 ;
                   0.      1.4375 2.53125 ;
                  -1.5     0.84   2.4     ;
                  -0.84    1.5    2.4     ;
                   0.      1.5    2.4     ;
                   0.784   1.4    2.4     ;
                   1.4     0.784  2.4     ;
                   0.749   1.3375 2.53125 ;
                   1.3375  0.749  2.53125 ;
                   0.805   1.4375 2.53125 ;
                   1.4375  0.805  2.53125 ;
                   0.84    1.5    2.4     ;
                   1.5     0.84   2.4     ;
                   1.75    0.     1.875   ;
                   1.75   -0.98   1.875   ;
                   0.98   -1.75   1.875   ;
                   0.     -1.75   1.875   ;
                   2.      0.     1.35    ;
                   2.     -1.12   1.35    ;
                   1.12   -2.     1.35    ;
                   0.     -2.     1.35    ;
                   2.      0.     0.9     ;
                   2.     -1.12   0.9     ;
                   1.12   -2.     0.9     ;
                   0.     -2.     0.9     ;
                  -0.98   -1.75   1.875   ;
                  -1.75   -0.98   1.875   ;
                  -1.75    0.     1.875   ;
                  -1.12   -2.     1.35    ;
                  -2.     -1.12   1.35    ;
                  -2.      0.     1.35    ;
                  -1.12   -2.     0.9     ;
                  -2.     -1.12   0.9     ;
                  -2.      0.     0.9     ;
                  -1.75    0.98   1.875   ;
                  -0.98    1.75   1.875   ;
                   0.      1.75   1.875   ;
                  -2.      1.12   1.35    ;
                  -1.12    2.     1.35    ;
                   0.      2.     1.35    ;
                  -2.      1.12   0.9     ;
                  -1.12    2.     0.9     ;
                   0.0     2.     0.9     ;
                   0.98    1.75   1.875   ;
                   1.75    0.98   1.875   ;
                   1.12    2.     1.35    ;
                   2.      1.12   1.35    ;
                   1.12    2.     0.9     ;
                   2.      1.12   0.9     ;
                   2.      0.     0.45    ;
                   2.     -1.12   0.45    ;
                   1.12   -2.     0.45    ;
                   0.     -2.     0.45    ;
                   1.5     0.     0.225   ;
                   1.5    -0.84   0.225   ;
                   0.84   -1.5    0.225   ;
                   0.     -1.5    0.225   ;
                   1.5     0.     0.15    ;
                   1.5    -0.84   0.15    ;
                   0.84   -1.5    0.15    ;
                   0.0    -1.5    0.15    ;
                  -1.12   -2.     0.45    ;
                  -2.     -1.12   0.45    ;
                  -2.      0.     0.45    ;
                  -0.84   -1.5    0.225   ;
                  -1.5    -0.84   0.225   ;
                  -1.5     0.     0.225   ;
                  -0.84   -1.5    0.15    ;
                  -1.5    -0.84   0.15    ;
                  -1.5     0.     0.15    ;
                  -2.      1.12   0.45    ;
                  -1.12    2.     0.45    ;
                   0.      2.     0.45    ;
                  -1.5     0.84   0.225   ;
                  -0.84    1.5    0.225   ;
                   0.      1.5    0.225   ;
                  -1.5     0.84   0.15    ;
                  -0.84    1.5    0.15    ;
                   0.      1.5    0.15    ;
                   1.12    2.     0.45    ;
                   2.      1.12   0.45    ;
                   0.84    1.5    0.225   ;
                   1.5     0.84   0.225   ;
                   0.84    1.5    0.15    ;
                   1.5     0.84   0.15    ;
                  -1.6     0.     2.025   ;
                  -1.6    -0.3    2.025   ;
                  -1.5    -0.3    2.25    ;
                  -1.5     0      2.25    ;
                  -2.3     0.     2.025   ;
                  -2.3    -0.3    2.025   ;
                  -2.5    -0.3    2.25    ;
                  -2.5     0.     2.25    ;
                  -2.7     0.     2.025   ;
                  -2.7    -0.3    2.025   ;
                  -3.     -0.3    2.25    ;
                  -3.      0.     2.25    ;
                  -2.7     0.     1.8     ;
                  -2.7    -0.3    1.8     ;
                  -3.     -0.3    1.8     ;
                  -3.      0.     1.8     ;
                  -1.5     0.3    2.25    ;
                  -1.6     0.3    2.025   ;
                  -2.5     0.3    2.25    ;
                  -2.3     0.3    2.025   ;
                  -3.      0.3    2.25    ;
                  -2.7     0.3    2.025   ;
                  -3.      0.3    1.8     ;
                  -2.7     0.3    1.8     ;
                  -2.7     0.     1.575   ;
                  -2.7    -0.3    1.575   ;
                  -3.     -0.3    1.35    ;
                  -3.      0.     1.35    ;
                  -2.5     0.     1.125   ;
                  -2.5    -0.3    1.125   ;
                  -2.65   -0.3    0.9375  ;
                  -2.65    0.     0.9375  ;
                  -2.     -0.3    0.9     ;
                  -1.9    -0.3    0.6     ;
                  -1.9     0.     0.6     ;
                  -3.      0.3    1.35    ;
                  -2.7     0.3    1.575   ;
                  -2.65    0.3    0.9375  ;
                  -2.5     0.3    1.125   ;
                  -1.9     0.3    0.6     ;
                  -2.      0.3    0.9     ;
                   1.7     0.     1.425   ;  
                   1.7    -0.66   1.425   ;
                   1.7    -0.66   0.6     ;
                   1.7     0.     0.6     ;
                   2.6     0.     1.425   ;
                   2.6    -0.66   1.425   ;
                   3.1    -0.66   0.825   ;
                   3.1     0.     0.825   ;
                   2.3     0.     2.1     ;
                   2.3    -0.25   2.1     ;
                   2.4    -0.25   2.025   ;
                   2.4     0.     2.025   ;
                   2.7     0.     2.4     ;
                   2.7    -0.25   2.4     ;
                   3.3    -0.25   2.4     ;
                   3.3     0.     2.4     ;
                   1.7     0.66   0.6     ;
                   1.7     0.66   1.425   ;
                   3.1     0.66   0.825   ;
                   2.6     0.66   1.425   ;
                   2.4     0.25   2.025   ;
                   2.3     0.25   2.1     ;
                   3.3     0.25   2.4     ;
                   2.7     0.25   2.4     ;
                   2.8     0.     2.475   ;
                   2.8    -0.25   2.475   ;
                   3.525  -0.25   2.49375 ;
                   3.525   0.     2.49375 ;
                   2.9     0.     2.475   ;
                   2.9    -0.15   2.475   ;
                   3.45   -0.15   2.5125  ;
                   3.45    0.     2.5125  ;
                   2.8     0.     2.4     ;
                   2.8    -0.15   2.4     ;
                   3.2    -0.15   2.4     ;
                   3.2     0.     2.4     ;
                   3.525   0.25   2.49375 ;
                   2.8     0.25   2.475   ;
                   3.45    0.15   2.5125  ;
                   2.9     0.15   2.475   ;
                   3.2     0.15   2.4     ;
                   2.8     0.15   2.4     ;
                   0.      0.     3.15    ;
                   0.     -0.002  3.15    ;
                   0.002   0.     3.15    ;
                   0.8     0.     3.15    ;
                   0.8    -0.45   3.15    ;
                   0.45   -0.8    3.15    ;
                   0.     -0.8    3.15    ;
                   0.      0.     2.85    ;
                   0.2     0.     2.7     ;
                   0.2    -0.112  2.7     ;
                   0.112  -0.2    2.7     ;
                   0.     -0.2    2.7     ;
                  -0.002   0.     3.15    ;
                  -0.45   -0.8    3.15    ;
                  -0.8    -0.45   3.15    ;
                  -0.8     0.     3.15    ;
                  -0.112  -0.2    2.7     ;
                  -0.2    -0.112  2.7     ;
                  -0.2     0.     2.7     ;
                   0       0.002  3.15    ;
                  -0.8     0.45   3.15    ;
                  -0.45    0.8    3.15    ;
                   0.      0.8    3.15    ;
                  -0.2     0.112  2.7     ;
                  -0.112   0.2    2.7     ;
                   0.      0.2    2.7     ;
                   0.45    0.8    3.15    ;
                   0.8     0.45   3.15    ;
                   0.112   0.2    2.7     ;
                   0.2     0.112  2.7     ;
                   0.4     0.     2.55    ;
                   0.4    -0.224  2.55    ;
                   0.224  -0.4    2.55    ;
                   0.     -0.4    2.55    ;
                   1.3     0.     2.55    ;
                   1.3    -0.728  2.55    ;
                   0.728  -1.3    2.55    ;
                   0.     -1.3    2.55    ;
                   1.3     0.     2.4     ;
                   1.3    -0.728  2.4     ; 
                   0.728  -1.3    2.4     ;
                   0.     -1.3    2.4     ;
                  -0.224  -0.4    2.55    ;
                  -0.4    -0.224  2.55    ;
                  -0.4     0.     2.55    ;
                  -0.728  -1.3    2.55    ;
                  -1.3    -0.728  2.55    ;
                  -1.3     0.     2.55    ;
                  -0.728  -1.3    2.4     ;  
                  -1.3    -0.728  2.4     ; 
                  -1.3     0.     2.4     ; 
                  -0.4     0.224  2.55    ;
                  -0.224   0.4    2.55    ;
                   0.      0.4    2.55    ;
                  -1.3     0.728  2.55    ;
                  -0.728   1.3    2.55    ;
                   0.      1.3    2.55    ;
                  -1.3     0.728  2.4     ;
                  -0.728   1.3    2.4     ;
                   0.      1.3    2.4     ;
                   0.224   0.4    2.55    ;
                   0.4     0.224  2.55    ;
                   0.728   1.3    2.55    ;
                   1.3     0.728  2.55    ;
                   0.728   1.3    2.4     ;
                   1.3     0.728  2.4     ;
                   0.      0.     0.      ;
                   1.5     0.     0.15    ;
                   1.5     0.84   0.15    ;
                   0.84    1.5    0.15    ;
                   0.      1.5    0.15    ;
                   1.5     0.     0.075   ;
                   1.5     0.84   0.075   ;
                   0.83    1.5    0.075   ;
                   0.      1.5    0.075   ;
                   1.425   0.     0.      ;
                   1.425   0.798  0.      ;
                   0.798   1.425  0.      ;
                   0.      1.425  0.      ;
                  -0.84    1.5    0.15    ;
                  -1.5     0.84   0.15    ;
                  -1.5     0.     0.15    ;
                  -0.84    1.5    0.075   ;
                  -1.5     0.84   0.075   ;
                  -1.5     0.     0.075   ;
                  -0.798   1.425  0.      ;
                  -1.425   0.798  0.      ;
                  -1.425   0.     0.      ;
                  -1.5    -0.84   0.15    ;
                  -0.84   -1.5    0.15    ;
                   0.     -1.5    0.15    ;
                  -1.5    -0.84   0.075   ;  
                  -0.84   -1.5    0.075   ;
                   0.     -1.5    0.075   ;
                  -1.425  -0.798  0.      ;
                  -0.798  -1.425  0.      ;
                   0.     -1.425  0.      ;
                   0.84   -1.5    0.15    ;
                   1.5    -0.84   0.15    ;
                   0.84   -1.5    0.075   ;
                   1.5    -0.84   0.075   ;
                   0.798  -1.425  0.      ;
                   1.425  -0.798  0.      ];
                
% These select which control points are used for each of the 32 bezier patches    .
function quads = teapotControlPoints() 
        quads = cat(3, [
                   % rim
                       1   2   3   4 ;   5   6   7   8 ;   9  10  11  12 ;  13  14  15  16 ] , [
                       4  17  18  19 ;   8  20  21  22 ;  12  23  24  25 ;  16  26  27  28 ] , [
                      19  29  30  31 ;  22  32  33  34 ;  25  35  36  37 ;  28  38  39  40 ] , [
                      31  41  42   1 ;  34  43  44   5 ;  37  45  46   9 ;  40  47  48  13 ] , [
                   % body                      
                      13  14  15  16 ;  49  50  51  52 ;  53  54  55  56 ;  57  58  59  60 ] , [
                      16  26  27  28 ;  52  61  62  63 ;  56  64  65  66 ;  60  67  68  69 ] , [
                      28  38  39  40 ;  63  70  71  72 ;  66  73  74  75 ;  69  76  77  78 ] , [
                      40  47  48  13 ;  72  79  80  49 ;  75  81  82  53 ;  78  83  84  57 ] , [
                      57  58  59  60 ;  85  86  87  88 ;  89  90  91  92 ;  93  94  95  96 ] , [
                      60  67  68  69 ;  88  97  98  99 ;  92 100 101 102 ;  96 103 104 105 ] , [
                      69  76  77  78 ;  99 106 107 108 ; 102 109 110 111 ; 105 112 113 114 ] , [
                      78  83  84  57 ; 108 115 116  85 ; 111 117 118  89 ; 114 119 120  93 ] , [
                   % handle
                     121 122 123 124 ; 125 126 127 128 ; 129 130 131 132 ; 133 134 135 136 ] , [
                     124 137 138 121 ; 128 139 140 125 ; 132 141 142 129 ; 136 143 144 133 ] , [
                     133 134 135 136 ; 145 146 147 148 ; 149 150 151 152 ;  69 153 154 155 ] , [
                     136 143 144 133 ; 148 156 157 145 ; 152 158 159 149 ; 155 160 161  69 ] , [
                   % spout
                     162 163 164 165 ; 166 167 168 169 ; 170 171 172 173 ; 174 175 176 177 ] , [
                     165 178 179 162 ; 169 180 181 166 ; 173 182 183 170 ; 177 184 185 174 ] , [
                     174 175 176 177 ; 186 187 188 189 ; 190 191 192 193 ; 194 195 196 197 ] , [
                     177 184 185 174 ; 189 198 199 186 ; 193 200 201 190 ; 197 202 203 194 ] , [
                   % lid
                     204 204 204 204 ; 207 208 209 210 ; 211 211 211 211 ; 212 213 214 215 ] , [
                     204 204 204 204 ; 210 217 218 219 ; 211 211 211 211 ; 215 220 221 222 ] , [
                     204 204 204 204 ; 219 224 225 226 ; 211 211 211 211 ; 222 227 228 229 ] , [
                     204 204 204 204 ; 226 230 231 207 ; 211 211 211 211 ; 229 232 233 212 ] , [
                     212 213 214 215 ; 234 235 236 237 ; 238 239 240 241 ; 242 243 244 245 ] , [
                     215 220 221 222 ; 237 246 247 248 ; 241 249 250 251 ; 245 252 253 254 ] , [
                     222 227 228 229 ; 248 255 256 257 ; 251 258 259 260 ; 254 261 262 263 ] , [
                     229 232 233 212 ; 257 264 265 234 ; 260 266 267 238 ; 263 268 269 242 ] , [
                   % bottom
                     270 270 270 270 ; 279 280 281 282 ; 275 276 277 278 ; 271 272 273 274 ] , [
                     270 270 270 270 ; 282 289 290 291 ; 278 286 287 288 ; 274 283 284 285 ] , [
                     270 270 270 270 ; 291 298 299 300 ; 288 295 296 297 ; 285 292 293 294 ] , [
                     270 270 270 270 ; 300 305 306 279 ; 297 303 304 275 ; 294 301 302 271 ] );
                
%this is the function that teapot uses to convert the bezier patches into surfaces
function varargout = evalCubicBezierPatch(n,xc,yc,zc,index,colorBy)
%EVALCUBICBEZIERPATCH(N,XC,YC,ZC,INDEX,COLORBY) Creates a surface from 
%   a cubic bezier patch. N is the number of interpolation steps which 
%   are to be used along each axis of the UV parameter space. XC, YC, and ZC 
%   are the X, Y, and Z coordinates of the 16 control points.  
%
% The eqn for a point on the surface is:
%
%   P(u,v) = [u^3 3u^2(1-u) 3u(1-u)^2 (1-u)^3]*P*[v^3 3v^2(1-v) 3v(1-v)^2 (1-v)^3]'
%
% where:
%   0<=u<=1
%   0<=v<=1
%   P is a 4x4 containing the 16 control points
%
%   COLORBY controls how the surface's colors are generated:
%       x      the X coordinates are used
%       y      the Y coordinates are used
%       z      the Z coordinates are used
%       y      the U parameter values are used
%       v      the V parameter values are used
%       index  the value of INDEX is used
%

    % generate N values for U   
    u = (0:n-1)'/(n-1);
    % and build the params for curves of constant U
    A = [(u.^3) (3 * u.^2 .* (1-u)) (3 * u .* (1-u).^2) ((1-u).^3)];
        
    % generate N values for V
    v = (0:n-1)'/(n-1);
    % and build the params for curves of constant V
    B = [(v.^3) (3 * v.^2 .* (1-v)) (3 * v .* (1-v).^2) ((1-v).^3)];
        
    % build the tensor product of the U's & V's
    mat=kron(A,B);
    
    % multiply by the control points
    xd = mat*xc;
    yd = mat*yc;
    zd = mat*zc;
     
    % reshape the 1x...'s into square matrices
    x=reshape(xd,n,n);
    y=reshape(yd,n,n);
    z=reshape(zd,n,n);
     
    % how should we color the patch?
    if strcmp(colorBy,'x')
        colors=x;
    elseif strcmp(colorBy,'y')
        colors=y;
    elseif strcmp(colorBy,'z')
        colors=z;     
    elseif strcmp(colorBy,'u')
        colors=repmat([0:1/(n-1):1],n,1);
    elseif strcmp(colorBy,'v')
        colors=repmat([0:1/(n-1):1]',1,n);
    elseif strcmp(colorBy,'index')
        colors=repmat(index,n,n);
    elseif strcmp(colorBy,'none')
        colors=[];
    end
        
    % if no output args, use surface to draw the geometry
    if nargout==0
        % create surface
        s = surface(reshape(xd,n,n),reshape(yd,n,n),reshape(zd,n,n),colors);
         
        % make it look nice
        set(s,'EdgeColor','none','FaceColor','interp')
        
    % otherwise, return the geometry in the correct form for patch        
    elseif nargout==3
        [f v c] = surf2patch(reshape(xd,n,n),reshape(yd,n,n),reshape(zd,n,n),colors);        
        varargout{1} = f;
        varargout{2} = v;
        varargout{3} = c;
    end
            