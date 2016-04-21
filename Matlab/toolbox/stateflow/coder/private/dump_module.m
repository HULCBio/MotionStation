function file = dump_module(fileName,file,objectId,location)

   switch(location)
   case 'source'
      isSource = 1;
   case 'header'
      isSource = 0;
   otherwise,
      error('why');
   end
   
   fclose(file);
   sf('Cg','dump_module',fileName,objectId,isSource);
   file = fopen(fileName,'at');
   if file<3
       construct_coder_error([],sprintf('Failed to create file: %s.',fileName),1);
       return;
   end             
   return;  
   
fprintf(file,'\n');
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Types
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(file,'/* Type Definitions */      \n');
   types = sf('Cg','get_types',objectId);
   for type = types
         codeStr = sf('Cg','get_type_def',type,isSource);
fprintf(file,'   %s         \n',codeStr);
   end   
fprintf(file,'\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% Named Constants 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'/* Named Constants */   \n');
   namedConsts = sf('Cg','get_named_consts',objectId);
   for namedConst = namedConsts
         codeStr = sf('Cg','get_named_const_def',namedConst,isSource);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
   end
fprintf(file,'\n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% Var Declarations
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'/* Variable Declarations */   \n');
   vars = sf('Cg','get_vars',objectId);
   for var = vars
         codeStr = sf('Cg','get_var_decl',var,isSource);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
   end
fprintf(file,' \n');

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% Var Definitions
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'/* Variable Definitions */   \n');
   vars = sf('Cg','get_vars',objectId);
   for var = vars
         codeStr = sf('Cg','get_var_def',var,isSource);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
   end
fprintf(file,' \n');
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% function Declarations
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'/* Function Declarations */   \n');
   funcs = sf('Cg','get_functions',objectId);
   for func = funcs
         codeStr = sf('Cg','get_fcn_decl',func,isSource);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
   end
fprintf(file,'\n');


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%% function Definitions
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fprintf(file,'/* Function Definitions */   \n');
   funcs = sf('Cg','get_functions',objectId);
   for func = funcs
         codeStr = sf('Cg','get_fcn_def',func,isSource);
fprintf(file,'   %s         \n',strip_trailing_new_lines(codeStr));
   end
fprintf(file,'\n');

