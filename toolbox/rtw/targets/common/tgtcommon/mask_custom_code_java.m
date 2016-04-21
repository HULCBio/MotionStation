function varargout = mask_custom_code_java(action,varargin)
%MASK_CUSTOM_CODE

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

   import('javax.swing.*');
   import('java.awt.*');

   switch action
   case 'reset'
      block = varargin{1};

      % The data before mask processing occurs
      obj.unique = 1;
      obj.key='';
      obj.location='Subsystem Enable Function';
      obj.vars = '';
      obj.top = '';
      obj.middle = '';
      obj.bottom = '';

      set_param(block,'userdatapersistent','on');
      set_param(block,'userdata',obj);

   case 'initfcn'
     block = varargin{1};
      obj.block = varargin{1};
      data = get_param(block,'userdata');


      % Window
      %obj.dialog = handle(JFrame('Custom Coder'),'callbackproperties');
      obj.dialog = JFrame;
      %obj.dialog.setLocationRelativeTo([]);
      obj.dialog = handle(obj.dialog,'callbackproperties');


      b = javax.swing.Box(BoxLayout.Y_AXIS);
      b.add(b.createVerticalStrut(12));
      obj.dialog.getContentPane.add(b,BorderLayout.NORTH);


      % UniqueCombo
      b.add(JLabel('Unique Code Generation'));
      obj.UniqueJComboBox = JComboBox( ...
         { 'Generate for every instance',...
         'Generate once per functional mask',...
         'Generate once per model' });

      b.add(obj.UniqueJComboBox);
      b.add(b.createVerticalStrut(5));
      obj.UniqueJComboBox.setSelectedIndex(data.unique-1);

      %Location
      b.add(JLabel('Code Location'));
      obj.LocationJComboBox = JComboBox({...
         'Header File', ...
         'Export Header',...
         'Parameter File', ...
         'Source File', ...
         'Registration File', ...
         'Subsystem Initialize Function', ...
         'Subsystem Outputs Function', ...
         'Subsystem Update Function', ...
         'Subsystem Derivatives Function', ...
         'Subsystem Terminate Function', ...
         'Subsystem Enable Function', ...
         'Subsystem Disable Function', ...
         'Registration Function', ...
         'Model Start Function', ...
         'Model Initialize Function', ...
         'Model Terminate Function', ...
         'Model Outputs Function', ...
         'Model Update Function', ...
         'Model Derivatives Function' });
      b.add(obj.LocationJComboBox);
      b.add(b.createVerticalStrut(5));
      obj.LocationJComboBox.setSelectedItem(data.location);

      %Key
      b.add(JLabel('Key'));
      obj.KeyTextField = JTextField('');
      b.add(obj.KeyTextField);
      b.add(b.createVerticalStrut(5));
      obj.KeyTextField.setText(data.key);


      %Imported Vars
      b.add(JLabel('Imported Variables'));
      obj.VariablesJTextField = JTextField;
      b.add(obj.VariablesJTextField);
      b.add(b.createVerticalStrut(5));
      obj.VariablesJTextField.setText(data.vars);

      %Code

      obj.tabbedPane = JTabbedPane;
      obj.tabbedPane.setBorder(BorderFactory.createTitledBorder( ...
         'Custom Code Sections' ));
      obj.topPanel = JPanel(BorderLayout);
      obj.middlePanel = JPanel(BorderLayout);
      obj.bottomPanel = JPanel(BorderLayout);

      obj.tabbedPane.addTab('Top',obj.topPanel);
      obj.tabbedPane.addTab('Middle',obj.middlePanel);
      obj.tabbedPane.addTab('Bottom',obj.bottomPanel);
      obj.tabbedPane.setPreferredSize(Dimension(300,350))

      obj.dialog.getContentPane.add(obj.tabbedPane);

      obj.topJTextArea = JTextArea;
      obj.middleJTextArea = JTextArea;
      obj.bottomJTextArea = JTextArea;

      obj.topPanel.add(JScrollPane(obj.topJTextArea));
      obj.middlePanel.add(JScrollPane(obj.middleJTextArea));
      obj.bottomPanel.add(JScrollPane(obj.bottomJTextArea));

      obj.topJTextArea.setText(data.top);
      obj.middleJTextArea.setText(data.middle);
      obj.bottomJTextArea.setText(data.bottom);

      % Apply Cancel OK Buttons

      p = JPanel(FlowLayout(FlowLayout.RIGHT,5,5));
      obj.applyButton = handle(JButton('Apply'),'callbackproperties');
      obj.okButton = handle(JButton('OK'),'callbackproperties');
      obj.cancelButton = handle(JButton('Cancel'),'callbackproperties');

      p.add(obj.okButton.java);
      p.add(obj.cancelButton.java);
      p.add(obj.applyButton.java);

      set(obj.applyButton,'ActionPerformedCallback', { @i_action_button_callback obj 'apply' }); 
      set(obj.okButton,'ActionPerformedCallback', { @i_action_button_callback obj 'ok' }); 
      set(obj.cancelButton,'ActionPerformedCallback', { @i_action_button_callback obj 'cancel' }); 

      obj.dialog.getContentPane.add(p,BorderLayout.SOUTH);

      obj.dialog.java.pack;

      screen_size = java.awt.Toolkit.getDefaultToolkit.getScreenSize;
      dialog_size = obj.dialog.getSize;

      new_pos = Dimension((screen_size.width-dialog_size.width)/2,(screen_size.height-dialog_size.height)/2);
      obj.dialog.java.setLocation(new_pos.width,new_pos.height);

      obj.dialog.java.show;
   case 'process_code'
      block = varargin{1};
      data = get_param(block,'userdata');

      % Generate a string like
      % '{ var1 var2 var3 }'
      % that can be evaluated
      vars = [ '{ ' data.vars ' } ' ]; 
      parent = get_param(block,'parent');

      %% Evaluate the imported variables and
      %% place the results in a cell array
      try
         parent = i_get_masked_parent(block);
         if ~isempty(parent)
            ws_name = parent;
            ws = get_param(parent,'maskwsvariables'); 
            evaluated_vars = local_eval(ws,vars);
            key = local_eval(ws,data.key);

         else
            ws_name = 'base';
            evaluated_vars = evalin('base',vars);
            key = evalin('base',data.key);
         end
      catch
         str =[ 'Tried to import variables : ', vars ,...
              'from the "' ws_name '" workspace. ' ,...
            'but got the error ',...
            lasterr, ...
            '. Either change the variable name or make sure the variable exists.']; 
         error(str);

      end

      %% Turn the varnames into a cell array
      %% of strings.
      if ~isempty(data.vars)
         varnames = strread(data.vars,'%s');
      else
         varnames = {};
      end

      %% Process each code snippet in a TLC workspace
      top    = process_template(data.top,    varnames, evaluated_vars);
      middle = process_template(data.middle, varnames, evaluated_vars);
      bottom = process_template(data.bottom, varnames, evaluated_vars);

      [dispstr,rtwdata] = mask_custom_code(data.unique,key,data.location, top, middle, bottom);
      varargout = { dispstr,rtwdata };

   otherwise
      error([action ' is an invalid action.']);
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CREATE_TEMPLATE - generate a MatlabTemplateEngine template
   %%
   %% text  -  the text from the template body
   %% vars  -  the list of variables to be passed to the template
function text = process_template(text, vars, varvalues)
   if isempty(regexp(text,'^\s*$'))
      arglist = sprintf('%s, ', vars{:});
      arglist = ['( ' arglist(1:end-1) ')' ];
      header = ['#template ' arglist ];
      templatetext = sprintf('%s\n%s',header,text);
      template = MatlabTemplateEngine.Template('<',templatetext);
		try
			text = template.exec(varvalues{:});
		catch
			error(sprintf('TEMPLATE ERROR\n--------------\n%s\n%s',template.mlint, lasterr));
		end
   else
      text = '';
   end
      

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Evaluate the expr in a TLC context after
   %% loading in the variables into the TLC 
   %% context
function code = tlc_expr(expr,varnames,evaluated_vars,error_str)
   try
      h = tlchandle;
      load_vars(h,varnames,evaluated_vars);
      code = tlc('execstring',h.Handle,  expr );
      close(h);
   catch
      close(h);
      
      error([sprintf('\n-------------------------\n') error_str ...
         sprintf('\n-------------------------\n') expr ...
         sprintf('\n-------------------------\n') lasterr]);
   end



   %%--------------------------------------------------------------------- 
   %% Evaluate the expression in the context of the workspace object
   %%
   %% Arguments
   %%   ws_xa_yz_zt_8123   -  The workspace object
   %%   expr_xa_yz_zt_8123 -  The string expression 

function return_value_x9_a_rzd = local_eval(ws_xa_yz_zt_8123,expr_xa_yz_zt_8123)
    setvar_(ws_xa_yz_zt_8123);
    return_value_x9_a_rzd = eval(expr_xa_yz_zt_8123);

    %%-------------------------------------------------------------------
    %% Load the workspace object into the workspace of the calling
    %% function
function ret = setvar_(ws)
    for i = 1:length(ws)
        assignin('caller',ws(i).Name,ws(i).Value)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  
    %%  CALLBACKS
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_action_button_callback(src,evt,obj,action)
   import('com.mathworks.toolbox.ecoder.utils.*');
   import('javax.swing.*');

   switch action
   case 'ok'
      i_apply_gui(obj);
      rw = RunnableWrapper(obj.dialog.java,'dispose',{});
      SwingUtilities.invokeLater(rw);
    case 'apply'
      i_apply_gui(obj);
    case 'cancel'
      rw = RunnableWrapper(obj.dialog.java,'dispose',{});
      SwingUtilities.invokeLater(rw);
   end;

	%% I_GET_MASK_PARENT get the handle of a parent block that has a mask
	%% 
	%% Searches up the model hierachy to find a parent
	%% block that is masked

function parent = i_get_masked_parent(block)
    block = get_param(block,'parent');
	while(~(isempty(block) || hasmask(block)==2))
		block = get_param(block, 'parent');
	end
	if ~isempty(block)
		parent = block;
	else
		parent = [];
	end


function i_apply_gui(obj)
   data = get_param(obj.block,'userdata'); 
   data.unique  = obj.UniqueJComboBox.getSelectedIndex + 1;
   data.key = char(obj.KeyTextField.getText);
   data.location = char(obj.LocationJComboBox.getSelectedItem);
   data.vars   = char(obj.VariablesJTextField.getText);
   data.top    = char(obj.topJTextArea.getText);
   data.middle = char(obj.middleJTextArea.getText);
   data.bottom = char(obj.bottomJTextArea.getText);
   set_param(obj.block,'userdata',data);

      

%   $Revision: 1.1.6.3 $  $Date: 2004/04/29 03:40:03 $
