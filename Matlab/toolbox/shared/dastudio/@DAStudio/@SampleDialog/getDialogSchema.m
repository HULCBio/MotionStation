function dlgstruct = getDialogSchema(h, name)

% Copyright 2004 The MathWorks, Inc.

  % We ignore name here, but if an object has more than one dialog,
  % we can use the name parameter to return the right schema like so.
  %  switch name
  %    case name1: Return some schema
  %    default:    Return another schema
  %
      
  %h.stringProp = 'help me';
  %h.radioProp1 = 'lvlThree';
  %h.checkProp = 1;
  %h.intProp = 4;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %  items in tab panel
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  item1.Name    = 'My list';
  item1.Type    = 'listbox';
  item1.Entries = { 'list item 1', ...
                    'list item 2', ...
                    'list item 3', ...
                    'list item 4'};
  
  item2.Name           = 'My edit bar';
  item2.ObjectProperty = 'doubleProp';
  item2.Mode           = 1;
  item2.Type           = 'edit';
  
  item3.Name           = 'Radio group';
  item3.Type           = 'radiobutton';
  item3.ObjectProperty = 'radioProp1';
  item3.Mode           = 1;
  item3.Entries        = {'Item 1', ...
                          'Item 2', ...
                          'Item 3'};
  
  item4.Name           = 'My hyperlink';
  item4.Type           = 'hyperlink';
  
  item5.Name           = 'My checkbox';
  item5.Type           = 'checkbox';
  item5.Mode           = 1;
  %item5.ObjectMethod   = 'sampleMethod';
  %item5.MethodArgs     = {5, 'string 1', true};
  %item5.ArgDataTypes   = {'int', 'string', 'bool'};
  item5.ObjectProperty = 'checkProp';
  item5.DialogRefresh  = 1;
  %item5.MatlabMethod   = 'open_system';
  %item5.MatlabArgs     = {'vdp'};
  
  spacer.Type     = 'panel';
  
  item6.Type       = 'textbrowser';
  item6.Text       = 'raw string on a textbrowser.  Click <a href=''matlab:doc''> here </a> for help. <br> Click <a href=''ddgrefresh:1+1''>here</a> to trigger a dialog refresh and add 1+1';
  
  item7.Name       = 'Click to show additional parameters';
  item7.Type       = 'togglepanel';
  item7.Items      = {item6, item1, item3, item3, item2, item2, item2};
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %   tab panels
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  tab1.Name = 'Tab 1';
  tab1.Items = {item1, item2};
  
  tab2.Name = 'Tab 2';
  tab2.Items = {item3, item4, item5};
    
  tab3.Name = 'Tab 3';
  tab3.Items = {item7, spacer, spacer};
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % description container items
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  % description    
  desc.FilePath = '/home/kbalasub/www/index2.html';
%  desc.ObjectProperty = 'stringProp1';
  %if h.checkProp == 1
  %  desc.Type = 'editarea';
  %else
    desc.Type = 'textbrowser';
  %end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%
  % massprop items
  %%%%%%%%%%%%%%%%%%%%%%%%%%
    
  % mass widget
  mass.Name = 'Mass';
  mass.Type = 'edit';
  mass.RowSpan = [1 1];
  mass.ColSpan = [1 3];
  mass.ToolTip = 'bla1';
  
   % mass_popup widget
  mass_popup.Name = '';
  mass_popup.Type = 'combobox';
  mass_popup.ObjectProperty = 'intProp';
  mass_popup.RowSpan = [1 1];
  mass_popup.ColSpan = [4 4];
  mass_popup.Entries = {'kg', 'g', 'mg', 'slug', 'lbm'};
  
   % inertia widget
  inertia.Name = 'Inertia';
  inertia.Type = 'edit';
  inertia.ObjectProperty = 'stringProp';
  inertia.Mode = 1;
  inertia.RowSpan = [1 1];
  inertia.ColSpan = [5 8];
  
   % inertia_popup widget
  inertia_popup.Tag = 'inertia'; 
  inertia_popup.Name = 'prompt';
  inertia_popup.Type = 'combobox';
  inertia_popup.RowSpan = [1 1];
  inertia_popup.ColSpan = [9 10];
  inertia_popup.ObjectProperty = 'radioProp2';
  inertia_popup.Entries = {'kg*m^s', 'g*cm^2', 'slug*ft^2', 'slug*in^2', 'lbm*ft^2', 'lbm*in^2' }; 
  inertia_popup.Values = [1 2 4 8 16 32];
  inertia_popup.ToolTip = 'bla2';
  
   % label widget
  
  label.Name = '* with respect to the CG (Center of Gravity) Body Coordinate system';
  label.RowSpan = [2 2];
  label.ColSpan = [4 9];
  label.Type = 'text';
  
  %%%%%%%%%%%%%%%%%%%%%%
  % bodycoord items
  %%%%%%%%%%%%%%%%%%%%%%
  tab_cont.Name = 'tabcont';
  tab_cont.Type = 'tab';
  tab_cont.Tabs = {tab1, tab2, tab3};
  
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Top level containers
  %%%%%%%%%%%%%%%%%%%%0%%%%%%%
  
  % Description container
  description.Type    = 'group';
  description.Name    = 'Groupbox with flat border';
  description.Flat    = true;
  description.Items   = {desc};
  description.ToolTip = 'my container';
  if h.checkProp == 1
    description.Visible = 0;
  else
    descriptino.Visible = 1;
  end
  % massprop container
  massprop.Type = 'group';
  massprop.Name = 'Mass properties';
  massprop.LayoutGrid = [2 10];
  massprop.Items = {mass, mass_popup, inertia, inertia_popup, label};
  
  % bodycoord container
  bodycoord.Type = 'group';
  bodycoord.Name = 'Body coordinate systems';
  bodycoord.Items = {tab_cont}; 
  
  %%%%%%%%%%%%%%%%%%%%%%%
  % Main dialog
  %%%%%%%%%%%%%%%%%%%%%%%
  dlgstruct.DialogTitle = 'Block parameters: Gain';
  dlgstruct.HelpMethod = 'doc';
  dlgstruct.HelpArgs =  {'eig'};
  dlgstruct.Items = {description, massprop, bodycoord};