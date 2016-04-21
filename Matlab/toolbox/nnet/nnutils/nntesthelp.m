%NNTESTHELP Test help comments for NNT 4.0.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 21:18:48 $

% network/adapt
clear

       p1 = {-1  0 1 0 1 1 -1  0 -1 1 0 1};
       t1 = {-1 -1 1 1 1 2  0 -1 -1 0 1 1};
       net = newlin([-1 1],1,[0 1],0.5);
       [net,y,e,pf] = adapt(net,p1,t1);
       mse(e)
       p2 = {1 -1 -1 1 1 -1  0 0 0 1 -1 -1};
       t2 = {2  0 -2 0 2  0 -1 0 0 1  0 -1};
       [net,y,e,pf] = adapt(net,p2,t2,pf);
       mse(e)
       p3 = [p1 p2];
       t3 = [t1 t2];
      net.adaptParam.passes = 100;
       [net,y,e] = adapt(net,p3,t3);
       mse(e)

% network/disp
clear

       net = newp([-1 1; 0 2],3);
       disp(net)

% network/display
clear

       net = newp([-1 1; 0 2],3);
       display(net)
       net

% network/gensim
clear

     net = newff([0 1],[5 1]);
     gensim(net)

% network/init
clear

      net = newp([0 1;-2 2],1);
       net.iw{1,1}
       net.b{1}
       P = [0 1 0 1; 0 0 1 1];
       T = [0 0 0 1];
       net = train(net,P,T);
       net.iw{1,1}
       net.b{1}
       net = init(net);
       net.iw{1,1}
       net.b{1}

% network/network
clear

       net = network
       net.numInputs = 1
       net.numLayers = 2
       net = network(1,2)
       net = network(1,2,[1;0],[1; 0],[0 0; 1 0],[0 1],[0 1])
       net.inputs{1}
       net.layers{1}, net.layers{2}
       net.biases{1}
       net.inputWeights{1,1}, net.layerWeights{2,1}
       net.outputs{2}
       net.targets{2}
       net.iw{1,1}, net.iw{2,1}, net.b{1}
       net.layers{1}.transferFcn = 'tansig';
       net.layers{2}.transferFcn = 'logsig';
       net.inputs{1}.range = [0 1; -1 1];
       p = [0.5; -0.1];
       y = sim(net,p)

% adaptwb - OBSOLETE

% boxdist
clear

       pos = rand(3,10);
       d = boxdist(pos)

% cell2mat
clear

     c = {[1 2] [3]; [4 5; 6 7] [8; 9]};
     m = cell2mat(c)

% combvec
clear

     a1 = [1 2 3; 4 5 6];
     a2 = [7 8; 9 10];
     a3 = combvec(a1,a2)

% compet
clear

       n = [0; 1; -0.5; 0.5];
       a = compet(n);
       subplot(2,1,1), bar(n), ylabel('n')
       subplot(2,1,2), bar(a), ylabel('a')

% con2seq
clear

       p1 = [1 4 2]
       p2 = con2seq(p1)
 
       p1 = {[1 3 4 5; 1 1 7 4]; [7 3 4 4; 6 9 4 1]}
       p2 = con2seq(p1,2)

% concur
clear

       b = [1; 3; 2; -1];
       concur(b,3)

% ddotprod
clear

       W = [0 -1 0.2; -1.1 1 0];
       P = [0.1; 0.6; -0.2];
       Z = dotprod(W,P)
       dZ_dP = ddotprod('p',W,P,Z)
       dZ_dW = ddotprod('w',W,P,Z)
 
% dhardlim
clear

       N = [0.1; 0.8; -0.7];
       A = hardlim(N)
       dA_dN = dhardlim(N,A)

% dhardlms
clear

       N = [0.1; 0.8; -0.7];
       A = hardlims(N)
       dA_dN = dhardlms(N,A)

% dist
clear

       W = rand(4,3);
       P = rand(3,1);
       Z = dist(W,P)
       pos = rand(3,10);
       D = dist(pos)

% dlogsig
clear

       N = [0.1; 0.8; -0.7];
       A = logsig(N)
       dA_dN = dlogsig(N,A)

% dmae
clear

       E = {[1; -2; 0.5]};
       X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
       perf = mae(E)
       dPerf_dE = dmae('e',E,X)
       dPerf_dX = dmae('x',E,X)

% dmse
clear

      E = {[1; -2; 0.5]};
       X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
       perf = mse(E)
       dPerf_dE = dmse('e',E,X)
       dPerf_dX = dmse('x',E,X)

% dmsereg
clear

       E = {[1; -2; 0.5]};
       X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
       pp.ratio = 5/(5+1);
       perf = msereg(E,X,pp)
       dPerf_dE = dmsereg('e',E,X,perf,pp)
       dPerf_dX = dmsereg('x',E,X,perf,pp)
 
% dnetprod
 clear

       Z1 = [0.1; 1; -1];
       Z2 = [1; 0.5; 1.2];
       N = netprod(Z1,Z2)
       dN_dZ1 = dnetprod(Z1,N)
       dN_dZ2 = dnetprod(Z2,N)
 

% dnetsum
 clear

       Z1 = [0; 1; -1];
       Z2 = [1; 0.5; 1.2];
       N = netsum(Z1,Z2)
       dN_dZ1 = dnetsum(Z1,N)
       dN_dZ2 = dnetsum(Z2,N)

% dotprod
clear

       W = rand(4,3);
       P = rand(3,1);
       Z = dotprod(W,P)

% dposlin
clear

       N = [0.1; 0.8; -0.7];
       A = poslin(N)
       dA_dN = dposlin(N,A)

% dpurelin
clear

       N = [0.1; 0.8; -0.7];
       A = purelin(N)
       dA_dN = dpurelin(N,A)
 
% dradbas
clear

       N = [0.1; 0.8; -0.7];
       A = radbas(N)
       dA_dN = dradbas(N,A)
 
% dsatlin
clear

       N = [0.1; 0.8; -0.7];
       A = satlin(N)
       dA_dN = dsatlin(N,A)
 
% dsatlins
clear

       N = [0.1; 0.8; -0.7];
       A = satlins(N)
       dA_dN = dsatlins(N,A)
 
% dsse
clear

       E = {[1; -2; 0.5]};
       X = [0; 0.2; -2.2; 4.1; 0.1; -0.2];
       perf = sse(E)
       dPerf_dE = dsse('e',E,X)
       dPerf_dX = dsse('x',E,X)
 
% dtansig
clear

       N = [0.1; 0.8; -0.7];
       A = tansig(N)
       dA_dN = dtansig(N,A)
 
% dtribas
clear

       N = [0.1; 0.8; -0.7];
       A = tribas(N)
       dA_dN = dtribas(N,A)
 
% errsurf
clear

     p = [-6.0 -6.1 -4.1 -4.0 +4.0 +4.1 +6.0 +6.1];
     t = [+0.0 +0.0 +.97 +.99 +.01 +.03 +1.0 +1.0];
     wv = -1:.1:1; bv = -2.5:.25:2.5;
     es = errsurf(p,t,wv,bv,'logsig');
     plotes(wv,bv,es,[60 30])
 
% gridtop
clear

       pos = gridtop(8,5); plotsom(pos)
       W = rands(40,2); plotsom(W,dist(pos))
 
% hardlim
clear

       n = -5:0.1:5;
       a = hardlim(n);
       plot(n,a)
 
% hardlims
clear

       n = -5:0.1:5;
       a = hardlims(n);
       plot(n,a)
 
% hextop
clear

       pos = hextop(8,5); plotsom(pos)
       W = rands(40,2); plotsom(W,dist(pos))
 
% hintonw
clear

     W = rands(4,5);
     hintonw(W)
   
% hintonwb
clear

     W = rands(4,5);
     b = rands(4,1);
     hintonwb(W,b)
   
% ind2vec
clear

       ind = [1 3 2 3]
       vec = ind2vec(ind)

% initcon
clear

       b = initcon(5)
 
% initlay

% initnw

% initwb

% initzero
clear

       W = initzero(5,[0 1; -2 2])
       b = initzero(5,[1 1])
 
% learncon
clear

       a = rand(3,1);
       b = rand(3,1);
       lp.lr = 0.5;
       dW = learncon(b,[],[],[],a,[],[],[],[],[],lp,[])
 
% learngd
clear

       gW = rand(3,2);
       lp.lr = 0.5;
       dW = learngd([],[],[],[],[],[],[],gW,[],[],lp,[])
 
% learngdm
clear

       gW = rand(3,2);
       lp.lr = 0.5;
       lp.mc = 0.8;
       ls = [];
       [dW,ls] = learngdm([],[],[],[],[],[],[],gW,[],[],lp,ls)
 
% learnh
clear

       p = rand(2,1);
       a = rand(3,1);
       lp.lr = 0.5;
       dW = learnh([],p,[],[],a,[],[],[],[],[],lp,[])
 
% learnhd
clear

       p = rand(2,1);
       a = rand(3,1);
       w = rand(3,2);
       lp.dr = 0.05;
       lp.lr = 0.5;
       dW = learnhd(w,p,[],[],a,[],[],[],[],[],lp,[])

% learnis
clear

       p = rand(2,1);
       a = rand(3,1);
       w = rand(3,2);
       lp.lr = 0.5;
       dW = learnis(w,p,[],[],a,[],[],[],[],[],lp,[])
 
% learnk
clear

       p = rand(2,1);
       a = rand(3,1);
       w = rand(3,2);
       lp.lr = 0.5;
       dW = learnk(w,p,[],[],a,[],[],[],[],[],lp,[])

% learnlv1
clear

       p = rand(2,1);
       w = rand(3,2);
       a = compet(negdist(w,p));
       gA = [-1;1; 1];
       lp.lr = 0.5;
       dW = learnlv1(w,p,[],[],a,[],[],[],gA,[],lp,[])
 
% learnlv2
clear

       p = rand(2,1);
       w = rand(3,2);
       n = negdist(w,p);
       a = compet(n);
       gA = [-1;1; 1];
       lp.lr = 0.5;
       dW = learnlv2(w,p,[],n,a,[],[],[],gA,[],lp,[])
 
% learnos
clear

       p = rand(2,1);
       a = rand(3,1);
       w = rand(3,2);
       lp.lr = 0.5;
       dW = learnos(w,p,[],[],a,[],[],[],[],[],lp,[])
 
% learnp
clear

       p = rand(2,1);
       e = rand(3,1);
       dW = learnp([],p,[],[],[],[],e,[],[],[],[],[])
 
% learnpn
clear

      p = rand(2,1);
       e = rand(3,1);
       dW = learnpn([],p,[],[],[],[],e,[],[],[],[],[])
 
% learnsom
clear

       p = rand(2,1);
       a = rand(6,1);
       w = rand(6,2);
       pos = hextop(2,3);
       d = linkdist(pos);
       lp.order_lr = 0.9;
       lp.order_steps = 1000;
       lp.tune_lr = 0.02;
       lp.tune_nd = 1;
       ls = [];
       [dW,ls] = learnsom(w,p,[],[],a,[],[],[],[],d,lp,ls)
 
% learnwh
clear

       p = rand(2,1);
       e = rand(3,1);
       lp.lr = 0.5;
       dW = learnwh([],p,[],[],[],[],e,[],[],[],lp,[])
 
% linkdist
clear

       pos = rand(3,10);
       D = linkdist(pos)

% logsig
clear

       n = -5:0.1:5;
       a = logsig(n);
       plot(n,a)

% mae
clear

      net = newp([-10 10],1);
       p = [-10 -5 0 5 10];
       t = [0 0 1 1 1];
       y = sim(net,p)
       e = t-y
       perf = mae(e)
 
% mandist
clear

       W = rand(4,3);
       P = rand(3,1);
       Z = mandist(W,P)
       pos = rand(3,10);
       D = mandist(pos)
 
% mat2cell
clear

      M = [1 2 3 4; 5 6 7 8; 9 10 11 12];
      C = mat2cell(M,[1 2],[2 2])

% maxlinlr
clear

       P = [1 2 -4 7; 0.1 3 10 6];
       lr = maxlinlr(P,'bias')

% midpoint
clear

       W = midpoint(5,[0 1; -2 2])

% minmax
clear

     p = [0 1 2; -1 -2 -0.5]
     pr = minmax(p)

% mse
clear

       net = newff([-10 10],[4 1],{'tansig','purelin'});
       p = [-10 -5 0 5 10];
       t = [0 0 1 1 1];
       y = sim(net,p)
       e = t-y
       perf = mse(e)

% msereg
clear

       net = newff([-2 2],[4 1],{'tansig','purelin'},'trainlm','learngdm','msereg');
       p = [-2 -1 0 1 2];
       t = [0 1 1 1 0];
       y = sim(net,p)
       e = t-y
       net.performParam.ratio = 20/(20+1);
       perf = msereg(e,net)
 
% negdist
clear

       W = rand(4,3);
       P = rand(3,1);
       Z = negdist(W,P)

% netprod
clear

       z1 = [1 2 4;3 4 1];
       z2 = [-1 2 2; -5 -6 1];
       n = netprod(z1,z2)
       b = [0; -1];
       n = netprod(z1,z2,concur(b,3))

% netsum
clear

       z1 = [1 2 4;3 4 1];
       z2 = [-1 2 2; -5 -6 1];
       n = netsum(z1,z2)
       b = [0; -1];
       n = netsum(z1,z2,concur(b,3))
 
% newc
clear

       P = [.1 .8  .1 .9; .2 .9 .1 .8];
       net = newc([0 1; 0 1],2);
       net = train(net,P);
       Y = sim(net,P)
       Yc = vec2ind(Y)

% newcf
clear

       P = [0 1 2 3 4 5 6 7 8 9 10];
       T = [0 1 2 3 4 3 2 1 2 3 4];
       net = newcf([0 10],[5 1],{'tansig' 'purelin'});
       Y = sim(net,P);
      plot(P,T,P,Y,'o')
       net.trainParam.epochs = 50;
       net = train(net,P,T);
       Y = sim(net,P);
      plot(P,T,P,Y,'o')
 

% newelm
clear

       P = round(rand(1,20));
       T = [0 (P(1:end-1)+P(2:end) == 2)];
       Pseq = con2seq(P);
       Tseq = con2seq(T);
       net = newelm([0 1],[10 1],{'tansig','logsig'});
       net = train(net,Pseq,Tseq);
       Y = sim(net,Pseq)

% newff
clear

       P = [0 1 2 3 4 5 6 7 8 9 10];
       T = [0 1 2 3 4 3 2 1 2 3 4];
       net = newff([0 10],[5 1],{'tansig' 'purelin'});
       Y = sim(net,P);
        plot(P,T,P,Y,'o')
       net.trainParam.epochs = 50;
       net = train(net,P,T);
       Y = sim(net,P);
        plot(P,T,P,Y,'o')

% newfftd
clear

       P = {1  0 0 1 1  0 1  0 0 0 0 1 1  0 0 1};
       T = {1 -1 0 1 0 -1 1 -1 0 0 0 1 0 -1 0 1};
       net = newfftd([0 1],[0 1],[5 1],{'tansig' 'purelin'});
       Y = sim(net,P)
       net.trainParam.epochs = 50;
       net = train(net,P,T);
       Y = sim(net,P)

% newgrnn
clear

       P = [1 2 3];
       T = [2.0 4.1 5.9];
       net = newgrnn(P,T);
       P = 1.5;
       Y = sim(net,P)
 
% newhop
clear

       T = [-1 -1 1; 1 -1 1]';
       net = newhop(T);
       Ai = T;
       [Y,Pf,Af] = sim(net,2,[],Ai);
       Y
       Ai = {[-0.9; -0.8; 0.7]};
       [Y,Pf,Af] = sim(net,{1 5},{},Ai);
       Y{1}
 
% newlin
clear

       net = newlin([-1 1],1,[0 1],0.01);
       P1 = {0 -1 1 1 0 -1 1 0 0 1};
       Y = sim(net,P1)
       T1 = {0 -1 0 2 1 -1 0 1 0 1};
       [net,Y,E,Pf] = adapt(net,P1,T1); Y
       P2 = {1 0 -1 -1 1 1 1 0 -1};
       T2 = {2 1 -1 -2 0 2 2 1 0};
       [net,Y,E,Pf] = adapt(net,P2,T2); Y
       net = init(net);
       P3 = [P1 P2];
       T3 = [T1 T2];
       net.trainParam.epochs = 200;
       net.trainParam.goal = 0.1;
       net = train(net,P3,T3);
       Y = sim(net,[P1 P2])
 
% newlind
clear

       P = [1 2 3];
       T = [2.0 4.1 5.9];
       net = newlind(P,T);
       Y = sim(net,P)
       P = {1 2 1 3 3 2};
       Pi = {1 3};
       T = {5.0 6.1 4.0 6.0 6.9 8.0};
       net = newlind(P,T,Pi);
       Y = sim(net,P,Pi)
       P1 = {1 2 1 3 3 2}; Pi1 = {1 3 0};
       P2 = {1 2 1 1 2 1}; Pi2 = {2 1 2};
       T1 = {5.0 6.1 4.0 6.0 6.9 8.0};
       T2 = {11.0 12.1 10.1 10.9 13.0 13.0};
       net = newlind([P1; P2],[T1; T2],[Pi1; Pi2]);
       Y = sim(net,[P1; P2],[Pi1; Pi2]);
       Y1 = Y(1,:)
       Y2 = Y(2,:)
 
% newlvq
 clear

       P = [-3 -2 -2  0  0  0  0 +2 +2 +3; ...
            0 +1 -1 +2 +1 -1 -2 +1 -1  0];
       Tc = [1 1 1 2 2 2 2 1 1 1];
       T = ind2vec(Tc);
       net = newlvq(minmax(P),4,[.6 .4]);
       net = train(net,P,T);
       Y = sim(net,P)
       Yc = vec2ind(Y)

% newp
 clear

       net = newp([0 1; -2 2],1);

       P = [0 0 1 1; 0 1 0 1];
       T = [0 1 1 1];

       Y = sim(net,P)
       net.trainParam.epochs = 20;
       net = train(net,P,T);
       Y = sim(net,P)

% newpnn
 clear

       P = [1 2 3 4 5 6 7];
       Tc = [1 2 3 2 2 3 1];
       T = ind2vec(Tc)
       net = newpnn(P,T);
       Y = sim(net,P)
       Yc = vec2ind(Y)

% newrb
 clear

       P = [1 2 3];
       T = [2.0 4.1 5.9];
       net = newrb(P,T);
       P = 1.5;
       Y = sim(net,P)

% newrbe
 clear

       P = [1 2 3];
       T = [2.0 4.1 5.9];
       net = newrbe(P,T);
       P = 1.5;
       Y = sim(net,P)

% newsom
 clear

       P = [rand(1,400)*2; rand(1,400)];
       net = newsom([0 2; 0 1],[3 5]);
       plotsom(net.layers{1}.positions)

      net.trainParam.epochs = 25;
       net = train(net,P);
       plot(P(1,:),P(2,:),'.g','markersize',20)
       hold on
       plotsom(net.iw{1,1},net.layers{1}.distances)
       hold off

% nncopy
clear

      x1 = [1 2 3; 4 5 6];
      y1 = nncopy(x1,3,2)
      x2 = {[1 2]; [3; 4; 5]}
      y2 = nncopy(x2,2,3)

% nnt2c

% nnt2elm

% nnt2ff

% nnt2hop

% nnt2lin

% nnt2lvq

% nnt2p

% nnt2rb

% nnt2som

% normc

% normprod
 clear

       W = rand(4,3);
       P = rand(3,1);
       Z = normprod(W,P)

% normr
 clear

     m = [1 2; 3 4]
     n = normr(m)

% percept - HELP FILE

% plotbr
clear

        p = [-1:.05:1];
        t = sin(2*pi*p)+0.1*randn(size(p));

% plotep

% plotes
   clear

     p = [3 2];
     t = [0.4 0.8];
     wv = -4:0.4:4; bv = wv;
     ES = errsurf(p,t,wv,bv,'logsig');
     plotes(wv,bv,ES,[60 30])

% plotpc
 clear

       p = [0 0 1 1; 0 1 0 1];
       t = [0 0 0 1];
       plotpv(p,t)

% plotperf
 clear

       P = 1:8; T = sin(P);
       VV.P = P; VV.T = T+rand(1,8)*0.1;
       net = newff(minmax(P),[4 1],{'tansig','tansig'});
       [net,tr] = train(net,P,T,[],[],VV);
       plotperf(tr)

% plotpv
 clear

       p = [0 0 1 1; 0 1 0 1];
       t = [0 0 0 1];
       plotpv(p,t)
       net = newp(minmax(p),1);
       net.iw{1,1} = [-1.2 -0.5];
       net.b{1} = 1;
       plotpc(net.iw{1,1},net.b{1})

% plotsom
clear

       pos = hextop(5,6); plotsom(pos)
       pos = gridtop(4,5); plotsom(pos)
       pos = randtop(18,12); plotsom(pos)
       pos = gridtop(4,5,2); plotsom(pos)
       pos = hextop(4,4,3); plotsom(pos)

% plotv
clear

     plotv([-.4 0.7 .2; -0.5 .1 0.5],'-')

% plotvec
clear

     x = [0 1 0.5 0.7; -1 2 0.5 0.1];
     c = [1 2 3 4];
     plotvec(x,c)

% pnormc
clear

     x = [0.1 0.6; 0.3 0.1];
     y = pnormc(x)

% poslin
clear

       n = -5:0.1:5;
       a = poslin(n);
       plot(n,a)

% postmnmx
clear

       p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
        t = [-0.08 3.4 -0.82 0.69 3.1];
       [pn,minp,maxp,tn,mint,maxt] = premnmx(p,t);
        net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
        net = train(net,pn,tn);
        an = sim(net,pn);
        [a] = postmnmx(an,mint,maxt);
        [m,b,r] = postreg(a,t);

% postreg
clear

       p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
        t = [-0.08 3.4 -0.82 0.69 3.1];
       [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
        [ptrans,transMat] = prepca(pn,0.02);
        net = newff(minmax(ptrans),[5 1],{'tansig' 'purelin'},'trainlm');
        net = train(net,ptrans,tn);
        an = sim(net,ptrans);
        a = poststd(an,meant,stdt);
        [m,b,r] = postreg(a,t);

% poststd
clear

       p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
        t = [-0.08 3.4 -0.82 0.69 3.1];
       [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
        net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
        net = train(net,pn,tn);
        an = sim(net,pn);
        a = poststd(an,meant,stdt);
        [m,b,r] = postreg(a,t);

% premnmx
clear

       p = [-10 -7.5 -5 -2.5 0 2.5 5 7.5 10];
        t = [0 7.07 -10 -7.07 0 7.07 10 7.07 0];
       [pn,minp,maxp,tn,mint,maxt] = premnmx(p,t);
        [pn,minp,maxp] = premnmx(p);

% prepca
clear

       p=[-1.5 -0.58 0.21 -0.96 -0.79; -2.2 -0.87 0.31 -1.4  -1.2];
       [pn,meanp,stdp] = prestd(p);
       [ptrans,transMat] = prepca(pn,0.02);
 
% prestd
clear

       p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
        t = [-0.08 3.4 -0.82 0.69 3.1];
       [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
        [pn,meanp,stdp] = prestd(p);

% purelin
clear

       n = -5:0.1:5;
       a = purelin(n);
       plot(n,a)

% quant
clear

     x = [1.333 4.756 -3.897];
     y = quant(x,0.1)

% radbas
clear

       n = -5:0.1:5;
       a = radbas(n);
       plot(n,a)

% radbasis - HELP FILE

% randnc
clear

% randnr
clear

% rands
clear

       rands(4,[0 1; -2 2])
       rands(4)
       rands(2,3)

% randtop
clear

       pos = randtop(16,12); plotsom(pos)
       W = rands(192,2); plotsom(W,dist(pos))

% satlin
clear

       n = -5:0.1:5;
       a = satlin(n);
       plot(n,a)
 
% satlins
   clear

       n = -5:0.1:5;
       a = satlins(n);
       plot(n,a)

% selforg - HELP FILE

% seq2con
clear

       p1 = {1 4 2}
       p2 = seq2con(p1) 
       p1 = {[1; 1] [5; 4] [1; 2]; [3; 9] [4; 1] [9; 8]}
       p2 = seq2con(p1)
 
% slblocks - SIMULINK BLOCK FILE

% softmax
clear

       n = [0; 1; -0.5; 0.5];
       a = softmax(n);
       subplot(2,1,1), bar(n), ylabel('n')
       subplot(2,1,2), bar(a), ylabel('a')

% srchbac
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
       a = sim(net,p)
        net.trainParam.searchFcn = 'srchbac';
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% srchbre
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
       a = sim(net,p)
        net.trainParam.searchFcn = 'srchbre';
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% srchcha
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
        net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
       a = sim(net,p)
        net.trainParam.searchFcn = 'srchcha';
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% srchgol
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
       a = sim(net,p)
         net.trainParam.searchFcn = 'srchgol';
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% srchhyb
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
       a = sim(net,p)
         net.trainParam.searchFcn = 'srchhyb';
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% sse
clear

       net = newff([-10 10],[4 1],{'tansig','purelin'});
       p = [-10 -5 0 5 10];
       t = [0 0 1 1 1];
       y = sim(net,p)
       e = t-y
       perf = sse(e)
 
% sumsqr
clear

     s = sumsqr([1 2;3 4])

% tansig
clear

       n = -5:0.1:5;
       a = tansig(n);
       plot(n,a)
 
% trainb

% trainbfg
clear

       P = [0 1 2 3 4 5];
       T = [0 0 0 1 1 1];
        net = newff([0 5],[2 1],{'tansig','logsig'},'trainbfg');
       a = sim(net,P)
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,P,T);
       a = sim(net,P)
 
% trainbr
clear

        p = [-1:.05:1];
        t = sin(2*pi*p)+0.1*randn(size(p));
         net=newff([-1 1],[20,1],{'tansig','purelin'},'trainbr');
        net.trainParam.epochs = 50;
        net.trainParam.show = 10;
        net = train(net,p,t);
        a = sim(net,p)
        plot(p,a,p,t,'+')
 
% trainc

% traincgb
clear

      p = [0 1 2 3 4 5];
       t  = [0 0 0 1 1 1];

      % Create and Test a Network
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgb');
       a = sim(net,p)
 
       % Train and Retest the Network
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% traincgf
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
 
       % Create and Test a Network
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgf');
       a = sim(net,p)
 
       % Train and Retest the Network
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% traincgp
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
 
       % Create and Test a Network
       net = newff([0 5],[2 1],{'tansig','logsig'},'traincgp');
       a = sim(net,p)
 
       % Train and Retest the Network
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% traingd

% traingda

% traingdm

% traingdx

% trainlm

% trainoss
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
 
       % Create and Test a Network
       net = newff([0 5],[2 1],{'tansig','logsig'},'trainoss');
       a = sim(net,p)
 
       % Train and Retest the Network
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% trainr
clear

% trainrp
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];

       % Create and Test a Network
       net = newff([0 5],[2 1],{'tansig','logsig'},'trainrp');
       a = sim(net,p)
 
       % Train and Retest the Network
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% trains

% trainscg
clear

       p = [0 1 2 3 4 5];
       t = [0 0 0 1 1 1];
 
       % Create and Test a Network
       net = newff([0 5],[2 1],{'tansig','logsig'},'trainscg');
       a = sim(net,p)
 
       % Train and Retest the Network
       net.trainParam.epochs = 50;
       net.trainParam.show = 10;
       net.trainParam.goal = 0.1;
       net = train(net,p,t);
       a = sim(net,p)
 
% trainwb - OBSOLETE

% trainwb1 - OBSOLETE

% tramnmx
clear

       p = [-10 -7.5 -5 -2.5 0 2.5 5 7.5 10];
        t = [0 7.07 -10 -7.07 0 7.07 10 7.07 0];
       [pn,minp,maxp,tn,mint,maxt] = premnmx(p,t);
        net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
        net = train(net,pn,tn);
 
        p2 = [4 -7];
        [p2n] = tramnmx(p2,minp,maxp);
        an = sim(net,pn);
        [a] = postmnmx(an,mint,maxt);

% trapca
clear

       p=[-1.5 -0.58 0.21 -0.96 -0.79; -2.2 -0.87 0.31 -1.4  -1.2];
        t = [-0.08 3.4 -0.82 0.69 3.1];
       [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
       [ptrans,transMat] = prepca(pn,0.02);
        net = newff(minmax(ptrans),[5 1],{'tansig' 'purelin'},'trainlm');
        net = train(net,ptrans,tn);
        p2 = [1.5 -0.8;0.05 -0.3];
        [p2n] = trastd(p2,meanp,stdp);
        [p2trans] = trapca(p2n,transMat)
        an = sim(net,p2trans);
        [a] = poststd(an,meant,stdt);

% trastd
clear

       p = [-0.92 0.73 -0.47 0.74 0.29; -0.08 0.86 -0.67 -0.52 0.93];
        t = [-0.08 3.4 -0.82 0.69 3.1];
       [pn,meanp,stdp,tn,meant,stdt] = prestd(p,t);
        net = newff(minmax(pn),[5 1],{'tansig' 'purelin'},'trainlm');
        net = train(net,pn,tn);
 
        p2 = [1.5 -0.8;0.05 -0.3];
        [p2n] = trastd(p2,meanp,stdp);
        an = sim(net,pn);
        [a] = poststd(an,meant,stdt);

% tribas
clear

       n = -5:0.1:5;
       a = tribas(n);
       plot(n,a)
 
% vec2ind
clear

       vec = [1 0 0 0; 0 0 1 0; 0 1 0 1]
       ind = vec2ind(vec)

