function pandown(pflag)
%PANDOWN Button down function for panner lines and patch.
%   pandown(0) - buttondownfcn of patch
%   pandown(1) - buttondownfcn of line in panner
%
 
%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.9 $

    fig = gcf;
  %  if justzoom(fig), return, end
    ud = get(fig,'userdata');

    if ~strcmp(get(fig,'pointer'),'custom') | ...
          ~((ud.pointer==0) | (ud.pointer==1)) 
        % we're not actually on the patch, or we're in the wrong
        % mouse mode (only pan if in pointer or zoom modes).
        if ud.pointer == 2  % help mode
            spthelp('exit','pandown',num2str(pflag))
        end
        return
    end

    if ~isempty(ud.lines)
        invis = [];
        if ud.prefs.tool.ruler
            invis = [ud.ruler.lines ud.ruler.markers ud.ruler.hand.buttons]';
        end
        if strcmp(get(ud.toolbar.complex,'enable'),'on')
            switch get(ud.toolbar.complex,'userdata')
            case 1, xform = 'real';
            case 2, xform = 'imag';
            case 3, xform = 'abs';
            case 4, xform = 'angle';
            end
        else
            xform = 'real';
        end
        if panfcn('Ax',ud.mainaxes,...
               'Bounds',ud.limits,...
               'BorderAxes',ud.mainaxes_border,...
               'DirectFlag',0,...
               'Data',ud.lines,...
               'PannerPatch',ud.panner.panpatch,...
               'DynamicDrag',ud.prefs.panner.dynamicdrag,...
               'Transform',xform,...
               'Invisible',invis)
            if ud.prefs.tool.ruler
                ruler('newlimits')
            end
        end
    end
