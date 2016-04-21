function eyescat(x, Fd, Fs, offset, Dpoint)
%EYESCAT Produce eye-pattern diagram or scatter plot.
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use eyediagram or scatterplot instead.

%   For eye-pattern diagrams:
%
%       EYESCAT(X, Fd, Fs) produces an eye-pattern diagram with time range
%       from 0 to 1/Fd.  The sample frequency for input signal X is 1/Fs. 
%       Fs must be larger than Fd.  Fs/Fd must be a positive integer.
%
%       EYESCAT(X, Fd, Fs, OFFSET) produces an eye-pattern diagram shifted
%       by OFFSET samples.  OFFSET must be an integer.
%
%       EYESCAT(X, Fd, Fs, OFFSET, DPOINT) produces an eye-pattern diagram
%       with a vertical line marking the location of the decision point. 
%       DPOINT indicates the sample number of the marker. 
%
%   For scatter plots:
%
%       EYESCAT(X, Fd, Fs, DPOINT, 'String') produces a scatter plot. String can
%       can be '.', '*', 'x', 'o' or '+', which specifies the plot symbols. 
%
%       See also DMOD, DMODCE, MODMAP.

%       Wes Wang 10/5/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.18 $

error(nargchk(3,5,nargin));
if nargin < 4
    offset = 0;
end;
if nargin < 5
    Dpoint = 0;
end;

[r, c] = size(x);
if r * c == 0
    disp('Input variable X is empty.')
    return;
end;
if r == 1
    x = x(:);
end;

FsDFd = Fs/ Fd;
offset = rem(offset/FsDFd, 1) * FsDFd;
if offset < 0
    offset = rem(offset/FsDFd + 1, 1) * FsDFd;
end;

if max(max(abs(imag(x)))) > 0
    x = [real(x), imag(x)];
    x = x(:, [1:2:size(x, 2), 2:2:size(x, 2)]);
end;

if isstr(Dpoint)
    %scatter plot
    if offset <= 0
        offset = FsDFd;
    end;
    yy = x(offset : FsDFd : size(x, 1), :);
    if isempty(yy)
        disp('Matrix is empty after taking the sample point.')
        return;
    end;
    if length(Dpoint) ~= 1
        Dpoint = '.';
    end;
    [len_yy, wid_yy]=size(yy);
    if wid_yy == 1
        tmp=plot(yy, zeros(1,len_yy), Dpoint);
        if Dpoint == '.'
            set(tmp, 'MarkerSize', 12);
        end;
        tmp = 'In-phase plot';
        min_y = min(yy);
        max_y = max(yy);
        if max_y <= min_y
            max_y = min_y + sqrt(eps);
            min_y = min_y - sqrt(eps);
        end;
        axis([min_y, max_y, -1, 1])
    else
        tmp=plot(yy(:, 1:2:wid_yy), yy(:, 2:2:wid_yy), Dpoint);
        if Dpoint == '.'
            set(tmp, 'MarkerSize', 12);
        end;
        if wid_yy == 2
            tmp = 'In-Phase';
        elseif wid_yy == 4
            tmp = '1st pair: blue; 2nd: green;';
        elseif wid_yy == 6
            tmp = '1st pair: blue; 2nd: green; 3rd: red';
        elseif wid_yy == 8
            tmp = '1st pair: blue; 2nd: green; 3rd: red; 4th: cyan';
        elseif wid_yy == 10
            tmp = '1st pair: blue; 2nd: green; 3rd: red; 4th: cyan; 5th: magenta';
        else
            tmp = '1st pair: blue; 2nd: green; 3rd: red; 4th: cyan; 5th: magenta; 6th: yellow';
        end;
        ylabel('Quadrature')
        min_y = min(min(yy));
        max_y = max(max(yy));
        if max_y <= min_y
            max_y = min_y + sqrt(eps);
            min_y = min_y - sqrt(eps);
        end;        
        axis('equal')
        axis([min_y, max_y, min_y, max_y])
    end;
    title('Scatter plot')
    xlabel(tmp)
else
    % eye-pattern plot.
    [len_x, wid_x]=size(x);
    t = rem([0 : (len_x-1)]/FsDFd, 1)'/Fd;

    if offset > 0
        tmp = find(t+eps*FsDFd < offset/Fs);
        t(tmp) = t(tmp) + 1/Fd;
    end;

    if Dpoint <= 0
        Dpoint = FsDFd;
    end;

    t_Dpoint = t(Dpoint);
    axx=[min(t), max(t)+1/Fs, min(min(x)), max(max(x))];
    [len_x, wid_x]  = size(x);

    if offset == 0
        offset = FsDFd;
    end;

    index = fliplr([1+offset : FsDFd : len_x]);
    NN = ones(1, wid_x) * NaN;
    for ii = 1 : length(index)
        i = index(ii);
        if i > 1
            x = [x(1:i, :); NN; x(i:size(x, 1), :)];
            t = [t(1:i-1); t(i-1)+1/Fs; NaN; t(i:size(t, 1))];
        end;
    end;

    if nargin >=5
        plot(t, x, [t_Dpoint, t_Dpoint], axx(3:4),'r')
        text(t_Dpoint, axx(4), 'DPoint')
    else
        plot(t, x)
    end;

    axis(axx);
    xlabel('time (second)');
    ylabel('amplitude');
    title('Eye-Pattern Diagram')
end

