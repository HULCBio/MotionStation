function times = bench(count)
%BENCH  MATLAB Benchmark
%   BENCH times six different MATLAB tasks and compares the execution
%   speed with the speed of several other computers.  The six tasks are:
%   
%    LU       LAPACK, n = 1000.        Floating point, regular memory access.
%    FFT      Fast Fourier Transform.  Floating point, irregular memory access.
%    ODE      Ordinary diff. eqn.      Data structures and M-files.
%    Sparse   Solve sparse system.     Mixed integer and floating point.
%    2-D      plot(fft(eye)).          2-D line drawing graphics.
%    3-D      MathWorks logo.          3-D animated OpenGL graphics.
%
%   A final bar chart shows speed, which is inversely proportional to 
%   time.  Here, longer bars are faster machines, shorter bars are slower.
%
%   BENCH runs each of the six tasks once.
%   BENCH(N) runs each of the six tasks N times.
%   BENCH(0) just displays the results from other machines.
%   T = BENCH(N) returns an N-by-6 array with the execution times.
%
%   The comparison data for other computers is stored in a text file:
%     .../toolbox/matlab/demos/bench.dat
%   Updated versions of this file are available from MATLAB Central:
%     http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?
%          objectId=1836&objectType=file#
%
%   Fluctuations of five or 10 percent in the measured times of repeated
%   runs on a single machine are not uncommon.  Your own mileage may vary.
%
%   This benchmark is intended to compare performance of one particular
%   version of MATLAB on different machines.  It does not offer direct
%   comparisons between different versions of MATLAB.  The tasks and 
%   problem sizes change from version to version.
%
%   The LU and FFT tasks involve large matrices and long vectors.
%   Machines with less than 64 megabytes of physical memory or without
%   optimized Basic Linear Algebra Subprograms may show poor performance.
%
%   The 2-D and 3-D tasks measure graphics performance, including software
%   or hardware support for OpenGL.  The command
%      opengl info
%   describes the OpenGL support available on a particular machine.
   
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.37.4.8 $  $Date: 2004/04/10 23:24:24 $

if nargin < 1, count = 1; end;
times = zeros(count,6);
fig1 = figure;
set(fig1,'pos','default','menubar','none','numbertitle','off', ...
   'name','MATLAB Benchmark')
axes('pos',[0 0 1 1])
axis off
%text(.5,.5,'MATLAB Benchmark','horizontal','center','fontsize',18)
text(.5,.6,'MATLAB Benchmark','horizontal','center','fontsize',18)
task = text(.50,.42, '',...
  'horizontal','center','fontsize',18);
drawnow
pause(1);

for k = 1:count

   % LU, n = 1000.
   
   set(task,'string','LU')
   drawnow
   lu(0);
   n = 1000;
   randn('state',0);
   A = randn(n,n);
   X = A;
   clear X
   tic
      X = lu(A);
   times(k,1) = toc;
   clear A
   clear X
   
   % FFT, n = 2^20.  Do it twice to roughly match LU time.
   
   set(task,'string','FFT')
   drawnow
   fft(0);
   n = 2^20;
   y = ones(1,n)+i*ones(1,n);
   clear y
   randn('state',1);
   x = randn(1,n);
   tic
      y = fft(x);
      clear y
      y = fft(x);
   times(k,2) = toc;
   clear x
   clear y
   
   % ODE. van der Pol equation, mu = 1
   
   set(task,'string','ODE')
   drawnow
   F = @vdp1;
   y0 = [2; 0];
   tspan = [0 eps];
   [s,y] = ode45(F,tspan,y0);
   tspan = [0 400];
   tic
      [s,y] = ode45(F,tspan,y0);
   times(k,3) = toc;
   clear s y
   
   % Sparse linear equations
   
   set(task,'string','Sparse')
   drawnow
   n = 120;
   A = delsq(numgrid('L',n));
   b = sum(A)';
   s = spparms;
   spparms('autommd',0);
   tic
      x = A\b;
   times(k,4) = toc;
   spparms(s);
   clear A b

   % 2-D graphics
   
   set(task,'string','2-D')
   drawnow
   pause(1)
   hh = figure('doublebuffer','on');
   x = (0:1/256:1)';
   plot(x,bernstein(x,0))
   drawnow
   tic
      for j = 1:2
         for n = [1:12 11:-1:2]
            plot(x,bernstein(x,n))
            drawnow
         end
      end
   times(k,5) = toc;
   close(hh)

   % 3-D graphics. Vibrating logo.
   % Gouraud lighting allows smooth motion with OpenGL.
   
   set(task,'string','3-D')
   drawnow
   pause(1)
   hh=figure;
   logo
   logoFig = hh;
   set(logoFig,'color',[.8 .8 .8])
   s = findobj('type','surf');
   set(s,'facelighting','gouraud')
   L1 = 40*membrane(1,25);
   L2 = 10*membrane(2,25);
   L3 = 10*membrane(3,25);
   mu = sqrt([9.6397238445, 15.19725192, 2*pi^2]);
   n = 40;
   tic
   for j = 0:n
      t = 0.5*(1-j/n);
      L = cos(mu(1)*t)*L1 + sin(mu(2)*t)*L2 + sin(mu(3)*t)*L3;
      set(s,'zdata',L)
      drawnow
   end
   times(k,6) = toc;
   pause(1)
   close(logoFig)
   
end  % loop on k
   
% Compare with other machines.  Get latest data file, bench.dat, from
% MATLAB Central at the URL 

if exist('bench.dat','file') ~= 2
   warning('Comparison data in file matlab/demos/bench.dat not available.')
   return
end
fp = fopen('bench.dat');

% Skip over headings in first six lines.
for k = 1:6
   fgetl(fp);
end

% Read the comparison data

specs = {};
T = [];
details = {};
g = fgetl(fp);
m = 0;
while length(g) > 1
   m = m+1;
   specs{m} = g(1:31);
   T(m,:) = sscanf(g(32:end),'%f')';
   details{m} = fgetl(fp);
   g = fgetl(fp);
end

% Close the data file
fclose(fp);

% Add the current machine and sort

T = [T; times];
this = [zeros(m,1); ones(count,1)];
for k = m+1:m+count
   specs{k} = 'This machine                  ';
   details{k} = ['It''s your machine running MATLAB ' version];
end
m = m+count;

totals = sum(T')';
speeds = 100./totals;
[speeds,k] = sort(speeds);
specs = specs(k);
details = details(k);
T = T(k,:);
this = this(k);

% Horizontal bar chart. Highlight this machine with another color.

figure(fig1)
clf
axes('position',[.35 .1 .55 .8])
barh(speeds.*(1-this),'y')
hold on
barh(speeds.*this,'m')
set(gca,'xlim',[0 max(speeds)+.1],'xtick',0:2:max(speeds))
title('Relative Speed')
axis([0 max(speeds)+.1 0 m+1])
set(gca,'ytick',1:m)
set(gca,'yticklabel',specs,'fontsize',9)

% Display report in second figure

fig2 = figure('pos',get(fig1,'pos')+[50 -150 0 0], 'menubar','none', ...
   'numbertitle','off','name','MATLAB Benchmark');
axes('pos',[0 0 1 1])
axis off
x1 = .02;
x2 = .42;
y1 = .93;
dy = (y1-.25)/(m+1);
s = sprintf('%6s \t','LU','FFT','ODE','Sparse','2-D','3-D');
bc = get(fig2,'color');
uicontrol('style','text','units','normal','position',[x2,y1,1-x2,dy], ...
   'background',bc,'string',s,'horizontal','left','fontname','courier',...
   'fontsize', 9);
for k = m:-1:1
   y = y1-(m+1-k)*dy;
   h = uicontrol('style','text','units','normal','position',[x1,y,x2-x1,dy], ...
      'string',specs{k},'horizontal','left','fontname','courier', ...
      'fontsize',9,'background',bc,'tooltip',details{k});
   if this(k), set(h,'foreground','blue'), end
   s = sprintf('%6.2f \t',T(k,:));
   h = uicontrol('style','text','units','normal','position',[x2,y,1-x2,dy], ...
      'string',s,'horizontal','left','fontname','courier', ...
      'fontsize',9,'background',bc);
   if this(k), set(h,'foreground','blue'), end
end
y = y1-(m+2)*dy;
% uicontrol('style','text','units','normal','position',[x1,y,1-x1,dy], ...
%    'string','Place pointer near machine name for details.', ...
%    'background',bc,'fontname','courier','fontsize',9,'fontangle','italic')
text(x1,y, sprintf('%s\n%s\n%s','Place pointer near machine name for system and version details.  Before using', ...
    'this data to compare different versions or to download an updated data file',...
    'please see help bench.'), 'fontname','courier','fontsize',9,'fontangle','italic')


% ----------------------------------------------- %

function B = bernstein(x,n)
% BERNSTEIN  Generate Bernstein polynomials.
% B = bernstein(x,n) is a length(x)-by-n+1 matrix whose columns
% are the Bernstein polynomials of degree n evaluated at x,
% B_sub_k(x) = nchoosek(n,k)*x.^k.*(1-x).^(n-k), k = 0:n.

x = x(:);
B = zeros(length(x),n+1);
B(:,1) = 1;
for k = 2:n+1
   B(:,k) = x.*B(:,k-1);
   for j = k-1:-1:2
      B(:,j) = x.*B(:,j-1) + (1-x).*B(:,j);
   end
   B(:,1) = (1-x).*B(:,1);
end
