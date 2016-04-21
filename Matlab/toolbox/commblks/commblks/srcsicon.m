function [x,y] = srcsicon(fla)
%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.12 $

% fla == 1 sin
% fla == 2 pulse
% fla == 3 noise
% fla == 4 interger
% fla == 5 binary
% fla == 6 from file
% fla == 7 from wkspace
% fla == 8 to file
% fla == 9 to wkspace
% fla == 10 eye pattern diagram.

x1 = [95  5 10 10 10];
y1 = [75 75 75 70 95];

N = 30;

if fla == 1
    x2 = [0:1/N:1];
    y2 = sin(x2*pi*2)*10+85;
    x2 = (100-15)*x2+10;
elseif fla == 2
    N = ceil(N/2);
    x2 = [0:N, N:-2:0 0];
    y2 = [(rem(x2(1:N+1), 2) == 0) (rem(ceil(x2(N+2:length(x2))/2), 2) == 0)+2];
    y2 = y2 * 5 + 80;
    x2 = x2 / N;
    N = length(x2);
    x2= [x2(1:N-1)' x2(2:N)']';
    x2 = (100-15)*x2(:)'+ 10;
    y2 = [y2(1:N-1)' y2(1:N-1)']';
    x2 = x2(:)';
    x2 = 100-x2;
    y2 = y2(:)';
    x1 = find(x2==min(x2));
    x1=x1(1);
    x2 = [x2(1:x1) x2(x1) x2(x1) x2(x1) x2(x1)-5 x2(x1)+85 x2(x1) x2(x1) x2(x1+1:length(x2))];
    y2 = [y2(1:x1) 98     70     75     75       75        75     y2(x1) y2(x1+1:length(y2))];
    x2=x2+5;
    x1=[];y1=[];
elseif fla == 3
    y2 = rand(1,N+1)*20+75;
    x2 = (100-15)*[0:1/N:1]+10;
elseif (fla == 4) | (fla == 5)
    N = ceil(N/2);
    y2 = rand(1,N+1)*20 + 75;
    if fla == 5
        y2 = (rand(1,N+1) > .5)*10 + 80;
    end;
    x2 = (100-15)*[0:1/N:1]+10;
    x2= [x2(1:N)' x2(2:N+1)']';
    y2 = [y2(1:N)' y2(1:N)']';
    x2 = x2(:)';
    y2 = y2(:)';
elseif fla == 6
    x2 = [0:1/N:1];
    z = exp(j*pi*([0:20]/10+1/2));
    x = [25 25 05 05 25 25 05 13 13 17 17 17 15];
    y = [85 95 95 75 75 89 89 89 95 95 89 89 89];
    x1 = [x real(z)*3.5+15 15 25 25];
    y1 = [y imag(z)*3.5+85 89 89 85];
    y2 = sin(x2*pi*2)*10+y(1);
    x2 = (100-x(1)-5)*x2+x(1); 
%    x = [x x2];
%    y = [y y2];
elseif fla == 7
    x2 = [0:1/N:1];
    x1 = [25 25 05 05 07 12 07 12 07 12 17 12 17 12 25 25];
    y1 = [85 95 95 75 75 83 91 83 75 75 83 91 83 75 75 85];
    y2 = sin(x2*pi*2)*10+y1(1);
    x2 = (100-x1(1)-5)*x2+x1(1); 
elseif fla == 8
    x2 = [0:1/N:1];
    z = exp(j*pi*([0:20]/10+1/2));
    x = [25 25 05 05 25 25 05 13 13 17 17 17 15];
    y = [85 95 95 75 75 89 89 89 95 95 89 89 89];
    x1 = [x real(z)*3.5+15 15 25 25];
    y1 = [y imag(z)*3.5+85 89 89 85];
    y2 = -sin(x2*pi*2)*10+y(1);
    x2 = 100-((100-x(1)-5)*x2+x(1));
    x1 = 100-x1;
elseif fla == 9
    x1 = [0:1/N:1];
    y1 = sin(x1*pi*2)*10+85;
    x1 = 70*x1+5; 
    x2 = [75 75 95 95 75 75 77 82 77 82 77 82 87 82];
    y2 = [85 75 75 95 95 75 75 83 91 83 75 75 83 91];
elseif fla == 10
    x1 = [5  95 95 5  5  5];
    y1 = [35 35 95 95 35 65];
    x2 = [0:1/N:1];
    y2 = sin(x2*pi*2)*25+65;
    x2 = 90*x2+5;
    x2 = [x2 x2(length(x2):-1:1)];
    y2 = [y2 y2];
end;

x = [x1 x2];
y = [y1 y2];
%plot(0,0,100,100,x, y)
