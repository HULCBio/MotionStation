function nnmodrefhelp(varargin);
%NNMODREFHELP Help text for the Indirect Adaptive Control GUI
%
%  Synopsis
%
%   nnmodrefhelp(varargin) 
%
%   displays the help text for the portion of the Indirect Adaptive Control 
%   GUI specified by varargin. 
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.4 $ $Date: 2002/04/14 21:11:25 $

ni=nargin;

if ni
   action=varargin{1};
else
   return
end

switch action,
case 'main',
   %---Help for the main Model Reference Control window
   helptext={'Overview', ...
         {'The Model Reference Control GUI is an interactive environment for';
         'developing neural network model reference controllers. ';
         '';
         'There are two steps in the controller design:';
         '  1) Identification of a neural network plant model';
         '  2) Training of the neural network controller using the identified plant';
         '     and a specified reference model.';
         '';
         'Flip through the remaining Topics for a detailed description of how ';
         'to use these and other Model Reference Control GUI features.'};
      'Menus', ...
         {'The menus provide additional options for setting up and configuring ';
         'the controller. The menus available are as follows.';
         '';
         '1) File:';
         '     a) Import Network: Import neural network controller and plant weights';
         '     b) Export Network: Export controller and plant weights';
         '     c) Save: Load all parameters into the Simulink controller block.';
         '     d) Save and Exit: Load all parameters into the Simulink controller block and close this menu.';
         '     e) Exit Without Saving: Close the Model Reference Control GUI and all related windows.';
         '';
         '';
         '2) Window:';
         '     Show and switch between all the open windows.';
         '';
         '';
         '3) Help:';
         '     a) Main Help: Open the general Model Reference Control GUI help text.';
         '     b) All other Help menus: Open tool specific help text.'};
      'Controller structure', ...
        {'The two-layer neural network controller has an input layer with a tansig';
         'transfer function. There are three sets of inputs to the controller:';
         'delayed reference values, delayed controller outputs and delayed plant ';
         'outputs. The output layer of the controller network has a purelin ';
         'transfer function. You can set the size of the hidden layer.';
         '';
         ''};      
      'Reference model', ...
        {'In order to train the controller, you must first enter the name of a';
         'simulink file that contains the reference model.  The controller is';
         'trained so that the plant output will follow the reference model output.';
         '';
         'The reference model must have one inport block and one outport block. The ';
         'reference model is used to generate training data for the Model ';
         'Reference Controller training algorithm.';
         '';
         ''};
      'Controller inputs', ...
         {'The controller has three inputs available:';
         '';
         '   1)Delayed reference inputs.';
         '   2)Delayed controller outputs.';
         '   3)Delayed plant outputs.';
         '';
         'For each input you must specify the number of delays to be used.';
         'The delays are based on the sample time defined in the Plant Identification';
         'window. For each controller input, you can select any nonzero value for';
         'the number of delays.';
         ''};
      'Max/Min Reference Value', ...
         {'You must define bounds for the random reference to be used';
         'in the controller training. Those bounds must have a physical relation';
         'to the plant response obtained in the identification process. If the';
         'controller reference bounds are outside the range of the plant response ';
         'during the identification process, the controller training may not converge.';
         'The random reference will consist of a series of step functions of random';
         'height and random interval.  In addition to setting the min and max height,';
         'you also set the minimum and maximum intervals.';
         '';
         ''}};
   
case 'train_contr',
   %---Help for the Training Controller process.
   helptext = {'Training the Controller', ...
         {'Before training the controller, a neural network plant model must first ';
         'be correctly identified. If you have not previously identified the plant, ';
         'then click the Plant Identification button, which will open an identification';
         'window.';
         '';
         'The controller training algorithm needs the following parameters:';
         '';
         '   1) Size of the Hidden layer: Define how many neurons will be in the hidden';
         '      layer of the controller.';
         '   2) Reference Model: A simulink file, with inport and outport blocks, used to';
         '      generate a reference response to train the controller.';
         '   3) No. Delayed Reference Inputs: defines how many delays in the reference';
         '      will be used to feed the controller.';
         '   4) No. Delayed Controller Outputs: defines how many delays in the controller';
         '      output will be used to feed the controller.';
         '   5) No. Delayed Plant Outputs: defines how many delays in the plant output';
         '      will be used to feed the controller.';
         '   6) Maximum/Minimum Reference Values: Defines the bounds on the random';
         '      input to the reference model.';
         '   7) Maximum/Minimum Interval Values: Defines the bounds on the interval';
         '      over which the random reference will remain constant.';
         '   8) Controller Training Samples: Defines the number of random values to';
         '      be generated to feed the reference model and therefore to be used ';
         '      in training the controller.';
         '   9) Controller Training Epochs: Defines how many epochs per segment will';
         '      be used during training. One segment of data is presented to the network,';
         '      and then the specified number of epochs of training are performed.';
         '      The next segment is then presented, and the process is repeated.  This';
         '      continues until all segments have been presented.';
         '  10) Controller Training Segments: Defines how many segments the training data';
         '      is divided into.';
         '  11) Use Cumulative Training: If selected, the initial training is done with';
         '      one segment of data.  Future training is performed by adding segments';
         '      to the previous training data, until the entire training data set is';
         '      used in the final stage. Use this option carefully due to increased training';
         '      time.';
         '  12) Use Current Weights: If selected, the current controller weights';
         '      are used as the initial weights for controller training.';
         '      Otherwise, random initial weights are generated.';
         '      If the controller network structure is modified, this option';
         '      will be overridden, and random weights will be used.';
         '';
         'The Generate Training Data button generates training data based on the';
         'reference model file. You can also Import training data.  Once the training ';
         'data is entered, you can perform one of the following actions:';
         '';
         '   1) Train Controller: Trains the neural network controller using';
         '      the available data. The previous weights are used as initial weights,';
         '      if that option is selected.';
         '   2) Apply: The weights are saved in the Neural Network Controller block.';
         '      You can simulate the system while this window remains open.';
         '   3) OK: The weights are saved in the Neural Network Controller block, and';
         '      the window is closed.';
         '   4) Cancel: The window is closed, and no values are saved.';
         '   5) Plant Identification: Opens a Plant Identification window.';
         '      You should identify the plant before performing controller';
         '      training.  You may also want to re-identify the plant if the';
         '      controller training is not satisfactory.  An accurate plant';
         '      model is needed for accurate controller training.';
         '';
         'During the training process, progress report messages are shown in the';
         'feedback line.';
         ''}};
         
case 'plant_ident',
   %---Help for the Plant Identification process
   helptext = {'Plant Identification', ...
        {'You can go to the Plant Identification window to train a neural';
         'network that mimics the plant behavior.  You should identify the';
         'plant before training the controller, and you may want to';
         're-identify the plant when controller training is not satisfactory.';
         ''}};
   
case 'simulation',
   %---Help for the simulation process
   helptext={'Simulation', ...
         {'The system can be simulated once the Plant Identification and the';
         'Controller Training are complete. After you select the Apply buttons in';
         'either window, you can simulate the plant. Go back to the Simulink';
         'window and select Start under the Simulation menu to start the simulation. ';
         'If the performance is not satisfactory, you can go back to retrain the controller.';
         ''}};
         
end, % switch action

helpwin(helptext);

