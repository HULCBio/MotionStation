#! /usr/bin/octave -q

%
% General test cases for Octave
%


%
% Tests for Information Theory Library.
%

p=[ 0 0.75;
   0.125 0.125 ];


jointentropy(p)
x=marginalc(p);
entropy(x)
y=marginalr(p);
entropy(y)



% Test on Mutual Information

XY=[ 1/8 1/16 1/32 1/32;
     1/16 1/8 1/32 1/32;
    1/16 1/16 1/16 1/16;
    1/4  0     0    0 ];

mutualinformation(XY)


entropy(marginalc(XY)) -  conditionalentropy_XY(XY)
entropy(marginalr(XY)) -  conditionalentropy_YX(XY)
jointentropy(XY)


% Test on Relative Entropy
X=[0.5 0.2 0.2 0.1];
Y=[0.2 0.2 0.2 0.4];

relativeentropy(X,Y)
relativeentropy(Y,X)



% Test on Conditional Entropy
XY=[ 1/8 1/16 1/32 1/32;
     1/16 1/8 1/32 1/32;
    1/16 1/16 1/16 1/16;
    1/4  0     0    0 ];

% x=marginalr(XY)
% y=marginalc(XY)

c1=conditionalentropy_XY(XY);
c2=conditionalentropy_YX(XY);
j=jointentropy(XY);
marx=entropy(marginalc(XY));
mary=entropy(marginalr(XY));
j         # H(x,y)
marx + c2 # H(x,y)
mary + c1 # H(x,y)


% Test on Joint Entropy
XY=[ 1/8 1/16 1/32 1/32;
     1/16 1/8 1/32 1/32;
    1/16 1/16 1/16 1/16;
    1/4  0     0    0 ];

jointentropy(XY)



% Test on Conditional Entropy


% Test on Entropy function
for N=2:20
    prob=ones(1,N)*(1/N);
    x=entropy(prob);
    printf("Entropy of %g is %g\n",prob(1),x);
end


prob=[1/2,1/4,1/8,1/8]
val=0
for i=1:length(prob)
    val=val+prob(i)*log2(prob(i))
end

entropy(prob)
