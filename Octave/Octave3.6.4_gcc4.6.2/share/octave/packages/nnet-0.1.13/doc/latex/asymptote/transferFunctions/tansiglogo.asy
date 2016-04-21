// tansig symbol for nnet

// define size of outer square = 1cm
unitsize(1cm);
draw(unitsquare);

// in the middle one short line from left to right
draw((0.1,0.5)--(0.9,0.5));

// now draw tansig
import graph;

real f(real x) {return tanh(x);}
draw(shift(0.5,0.5)*((scale(0.2)*graph(f,-2.0,2.0,operator ..))));
//shift(2,1);

//scale(real 0.5);