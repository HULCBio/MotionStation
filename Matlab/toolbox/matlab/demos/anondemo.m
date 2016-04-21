%% Anonymous Function Examples
% Defining (Anonymous) Functions at the Command Line
%
% This demo shows some examples of how to define functions at the
% command line in a new much simpler way than with the |inline|
% function.

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.3 $  $Date: 2004/03/19 17:49:27 $


%% Integrating a function
% Consider the function 10*x.
%
% $$h(x)= 10x$$
%
% If we want to allow any multiplier of x, not just 10, we might
% create a variable g (where g is initially set to 10), and create a
% new function
%
% $$h(x)= g * x$$
%
% Let's do this in MATLAB by creating a function handle h.
g=10;
h=@(x) g*x;

%%
% You can integrate the function by passing its handle to quad.
quad(h,1,10)

%%
% Consider another function:
%
% $$f(x)= sin(\alpha x)$$
% 
% Create a function handle to this function where |alpha = 0.9|.
alpha=0.9;
f=@(x) sin(alpha*x); 

%%
% Plot the function and shade the area under it.
x=0:pi/100:pi;
area(x,f(x)); % You can evaluate f without feval
title('f(x)= sin(\alpha x), \alpha =.9');

%%
% We can use quad to calculate the area under the function between a
% range of values.
quad(f,0,pi)

%% Minimizing a function
% Consider the function:
% 
% $$f(x)=a x^2 + bx + c$$ 
%
% where |a=1, b=-2, and c=1|
%
% Create a function handle for it.
a=1;b=-2;c=1;
f=@(x)(a*x.^2+b*x+c);

%%
ezplot(f); % Plot the function
title('f(x)=ax^2+bx+c, a=1,b=-2,c=1');
hold on;

% Find and plot the minimum
minimum=fminbnd(f,-2,2); % We can pass the function handle direct to the minimization routine
plot(minimum,f(minimum),'d'); % We can evaluate the function without using feval
grid;
hold off;

%% 2D functions
% We can create handles to functions of many variables
a=pi;b=15;
f=@(x,y) (a*x+b*y); 
ezsurf(f);
title('f(x,y)=ax+by, a=\pi, b=15');

%% Function composition
% We can also create handles to functions of functions

f=@(x) x.^2;
g=@(x) 3*x;
h=@(x) g(f(x));
h(3)
