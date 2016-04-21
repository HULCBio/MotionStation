function [cs,eu] = convert2engstrs(yy,varargin)
%CONVERT2ENGSTRS Convert a vector to engineering strings.
%   [CX,EU] = CONVERT2ENGSTRS(X) converts X to a character array,  CX,
%   representing the converted vector.  The engineering unit prefix is
%   returned as a character in EU.  If X is a matrix, CX will be a cell
%   array of string matrices.
%
%   [...] = CONVERT2ENGSTRS(X,TIMESTR) will cause conversion  from seconds
%   to mins/hrs/days/etc when appropriate, and the new units in EU.
%
%   [...] = CONVERT2ENGSTRS(X,PREC) will return CX with PREC digits after
%   the decimal.  PREC is 3 by default.
%
%   EXAMPLE:
%   fig = figure; ax = axes;
%   plot(1:1000);
%   xticks = get(ax,'XTick');
%   [cxticks,eu] = convert2engstrs(xticks);
%   set(ax,'XTickLabel',cxticks);
%   set(get(ax,'XLabel'),'String',['Frequency, ',eu, 'Hz']);
%
%   See also ENGUNITS.

%   Author(s): D. Orofino
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/07/17 13:16:32 $

error(nargchk(1,3,nargin));

timeStr = '';
prec    = 3;

for indx = 1:length(varargin),
    if ischar(varargin{indx}),        timeStr = varargin{indx};
    elseif isnumeric(varargin{indx}), prec    = varargin{indx};
    end
end

if nargin<2 | ~strcmpi(timeStr, 'time'),
    [ey,ee,eu]=engunits(yy(end),'latex');
else
    [ey,ee,eu]=engunits(yy(end),'latex','time');
end

hasDecimal=0;

% To support matrices we must loop over the rows and columns
[rows, cols] = size(yy);

z = 0;

for indx = 1:rows,
    for jndx = 1:cols,
        c{indx,jndx} = sprintf(['%.' sprintf('%d', prec) 'f'], ...
            yy(indx,jndx).*ee);
        dindx = strfind(c{indx,jndx}, '.');
        if ~isempty(dindx),
            zindx = strfind(c{indx,jndx}(dindx+1:end), '0');
            if isempty(zindx) | max(zindx) < prec,
                z = prec;
            else
                d = max(find(diff(zindx) ~= 1));
                if isempty(d),
                    z = max(z, min(zindx)-1);
                else
                    z = max(z, zindx(d+1)-1);
                end
            end
        end
                
        if any(c{indx,jndx} == '.'), hasDecimal = 1; end
    end
end

for indx = 1:rows,
    for jndx = 1:cols,
        dindx = strfind(c{indx,jndx}, '.');
        c{indx,jndx}(dindx+z+1:end) = [];
    end
end


% if any entry has a decimal, force all to have the same number
% of decimal places
if hasDecimal,
    % Determine maximum # decimal places
    maxPlaces=0;
    for indx = 1:rows,
        for jndx = 1:cols,
            j = find(c{indx, jndx} == '.');
            if ~isempty(j),
                newPlaces = length(c{indx, jndx}) - j;
                maxPlaces = max(maxPlaces,newPlaces);
            end
        end
    end
    maxPlaces = min(prec,maxPlaces);
    % Print using maxPlaces decimal places:
    for indx = 1:rows,
        for jndx = 1:cols,
            c{indx,jndx}=sprintf(['%.' sprintf('%d', maxPlaces) 'f'], ...
                yy(indx,jndx).*ee);
        end
    end
end
cs = cell2mat(c);


%---------------------------------------------------------------
function y=cell2mat(x,align)
% Convert cell-array of strings to a string matrix
% align='right' or 'left'

if nargin<2, align='right'; end
isRight=strcmp(lower(align),'right');

[rows, cols] = size(x);
maxlen=0;
for indx = 1:rows,
    for jndx = 1:cols,
        maxlen=max(maxlen,length(x{indx,jndx}));
    end
end

for jndx = 1:cols,
    y{jndx} = ones(rows,maxlen) .* ' ';
    for indx = 1:rows,
        j=length(x{indx,jndx});
        if isRight,
            y{jndx}(indx,end-j+1:end)=x{indx, jndx}; % right-align
        else
            y{jndx}(indx,1:length(x{indx}))=x{indx};  % left-align
        end
    end
    y{jndx} = char(y{jndx});
end

if length(y) == 1, y = y{1}; end

% [EOF]
