function [oHadErr, oErrMsg] = compare_configuration_sets(iTopMdl, iTopCS, ...
                                                  iChildMdl, iChildCS, iTargetType)
%
% Abstract
%   Given two models and configuration sets, compare the sets and return an
%   error if they are not compatible.
%
% Syntax
%
%   [oHadErr, oErrMsg] = compare_configuration_sets(iTopMdl, iTopCS,
%                                             iChildMdl, iChildCS, iTargetType)
%
% Inputs
%
%   iTopMdl   :  (string) The name of the topmost model.
%   iTopCS    :  (Simulink.Configset)  The configuration set of the top model.
%   iChildMdl :  (string) The name of the child model reference block.
%   iChildCS  :  (Simulink.Configset) The configuration set of the child.
%   iTargetType : ('SIM', 'RTW') The type of model reference target.
%
% Output
%   oHadErr:   (bool)   true if there have been any errors, false otherwise.
%   oErrMsg:   (string) string explaining what the error is, if oHadErr = true
%
% Notes:
%   1.  If you update this file, please add/modify the tests in
%   simulink/modelref/tcompareconfigsets.m.
%

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $


  oHadErr = false;
  oErrMsg = '';

  if strcmpi(iTargetType,'SIM')
    % In the current (R14) config set comparison mechanism, we compare the
    % relevant parent/child prop values in the mdlStart function for the model
    % reference SIM target. Hence we should not be calling this function
    % during the code generation process.
    oHadErr = true;
    oErrMsg = [mfilename, ' should not be called for SIM target'];
    return;
  end

  incompat = {};
  errors = [];


  % Verify that the configuration sets are "compatible"
  [oHadErr, oErrMsg, components] = loc_check_config_sets(iTopMdl, iTopCS, ...
                                                    iChildMdl, iChildCS);
  if oHadErr
    return;
  end

  % Calculate all the differences between the configuration sets
  [oHadErr, errors, oErrMsg] = loc_compare_config_sets(iTopMdl, iTopCS, ...
                                                    iChildMdl, iChildCS, ...
                                                    components);
  if oHadErr && ~isempty(oErrMsg)
    return;
  end

  % Combine all the error messages into one.
  reportStateLoggingErr = false;
  stateTopVal = '';
  stateChildVal = '';
  if oHadErr
    tab = sprintf('    ');
    oErrMsg = ['The following  Configuration parameter option(s) do not ' ...
               'match between ', iTopMdl, ' and ', iChildMdl, ' models:', cr];
    for i = 1:length(errors)
      for j = 1:length(errors(i).Incompatibilities)
        err = errors(i).Incompatibilities{j};
        
        property =  err.property;
        if strcmp(property,'RTWCAPIStates')
          reportStateLoggingErr = true;
          stateTopVal = err.topValue;
          stateChildVal = err.childValue;
          continue;
        end
        
        UIInfo = slCSProp2UI(iTopCS, [], property);

        if j == 1
          if ~isempty(UIInfo) && ~isempty(UIInfo.Path)
            oErrMsg = [oErrMsg, tab, UIInfo.Path(2:end), cr];
          else
            oErrMsg = [oErrMsg, tab, errors(i).Component, cr];
          end
        end

        oErrMsg = [oErrMsg, tab,tab,'- ', property, ' (', err.topValue, ...
                  ' != ', err.childValue, ')', cr];

        if ~isempty(UIInfo) && ~isempty(UIInfo.Prompt)
          msg = [tab, tab, '  ', property, ' is mapped to ''', UIInfo.Prompt, ''''];
          oErrMsg = [oErrMsg, msg, cr];
        end
      end
    end
    
    if reportStateLoggingErr
      errmsg = ['The state logging option (',...
                stateTopVal, ' != ',stateChildVal, ') '...
                'which is computed as: ',...
                '(SaveState or SaveFinalState) and MatFileLogging'];
      oErrMsg = [oErrMsg, tab, errmsg, cr];

      UIInfo = slCSProp2UI(iTopCS, [], 'SaveState');
      oErrMsg = [oErrMsg, tab,tab,'- SaveState is mapped to ''', ...
                 UIInfo.Prompt,''' on ''',UIInfo.Path(2:end),'''',cr];
      
      UIInfo = slCSProp2UI(iTopCS, [], 'SaveFinalState');
      oErrMsg = [oErrMsg, tab,tab,'- SaveFinalState is mapped to ''', ...
                 UIInfo.Prompt,''' on ''',UIInfo.Path(2:end),'''',cr];
      
      UIInfo = slCSProp2UI(iTopCS, [], 'MatFileLogging');
      if ~isempty(UIInfo) && ~isempty(UIInfo.Prompt)
        oErrMsg = [oErrMsg, tab,tab,'- MatFileLogging is mapped to ''', ...
                   UIInfo.Prompt,''' on ''',UIInfo.Path(2:end),'''',cr];
      end
      
    end
    
  end

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the information needed in the error message.
function oErrInfo = loc_create_error_info(property, valueA, valueB)

  oErrInfo.property = property;
  oErrInfo.topValue = num2str(valueA);
  oErrInfo.childValue = num2str(valueB);

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through the components to determine if they have the same number of
% subcomponents and create a list of components to compare.  The return value
% oComponents is a structure of the form:
%         oComponents.Name          - name of the components
%         oComponents.SubComponents - contains info on any subcomponents
%
% This structure is recursive, so each level in the SubComponents looks
% like its parent.
function [oHadErr, oErrMsg, oComponents] = loc_check_config_sets(iTopMdl, ...
                                                    iTopCS, iChildMdl, iChildCS)

  oComponents = {};
  oHadErr     = false;
  oErrMsg     = '';

  numTopComp = length(iTopCS.Components);
  numChildComp = length(iChildCS.Components);

  % Figure out which component has more subcomponents
  if (numTopComp >= numChildComp)
    numComponents = numTopComp;
    largeCS  = iTopCS;
    largeMdl = iTopMdl;
    smallCS  = iChildCS;
    smallMdl = iChildMdl;
  else
    numComponents = numChildComp;
    largeCS  = iChildCS;
    largeMdl = iChildMdl;
    smallCS  = iTopCS;
    smallMdl = iTopMdl;
  end

  % Loop over all the components in the CS that has the most components
  % and check if that component exists in the submodel.  If it does not
  % error out for all components except Stateflow.
  for i = 1:numComponents
    largeComp = largeCS.Components(i);
    largeName = largeComp.Name;
    smallComp = smallCS.getComponent(largeName);

    component.Name = '';
    component.subComponents = [];

    % If the smaller config set does not have the component,
    % then it will be empty.
    if isempty(smallComp)
      switch (largeName)
       case 'Stateflow'
        %% Add any components for which we know know that it
        %% is ok for a model in the hierarchy to not have.

       otherwise
        oHadErr = true;
        oErrMsg = [oErrMsg, 'The component "', largeComp.getFullName, ...
                   '" of the model "', largeMdl, ...
                   '" does not exist for the model "', smallMdl, ...
                   '"', cr, cr];
      end

      continue;
    end

    component.Name = largeName;

    % If there are any subcomponents in either the child or
    % parent, then we must check them also.
    if ~isempty(largeComp.Components) || ~isempty(smallComp.Components)
      [hadErr, errmsg, comp] = loc_check_config_sets(largeMdl, largeComp, ...
                                                      smallMdl, smallComp);
      if hadErr
        oHadErr = true;
        oErrMsg = [oErrMsg, errmsg, cr, cr];
      end

      component.subComponents = comp;
    end

    oComponents{end+1} = component;
  end

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over the common components of the two config sets and report
% any differences.  If there are differences between the two config sets,
% then they will be returned in oErrStruct.  If there is a hard error during
% the comparison such as when the components are not compatible, then
% that message is returned in oHardErrMsg.
function [oHadErr, oErrStruct, oHardErrMsg] = ...
      loc_compare_config_sets(iTopMdl, iTopCS, iChildMdl, iChildCS, iComponents)

  oHadErr     = false;
  oErrStruct  = [];
  oHardErrMsg = '';

  for i = 1:length(iComponents)
    try
      compName  = iComponents{i}.Name;
      topComp   = iTopCS.getComponent(compName);
      childComp = iChildCS.getComponent(compName);
      incompat  = {};

      % Compare the top component with the child component
      diff = topComp.compareComponentWithChild(childComp);

      % Loop over all the differences and store away information
      % that is used in the error message.
      for errIdx = 1:length(diff)
        oHadErr = true;
        valueA = get(topComp, diff{errIdx});
        valueB = get(childComp, diff{errIdx});
        incompat{end+1} = loc_create_error_info(diff{errIdx},valueA, valueB);
      end

      if ~isempty(incompat)
        oErrStruct(end+1).Component       = compName;
        oErrStruct(end).Incompatibilities = incompat;
      end

      % If there are any subcomponents, recurse
      if ~isempty(iComponents{i}.subComponents)
        subComp = iComponents{i}.subComponents;

        [hadErr, errStruct, oHardErrMsg] = ...
            loc_compare_config_sets(iTopMdl, topComp, iChildMdl, ...
                                    childComp, subComp);
        if hadErr
          oHadErr = true;
          if ~isempty(oHardErrMsg)
            return;
          end
          oErrStruct = [oErrStruct, errStruct];
        end
      end
    catch
      oHadErr = true;
      errMsg = lasterr;
      oHardErrMsg = ['Configuration component "', topComp.getFullName,...
                 '"  of ', iTopMdl, ' and configuration component "', ...
                     childComp.getFullName, '" of ', iChildMdl, ...
                     ' are not compatible.  The error message returned by ', ...
                    'the comparison function is:', cr, errMsg];
      return;
    end
  end

%endfunction
