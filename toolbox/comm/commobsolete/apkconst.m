function yy=apkconst(nir, air, pir, plot_type)
%APKCONST 
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use SCATTERPLOT instead.

%   APKCONST(NUMSIG, AMP, PHASE) plots a circle signal constellation whose kth
%   circle has NUMSIG(k) evenly spaced constellation points at radius AMP(k).
%   One point on the kth circle has phase PHASE(k). NUMSIG, AMP, and PHASE are
%   vectors of the same length.
%
%   APKCONST(NUMSIG, AMP) is the same as the syntax above, except that one
%   point on each circle has zero phase.
%
%   APKCONST(NUMSIG) is the same as the syntax above, except that the kth
%   circle has radius k.
%
%   Y = APKCONST(...) outputs a complex vector whose real part is the in-phase
%   component and whose imaginary part is the quadrature component.  This
%   syntax does not produce a plot.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

error(nargchk(1,4,nargin));

m = length(nir);
if nargin <= 1
    air = [1:m];
end

if nargin <= 2
    pir = zeros(1,m);
end

if nargin <= 3
    plot_type = 'r*';
end

if isempty(plot_type)
    plot_type = 'r*';
end

if nargout < 1
    plot_flag = 1;
else
    plot_flag = 0;
end

j=sqrt(-1);
z = exp(j*[0:100]*pi/50);
x=real(z); y=imag(z);
if plot_flag
    cax = newplot;
    hold_state = ishold;
    plot(x*max(air), y*max(air));
    if ~hold_state
        hold on
    end;
    zz=axis*1.05;
    plot(zz(1:2),[0,0],'k');
    plot([0,0],zz(3:4),'k');
end
z=[];
for i = 1:m
    for k = 1:nir(i)
        z = [z air(i)*exp(j*((k-1)*2*pi/nir(i)+pir(i)))];
    end
    if plot_flag
        if (i ~= m)
            plot(x*air(i), y*air(i));
        end
    end
end
% plot the ASK/PSK signal.
if plot_flag
    if findstr(lower(plot_type), 'n')
        tmp = plot(z, 'r.');
	set(tmp, 'MarkerSize', 12)
	for i = 1 : length(z)
            text(real(z(i)), imag(z(i)), num2str(i-1));
	end
    else
        tmp = plot(z, plot_type);
        if findstr(lower(plot_type), '.')
            set(tmp, 'MarkerSize', 12)
	end
    end

    if ~hold_state
        axis('equal');
        axis('off');
        text(zz(1)+(zz(2)-zz(1))/4, zz(3)-(zz(4)-zz(3))/15, 'ASK/PSK Constellation');
        hold off;
    end
else
    yy = z;
end