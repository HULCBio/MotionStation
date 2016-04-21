function updateResultSummary(this)

% Copyright 2004 The MathWorks, Inc.

%% updateResultSummary - Update the text field with the result summary

%% Get the summary area handle and lti system
sa = this.SummaryAreaUDD;
sys = this.LinearizedModel(:,:,1);

%% Label
data = {'<font face="monospaced"; size=3>'};
data{end+1} = sprintf('Linearization Result Summary');
data{end+1} = '';
data{end+1} = sprintf('  To export the result click on the Export To Workspace button below.');
data{end+1} = sprintf('Sample Rate (sec.): %0.5g', sys.Ts);
data{end+1} = '';
data{end+1} = sprintf('State Names:');
data{end+1} = sprintf('-----------');
for ct = 1:length(sys.StateName)
    block = regexprep(sys.StateName{ct},'\n',' ');
    data{end+1} = sprintf('<a href="block:%s">%s</a>',block,block);
end
data{end+1} = ' ';
data{end+1} = sprintf('Input Channel Names:');
data{end+1} = sprintf('-------------------\n');
for ct = 1:length(sys.InputName)
    block = regexprep(sys.InputName{ct},'\n',' ');
    data{end+1} = block;
end
data{end+1} = ' ';
data{end+1} = sprintf('Output Channel Names:');
data{end+1} = sprintf('-------------------\n');
for ct = 1:length(sys.OutputName)
    block = regexprep(sys.OutputName{ct},'\n',' ');
    data{end+1} = block;
end

sa.setContent(data)
