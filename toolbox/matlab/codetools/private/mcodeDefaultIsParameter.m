function [bool] = mcodeDefaultIsParameter(hObj,hProp)
% Default implementation for m-code generation object interface
% Called by MAKEMCODE, the code generator engine

% Copyright 2003 The MathWorks, Inc.

bool = false;

if isa(hObj,'hg.GObject')
  bool = localGenericHG_mcodeIsParameter(hObj,hProp);  
  if bool, return, end
end

if isa(hObj,'hg.line')
   bool = localHGLine_mcodeIsParameter(hObj,hProp);
elseif isa(hObj,'hg.patch')
   bool = localHGPatch_mcodeIsParameter(hObj,hProp);   
elseif isa(hObj,'hg.surface')
   bool = localHGSurface_mcodeIsParameter(hObj,hProp);
elseif isa(hObj,'hg.image')
   bool = localHGImage_mcodeIsParameter(hObj,hProp);
end

%----------------------------------------------------------%
function [bool] = localGenericHG_mcodeIsParameter(hObj,hProp)  

name = get(hProp,'Name');
param = {'Parent'};
bool = any(strcmp(name,param));


%----------------------------------------------------------%
function [bool] = localHGImage_mcodeIsParameter(hObj,hProp)

name = get(hProp,'Name');
param = {'XData','YData','CData'};
bool = any(strcmp(name,param));

%----------------------------------------------------------%
function [bool] = localHGSurface_mcodeIsParameter(hObj,hProp)

name = get(hProp,'Name');
param = {'XData','YData','ZData',...
         'CDataMapping','CData',...
         'VertexNormals'};
bool = any(strcmp(name,param));

%----------------------------------------------------------%
function [bool] = localHGPatch_mcodeIsParameter(hObj,hProp)

name = get(hProp,'Name');
param = {'XData','YData','ZData',...
         'Vertices','Faces',...
         'FaceVertexAlphaData','FaceVertexCData',...
         'CDataMapping','CData',...
         'VertexNormals'};
bool = any(strcmp(name,param));

%----------------------------------------------------------%
function [bool] = localHGLine_mcodeIsParameter(hObj,hProp)

name = get(hProp,'Name');
param = {'XData','YData','ZData'};
bool = any(strcmp(name,param));




