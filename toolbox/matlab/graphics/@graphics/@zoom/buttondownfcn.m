function buttondownfcn(hZoom,param,dorightclick)
% Mouse Button Down Function

% Copyright 2002-2004 The MathWorks, Inc.

% By default, don't support right click zoom out
if nargin==1
  dorightclick = false;
end

if strcmp(hZoom.Debug,'on')
    disp('buttondownfcn')
end

hFig = get(hZoom,'FigureHandle');
hAxesVector = findaxes(hZoom);
if ~isempty(hAxesVector),
   set(hZoom,'CurrentAxes',hAxesVector);
 
   sel_type = get(hFig,'SelectionType');
   switch sel_type

       case 'normal' % left click        
         localZoom(hZoom,hAxesVector);
                    
       case 'open' % double click
          % Reset top plot
          resetplot(hZoom,hAxesVector);
         
       case 'alt' % right click
          % zoom out
          if dorightclick
             applyzoomfactor(hZoom,hAxesVector,.9);
          end
          
       case 'extend' % center click
          % Do nothing 
   end
end

%---------------------------------------------------%
function localZoom(hZoom,hAxesVector),

hFigure = get(hZoom,'FigureHandle');

resetplotview(hAxesVector,'InitializeCurrentView');

% Call appropriate zoom method based on whether plot is
% 2-D or 3-D plot
if is2D(hAxesVector(1))
  buttondownfcn2D(hZoom,hAxesVector);
else
  buttondownfcn3D(hZoom,hAxesVector);
end









