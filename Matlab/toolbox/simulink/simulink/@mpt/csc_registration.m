function defs = csc_registration(action)
% CSC_REGISTRATION Register custom storage classes.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $   $Date: 2004/04/15 00:44:06 $

try
    switch action
        case 'CSCDefn'
            defs = [];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'Global');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', true);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource','Default'); %'Specify' for Specifying Decl/defn/type comment
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');  %Specify Declare comment for this CSC
            set(h, 'DefineComment', '');   %Specify Define comment for this CSC
            set(h, 'CSCTypeAttributesClassName', 'mpt.CSCTypeAttributes_Unstructed');
            set(h.CSCTypeAttributes, 'Owner', '');
            set(h.CSCTypeAttributes, 'IsOwnerInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'DefinitionFile', '');
            set(h.CSCTypeAttributes, 'IsDefinitionFileInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'PersistenceLevel', int32(1));
            set(h.CSCTypeAttributes, 'IsPersistenceLevelInstanceSpecific', true);
            set(h, 'TLCFileName', 'MPTUnstructured.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'BitField');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', true);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', false);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'Simulink.CSCTypeAttributes_FlatStructure');
            set(h.CSCTypeAttributes, 'StructName', '');
            set(h.CSCTypeAttributes, 'IsStructNameInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'BitPackBoolean', true);
            set(h.CSCTypeAttributes, 'IsTypeDef', true);
            set(h.CSCTypeAttributes, 'TypeName', '');
            set(h.CSCTypeAttributes, 'TypeToken', '');
            set(h.CSCTypeAttributes, 'TypeTag', '');
            set(h, 'TLCFileName', 'MPTFlatStructure.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'Const');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'MemConst');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', false);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'mpt.CSCTypeAttributes_Unstructed');
            set(h.CSCTypeAttributes, 'Owner', '');
            set(h.CSCTypeAttributes, 'IsOwnerInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'DefinitionFile', '');
            set(h.CSCTypeAttributes, 'IsDefinitionFileInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'PersistenceLevel', int32(1));
            set(h.CSCTypeAttributes, 'IsPersistenceLevelInstanceSpecific', true);
            set(h, 'TLCFileName', 'MPTUnstructured.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'Volatile');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'MemVolatile');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'mpt.CSCTypeAttributes_Unstructed');
            set(h.CSCTypeAttributes, 'Owner', '');
            set(h.CSCTypeAttributes, 'IsOwnerInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'DefinitionFile', '');
            set(h.CSCTypeAttributes, 'IsDefinitionFileInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'PersistenceLevel', int32(1));
            set(h.CSCTypeAttributes, 'IsPersistenceLevelInstanceSpecific', true);
            set(h, 'TLCFileName', 'MPTUnstructured.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'ConstVolatile');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'MemConstVolatile');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', false);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'mpt.CSCTypeAttributes_Unstructed');
            set(h.CSCTypeAttributes, 'Owner', '');
            set(h.CSCTypeAttributes, 'IsOwnerInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'DefinitionFile', '');
            set(h.CSCTypeAttributes, 'IsDefinitionFileInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'PersistenceLevel', int32(1));
            set(h.CSCTypeAttributes, 'IsPersistenceLevelInstanceSpecific', true);
            set(h, 'TLCFileName', 'MPTUnstructured.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'Define');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', false);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Macro');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'mpt.CSCTypeAttributes_Unstructed');
            set(h.CSCTypeAttributes, 'Owner', '');
            set(h.CSCTypeAttributes, 'IsOwnerInstanceSpecific', false);
            set(h.CSCTypeAttributes, 'DefinitionFile', '');
            set(h.CSCTypeAttributes, 'IsDefinitionFileInstanceSpecific', false);
            set(h.CSCTypeAttributes, 'PersistenceLevel', int32(1));
            set(h.CSCTypeAttributes, 'IsPersistenceLevelInstanceSpecific', false);
            set(h, 'TLCFileName', 'MPTUnstructured.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'ExportToFile');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', true);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'mpt.CSCTypeAttributes_Unstructed');
            set(h.CSCTypeAttributes, 'Owner', '');
            set(h.CSCTypeAttributes, 'IsOwnerInstanceSpecific', false);
            set(h.CSCTypeAttributes, 'DefinitionFile', '');
            set(h.CSCTypeAttributes, 'IsDefinitionFileInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'PersistenceLevel', int32(1));
            set(h.CSCTypeAttributes, 'IsPersistenceLevelInstanceSpecific', false);
            set(h, 'TLCFileName', 'MPTUnstructured.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'ImportFromFile');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Unstructured');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Imported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'None');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', true);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', '');
            set(h, 'TLCFileName', 'Unstructured.tlc');

            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'Struct');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', true);
            set(h.DataUsage, 'IsParameter', true);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Exported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'Static');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', false);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'Simulink.CSCTypeAttributes_FlatStructure');
            set(h.CSCTypeAttributes, 'StructName', '');
            set(h.CSCTypeAttributes, 'IsStructNameInstanceSpecific', true);
            set(h.CSCTypeAttributes, 'BitPackBoolean', false);
            set(h.CSCTypeAttributes, 'IsTypeDef', true);
            set(h.CSCTypeAttributes, 'TypeName', '');
            set(h.CSCTypeAttributes, 'TypeToken', '');
            set(h.CSCTypeAttributes, 'TypeTag', '');
            set(h, 'TLCFileName', 'MPTFlatStructure.tlc');
            defs = [defs; h];

            h = Simulink.CSCDefn;
            set(h, 'Name', 'GetSet');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'CSCType', 'Other');
            set(h, 'MemorySection', 'Default');
            set(h, 'IsMemorySectionInstanceSpecific', false);
            set(h, 'IsGrouped', false);
            set(h.DataUsage, 'IsParameter', false);
            set(h.DataUsage, 'IsSignal', true);
            set(h, 'DataScope', 'Imported');
            set(h, 'IsDataScopeInstanceSpecific', false);
            set(h, 'DataInit', 'None');
            set(h, 'IsDataInitInstanceSpecific', false);
            set(h, 'DataAccess', 'Direct');
            set(h, 'IsDataAccessInstanceSpecific', false);
            set(h, 'HeaderFile', '');
            set(h, 'IsHeaderFileInstanceSpecific', true);
            set(h, 'CommentSource', 'Default');
            set(h, 'TypeComment', '');
            set(h, 'DeclareComment', '');
            set(h, 'DefineComment', '');
            set(h, 'CSCTypeAttributesClassName', 'Simulink.CSCTypeAttributes_GetSet');
            set(h.CSCTypeAttributes, 'GetFunction', '');
            set(h.CSCTypeAttributes, 'SetFunction', '');
            set(h, 'TLCFileName', 'MPTGetSet.tlc');
            defs = [defs; h];

            if exist('custom_csc_registration') == 2
                cusDefs = custom_csc_registration(action);
                for i = 1:length(cusDefs)
                    defs = [defs; cusDefs(i)];
                end
            end

        case 'MemorySectionDefn'
            defs = [];

            h = Simulink.MemorySectionDefn;
            set(h, 'Name', 'MemConst');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'Comment', '');
            set(h, 'PrePragma', '');
            set(h, 'PostPragma', '');
            set(h, 'IsConst', true);
            set(h, 'IsVolatile', false);
            set(h, 'Qualifier', '');
            defs = [defs; h];

            h = Simulink.MemorySectionDefn;
            set(h, 'Name', 'MemVolatile');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'Comment', '');
            set(h, 'PrePragma', '');
            set(h, 'PostPragma', '');
            set(h, 'IsConst', false);
            set(h, 'IsVolatile', true);
            set(h, 'Qualifier', '');
            defs = [defs; h];

            h = Simulink.MemorySectionDefn;
            set(h, 'Name', 'MemConstVolatile');
            set(h, 'OwnerPackage', 'mpt');
            set(h, 'Comment', '');
            set(h, 'PrePragma', '');
            set(h, 'PostPragma', '');
            set(h, 'IsConst', true);
            set(h, 'IsVolatile', true);
            set(h, 'Qualifier', '');
            defs = [defs; h];

            if exist('custom_csc_registration') == 2
                cusDefs = custom_csc_registration(action);
                for i = 1:length(cusDefs)
                    defs = [defs; cusDefs(i)];
                end
            end

        otherwise
            error('Invalid action in custom storage class registration');
    end  % switch action
catch
    cr = sprintf('\n');
    errMsg = ['Bad custom storage class registration file: ', cr, '  ',pwd,...
        filesep,'csc_registration.m',cr,lasterr];
    error(errMsg);
end
%EOF
