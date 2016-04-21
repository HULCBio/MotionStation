function [x,y]=qaskenco(msg,M)
%QASKENCO
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use QAMMOD instead.

%   QASKENCO(M) plots a QASK square constellation with M-ary number M.
%   M must be an integer power of 2.
%
%   QASKENCO(MSG, M) plots the location of MSG in constellation with
%   M-ary number M. The elements in MSG must be integers in the range
%   [0, M-1].
%
%   [X, Y] = QASKENCO(M) outputs the in-phase and quadrature components
%   of the QASK square constellation in variables X and Y respectively.
%
%   [X, Y] = QASKENCO(MSG, M) encodes the message signal given in MSG
%   into in-phase and quadrature component variables X and Y.
%
%	The output signal constellations are scaled such that the minimum
%   distance between adjacent signal points is 2.
%
%   This function generates a Gray code with K = log2(M) bits, when K
%   is an even integer. When K is an odd integer, this function generates a
%   non-Gray-code near-square constellation.
%
%   See also QASKDECO.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

if nargin < 1
    disp('Usage: QASKENCO(M)');
end;

plot_type = [];
if nargin == 1
    M = msg;
    plot_type = 'N';
elseif isstr(M)
    plot_type = M;
    M = msg;
end;

if M < 0
    error('M must be a positive number.');
end;

K = log2(M);
if floor(K) ~= K
	error('M must equal an integer power of 2.');
end;

if ~isempty(plot_type)
    msg = 0:M-1;
end;

if any(msg<0) | any(msg>M-1)
	error('Input message to QASKENCO must be integers in the range [0, M-1].');
end

msg = msg + 1;
% define a table for the coding.
[tabx, taby] = QASKConstlation(K);

if nargout > 0 % Encode the message
    x = tabx(msg);
    y = taby(msg);
else % Plot the constellation
    if isempty(plot_type)
	plot_type = 'N';
    end

	lims = max(max([tabx(msg) taby(msg)])) * [-1 1];
    axx =  lims + [-1 1];
    if findstr(lower(plot_type), 'n')
       handle = plot(tabx(msg), taby(msg), 'r.',...
          [max(tabx(msg)) min(tabx(msg))],[0 0], 'k-',...
          [0 0], [max(taby(msg)) min(taby(msg))], 'k-');
        set(handle(1),'Markersize',12);
        set(get(handle(1),'parent'), ...
            'box','off',...
            'defaulttextfontsize', 9,...
            'Ylim',axx,...
            'Xlim',axx );
        for i = 1 : length(msg)
            text(tabx(msg(i)), taby(msg(i)), num2str(msg(i)-1));
        end;
    else
        handle = plot(tabx(msg), taby(msg), plot_type,...
                 axx, [0 0], 'k-', [0 0], axx, 'k-');
    end
    axis('square');
    set(handle(2), 'Xdata', get(get(handle(2), 'parent'), 'Xlim'));
    set(handle(3), 'Ydata', get(get(handle(3), 'parent'), 'Ylim'));
	set(gca, 'xtick', lims(1):2:lims(2), 'ytick', lims(1):2:lims(2));
	pos = get(gcf, 'position');
	pos = [pos(1) pos(2)-(pos(3)-pos(4)) pos(3) pos(3)];
	set(gcf,'position',pos);
    xlabel('In-phase'); ylabel('Quadrature'); title('QASK Constellation');
end;

%------------------------------------------------------------------
function [xt, yt] = QASKConstlation(K)
% Output the constellation in-phase and quadrature components.

xx = constlay(K, 1);

[leny, lenx] = size(xx);
[xt, yt]= meshgrid([1-lenx : 2 : lenx-1], [leny-1 : -2 : 1-leny]');

xx = xx(:);
xt = xt(:);
yt = yt(:);

tmp = isnan(xx);
if ~isempty(tmp)
  xx(tmp) = [];
  xt(tmp) = [];
  yt(tmp) = [];
end;

[xx, tmp] = sort(xx);
xt = xt(tmp);
yt = yt(tmp);

% [EOF]
