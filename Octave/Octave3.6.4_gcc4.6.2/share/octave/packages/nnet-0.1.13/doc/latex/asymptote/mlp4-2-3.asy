import graph;
size(100,0);

// define sizes for neurons
pair center1 = (10,10);
pair center2 = (10,30);
pair center3 = (10,50);
pair center4 = (10,70);
pair center1hidden = (50,30);
pair center2hidden = (50,50);
pair center1out = (90,20);
pair center2out = (90,40);
pair center3out = (90,60);
real radius  = (5);


// define circle for neurons
path in1 = circle(center1,radius);
path in2 = circle(center2,radius);
path in3 = circle(center3,radius);
path in4 = circle(center4,radius);
path hn1 = circle(center1hidden,radius);
path hn2 = circle(center2hidden,radius);
path on1 = circle(center1out,radius);
path on2 = circle(center2out,radius);
path on3 = circle(center3out,radius);

// draw neurons
draw(in1);
draw(in2);
draw(in3);
draw(in4);
draw(hn1);
draw(hn2);
draw(on1);
draw(on2);
draw(on3);

// now draw arrows from input
// to hidden neurons
// (starts from bottom to top)

// first input
pair z11=(16,10);
pair z12=(45,27);
draw(z11--z12,Arrow);
// first input
pair z21=(16,30);
pair z22=(44,29);
draw(z21--z22,Arrow);
// first input
pair z31=(16,50);
pair z32=(44,31);
draw(z31--z32,Arrow);
 // first input
pair z41=(16,70);
pair z42=(45,33);
draw(z41--z42,Arrow);

// second input
pair z11=(16,10);
pair z12=(45,47);
draw(z11--z12,Arrow);
// second input
pair z21=(16,30);
pair z22=(44,49);
draw(z21--z22,Arrow);
// second input
pair z31=(16,50);
pair z32=(44,51);
draw(z31--z32,Arrow);
// second input
pair z41=(16,70);
pair z42=(45,53);
draw(z41--z42,Arrow);

// now draw arrows from hidden
// to output neurons
// (starts from bottom to top)

// first hidden
pair z11=(56,30);
pair z12=(84,19);
draw(z11--z12,Arrow);
// first hidden
pair z21=(56,30);
pair z22=(84,39);
draw(z21--z22,Arrow);
// first hidden
pair z21=(56,30);
pair z22=(84,59);
draw(z21--z22,Arrow);
// second hidden
pair z31=(56,50);
pair z32=(84,21);
draw(z31--z32,Arrow);
 // second hidden
pair z41=(56,50);
pair z42=(84,41);
draw(z41--z42,Arrow);
 // second hidden
pair z41=(56,50);
pair z42=(84,61);
draw(z41--z42,Arrow);

// now define text for input neurons
// p1 for the top neuron
label(scale(0.5)*minipage("\centering \textbf{p1}",0.5cm),(0,70));
label(scale(0.5)*minipage("\centering \textbf{p2}",0.5cm),(0,50));
label(scale(0.5)*minipage("\centering \textbf{p3}",0.5cm),(0,30));
label(scale(0.5)*minipage("\centering \textbf{p4}",0.5cm),(0,10));

// now define text for hidden neurons
// n1 for the top neuron
label(scale(0.5)*minipage("\centering \textbf{n1}",0.5cm),(50,60));
label(scale(0.5)*minipage("\centering \textbf{n2}",0.5cm),(50,40));

// now define text for output neurons
// a1 for the top neuron
label(scale(0.5)*minipage("\centering \textbf{a1}",0.5cm),(100,60));
label(scale(0.5)*minipage("\centering \textbf{a2}",0.5cm),(100,40));
label(scale(0.5)*minipage("\centering \textbf{a3}",0.5cm),(100,20));
