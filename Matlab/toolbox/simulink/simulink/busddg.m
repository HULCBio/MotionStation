function dlgstruct = busddg(h, name)
  
    %-----------------------------------------------------------------------
    % First Row contains:
    % - elements groupbox with
    % - elements table widget
    %-----------------------------------------------------------------------  

    tableData = {};
    if ~isempty(h.Elements)
      tableData = cell(length(h.Elements), 5);
      for i=1:length(h.Elements)
        val = h.Elements(i);
        tableData{i, 1} = val.Name;

        if ~isscalar(val.Dimensions)
          dim = sprintf('[%d %d]', val.Dimensions(1), val.Dimensions(2));
        else
          dim = num2str(val.Dimensions);
        end
        tableData{i, 2} = dim;
        tableData{i, 3} = val.DataType;

        if ~isscalar(val.SampleTime)
          sam = sprintf('[%d %d]', val.SampleTime(1), val.SampleTime(2));
        else
          sam = num2str(val.SampleTime);
        end
        tableData{i, 4} = sam;

        tableData{i, 5} = val.Complexity;
        tableData{i, 6} = val.SamplingMode;
      end
    end

    bustable.Type = 'table';
    bustable.TableSize = [length(h.Elements) 6];
    bustable.TableGrid = 1;
    bustable.TableHeaderVisibility = [0 1];
    bustable.TableColHeader = {'Name', 'Dimension', 'Data/Bus Type', 'Sample Time', ...
                               'Complexity', 'Sampling Mode'};
    bustable.TableData = tableData;

    elementsgrp.Name = 'Bus elements (read only)';
    elementsgrp.RowSpan = [1 1];
    elementsgrp.ColSpan = [1 3];
    elementsgrp.Type = 'group';
    elementsgrp.Flat = 1;
    elementsgrp.Items = {bustable};
     
  
  %-----------------------------------------------------------------------
  % Second  Row contains:
  % - headerFile label widget
  % - headerFile edit field widget
  %-----------------------------------------------------------------------
  headerFileLbl.Name = 'Header file:';
  headerFileLbl.Type = 'text';
  headerFileLbl.RowSpan = [2 2];
  headerFileLbl.ColSpan = [1 1];
  
  headerFile.Name = '';
  headerFile.RowSpan = [2 2];
  headerFile.ColSpan = [2 3];
  headerFile.Type = 'edit';
  headerFile.Tag = 'headerFile_tag';
  headerFile.ObjectProperty = 'HeaderFile';
  
  %-----------------------------------------------------------------------
  % Third Row contains:
  % - Description editarea widget
  %----------------------------------------------------------------------- 
  description.Name           = 'Description:';
  description.Type           = 'editarea';
  description.RowSpan        = [3 3];
  description.ColSpan        = [1 3];
  description.Tag            = 'description_tag';
  description.ObjectProperty = 'Description';  
  
  %-----------------------------------------------------------------------
  % Fourth Row contains:
  % - Launch buseditor button
  %----------------------------------------------------------------------- 
  editorbtn.Name = 'Launch Bus Editor';
  editorbtn.Type = 'pushbutton';
  editorbtn.MatlabMethod = 'buseditor';
  editorbtn.MatlabArgs = {'Create', name};
  editorbtn.RowSpan = [4 4];
  editorbtn.ColSpan = [3 3];
   
  %-----------------------------------------------------------------------
  % Assemble main dialog struct
  %-----------------------------------------------------------------------  
  dlgstruct.DialogTitle = ['Simulink.Bus: ', name];
  dlgstruct.LayoutGrid  = [4 3];
  dlgstruct.RowStretch  = [0 0 1 0];
  dlgstruct.ColStretch  = [0 1 0];
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs   = {[docroot, '/mapfiles/simulink.map'], 'simulink_bus'};

  dlgstruct.Items = {elementsgrp, ...
                       headerFileLbl, headerFile, ...
                       description, editorbtn};
                   
