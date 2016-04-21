function [gX]=calcgradxmodref(net,Q,PD,BZ,IWZ,LWZ,N,Ac,gE,TS)
%CALCGRADXMODREF Calculate bias and weight performance gradients for a
%                 fixed Neural Network based Model Reference Controller.
%
%  Synopsis
%
%    [gX] = calcgradxmodref(net,Q,PD,BZ,IWZ,LWZ,N,Ac,gE,TS)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:10:55 $

counter=0;

% Shortcuts
numLayerDelays = net.numLayerDelays;
layerWeights=net.layerWeights;

IW = net.IW;
LW = net.LW;
b = net.b;

% Signals
input_delays{2,4}=layerWeights{3,2}.delays;
input_delays{4,4}=layerWeights{3,4}.delays;
input_delays{2,2}=layerWeights{1,2}.delays;
input_delays{4,2}=layerWeights{1,4}.delays;

dF_b1=zeros(size(b{1}));
dF_b2=zeros(size(b{2}));
dF_iw11=zeros(size(IW{1,1}));
dF_lw12=zeros(size(LW{1,2}));
dF_lw14=zeros(size(LW{1,4}));
dF_lw21=zeros(size(LW{2,1}));
for k=1:numLayerDelays + TS
   da2_b1{k}=zeros(size(b{1}));
   da4_b1{k}=zeros(size(b{1}));
   da2_b2{k}=zeros(size(b{2}));
   da4_b2{k}=zeros(size(b{2}));
   da2_iw11{k}=zeros(size(IW{1,1}));
   da4_iw11{k}=zeros(size(IW{1,1}));
   da2_lw12{k}=zeros(size(LW{1,2}));
   da4_lw12{k}=zeros(size(LW{1,2}));
   da2_lw14{k}=zeros(size(LW{1,4}));
   da4_lw14{k}=zeros(size(LW{1,4}));
   da2_lw21{k}=zeros(size(LW{2,1}));
   da4_lw21{k}=zeros(size(LW{2,1}));
end

% Backpropagate Derivatives...
for ts=1:TS

  ts2 = numLayerDelays + ts;
  
  f3_dot=sparse(diag(1-(Ac{3,ts2}.*Ac{3,ts2})));
  dea4_b3=[LW{4,3}*f3_dot]';
  
  dea2_b2=1;
  dea2_lw21=[Ac{1,ts2,:}]';
  f1_dot=sparse(diag(1-(Ac{1,ts2}.*Ac{1,ts2})));
  dea2_b1=[LW{2,1}*f1_dot]';
  temp=[];
  for zzz=1:size(layerWeights{1,2}.delays,2)
      temp = [temp Ac{2,ts2-layerWeights{1,2}.delays(zzz)}];
  end
  dea2_lw12=dea2_b1*temp;
  
  temp=[];
  for zzz=1:size(layerWeights{1,4}.delays,2)
      temp = [temp Ac{4,ts2-layerWeights{1,4}.delays(zzz)}];
  end
  dea2_lw14=dea2_b1*temp;
          
  dea2_iw11=dea2_b1*PD{1,1,ts}';
  
  dea4_a42=dea4_b3'*LW{3,2};
  dea4_a44=dea4_b3'*LW{3,4};
  dea2_a22=dea2_b1'*LW{1,2};
  dea2_a24=dea2_b1'*LW{1,4};
  
  da2_b1{ts2}=dea2_b1;
  da2_b2{ts2}=dea2_b2;
  da2_iw11{ts2}=dea2_iw11;
  da2_lw12{ts2}=dea2_lw12;
  da2_lw14{ts2}=dea2_lw14;
  da2_lw21{ts2}=dea2_lw21;
  for nx=1:size(input_delays{2,2},2)
     nd=input_delays{2,2}(nx);
     da2_b1{ts2}=da2_b1{ts2}+dea2_a22(nx)*da2_b1{ts2-nd};
     da2_b2{ts2}=da2_b2{ts2}+dea2_a22(nx)*da2_b2{ts2-nd};
     da2_iw11{ts2}=da2_iw11{ts2}+dea2_a22(nx)*da2_iw11{ts2-nd};
     da2_lw12{ts2}=da2_lw12{ts2}+dea2_a22(nx)*da2_lw12{ts2-nd};
     da2_lw14{ts2}=da2_lw14{ts2}+dea2_a22(nx)*da2_lw14{ts2-nd};
     da2_lw21{ts2}=da2_lw21{ts2}+dea2_a22(nx)*da2_lw21{ts2-nd};
  end
  for nx=1:size(input_delays{4,2},2)
     nd=input_delays{4,2}(nx);
     da2_b1{ts2}=da2_b1{ts2}+dea2_a24(nx)*da4_b1{ts2-nd};
     da2_b2{ts2}=da2_b2{ts2}+dea2_a24(nx)*da4_b2{ts2-nd};
     da2_iw11{ts2}=da2_iw11{ts2}+dea2_a24(nx)*da4_iw11{ts2-nd};
     da2_lw12{ts2}=da2_lw12{ts2}+dea2_a24(nx)*da4_lw12{ts2-nd};
     da2_lw14{ts2}=da2_lw14{ts2}+dea2_a24(nx)*da4_lw14{ts2-nd};
     da2_lw21{ts2}=da2_lw21{ts2}+dea2_a24(nx)*da4_lw21{ts2-nd};
  end
  for nx=1:size(input_delays{2,4},2)
     nd=input_delays{2,4}(nx);
     da4_b1{ts2}=da4_b1{ts2}+dea4_a42(nx)*da2_b1{ts2-nd};
     da4_b2{ts2}=da4_b2{ts2}+dea4_a42(nx)*da2_b2{ts2-nd};
     da4_iw11{ts2}=da4_iw11{ts2}+dea4_a42(nx)*da2_iw11{ts2-nd};
     da4_lw12{ts2}=da4_lw12{ts2}+dea4_a42(nx)*da2_lw12{ts2-nd};
     da4_lw14{ts2}=da4_lw14{ts2}+dea4_a42(nx)*da2_lw14{ts2-nd};
     da4_lw21{ts2}=da4_lw21{ts2}+dea4_a42(nx)*da2_lw21{ts2-nd};
  end
  for nx=1:size(input_delays{4,4},2)
     nd=input_delays{4,4}(nx);
     da4_b1{ts2}=da4_b1{ts2}+dea4_a44(nx)*da4_b1{ts2-nd};
     da4_b2{ts2}=da4_b2{ts2}+dea4_a44(nx)*da4_b2{ts2-nd};
     da4_iw11{ts2}=da4_iw11{ts2}+dea4_a44(nx)*da4_iw11{ts2-nd};
     da4_lw12{ts2}=da4_lw12{ts2}+dea4_a44(nx)*da4_lw12{ts2-nd};
     da4_lw14{ts2}=da4_lw14{ts2}+dea4_a44(nx)*da4_lw14{ts2-nd};
     da4_lw21{ts2}=da4_lw21{ts2}+dea4_a44(nx)*da4_lw21{ts2-nd};
  end
  
 
  gEE=gE{4,ts};
  dF_b1=dF_b1+gEE*da4_b1{ts2};
  dF_b2=dF_b2+gEE*da4_b2{ts2};
  dF_iw11=dF_iw11+gEE*da4_iw11{ts2};
  dF_lw12=dF_lw12+gEE*da4_lw12{ts2};
  dF_lw14=dF_lw14+gEE*da4_lw14{ts2};
  dF_lw21=dF_lw21+gEE*da4_lw21{ts2};
  
end

inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

gX = zeros(net.hint.xLen,1);
gX(inputWeightInd{1,1}) = dF_iw11(:);
gX(layerWeightInd{1,2}) = dF_lw12(:);
gX(layerWeightInd{1,4}) = dF_lw14(:);
gX(biasInd{1}) = dF_b1(:);
gX(layerWeightInd{2,1}) = dF_lw21(:);
gX(biasInd{2}) = dF_b2(:);
