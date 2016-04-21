// purelin
import graph;
size(100,0);

real f(real x) {return 1*x;}
pair F(real x) {return (x,f(x));}


xaxis("$n$",EndArrow);
yaxis("$a$",-1.75,1.75,EndArrow);

draw(graph(f,-2.5,2.5,operator ..));
draw((-2.5,-1)--(2.5,-1),currentpen+dashed);
draw((-2.5,1)--(2.5,1),currentpen+dashed);

label("$a = purelin(n) $",(0,-2.00));
label("$0$",(0.2,-0.3));
label("$-1$",(0.6,-1.35));
label("$+1$",(0.75,1.35));