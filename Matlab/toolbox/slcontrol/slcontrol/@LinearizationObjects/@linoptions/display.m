function display(this)
%DISPLAY  Defines properties for @linoptions class

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2004 The MathWorks, Inc.
%% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:34:58 $

disp(' ')
disp(sprintf('Options for <a href="matlab:help linearize">LINEARIZE</a>:'))
disp(sprintf('    LinearizationAlgorithm     : %s', this.LinearizationAlgorithm));
if ischar(this.SampleTime)
    disp(sprintf('    SampleTime (-1 Auto Detect): %s', this.SampleTime));
else
    disp(sprintf('    SampleTime (-1 Auto Detect): %d', this.SampleTime));
end
disp(sprintf(' '));
disp(sprintf('  Options for ''blockbyblock'' algorithm'))
disp(sprintf('    BlockReduction (on/off)      : %s', this.BlockReduction));       
disp(sprintf('    IgnoreDiscreteStates (on/off): %s', this.IgnoreDiscreteStates));
disp(sprintf(' '));
disp(sprintf('  Options for ''numericalpert'' algorithm'))
disp(sprintf('    NumericalPertRel : %d', this.NumericalPertRel));  
if isempty(this.NumericalXPert)
    disp(sprintf('    NumericalXPert   : []'));
else
    disp(sprintf('    NumericalXPert   : [%dx%d double]', size(this.NumericalXPert)));
end
if isempty(this.NumericalXPert)
    disp(sprintf('    NumericalUPert   : []'));
else
    disp(sprintf('    NumericalUPert   : [%dx%d double]', size(this.NumericalUPert)));
end
disp(sprintf(' '));
disp(sprintf('Options for <a href="matlab:help findop">FINDOP</a>:'))

disp(sprintf('    OptimizationOptions        : [1x1 struct]'));       
disp(sprintf('    OptimizerType              : %s', this.OptimizerType));
disp(sprintf('    DisplayReport (on/iter/off): %s', this.DisplayReport));
disp(sprintf('\n'));
