function expand(Axes,X,Y,Xm,Ym)
%EXPAND  Zooms out (increases axes window) to include (X,Y) point.

%   Author(s): P. Gahinet, B. Eryilmaz
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:29 $

ExpandFlag = 0;
AutoScaleX = strcmp(Axes.XlimMode,'auto');
AutoScaleY = strcmp(Axes.YlimMode,'auto');
Xlim = Axes.Xlim;
Ylim = Axes.Ylim;
X1 = min(X);  X2 = max(X);
Y1 = min(Y);  Y2 = max(Y);

switch Axes.Type
case 'pzmap'
	% Trigger magnification when exiting axis
	if AutoScaleX & AutoScaleY & (X1<Xlim(1) | X2>Xlim(2) | Y1<Ylim(1) | Y2>Ylim(2)),
		% Dilate rectangle to 200% of current size
		ExpandFlag = 1;
		HalfX = (Xlim(2)-Xlim(1))/2;
		HalfY = (Ylim(2)-Ylim(1))/2;
        Xlim = Xlim + [-HalfX,HalfX];
        Ylim = Ylim + [-HalfY,HalfY];
	end
	
case 'bodemag'
	% Magnify when (X,Y) exits axes area
	if AutoScaleX & (X1<Xlim(1) | X2>Xlim(2))
		% Frequency axis: Add a decade to the left or right
		ExpandFlag = 1;
		Xlim(1) = Xlim(1)/10^(X1<Xlim(1));   
		Xlim(2) = Xlim(2)*10^(X2>Xlim(2));   
	end
	
	if AutoScaleY & (Y1<Ylim(1) | Y2>Ylim(2))
		% Mag axis: add 40 dB up, 20 dB down
		Ylinabs = strcmpi(Axes.YUnits,'abs') & strcmp(get(Axes.Handle,'Yscale'),'linear');
		if Ylinabs
			ExpandFlag = Y2>Ylim(2) | Y1>0;  % watch for case Ylim(1)=0
			if ExpandFlag
				Ylim(1) = Ylim(1) / 2^(Y1<Ylim(1));
				Ylim(2) = Ylim(2) * 2^(Y2>Ylim(2));
			end
		else
			ExpandFlag = 1;
			if strcmpi(Axes.YUnits,'dB')
				Ylim(1) = Ylim(1) - 20 * (Y1<Ylim(1));
				Ylim(2) = Ylim(2) + 40 * (Y2>Ylim(2));
			else
				Ylim(1) = Ylim(1) / 10^(Y1<Ylim(1));
				Ylim(2) = Ylim(2) * 100^(Y2>Ylim(2));
			end
		end
	end
	
case 'bodephase'
	% Magnify when (X,Y) exits axes area
	if AutoScaleX & (X1<Xlim(1) | X2>Xlim(2))
		% Frequency axis: Add a decade to the left or right
		ExpandFlag = 1;
		Xlim(1) = Xlim(1)/10^(X1<Xlim(1));   
		Xlim(2) = Xlim(2)*10^(X2>Xlim(2));   
	end
	
	if AutoScaleY & (Y1<Ylim(1) | Y2>Ylim(2))
		% Phase: add 90 degree up or down
		ExpandFlag = 1;
		if strcmpi(Axes.YUnits,'deg')
			Ylim(1) = Ylim(1) - 90 * (Y1<Ylim(1));
			Ylim(2) = Ylim(2) + 90 * (Y2>Ylim(2));
			% Reset phase ticks
			set(Axes.Handle,'Ylim',Ylim,'YtickMode','auto')
			NewTicks = phaseticks(get(Axes.Handle,'YTick'),Ylim);
			set(Axes.Handle,'YTick',NewTicks)
		else
			Ylim(1) = Ylim(1) - 2 * (Y1<Ylim(1));
			Ylim(2) = Ylim(2) + 2 * (Y2>Ylim(2));
		end
	end
	
case 'nichols'
	if AutoScaleX & (X1 < Xlim(1) | X2 > Xlim(2))
		ExpandFlag = 1;
		% Phase: add 90 degree left or right
		if strcmpi(Axes.XUnits, 'deg')
			Xlim(1) = Xlim(1) - 90 * (X1 < Xlim(1));
			Xlim(2) = Xlim(2) + 90 * (X2 > Xlim(2));
			
			% Reset phase ticks
			set(Axes.Handle,'XLim',Xlim,'XtickMode','auto');
			NewTicks = phaseticks(get(Axes.Handle,'XTick'),Xlim);
			set(Axes.Handle, 'XTick', NewTicks)
		else      
			Xlim(1) = Xlim(1) - 2 * (X1 < Xlim(1));
			Xlim(2) = Xlim(2) + 2 * (X2 > Xlim(2));
		end
	end
	
	if AutoScaleY & (Y1 < Ylim(1) | Y2 > Ylim(2))
		% Mag axis: add 20 dB up, 20 dB down
		Ylinabs = strcmpi(Axes.YUnits, 'abs') & ...
			strcmp(get(Axes.Handle, 'Yscale'), 'linear');
		if Ylinabs
			ExpandFlag = Y2 > Ylim(2) | Y1 > 0;  % watch for case Ylim(1) = 0
			if ExpandFlag
				Ylim(1) = Ylim(1) / 2^(Y1 < Ylim(1));
				Ylim(2) = Ylim(2) * 2^(Y2 > Ylim(2));
			end
		else
			ExpandFlag = 1;
			if strcmpi(Axes.YUnits, 'dB')
				Ylim(1) = Ylim(1) - 20 * (Y1 < Ylim(1));
				Ylim(2) = Ylim(2) + 20 * (Y2 > Ylim(2));
			else
				Ylim(1) = Ylim(1) / 10^(Y1 < Ylim(1));
				Ylim(2) = Ylim(2) * 10^(Y2 > Ylim(2));
			end
		end
	end
end

% Update limits and fire LimitChanged event
if ExpandFlag
    % Update limits
	set(Axes.Handle,'Xlim',Xlim,'Ylim',Ylim)
    % Move pointer
    if nargin<4,
        % Use (X,Y) as mouse position if none supplied
        Axes.moveptr('move',X,Y);
    else
        Axes.moveptr('move',Xm,Ym);
    end
    % Notify of limit change
	Axes.send('LimitChanged');
end

