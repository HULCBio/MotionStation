function nnidenthelp(varargin);
%NNIDENTHELP Help text for the Indirect Adaptive Control GUI
%   NNIDENTHELP(ACTION) displays the help text for the portion of
%   the Indirect Adaptive Control GUI specified by ACTION. 

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.3 $ $Date: 2002/04/14 21:11:13 $

ni=nargin;

if ni
   action=varargin{1};
else
   return
end

switch action,
case 'main',
   %---Help for the main Plant Identification window
   helptext={'Overview', ...
         {'The Plant Identification GUI is an interactive environment for developing';
         'a Neural Network capable of modeling a given plant. ';
         '';
         'Flip through the remaining Topics for a detailed description of how ';
         'to use these and other Plant Identification GUI features.'};
      'Menus', ...
         {'The menus provide additional options for setting up and configuring ';
         'the controller. The menus available are as follows.';
         '';
         '1) File:';
         '     a) Import Network: Import neural network plant model weights.';
         '     b) Export Network: Export neural network plant model weights.';
         '     c) Save: Load all parameters into the Simulink controller block.';
         '     d) Save and Exit: Load all parameters into the Simulink controller block and close this menu.';
         '     e) Exit Without Saving: Close the Plant Identification GUI and all related windows.';
         '';
         '';
         '2) Window:';
         '     Show and switch between all the open windows.';
         '';
         '';
         '3) Help:';
         '     a) Main Help: Open the general Indirect Adaptive Control GUI help text.';
         '     b) All other Help menus: Open tool specific help text.'};
      'Neural Network Plant structure', ...
        {'The two-layer neural network plant has an input layer with a tansig transfer';
         'function. There are two sets of inputs to the plant model: delayed values of';
         'the plant output and delayed values of the controller output. The output ';
         'layer has a purelin transfer function. You can set the size of the hidden';
         'layer.';
         'For the NARMA-L2 controller, the plant model has a more complex structure.';
         'The inputs to the network are the same, but the network has four layers';
         'instead of two.  See the User''s Guide for a complete description.';
         '';
         ''};      
      'Simulink Plant Model', ...
        {'You enter the name of a simulink file that has the plant model to be';
         'used in the identification process.';
         '';
         'The Simulink model must have one inport block and one outport block.';
         'The Simulink model will be used to generate data for the plant';
         'identification.  Random inputs will be applied to the model to';
         'generate the training data.';
         '';
         ''};
      'Neural network inputs', ...
         {'The neural network plant model has two inputs available:';
         '';
         '   1)Delayed Controller Outputs.';
         '   2)Delayed Plant Outputs.';
         '';
         'For each input you must specify the number of delays to be used.';
         'The delays are based on the sample time defined in the Sampling Interval';
         'field. For each plant input, you can select any nonzero value for';
         'the number of delays.';
         '';
         'The sampling time is given in seconds.';
         ''};
      'Training function', ...
        {'The Plant Identification algorithm has the following algorithms available';
         'for training:';
         '';
         '   1) trainbfg: BFGS quasi-Newton backpropagation';
         '   2) trainbr:  Bayesian regularization backpropagation';
         '   3) traincgb: Conjugate gradient backpropagation with Powell-Beale';
         '                restarts.';
         '   4) traincgf: Conjugate gradient backpropagation with Fletcher-Reeves';
         '                updates.';
         '   5) traincgp: Conjugate gradient backpropagation with Polak-Ribiere';
         '                updates.';
         '   6) traingd:  Gradient descent backpropagation.';
         '   7) traingdm: Gradient descent with momentum backpropagation.';
         '   8) traingda: Gradient descent with adaptive learning rate backpropagation.';
         '   9) traingdx: Gradient descent with momentum & adaptive learning rate';
         '                backpropagation.';
         '  10) trainlm:  Levenberg-Marquardt backpropagation.';
         '  11) trainoss: One step secant backpropagation.';
         '  12) trainrp:  Resilient backpropagation algorithm (RPROP).';
         '  13) trainscg: Scaled conjugate gradient backpropagation.';
         '';
         ''};
      'Training data', ...
         {'You have two options for obtaining the data used to train the neural';
         'network plant model:';
         '';
         '   1) Import Training Data: Here you have a file with the data';
         '      used for training. The data is retrieved from a .mat file whose name';
         '      you enter in the appropriate field. The data file can contain a structure';
         '      with fields named U and Y for the input and output of the plant, respectively.';
         '      It can also obtain two individual arrays.';
         '';
         '   2) Generate Training Data: You allow the GUI to generate the random';
         '      training data to be used in the identification process. You must';
         '      define the minimum and maximum values of the random control signal. ';
         '      The simulink file with the plant model is used to generate the targets.';
         '      If the user selects Limit Output Data, the GUI will stop the target';
         '      generation process each time a limit is violated. The simulation';
         '      process will then continue with new initial conditions. The number of';
         '      training samples will define how many random inputs will be applied';
         '      to the simulink plant to generate the targets.';
         '';
         'The data will be normalized to a range 0-1 if you select the Normalize ';
         'Training Data option. This option is preferred when trainbr is used as the';
         'training function.';
         '';
         ''};
      'Training epochs', ...
         {'Defines the number of iterations that will be applied to train the neural';
         'network plant model.';
         ''};
      'Use Validation/Testing Data', ...
        {'The Validation option is used to stop training early if the network';
         'performance on the validation data fails to improve or remains the same';
         'for 5 epochs in a row. ';
         '';
         'The Testing option is used to test the generalization capability of the';
         'trained network.  The error on a test data set is monitored and displayed';
         'during training.';
         '';
         'If any of these options are selected, 25 % of the data is used for each ';
         '(validation or testing) option, allowing a minmum of 50 % for training';
         'if both options are selected. After training, graphs are created to present';
         'the training data (and the validation and testing data if selected). You can';
         'then continue training or repeat the training with new random initial weights.';
         ''}};
   
case 'plant_ident',
   %---Help for the Plant Identification process
   helptext = {'Plant Identification', ...
        {'The Plant Identification process allows you to train a neural network';
        'that models the plant.  If the neural network plant model is to be used';
        'in training a controller, you should identify the plant before training';
         'the controller, and you may want to re-identify the plant when controller';
         'training is not satisfactory.';
         '';
         'Plant Identification requires the following parameters:';
         '';
         '   1) Size of the Hidden Layer: Define how many neurons will be in the hidden';
         '      layer of the neural network plant model.';
         '   2) Simulink Plant Model: A simulink file, with inport and';
         '      outport blocks, used to generate a plant response to train the';
         '      neural network plant model.';
         '   3) No. Delayed Controller Outputs: defines how many delays in the controller output';
         '       will be used to feed the NN plant model.';
         '   4) No. Delayed Plant Outputs: defines how many delays in the plant output will be';
         '      used to feed the NN plant model.';
         '   5) Sampling Interval (in seconds): defines the sampling interval used to collect';
         '      data to be used in the training process.';
         '   6) Training function: The training function to be used in the identification';
         '      process.';
         '   7.1) Import Training Data: If you select this option, you';
         '        enter a valid data file with the input-output values from the';
         '        plant to be used for training.';
         '   7.2) Generate Training Data: If you select this option, you ';
         '        define the range of the input, the limit on the output signal';
         '        (if any), and the number of training samples.';
         '   8) Normalize Training Data: If you select this option, the input-output ';
         '      data is normalized to a range 0-1.';
         '   9) Training Epochs: Defines how many epochs will be used during training.';
         '  10) Use Validation/Testing for Training: If selected, 25 % of the training';
         '      data will be used for validation and/or testing.';
         '';
         'The Generate Training Data button generates training data based on the simulink plant';
         'model file (if selected). The input-output data will be displayed';
         'in another window. You can accept or refuse the data. If refused, the';
         'new window is closed and you can adjust parameters on the Plant';
         'Identification window to generate data again. If the data is accepted, you';
         'can then Train the Network. Once the training is concluded you can perform one';
         'of the following actions:';
         '';
         '   1) Generate more data: New training data based on the simulink plant ';
         '      model file are generated. You can then continue training. ';
         '   2) Train Network: The same training data set is used, and the';
         '      training continues using the last generated weights.';
         '   3) Apply: The weights are saved in the Neural Network Plant Model block.';
         '      You can simulate the system while this window remains open.';
         '   4) OK: The weights are saved in the Neural Network Plant Model block and';
         '      the window is closed.';
         '   5) Cancel: The window is closed and no vales are saved.';
         '';
         'During the training process, progress report messages are shown in the';
         'feedback line.';
         ''}};
         
end, % switch action

helpwin(helptext);

