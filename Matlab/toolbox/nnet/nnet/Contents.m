% Neural Network Toolbox
% Version 4.0.3 (R14) 05-May-2004
%
% Graphical user interface functions.
%   nntool   - Neural Network Toolbox graphical user interface.
%
% Analysis functions.
%   errsurf  - Error surface of single input neuron.
%   maxlinlr - Maximum learning rate for a linear layer.
%
% Distance functions.
%   boxdist  - Box distance function.
%   dist     - Euclidean distance weight function.
%   mandist  - Manhattan distance weight function.
%   linkdist - Link distance function.
%
% Layer initialization functions.
%   initnw   - Nguyen-Widrow layer initialization function.
%   initwb   - By-weight-and-bias layer initialization function.
%
% Learning functions.
%   learncon - Conscience bias learning function.
%   learngd  - Gradient descent weight/bias learning function.
%   learngdm - Gradient descent w/momentum weight/bias learning function.
%   learnh   - Hebb weight learning function.
%   learnhd  - Hebb with decay weight learning function.
%   learnis  - Instar weight learning function.
%   learnk   - Kohonen weight learning function.
%   learnlv1 - LVQ1 weight learning function.
%   learnlv2 - LVQ2 weight learning function.
%   learnos  - Outstar weight learning function.
%   learnp   - Perceptron weight/bias learning function.
%   learnpn  - Normalized perceptron weight/bias learning function.
%   learnsom - Self-organizing map weight learning function.
%   learnwh  - Widrow-Hoff weight/bias learning rule.
%
% Line search functions.
%   srchbac  - Backtracking search.
%   srchbre  - Brent's combination golden section/quadratic interpolation.
%   srchcha  - Charalambous' cubic interpolation.
%   srchgol  - Golden section search.
%   srchhyb  - Hybrid bisection/cubic search.
%
% New networks.
%   network  - Create a custom neural network.
%   newc     - Create a competitive layer.
%   newcf    - Create a cascade-forward backpropagation network.
%   newelm   - Create an Elman backpropagation network.
%   newff    - Create a feed-forward backpropagation network.
%   newfftd  - Create a feed-forward input-delay backprop network.
%   newgrnn  - Design a generalized regression neural network.
%   newhop   - Create a Hopfield recurrent network.
%   newlin   - Create a linear layer.
%   newlind  - Design a linear layer.
%   newlvq   - Create a learning vector quantization network.
%   newp     - Create a perceptron.
%   newpnn   - Design a probabilistic neural network.
%   newrb    - Design a radial basis network.
%   newrbe   - Design an exact radial basis network.
%   newsom   - Create a self-organizing map.
%
% Net input functions.
%   netprod  - Product net input function.
%   netsum   - Sum net input function.
%
% Net input derivative functions.
%   dnetprod - Product net input derivative function.
%   dnetsum  - Sum net input derivative function.
%
% Network initialization functions.
%   initlay  - Layer-by-layer network initialization function.
%
% Performance functions.
%   mae      - Mean absolute error performance function.
%   mse      - Mean squared error performance function.
%   msereg   - Mean squared error with regularization performance function.
%   sse      - Sum squared error performance function.
%
% Performance derivative functions.
%   dmae     - Mean absolute error performance derivatives function.
%   dmse     - Mean squared error performance derivatives function.
%   dmsereg  - Mean squared error w/reg performance derivative function.
%   dsse     - Sum squared error performance derivative function.
%
% Plotting functions.
%   hintonw  - Hinton graph of weight matrix.
%   hintonwb - Hinton graph of weight matrix and bias vector.
%   plotbr   - Plot network performance for Bayesian regularization training.
%   plotes   - Plot an error surface of a single input neuron.
%   plotpc   - Plot classification line on perceptron vector plot.
%   plotpv   - Plot perceptron input/target vectors.
%   plotep   - Plot a weight-bias position on an error surface.
%   plotperf - Plot network performance.
%   plotsom  - Plot self-organizing map.
%   plotv    - Plot vectors as lines from the origin.
%   plotvec  - Plot vectors with different colors.
%
% Pre and Post Processing.
%   prestd   - Normalize data for unity standard deviation and zero mean.
%   poststd  - Unnormalize data which has been normalized by PRESTD.
%   trastd   - Transform data with precalculated mean and standard deviation.
%   premnmx  - Normalize data for maximum of 1 and minimum of -1.
%   postmnmx - Unnormalize data which has been normalized by PREMNMX.
%   tramnmx  - Transform data with precalculated minimum and maximum.
%   prepca   - Principal component analysis on input data.
%   trapca   - Transform data with PCA matrix computed by PREPCA.
%   postreg  - Post-training regression analysis.
%
% Simulink support.
%   gensim   - Generate a Simulink block to simulate a neural network.
%
% Topology functions.
%   gridtop  - Grid layer topology function.
%   hextop   - Hexagonal layer topology function.
%   randtop  - Random layer topology function.
%
% Training functions.
%   trainb   - Batch training with weight & bias learning rules.
%   trainbfg - BFGS quasi-Newton backpropagation.
%   trainbr  - Bayesian regularization.
%   trainc   - Cyclical order incremental training w/learning functions.
%   traincgb - Powell-Beale conjugate gradient backpropagation.
%   traincgf - Fletcher-Powell conjugate gradient backpropagation.
%   traincgp - Polak-Ribiere conjugate gradient backpropagation.
%   traingd  - Gradient descent backpropagation.
%   traingdm - Gradient descent with momentum backpropagation.
%   traingda - Gradient descent with adaptive lr backpropagation.
%   traingdx - Gradient descent w/momentum & adaptive lr backpropagation.
%   trainlm  - Levenberg-Marquardt backpropagation.
%   trainoss - One step secant backpropagation.
%   trainr   - Random order incremental training w/learning functions.
%   trainrp  - Resilient backpropagation (Rprop).
%   trains   - Sequential order incremental training w/learning functions.
%   trainscg - Scaled conjugate gradient backpropagation.
%
% Transfer functions.
%   compet   - Competitive transfer function.
%   hardlim  - Hard limit transfer function.
%   hardlims - Symmetric hard limit transfer function.
%   logsig   - Log sigmoid transfer function.
%   poslin   - Positive linear transfer function.
%   purelin  - Linear transfer function.
%   radbas   - Radial basis transfer function.
%   satlin   - Saturating linear transfer function.
%   satlins  - Symmetric saturating linear transfer function.
%   softmax  - Soft max transfer function.
%   tansig   - Hyperbolic tangent sigmoid transfer function.
%   tribas   - Triangular basis transfer function.
%
% Transfer derivative functions.
%   dhardlim - Hard limit transfer derivative function.
%   dhardlms - Symmetric hard limit transfer derivative function.
%   dlogsig  - Log sigmoid transfer derivative function.
%   dposlin  - Positive linear transfer derivative function.
%   dpurelin - Hard limit transfer derivative function.
%   dradbas  - Radial basis transfer derivative function.
%   dsatlin  - Saturating linear transfer derivative function.
%   dsatlins - Symmetric saturating linear transfer derivative function.
%   dtansig  - Hyperbolic tangent sigmoid transfer derivative function.
%   dtribas  - Triangular basis transfer derivative function.
%
% Update networks from previous versions.
%   nnt2c    - Update NNT 2.0 competitive layer.
%   nnt2elm  - Update NNT 2.0 Elman backpropagation network.
%   nnt2ff   - Update NNT 2.0 feed-forward network.
%   nnt2hop  - Update NNT 2.0 Hopfield recurrent network.
%   nnt2lin  - Update NNT 2.0 linear layer.
%   nnt2lvq  - Update NNT 2.0 learning vector quantization network.
%   nnt2p    - Update NNT 2.0 perceptron.
%   nnt2rb   - Update NNT 2.0 radial basis network.
%   nnt2som  - Update NNT 2.0 self-organizing map.
%
% Using networks.
%   sim      - Simulate a neural network.
%   init     - Initialize a neural network.
%   adapt    - Allow a neural network to adapt.
%   train    - Train a neural network.
%   disp     - Display a neural network's properties.
%   display  - Display the name and properties of a neural network variable.
%
% Vectors.
%   cell2mat - Combine cell array of matrices into one matrix (MATLAB Toolbox).
%   concur   - Create concurrent bias vectors.
%   con2seq  - Convert concurrent vectors to sequential vectors.
%   combvec  - Create all combinations of vectors.
%   ind2vec  - Convert indices to vectors.
%   mat2cell - Break matrix up into cell array of matrices (MATLAB Toolbox).
%   minmax   - Ranges of matrix rows.
%   nncopy   - Copy matrix or cell array.
%   normc    - Normalize columns of a matrix.
%   normr    - Normalize rows of a matrix.
%   pnormc   - Pseudo-normalize columns of a matrix.
%   quant    - Discretize values as multiples of a quantity.
%   seq2con  - Convert sequential vectors to concurrent vectors.
%   sumsqr   - Sum squared elements of matrix.
%   vec2ind  - Convert vectors to indices.
%
% Weight functions.
%   dist     - Euclidean distance weight function.
%   dotprod  - Dot product weight function.
%   mandist  - Manhattan distance weight function.
%   negdist  - Dot product weight function.
%   normprod - Normalized dot product weight function.
%
% Weight derivative functions.
%   ddotprod - Dot product weight derivative function.
%
% Weight and bias initialization functions.
%   initcon  - Conscience bias initialization function.
%   initzero - Zero weight/bias initialization function.
%   midpoint - Midpoint weight initialization function.
%   randnc   - Normalized column weight initialization function.
%   randnr   - Normalized row weight initialization function.
%   rands    - Symmetric random weight/bias initialization function.
%
% Weight derivative functions.
%   ddotprod - Dot product weight derivative function.

% Copyright 1992-2004 The MathWorks, Inc.

