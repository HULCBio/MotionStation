/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* compare strings to skip Version field */
int compareString(char *string1, char *string2)

{
    int i;

    for (i = 0; i<7; i++)
        {
        if (string1[i] != string2[i])
            {
                return 0;
            }
        }
    return 1;
}

/* return the next valid line without comments */
static char *
#ifdef __STDC__
getNextLine(char *buf, FILE *fp)
#else
getNextLine(buf, fp)
char *buf;
FILE *fp;
#endif
{
    char  *returned_value;
    int i, j;

    returned_value = fgets(buf, STR_LEN, fp);
    if (NULL == returned_value)
        return(NULL);

    /* skip if it starts with '%' or '\n' */
    /* skip if it stars with 'V' to protect against version field
       from writefis.m which was added for Fuzzy Logic 2.0*/
    if ((buf[0] == '%') || (buf[0] == '\n') || compareString("Version",buf) == 1 )
        return(getNextLine(buf, fp));

    /* get rid of trailing comment or new line */
    for (i = 0; buf[i]!='%' && buf[i]!='\n' && i < STR_LEN; i++);
    /*
      printf("%s\n", buf);
      printf("i = %d\n", i);
    */
    for (j = i; j < STR_LEN; j++)
        buf[j] = 0;

    return(returned_value);
}

/* find number x in "******=x" */
static DOUBLE
#ifdef __STDC__
getNumber(char *buf, FILE *fp)
#else
getNumber(buf, fp)
char *buf;
FILE *fp;
#endif
{
	int tmp;
	char string[STR_LEN];
	DOUBLE num;

	if (getNextLine(buf, fp) == NULL)
		fisError("getNumber: Incomplete FIS file!");

	tmp = sscanf(buf, " %[^=] = %lf ", string, &num);
	if (tmp != 2) {
		PRINTF("Error format in FIS file when parsing\n");
		PRINTF("\"%s\"\n", buf);
		fisError("Error in getNumber().");
	}
	/*
	printf("getNumber --> %s%lf\n", string, num);
	printf("getNumber --> %lf\n", num);
	*/
	return(num);
}

/* find string x in "*******='x'" */
static void
#ifdef __STDC__
getString(char *buf, FILE *fp, DOUBLE *array)
#else
getString(buf, fp, array)
char *buf;
FILE *fp;
DOUBLE *array;
#endif
{
	int i;
	char string1[STR_LEN];
	char string2[STR_LEN];
	int tmp;

	if (getNextLine(buf, fp) == NULL)
		fisError("getString: Incomplete FIS file!");
	
	tmp = sscanf(buf, " %[^'] '%[^']' ", string1, string2);
	if (tmp != 2) {
		PRINTF("Error format in FIS file when parsing\n");
		PRINTF("\"%s\"\n", buf);
		fisError("Error in getString().");
	}

	/* copy it to output array */
	for (i = 0; i < (int)strlen(string2); i++)
		array[i] = string2[i];
	/*
	printf("getString --> %s\n", string2);
	*/
}

/* put a string "a b c" to an array [a b c]*/
/* return number of elements */
static int
#ifdef __STDC__
getArray(char *string, DOUBLE *array)
#else
getArray(string, array)
char *string;
DOUBLE *array;
#endif
{
	int i;
	int start, end, index;
	char tmp[STR_LEN];

	start = 0;	/* start of a number */
	end = 0;	/* end of a number */
	index = 0;	/* index of array */
	while (start <= (int)strlen(string)-1) {
		/* find end */
		for (end = start; end < (int)strlen(string); end++)
			if (string[end] == ' ')
				break;
		for (i = start; i <= end; i++)
			tmp[i-start] = string[i]; 
		tmp[i-start] = 0;
		array[index++] = atof(tmp);
		/* find new start */
		for (start = end; start < (int)strlen(string); start++)
			if (string[start] != ' ')
				break;
	}
	/*
	printf("%s\n", string);
	fisPrintArray(array, 8);
	*/
	return(index);
}

static void
#ifdef __STDC__
getMfN(char *filename, int in_n, DOUBLE *in_mf_n, int out_n, DOUBLE *out_mf_n)
#else
getMfN(filename, in_n, in_mf_n, out_n, out_mf_n)
char *filename;
int in_n;
DOUBLE *in_mf_n;
int out_n;
DOUBLE *out_mf_n;
#endif
{
	int i, tmp;
	char buf[STR_LEN];
	FILE *fp = fisOpenFile(filename, "r");

	for (i = 0; i < in_n+out_n; i++) {
		while (1) {
			if (getNextLine(buf, fp) == NULL)
				fisError("Not enough NumMFs in FIS file!");
			if (sscanf(buf, " NumMFs = %d ", &tmp) == 1)
				break;
		}
		if (i < in_n)
			in_mf_n[i] = tmp;
		else
			out_mf_n[i-in_n] = tmp;
	}
	fclose(fp);
	/*
	fisPrintArray(in_mf_n, in_n);
	fisPrintArray(out_mf_n, out_n);
	*/
}

/* return an empty FIS matrix with right size */
static DOUBLE **
#ifdef __STDC__
returnEmptyFismatrix(char *filename, int *row_n_p, int *col_n_p)
#else
returnEmptyFismatrix(filename, row_n_p, col_n_p)
char *filename;
int *row_n_p;
int *col_n_p;
#endif
{
	int in_n, out_n, rule_n, total_in_mf_n, total_out_mf_n;
	int row_n, col_n;
 	char buf[STR_LEN], fisType[STR_LEN];
 	char fisName[STR_LEN], IoName[STR_LEN];
	char tmp1[STR_LEN], tmp2[STR_LEN], tmp3[STR_LEN], tmp4[STR_LEN];
	FILE *fp;
	DOUBLE *in_mf_n;
	DOUBLE *out_mf_n;
	DOUBLE **fismatrix;

	/* find the row_n */
	fp = fisOpenFile(filename, "r");
	/* find in_n */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find NumInputs in FIS file!");
		if (sscanf(buf, " NumInputs = %d ", &in_n) == 1)
			break;
	}
	/* find out_n */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find NumOutputs in FIS file!");
		if (sscanf(buf, " NumOutputs = %d ", &out_n) == 1)
			break;
	}
	/* find rule_n */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find NumRules in FIS file!");
		if (sscanf(buf, " NumRules = %d ", &rule_n) == 1)
			break;
	}
	fclose(fp);
	in_mf_n = (DOUBLE *)fisCalloc(in_n, sizeof(DOUBLE));
	out_mf_n = (DOUBLE *)fisCalloc(out_n, sizeof(DOUBLE));
	getMfN(filename, in_n, in_mf_n, out_n, out_mf_n);
	total_in_mf_n = fisArrayOperation(in_mf_n, in_n, fisSum);
	total_out_mf_n = fisArrayOperation(out_mf_n, out_n, fisSum);
	row_n = 11 + 2*(in_n+out_n) + 
		3*(total_in_mf_n + total_out_mf_n) + rule_n;
	FREE(in_mf_n);
	FREE(out_mf_n);

	/* find the col_n */
	fp = fisOpenFile(filename, "r");
	/* find FIS name */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find FIS Name in FIS file!");
		if (sscanf(buf, " Name = '%[^']' ", fisName) == 1)
			break;
	}
	col_n = (int)strlen(fisName);
	col_n = MAX(col_n, 8);	/* 'centroid' defuzzification */
	/* find FIS type */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find FIS Type in FIS file!");
		if (sscanf(buf, " Type = '%[^']' ", fisType) == 1)
			break;
	}
 	/* find IO names, MF labels, MF types */
	while (getNextLine(buf, fp) != NULL) {
 		if (sscanf(buf, " Name = '%[^']' ", IoName) == 1)
 			col_n = MAX(col_n, (int)strlen(IoName));
		if (sscanf(buf, " %[^'] '%[^']' : '%[^']' , [ %[^]] ",
			tmp1, tmp2, tmp3, tmp4) == 4) {
			col_n = MAX(col_n, (int)strlen(tmp2));
			col_n = MAX(col_n, (int)strlen(tmp3));
		}
	}
	if (!strcmp(fisType, "mamdani"))
		col_n = MAX(col_n, MF_PARA_N);
	else if (!strcmp(fisType, "sugeno"))
		col_n = MAX(col_n, in_n+out_n+2);
	else
		fisError("Unknown FIS type!");

	fclose(fp);
	/*
	printf("row_n = %d\n", row_n);
	printf("col_n = %d\n", col_n);
	*/
	*row_n_p = row_n;
	*col_n_p = col_n;
	fismatrix = (DOUBLE **)fisCreateMatrix(row_n, col_n, sizeof(DOUBLE));
	return(fismatrix);
}

/* return a FIS matrix with all information */
static DOUBLE **
#ifdef __STDC__
returnFismatrix(char *fis_file, int *row_n_p, int *col_n_p)
#else
returnFismatrix(fis_file, row_n_p, col_n_p)
char *fis_file;
int *row_n_p;
int *col_n_p;
#endif
{
	int i, j, k;
	FILE *fp;
	char buf[STR_LEN];
	char str1[STR_LEN], str2[STR_LEN], str3[STR_LEN], str4[STR_LEN];
	char fisType[STR_LEN];

	int in_n, out_n, rule_n;
	int mf_n;

	int now;
	DOUBLE **fismatrix;
	DOUBLE *in_mf_n, *out_mf_n;

	fismatrix = returnEmptyFismatrix(fis_file, row_n_p, col_n_p);

	fp = fisOpenFile(fis_file, "r");
	/* looping till it finds "[System]" */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find [System] in FIS file!");
		if (!strcmp(buf, "[System]")) /* found it! */
			break;
	}

	/* get FIS information */
	now = 0;
	getString(buf, fp, fismatrix[now++]);	/* name */
	getString(buf, fp, fismatrix[now++]);	/* type */
	for (i = 0; i < STR_LEN && fismatrix[1][i] != 0; i++)
		fisType[i] = (int) fismatrix[1][i];
	fisType[i] = 0;
	in_n = (int)getNumber(buf, fp);
	out_n = (int)getNumber(buf, fp);

	fismatrix[now][0] = (DOUBLE) in_n;
	fismatrix[now][1] = (DOUBLE) out_n;
	now++;

	/* create in_mf_n and out_mf_n */
	in_mf_n = (DOUBLE *)fisCalloc(in_n, sizeof(DOUBLE));
	out_mf_n = (DOUBLE *)fisCalloc(out_n, sizeof(DOUBLE));
	getMfN(fis_file, in_n, in_mf_n, out_n, out_mf_n);
	for (i = 0; i < in_n; i++)
		fismatrix[now][i] = in_mf_n[i];
	now++;
	for (i = 0; i < out_n; i++)
		fismatrix[now][i] = out_mf_n[i];
	now++;
	rule_n = (int)getNumber(buf, fp);
	fismatrix[now++][0] = (DOUBLE) rule_n;
	getString(buf, fp, fismatrix[now++]);	/* and method */
	getString(buf, fp, fismatrix[now++]);	/* or method */
	getString(buf, fp, fismatrix[now++]);	/* imp method */
	getString(buf, fp, fismatrix[now++]);	/* agg method */
	getString(buf, fp, fismatrix[now++]);	/* defuzz method */
	fclose(fp);

	/*
	printf("in_n = %d, out_n = %d, rule_n = %d\n", in_n, out_n, rule_n);
	*/

	/* get input & output labels */
	/* get rid of FIS name */
	fp = fisOpenFile(fis_file, "r");
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find the first Name in FIS file!");
		if (sscanf(buf, " Name = '%[^']' ", str1) == 1)
			break;
	}
	for (i = 0; i < in_n+out_n; i++) {
		while (1) {
			if (getNextLine(buf, fp) == NULL)
				fisError("Not enough Name in FIS file!");
			if (sscanf(buf, " Name = '%[^']' ", str1) == 1)
				break;
		}
		for (j = 0; j < (int)strlen(str1); j++)
			fismatrix[now][j] = str1[j];
		now++;
	}
	fclose(fp);

	/* get input & output ranges */
	fp = fisOpenFile(fis_file, "r");
	for (i = 0; i < in_n+out_n; i++) {
		while (1) {
			if (getNextLine(buf, fp) == NULL)
				fisError("Not enough Range in FIS file!");
			if (sscanf(buf, " Range = [ %[^]] ", str1) == 1)
				break;
		}
		if (getArray(str1, fismatrix[now++]) != 2)
			fisError("Error in parsing I/O ranges.");
	}
	fclose(fp);

	/* get input and output MF labels */
	fp = fisOpenFile(fis_file, "r");
	for (i = 0; i < in_n+out_n; i++) {
		mf_n = i < in_n? in_mf_n[i]:out_mf_n[i-in_n];
		for (j = 0; j < mf_n; j++) {
			while (1) {
				if (getNextLine(buf, fp) == NULL)
					fisError("Not enough MF Labels in FIS file!");
				if (sscanf(buf, " %[^']'%[^']' : '%[^']' , [ %[^]] ",
					str1, str2, str3, str4) == 4)
					break;
			}
			for (k = 0; k < (int)strlen(str2); k++)
				fismatrix[now][k] = str2[k];
			now++;
		}
	}
	fclose(fp);

	/* get input and output MF types */
	fp = fisOpenFile(fis_file, "r");
	for (i = 0; i < in_n+out_n; i++) {
		mf_n = i < in_n? in_mf_n[i]:out_mf_n[i-in_n];
		for (j = 0; j < mf_n; j++) {
			while (1) {
				if (getNextLine(buf, fp) == NULL)
					fisError("Not enough MF types in FIS file!");
				if (sscanf(buf, " %[^']'%[^']' : '%[^']' , [ %[^]] ",
					str1, str2, str3, str4) == 4)
					break;
			}
			for (k = 0; k < (int)strlen(str3); k++)
				fismatrix[now][k] = str3[k];
			now++;
		}
	}
	fclose(fp);

	/* get input & output MF parameters */
	fp = fisOpenFile(fis_file, "r");
	for (i = 0; i < in_n+out_n; i++) {
		mf_n = i < in_n? in_mf_n[i]:out_mf_n[i-in_n];
		for (j = 0; j < mf_n; j++) {
			while (1) {
				if (getNextLine(buf, fp) == NULL)
					fisError("Not enough MF parameters in FIS file!");
				if (sscanf(buf, " %[^']'%[^']' : '%[^']' , [ %[^]] ",
					str1, str2, str3, str4) == 4) {
					/*
					printf("%s\n", buf);
					printf("str1 = %s\n", str1);
					printf("str2 = %s\n", str2);
					printf("str3 = %s\n", str3);
					printf("str4 = %s\n", str4);
					*/
					break;
				}
			}
			if (i < in_n) {
				if (getArray(str4, fismatrix[now]) > MF_PARA_N) {
					/*
					printf("%s\n", str4);
					printf("%d\n", getArray(str4, fismatrix[now]));
					*/
					fisError("Error in parsing input MF parameters.");
				}
			} else {
				if (!strcmp(fisType, "mamdani")) {
					if (getArray(str4, fismatrix[now]) > MF_PARA_N) {
						fisError("Error in parsing output MF parameters.");
					}
				} else {	/* sugeno system */
					int tmp = getArray(str4, fismatrix[now]);
					if (!strcmp(str3, "constant")){
						if (tmp != 1)
							fisError("Zero-order Sugeno system does not has the right number of output MF parameters.");
						else { /* pad with zeros for zero coefficients */
							fismatrix[now][in_n] = fismatrix[now][0];
							fismatrix[now][0] = 0;
						}
					} else if (!strcmp(str3, "linear")) {
						if (tmp != in_n+1)
							fisError("First-order Sugeno system does not has the right number of output MF parameters.");
					} else {
						fisError("Unknown output MF type for Sugeno system.");
					}
				}
			}
			now++;
		}
	}
	fclose(fp);

	/* get rule list */
	fp = fisOpenFile(fis_file, "r");
	/* looping till it finds "[Rules]" */
	while (1) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Cannot find [Rules] in FIS file!");
		if (!strcmp(buf, "[Rules]")) /* found it! */
			break;
	}
	for (i = 0; i < rule_n; i++) {
		if (getNextLine(buf, fp) == NULL)
			fisError("Not enough rule list in FIS file!");
		/* get rid of ",", "(" and ")" */
		for (j = 0; j < (int)strlen(buf); j++)
			if (buf[j]==',' || buf[j]=='(' || buf[j]==')' || buf[j]==':')
				buf[j] = ' ';
		if (getArray(buf, fismatrix[now++]) != in_n + out_n + 2) {
			/*
			printf("%s\n", buf);
			printf("%d\n", getArray(buf, fismatrix[now]));
			*/
			fisError("Error in parsing rule list!");
		}
	}
	fclose(fp);

	/* clean up */
	FREE(in_mf_n);
	FREE(out_mf_n);

	return(fismatrix);
}

/* return data matrix */
DOUBLE **
#ifdef __STDC__
returnDataMatrix(char *filename, int *row_n_p, int *col_n_p)
#else
returnDataMatrix(filename, row_n_p, col_n_p)
char *filename;
int *row_n_p;
int *col_n_p;
#endif
{
	DOUBLE **datamatrix;
	int element_n = 0, row_n = 0, col_n = 0, i, j;
	FILE *fp;
	char str1[STR_LEN];
	DOUBLE num1;

	/* find the size of the data file */

	/* find data number */
	fp = fisOpenFile(filename, "r");
	row_n = 0;
	while (fscanf(fp, " %[^\n] ", str1) != EOF)
		row_n++;
	fclose(fp);

	/* find element number */
	fp = fisOpenFile(filename, "r");
	while (fscanf(fp, "%lf", &num1) != EOF)
		element_n++;
	fclose(fp);
	col_n = element_n/row_n;
	/*
	printf("row_n = %d\n", row_n);
	printf("element_n = %d\n", element_n);
	printf("col_n = %d\n", col_n);
	*/

	/* create a data matrix */
	datamatrix = (DOUBLE **)fisCreateMatrix(row_n, col_n, sizeof(DOUBLE));
	/* read data file and put data into data matrix */
	fp = fisOpenFile(filename, "r");
	for (i = 0; i < row_n; i++) {
		for (j = 0; j < col_n; j++) {
			if (fscanf(fp, "%lf", &num1) != EOF)
				datamatrix[i][j] = num1;
			else
				fisError("Not enough data in data file!");
		}
	}
	fclose(fp);

	*row_n_p = row_n;
	*col_n_p = col_n;
	return(datamatrix);
}


