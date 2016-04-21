/*=================================================================
 * The main routine analyzes all incoming (right-hand side) arguments 
 *
 * Copyright 1984-2000 The MathWorks, Inc.
 * $Revision: 1.14 $ 
 *	
 *=================================================================*/
#include <stdio.h>
#include <string.h>
#include "mex.h"
 

void        display_subscript(const mxArray *array_ptr, int index);
void        get_characteristics(const mxArray  *array_ptr);
mxClassID   analyze_class(const mxArray *array_ptr);


/* Pass analyze_cell a pointer to a cell mxArray.  Each element
   in a cell mxArray is called a "cell"; each cell holds zero
   or one mxArray.  analyze_cell accesses each cell and displays
   information about it. */  
static void
analyze_cell(const mxArray *cell_array_ptr)
{
  int       total_num_of_cells;
  int       index;
  const mxArray *cell_element_ptr;
  
  total_num_of_cells = mxGetNumberOfElements(cell_array_ptr); 
  mexPrintf("total num of cells = %d\n", total_num_of_cells);
  mexPrintf("\n");

  /* Each cell mxArray contains m-by-n cells; Each of these cells
     is an mxArray. */ 
  for (index=0; index<total_num_of_cells; index++)  {
    mexPrintf("\n\n\t\tCell Element: ");
    display_subscript(cell_array_ptr, index);
    mexPrintf("\n");
    cell_element_ptr = mxGetCell(cell_array_ptr, index);
    if (cell_element_ptr == NULL) 
      mexPrintf("\tEmpty Cell\n");
    else {
      /* Display a top banner. */
      mexPrintf("------------------------------------------------\n");
      get_characteristics(cell_element_ptr);
      analyze_class(cell_element_ptr);
      mexPrintf("\n");
    }
  }
  mexPrintf("\n");
}


/* Pass analyze_structure a pointer to a structure mxArray.  Each element
   in a structure mxArray holds one or more fields; each field holds zero
   or one mxArray.  analyze_structure accesses every field of every
   element and displays information about it. */ 
static void
analyze_structure(const mxArray *structure_array_ptr)
{
  int          total_num_of_elements, number_of_fields, index, field_index;
  const char  *field_name;
  const mxArray     *field_array_ptr;
  

  mexPrintf("\n");
  total_num_of_elements = mxGetNumberOfElements(structure_array_ptr); 
  number_of_fields = mxGetNumberOfFields(structure_array_ptr);
  
  /* Walk through each structure element. */
  for (index=0; index<total_num_of_elements; index++)  {
    
    /* For the given index, walk through each field. */ 
    for (field_index=0; field_index<number_of_fields; field_index++)  {
      mexPrintf("\n\t\t");
      display_subscript(structure_array_ptr, index);
         field_name = mxGetFieldNameByNumber(structure_array_ptr, 
                                             field_index);
      mexPrintf(".%s\n", field_name);
      field_array_ptr = mxGetFieldByNumber(structure_array_ptr, 
					   index, 
					   field_index);
      if (field_array_ptr == NULL)
	mexPrintf("\tEmpty Field\n");
      else {
	/* Display a top banner. */
	mexPrintf("------------------------------------------------\n");
	get_characteristics(field_array_ptr);
	analyze_class(field_array_ptr);
	mexPrintf("\n");
      }
    }
      mexPrintf("\n\n");
  }
  
  
}


/* Pass analyze_string a pointer to a char mxArray.  Each element
   in a char mxArray holds one 2-byte character (an mxChar); 
   analyze_string displays the contents of the input char mxArray
   one row at a time.  Since adjoining row elements are NOT stored in 
   successive indices, analyze_string has to do a bit of math to
   figure out where the next letter in a string is stored. */ 
static void
analyze_string(const mxArray *string_array_ptr)
{
  char *buf;
  int   number_of_dimensions; 
  const int  *dims;
  int   buflen, d, page, total_number_of_pages, elements_per_page;
  
  /* Allocate enough memory to hold the converted string. */ 
  buflen = mxGetNumberOfElements(string_array_ptr) + 1;
  buf = mxCalloc(buflen, sizeof(char));
  
  /* Copy the string data from string_array_ptr and place it into buf. */ 
  if (mxGetString(string_array_ptr, buf, buflen) != 0)
    mexErrMsgTxt("Could not convert string data.");
  
  /* Get the shape of the input mxArray. */
  dims = mxGetDimensions(string_array_ptr);
  number_of_dimensions = mxGetNumberOfDimensions(string_array_ptr);
  
  elements_per_page = dims[0] * dims[1];
  /* total_number_of_pages = dims[2] x dims[3] x ... x dims[N-1] */ 
  total_number_of_pages = 1;
  for (d=2; d<number_of_dimensions; d++) 
    total_number_of_pages *= dims[d];
  
  for (page=0; page < total_number_of_pages; page++) {
    int row;
    /* On each page, walk through each row. */ 
    for (row=0; row<dims[0]; row++)  {
      int column;     
      int index = (page * elements_per_page) + row;
      mexPrintf("\t");
      display_subscript(string_array_ptr, index);
      mexPrintf(" ");
      
      /* Walk along each column in the current row. */ 
      for (column=0; column<dims[1]; column++) {
	mexPrintf("%c",buf[index]);
	index += dims[0];
      }
      mexPrintf("\n");

    }
    
  } 
}




/* Pass analyze_sparse a pointer to a sparse mxArray.  A sparse mxArray
   only stores its nonzero elements.  The values of the nonzero elements 
   are stored in the pr and pi arrays.  The tricky part of analyzing
   sparse mxArray's is figuring out the indices where the nonzero
   elements are stored.  (See the mxSetIr and mxSetJc reference pages
   for details. */  
static void
analyze_sparse(const mxArray *array_ptr)
{
  double  *pr, *pi;
  int     *ir, *jc;
  int      col, total=0;
  int      starting_row_index, stopping_row_index, current_row_index;
  int      n;
  
  /* Get the starting positions of all four data arrays. */ 
  pr = mxGetPr(array_ptr);
  pi = mxGetPi(array_ptr);
  ir = mxGetIr(array_ptr);
  jc = mxGetJc(array_ptr);
  
  /* Display the nonzero elements of the sparse array. */ 
  n = mxGetN(array_ptr);
  for (col=0; col<n; col++)  { 
    starting_row_index = jc[col]; 
    stopping_row_index = jc[col+1]; 
    if (starting_row_index == stopping_row_index)
      continue;
    else {
      for (current_row_index = starting_row_index; 
	   current_row_index < stopping_row_index; 
	   current_row_index++)  {
	if (mxIsComplex(array_ptr))  {
	  mexPrintf("\t(%d,%d) = %g+%g i\n", ir[current_row_index]+1, 
		    col+1, pr[total], pi[total++]);
	}
	else
	  mexPrintf("\t(%d,%d) = %g\n", ir[current_row_index]+1, 
		    col+1, pr[total++]);
      }
    }
  }
}

static void
analyze_int8(const mxArray *array_ptr)
{
  signed char   *pr, *pi; 
  char    total_num_of_elements, index; 
  
  pr = (signed char *)mxGetData(array_ptr);
  pi = (signed char *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %d + %di\n", *pr++, *pi++); 
    else
      mexPrintf(" = %d\n", *pr++);
  } 
}


static void
analyze_uint8(const mxArray *array_ptr)
{
  unsigned char   *pr, *pi; 
  int    total_num_of_elements, index; 
  
  pr = (unsigned char *)mxGetData(array_ptr);
  pi = (unsigned char *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %u + %ui\n", *pr, *pi++); 
    else
      mexPrintf(" = %u\n", *pr++);
  } 
}


static void
analyze_int16(const mxArray *array_ptr)
{
  short int   *pr, *pi; 
  short int    total_num_of_elements, index; 
  
  pr = (short int *)mxGetData(array_ptr);
  pi = (short int *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %d + %di\n", *pr++, *pi++); 
    else
      mexPrintf(" = %d\n", *pr++);
  } 
}


static void
analyze_uint16(const mxArray *array_ptr)
{
  unsigned short int   *pr, *pi; 
  int    total_num_of_elements, index; 
  
  pr = (unsigned short int *)mxGetData(array_ptr);
  pi = (unsigned short int *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %u + %ui\n", *pr++, *pi++); 
    else
      mexPrintf(" = %u\n", *pr++);
  } 
}



static void
analyze_int32(const mxArray *array_ptr)
{
  int   *pr, *pi; 
  int    total_num_of_elements, index; 
  
  pr = (int *)mxGetData(array_ptr);
  pi = (int *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %d + %di\n", *pr++, *pi++); 
    else
      mexPrintf(" = %d\n", *pr++);
  } 
}


static void
analyze_uint32(const mxArray *array_ptr)
{
  unsigned int   *pr, *pi; 
  int    total_num_of_elements, index; 
  
  pr = (unsigned int *)mxGetData(array_ptr);
  pi = (unsigned int *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %u + %ui\n", *pr++, *pi++); 
    else
      mexPrintf(" = %u\n", *pr++);
  } 
}


static void
analyze_single(const mxArray *array_ptr)
{
  float *pr, *pi; 
  int    total_num_of_elements, index; 
  
  pr = (float *)mxGetData(array_ptr);
  pi = (float *)mxGetImagData(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %g + %gi\n", *pr++, *pi++); 
    else
      mexPrintf(" = %g\n", *pr++);
  } 
}


static void
analyze_double(const mxArray *array_ptr)
{
  double *pr, *pi; 
  int     total_num_of_elements, index; 
  
  pr = mxGetPr(array_ptr);
  pi = mxGetPi(array_ptr);
  total_num_of_elements = mxGetNumberOfElements(array_ptr);
  
  for (index=0; index<total_num_of_elements; index++)  {
    mexPrintf("\t");
    display_subscript(array_ptr, index);
    if (mxIsComplex(array_ptr)) 
      mexPrintf(" = %g + %gi\n", *pr++, *pi++); 
    else
      mexPrintf(" = %g\n", *pr++);
  } 
}


/* Pass analyze_full a pointer to any kind of numeric mxArray.  
   analyze_full figures out what kind of numeric mxArray this is. */ 
static void
analyze_full(const mxArray *numeric_array_ptr)
{
  mxClassID   category;
  
  category = mxGetClassID(numeric_array_ptr);
  switch (category)  {
     case mxINT8_CLASS:   analyze_int8(numeric_array_ptr);   break; 
     case mxUINT8_CLASS:  analyze_uint8(numeric_array_ptr);  break;
     case mxINT16_CLASS:  analyze_int16(numeric_array_ptr);  break;
     case mxUINT16_CLASS: analyze_uint16(numeric_array_ptr); break;
     case mxINT32_CLASS:  analyze_int32(numeric_array_ptr);  break;
     case mxUINT32_CLASS: analyze_uint32(numeric_array_ptr); break;
     case mxSINGLE_CLASS: analyze_single(numeric_array_ptr); break; 
     case mxDOUBLE_CLASS: analyze_double(numeric_array_ptr); break; 
  }
}


/* Display the subscript associated with the given index. */ 
void
display_subscript(const mxArray *array_ptr, int index)
{
  int     inner, subindex, total, d, q;
  int     number_of_dimensions; 
  int    *subscript;
  const int *dims;
  
  number_of_dimensions = mxGetNumberOfDimensions(array_ptr);
  subscript = mxCalloc(number_of_dimensions, sizeof(int));
  dims = mxGetDimensions(array_ptr); 
  
  mexPrintf("(");
  subindex = index;
  for (d = number_of_dimensions-1; d >= 0; d--)  {
    
    for (total=1, inner=0; inner<d; inner++)  
      total *= dims[inner]; 
    
    subscript[d] = subindex / total;
    subindex = subindex % total; 
  }
  
  for (q=0; q<number_of_dimensions-1; q++) 
    mexPrintf("%d,", subscript[q] + 1);
  mexPrintf("%d)", subscript[number_of_dimensions-1] + 1);
  
  mxFree(subscript);
}



/* get_characteristics figures out the size, and category 
   of the input array_ptr, and then displays all this information. */ 
void
get_characteristics(const mxArray *array_ptr)
{
  const char    *name;
  const char    *class_name;
  const int     *dims;
        char    *shape_string;
	char    *temp_string;
        int      c;
        int      number_of_dimensions; 
        int      length_of_shape_string;

  /* Display the mxArray's Dimensions; for example, 5x7x3.  
     If the mxArray's Dimensions are too long to fit, then just
     display the number of dimensions; for example, 12-D. */ 
  number_of_dimensions = mxGetNumberOfDimensions(array_ptr);
  dims = mxGetDimensions(array_ptr);
  
  /* alloc memory for shape_string w.r.t thrice the number of dimensions */
  /* (so that we can also add the 'x')                                   */
  shape_string=(char *)mxCalloc(number_of_dimensions*3,sizeof(char));
  shape_string[0]='\0';
  temp_string=(char *)mxCalloc(64, sizeof(char));

  for (c=0; c<number_of_dimensions; c++) {
    sprintf(temp_string, "%dx", dims[c]);
    strcat(shape_string, temp_string);
  }

  length_of_shape_string = strlen(shape_string);
  /* replace the last 'x' with a space */
  shape_string[length_of_shape_string-1]='\0';
  if (length_of_shape_string > 16)
    sprintf(shape_string, "%d-D\0", number_of_dimensions); 
  
  mexPrintf("Dimensions: %s\n", shape_string);
  
  /* Display the mxArray's class (category). */
  class_name = mxGetClassName(array_ptr);
  mexPrintf("Class Name: %s%s\n", class_name,
	    mxIsSparse(array_ptr) ? " (sparse)" : "");
  
  /* Display a bottom banner. */
  mexPrintf("------------------------------------------------\n");
  
  /* free up memory for shape_string */
  mxFree(shape_string);
}



/* Determine the category (class) of the input array_ptr, and then
   branch to the appropriate analysis routine. */
mxClassID
analyze_class(const mxArray *array_ptr)
{
    mxClassID  category;
    
    category = mxGetClassID(array_ptr);
    
    if (mxIsSparse(array_ptr)) {
	analyze_sparse(array_ptr);
    } else {
	switch (category) {
	  case mxCHAR_CLASS:    analyze_string(array_ptr);     break;
	  case mxSTRUCT_CLASS:  analyze_structure(array_ptr);  break;
	  case mxCELL_CLASS:    analyze_cell(array_ptr);       break;
	  case mxUNKNOWN_CLASS: mexWarnMsgTxt("Unknown class."); break;
	  default:              analyze_full(array_ptr);       break;
	}
    }
    
    return(category);
}

/* mexFunction is the gateway routine for the MEX-file. */ 
void
mexFunction( int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
{
  int        i;

 /* Look at each input (right-hand-side) argument. */
  for (i=0; i<nrhs; i++)  {
    mexPrintf("\n\n");
    /* Display a top banner. */
    mexPrintf("------------------------------------------------\n");
    /* Display which argument */
    mexPrintf("Name: %s%d%c\n", "prhs[",i,']');     
  
    get_characteristics(prhs[i]);
    analyze_class(prhs[i]);
  }
}

