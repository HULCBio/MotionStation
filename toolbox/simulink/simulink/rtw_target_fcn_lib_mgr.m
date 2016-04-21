function obj = rtw_target_fcn_lib_mgr(method,varargin)
%RTW_TARGET_FCN_LIB_MGR - Manage the loading and retrieval of RTW target
%function libraries This function globally manages all instances of the
%Simulink.RtwFcnLib class so that each file is only loaded into memory once.

% Copyright 2003 The MathWorks, Inc.

    persistent AllTargetFcnLibs;

    switch(method)
    case 'load'
        fileName = varargin{1};
        % First check if the library is already loaded
        if isempty(AllTargetFcnLibs)
            obj = [];
        else
            obj =  find(AllTargetFcnLibs,'matFileName',fileName);
        end
        if isempty(obj)
            struct = load(fileName);
            obj = struct.hRtwFcnLib;
            rtw_target_fcn_lib_mgr('store',obj,obj.matFileName);
        end

    case 'clear'
        fileName = varargin{1};
        if ~isempty(AllTargetFcnLibs)
            obj =  find(AllTargetFcnLibs,'matFileName',fileName);
        end
        if ~isempty(obj)
            idx = find(AllTargetFcnLibs==obj);
            AllTargetFcnLibs(idx) = [];
        end
        
     case 'store'
        % we want to prevent multiple inclusions of the same source matfile for
        % different objects.  If we don't, then the 'load' call above could
        % potentially return an array of objects, instead of just one.
        fileName = varargin{2};
        if isempty(AllTargetFcnLibs)
            obj = [];
        else
            obj =  find(AllTargetFcnLibs,'matFileName',fileName);
        end
        if isempty(obj)
          AllTargetFcnLibs = [AllTargetFcnLibs varargin{1}];
        end
        obj = [];

    otherwise,
        error(['Unkown method: ' method]);
    end


