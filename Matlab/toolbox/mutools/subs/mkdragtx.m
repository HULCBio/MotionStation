% function out = mkdragtx(message,figs,apos,axlim,aylim)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function out = mkdragtx(message,figs,apos,axlim,aylim)

%   creates 1 Dummy Icon for EVERY window in figs,
%       the icon is a text object inside a normalized
%       invisible AXES in the figure.  MKDRAGTX returns
%       the AXES handles for all of the FIGS

global MUDUMMYICONS  % handles of the extra icons

if strcmp('create',message)
        numberwins = length(figs);
        axhans = zeros(numberwins,1);
        txhans = zeros(numberwins,1);
        for i=1:numberwins
                if nargin == 2
                    aposi = [0 0 1 1];
                    xlimi = [0 1];
                    ylimi = [0 1];
                else
                    aposi = apos(i,:);
                    xlimi = axlim(i,:);
                    ylimi = aylim(i,:);
                end

		if gcf ~= figs(i)	% try to keep visible off
                  figure(figs(i));
                end

                axhans(i) = axes('position',aposi,...
                        'xlim',xlimi,'ylim',ylimi,...
                        'visible','off');   % create invisible, full, normalized AXES
                txhans(i) = text('position',[0.1 0.9],...
                                'color',[0 0 0],...
                                'string','IC',...
				'interpreter','none',...
                                'visible','off');
        end
        out = axhans;
        if isempty(MUDUMMYICONS)
            MUDUMMYICONS = [figs(:) axhans txhans];
        else
            MUDUMMYICONS = [MUDUMMYICONS ; [figs(:) axhans txhans]];
        end
        set(MUDUMMYICONS(:,2),'BusyAction','queue','Interruptible','off');
        set(MUDUMMYICONS(:,3),'BusyAction','queue','Interruptible','off');

elseif strcmp(message,'destroy')    % doesn't clean up AXES and TEXT, but fixes MUDUMMYICONS
    for i=1:length(figs)
        if ~isempty(MUDUMMYICONS)
            loc = find(MUDUMMYICONS(:,1)~=figs(i));
            MUDUMMYICONS = MUDUMMYICONS(loc,:);
        end
    end
end
