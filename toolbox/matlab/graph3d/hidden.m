function ret_type = hidden(onoff)
%HIDDEN Mesh hidden line removal mode.
%   HIDDEN ON sets hidden line removal on for meshes in the current axes.
%   HIDDEN OFF sets hidden line removal off so you can see through
%   meshes in the current axes.
%   HIDDEN by itself toggles the state of hidden line removal.
%
%   See also MESH.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 04:27:45 $

if nargin == 0
    tog = 'tog';    % toggle hidden state
else
    tog = lower(onoff);
end
hf = gcf;
ax = gca;
if isstr(get(ax,'color')),
  bkgd = get(hf,'Color');
else
  bkgd = get(ax,'color');
end
% get mesh handle
hk = get(ax,'Children');
for i = 1:length(hk)
    % see if the object could be a mesh - must be a surface first.
    if strcmp('surface',get(hk(i),'type')) | strcmp(get(hk(i),'type'),'patch'),
        fc = get(hk(i),'facecolor');
        % see if the object could be a mesh.
        if strcmp(fc,'none') | isequal(fc,bkgd),
            if strcmp(tog,'on')
                set(hk(i),'facecolor',bkgd);
            elseif strcmp(tog,'off')
                set(hk(i),'facecolor','none');
            else
                if strcmp(fc,'none')
                    set(hk(i),'facecolor',bkgd);
                    tog = 'on';
                else
                    set(hk(i),'facecolor','none');
                    tog = 'off';
                end
            end
        end
    end
end

if nargout > 0
   ret_type = tog;
end


