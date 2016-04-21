function hmodem(str, id);
%HMODEM Modulation and demodulation demos.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       HMODEM(STR, ID) plot the figure generated for the modem method given
%       in the string variable STR. The ID is for the simulation method
%       control.
%       ID = 1: Passband Analog modem simulation.
%       ID = 3: Passband Digital modem simulation.
%
%       See also TUTDPCM.
%

%       Wes Wang 11/20/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.15 $

ts = 0.01;
[num,den] = butter(2, 100/2/pi*ts);
Fc = 100/2/pi;

t = [0:ts:3]';
x=sin(t*pi);

if id == 1
    %passband simulation
    if findstr(str, 'amdsb-sc')
        y = amod(x, Fc, 1/ts, 'amdsb-sc');
        z = ademod(y, Fc, 1/ts, 'amdsb-sc/costas', num, den);
    elseif findstr(str, 'amdsb-tc')
        y = amod(x, Fc, 1/ts, 'amdsb-tc',1);
        z = ademod(y, Fc, 1/ts, 'amdsb-tc/costas', 1, num, den);
    elseif findstr(str,'amssb')
        [num1, den1] = hilbiir(ts, ts*10, 10);
        y = amod(x, Fc, 1/ts, 'amssb', num1, den1);
        z = ademod(y, Fc, 1/ts, 'amssb', num, den);
        yu = amod(x, Fc, 1/ts, 'amssb/upper', num1, den1);
        y1 = fft(y, 512); y1 = y1 .* conj(y1) / 512;
        y2 = fft(yu, 512); y2 = y2 .* conj(y2) / 512;
        f = 1000*(0:255)/512;
        figure('position',[25, 50, 576, 600]);
        subplot(311);
        plot(f, [y1(1:256) y2(1:256)]);
        title('Spectrum for LSB and USB');
    elseif findstr(str,'qam')
        x = [x sin(t*3*pi)];
        y = amod(x, Fc, 1/ts, 'qam');
        z = ademod(y, Fc, 1/ts, 'qam', num, den);
    elseif findstr(str,'fm')
        y = amod(x, Fc, 1/ts, 'fm');
        z = ademod(y, Fc, 1/ts, 'fm', num, den);
    elseif findstr(str,'pm')
        y = amod(x, Fc, 1/ts, 'pm');
        z = ademod(y, Fc, 1/ts, 'pm', num, den);
    end;
    if findstr(str, 'amssb')
        subplot(312)
    else
        h=figure;
        subplot(211)
    end;
    plot(t,[x z])
    title('original signal vs. demodulation recovered signal.');
    if findstr(str, 'amssb')
        subplot(313)
    else
        subplot(212)
    end;
    plot(t,y)
    title('Modulated signal.');
elseif id ==3
    M=16;
    N = 20;
    Fs = 100;
    x = randint(N, 1, M);
    y = dmod(x, 10, 1, Fs, 'qask', M);
    xx=modmap(x, 1, 1, 'qask', M);
    [ny, my] = size(y);
    y_n = y  + (rand(ny, my) - .5) * 1.5;
    z = ddemod(y_n, 10, 1, Fs, 'qask', M);
    figure('position',[25, 50, 576, 600]);
    subplot(311)
    plot([0:N-1],x(:),'o',[0:N-1],z(:),'*');
    title('Digital signal. original: o, and recovered: *');
    subplot(312)
    plot([0:N-1],xx(:,1),'+',[0:N-1],xx(:,2),'x')
    title('Mapped Signal. In-phase + and Quadrature x');
    subplot(313)
    plot([0:1/Fs:N-1/Fs],y);
    title('Modulated signal');
end;
