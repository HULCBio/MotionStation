/* Copyright 1984-2001 The MathWorks, Inc. */
/* $Revision: 1.17.4.4 $  $Date: 2004/01/15 21:14:39 $ */

/*
 *  Helper function for textread and strread.
 *
 *     A = DATAREAD('FILE','FILENAME')
 *     A = DATAREAD('STRING','STRING TO PARSE')
 */
 
static char rcsid[] = "$Id: dataread.c,v 1.17.4.4 2004/01/15 21:14:39 batserve Exp $";

#include <string.h>
#include <ctype.h>

/* MATLAB API header file */
#include "mex.h"
#include "matrix.h"

/* File defines */
#define OPEN_SET '['
#define CLOSE_SET ']'
#define ToNumber(c) ((c) - '0')
#define DEFAULTBUFSIZE 4095
#define UNSPECIFIED -1
#define READ_WHOLE_FILE -1
#define DEFAULT_LINKED_BUFFER_LENGTH 1024
#define PRIVATE static

/* File globals */
PRIVATE char *delimiter = NULL;
PRIVATE double emptyvalue = 0.0;
PRIVATE int headerlines = 0;
PRIVATE int headercolumns = 0;
PRIVATE int commentstyle = 0;
PRIVATE bool returnonerror = false;
PRIVATE int inputOverrun = 0;
PRIVATE char *inputCurrent = NULL;
PRIVATE char *inputStart = NULL;
PRIVATE char *whitespace = NULL;
PRIVATE char defaultWhitespace[] = " \t\b";
PRIVATE char *endofline = NULL;
PRIVATE int endoflineLength = 0;
PRIVATE char *expchars = NULL;
PRIVATE char defaultExpchars[] = "eEdD";
PRIVATE char noDelimiter[] = "";
PRIVATE int offsetFromStart = 0;
PRIVATE FILE *fp = NULL;
PRIVATE int bufsize = DEFAULTBUFSIZE;
PRIVATE char *buf;
PRIVATE bool whitespaceIsDefault = false;
PRIVATE bool delimiterIsEOL = false;
PRIVATE bool firsttime = true;
PRIVATE int pushBackBuffer[4] = {'\0','\0','\0','\0'};
PRIVATE int pushBackLength = 0;
PRIVATE int *matches = NULL; /* used to keep track of param/value matches */

typedef enum {READ_SUCCESS, READ_FAILURE, READ_BUFFER_OVERFLOW} readStatus;

PRIVATE void initGlobals(void)
{
    delimiter = NULL;
    emptyvalue = 0.0;
    headerlines = 0;
    headercolumns = 0;
    commentstyle = 0;
    returnonerror = false;
    inputOverrun = 0;
    inputCurrent = NULL;
    inputStart = NULL;
    whitespace = NULL;
    strcpy(defaultWhitespace, " \t\b");
    endofline = NULL;
    endoflineLength = 0;
    expchars = NULL;
    strcpy(defaultExpchars, "eEdD");
    strcpy(noDelimiter, "");
    offsetFromStart = 0;
    fp = NULL;
    bufsize = DEFAULTBUFSIZE;
    whitespaceIsDefault = false;
    delimiterIsEOL = false;
    firsttime = true;
    pushBackBuffer[0] = '\0';
    pushBackBuffer[1] = '\0';
    pushBackBuffer[2] = '\0';
    pushBackBuffer[3] = '\0';
    pushBackLength = 0;
    matches = NULL; /* used to keep track of param/value matches */
}
/************************************************************
 * Character I/O
 ************************************************************/
 
/*
 * AtExitFcn -- Close any open files.
 */
PRIVATE void AtExitFcn(void)
{
    if (fp != NULL)
        fclose(fp);
    fp = NULL;
}

/* private error function to make sure file is closed */
PRIVATE void ErrMsgIdAndTxt(const char * id, const char * message)
{
    AtExitFcn();
    mexErrMsgIdAndTxt(id, message);
}

/*
 * GetNChars -- Get pointer to n characters from input (caller must free)
 */
PRIVATE char* GetNChars(int n)
{
    char * result = NULL;
    int i;
    result = (char *)mxCalloc(n+1, sizeof(char));

    if (fp != NULL)
    {
        /* seed result with current pushBackBuffer */
        for (i=0; i < pushBackLength; i++)
        {
            result[i] = (char) pushBackBuffer[i];
        }

        if (n > pushBackLength)
        {
            fpos_t *start_position = (fpos_t*) mxCalloc(1, sizeof(fpos_t));

            /* store file position */
            if (fgetpos(fp, start_position))
            {
                ErrMsgIdAndTxt("MATLAB:dataread:FilePositionSettingError","Internal error setting file position.");
            }

            /* fread requeseted number of bytes */
            if ((int)fread(result+pushBackLength, sizeof(char), n - pushBackLength, fp) != n - pushBackLength)
            {
                if (!feof(fp))
                {
                    ErrMsgIdAndTxt("MATLAB:dataread:FileReadError","Internal error reading from file.");
                }
                mxFree(result);
                result = NULL;
            }

            /* reset file position */
            if (fsetpos(fp, start_position))
            {
                ErrMsgIdAndTxt("MATLAB:dataread:FilePositionResetError","Internal error resetting file position.");
            }
            mxFree(start_position);
        }

        result[n] = '\0';
    }

    else
    {
        for (i=0; i < n; i++)
        {
            if ('\0' == (*inputCurrent + i))
            {
                break;
            }
            result[i] = *inputCurrent+i;
        }
        
        if (i != n)
        {
            mxFree(result);
            result = NULL;
        }
        else
        {
            result[i] = '\0';
        }
    }
    return result;
}

/*
 * GetCharacter -- Get one character
 */

PRIVATE int GetCharacter(void)
{
    int result;
	
    offsetFromStart++;

    if (fp != NULL)
    {
        if (pushBackLength == 0)
        {
            result = getc(fp);
        }
        else
        {
            result = pushBackBuffer[--pushBackLength];
        }
    }
    else
    {
        if (*inputCurrent == '\0')
        {
            inputOverrun ++;
            result = EOF;
        }
        else
        {
            result = *inputCurrent++;
        }
    }

    return result;
}

/*
 * UngetCharacter -- Unget one character
 *
 * Up to four characters can be pushed back when reading from file.
 */
PRIVATE void UngetCharacter(int ch)
{
    offsetFromStart--;

    mxAssert(offsetFromStart >= 0, "Offset count error.");
    
    if (fp != NULL)
    {
        mxAssert(pushBackLength < 4,"Overflowed internal buffer.");
        pushBackBuffer[pushBackLength++] = ch;
    }
    else
    {
        mxAssert(inputCurrent >= inputStart,"Underflowed input buffer.");
        if (inputCurrent > inputStart)
        {
            if (inputOverrun > 0)
            {
                inputOverrun--;
            }
            else
            {
                inputCurrent--;
            }
        }
    }
}


PRIVATE void doRewind(void)
{
    if (fp != NULL)
    {
        rewind(fp);
    }
    else
    {
        inputCurrent = inputStart;
        inputOverrun = 0;
    }
}


PRIVATE void InitializePushBackBuffer(void)
{
    if (fp != NULL)
    {
        int i;
	
        for (i=0; i< 4; i++)
        {
            pushBackBuffer[i] = '\0';
        }
        pushBackLength = 0;
    }
}

/*********************************************************
 * Mex utilities
 *********************************************************/
 
/*
 * muIsDoubleScalar
 *
 * True if input is a real double scalar
 */
PRIVATE bool muIsDoubleScalar(const mxArray *A)
{
    return mxIsDouble(A) && (mxGetNumberOfElements(A)==1) && !mxIsComplex(A);
}


/*
 * muGetDoubleScalar
 *
 * Purpose: Get double value from MATLAB array; error out if array is
 *          empty or not double
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  double-precision value
 *
 */ 
PRIVATE double muGetDoubleScalar(const mxArray *A, char *name)
{
    double result;
    char error_message[255];
    static char trailer[] = " must be a scalar double.";

    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!muIsDoubleScalar(A))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        ErrMsgIdAndTxt("MATLAB:dataread:NotScalarDouble",error_message);
    }

    result = *((double *) mxGetPr(A));
    return(result);
}


/*
 * muGetIntegerScalar
 *
 * Purpose: Get an integer value from MATLAB array; error out if array is
 *          empty or not an integer.
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  integer value
 *
 */ 
PRIVATE int muGetIntegerScalar(const mxArray *A, char *name)
{
    double d;
    int result;
    char error_message[255];
    static char trailer[] = " must be a scalar integer.";

    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!muIsDoubleScalar(A))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        ErrMsgIdAndTxt("MATLAB:dataread:NotScalarInteger",error_message);
    }

    d = *((double *) mxGetPr(A));
    result = (int)d;
	
    if (((double) result) != d)
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        ErrMsgIdAndTxt("MATLAB:dataread:NotScalarInteger",error_message);
    }
    return(result);
}


/*
 * muGetString
 * 
 * Purpose: Get C string from MATLAB string array; error out if
 *          array is not a string array
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  string
 *
 * Note:  This function allocates memory to hold the string.  
 * The calling function is responsible for freeing the memory when done
 * with it!
 */
PRIVATE char *muGetString(const mxArray *A, char *name)
{
    int numEl;
    char *result = NULL;
    char error_message[255];
    static char trailer[] = " must be a string.";


    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!mxIsChar(A))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        ErrMsgIdAndTxt("MATLAB:dataread:NotAString",error_message);
    }

    numEl = mxGetM(A) * mxGetN(A) * sizeof(mxChar);
    result = mxCalloc(numEl+1, sizeof(*result));

    mxGetString(A, result, numEl+1);

    return(result);
}


/*
 * muGetStringCC
 * 
 * Purpose: Get C string from MATLAB string array (with carriage control); 
 *          error out if array is not a string array or if \c carriage
 *          control is badly formed.
 *
 * Inputs:  A --- MATLAB array
 *          name --- string identifying what the input array is supposed
 *                   to represent.  name is used to construct a
 *                   meaningful error message.
 * Outputs: none
 * Return:  string
 *
 * Note:  This function allocates memory to hold the string.  
 * The calling function is responsible for freeing the memory when done
 * with it!
 */
PRIVATE char *muGetStringCC(const mxArray *A, char *name)
{
    int numEl;
    char *result = NULL;
    char error_message[255];
    static char trailer[] = " must be a string.";
    static char cc_trailer[] = " has bad \\ constant.";
    char *p, *q;


    mxAssertS(A != NULL, "NULL mxArray pointer");
    mxAssertS(name != NULL, "NULL char pointer");

    if (!mxIsChar(A))
    {
        strncpy(error_message, name, 255-strlen(trailer)-1);
        strcat(error_message, trailer);
        ErrMsgIdAndTxt("MATLAB:dataread:NotAString",error_message);
    }

    numEl = mxGetM(A) * mxGetN(A) * sizeof(mxChar);
    result = mxCalloc(numEl+1, sizeof(*result));

    mxGetString(A, result, numEl+1);

    /* Convert carriage control sequences \c into equivalent characters */
    p = q = result;
    while (*p != '\0')
    {
        if (*p != '\\')
            *q++ = *p++;
        else if (*p == '\\')
        {
            p++;
            switch (*p)
            {
            case '\0':
                strncpy(error_message, name, 255-strlen(trailer)-1);
                strcat(error_message, cc_trailer);
                ErrMsgIdAndTxt("MATLAB:dataread:InvalidTerminatingCharacter",error_message);
                break;
            case 'n':
                *q++ = '\n';
                break;
            case 'r':
                *q++ = '\r';
                break;
            case 't':
                *q++ = '\t';
                break;
            case 'b':
                *q++ = '\b';
                break;
            case '\\':
                *q++ = '\\';
                break;
            default:
                strncpy(error_message, name, 255-strlen(trailer)-1);
                strcat(error_message, cc_trailer);
                ErrMsgIdAndTxt("MATLAB:dataread:InvalidTerminatingCharacter",error_message);
            }
            p++;
        }
    }
    *q++ = '\0';
	
    return result;
}

/*********************************************************
 * Whitespace and delimiters
 *********************************************************/
 
/*
 * DestroyWhitespace -- Free whitespace character buffer
 */
PRIVATE void DestroyWhitespace(void)
{
    mxFree(whitespace);
    whitespace = NULL;
}


/*
 * DestroyEndofline -- Free endofline character buffer
 */
PRIVATE void DestroyEndofline(void)
{
    mxFree(endofline);
    endofline = NULL;
    endoflineLength = 0;
}


/*
 * DestroyExpchars -- Free expchars character buffer
 */
PRIVATE void DestroyExpchars(void)
{
    if (expchars != defaultExpchars) {
        mxFree(expchars);
    }
    expchars = NULL;
}


/*
 * DestroyDelimiter -- Free delimiter character buffer if necessary
 */
PRIVATE void DestroyDelimiter(void)
{
    if (delimiter != noDelimiter && delimiter != NULL)
    {
        mxFree(delimiter);
        delimiter = NULL;
    }
}


/* 
 * Look for param/value pair of the form 'Bufsize',N.  Set
 * the bufsize global to the integer specified or the default
 * set if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetBufsize(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    int i;
	
    bufsize = DEFAULTBUFSIZE;
	
    mxAssert(matches != NULL,"");
	
    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"bufsize",7) == 0)
            {
                bufsize = muGetIntegerScalar(prhs[i+1],"Buffer size");
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
    if (bufsize < 100)
    {
        mexWarnMsgIdAndTxt("MATLAB:dataread:BufferTooSmall", "Buffer too small, using bufsize = 100 instead.");
        bufsize = 100;
    }
}


/* 
 * Look for param/value pair of the form 'headerlines',N.  Set
 * the headerlines global to the integer specified or the default
 * set if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetHeaderLines(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    int i;
	
    headerlines = 0;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"headerlines",11) == 0)
            {
                headerlines = muGetIntegerScalar(prhs[i+1],"Header lines");
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
    if (headerlines < 0) {
        ErrMsgIdAndTxt("MATLAB:dataread:InvalidHeaderlineValue","Headerlines must be a positive integer.");
    }
}

/* 
 * Look for param/value pair of the form 'emptyvalue',N.
 */
PRIVATE void LookforAndGetEmptyValue(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    int i;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"emptyvalue",10) == 0)
            {
                emptyvalue = muGetDoubleScalar(prhs[i+1],"Empty Value");
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
}

/* 
 * Look for param/value pair of the form 'headercolumns',N.  Set
 * the headercolumns global to the integer specified or the default
 * set if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetHeaderColumns(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    int i;
	
    headercolumns = 0;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"headercolumns",7) == 0)
            {
                headercolumns = muGetIntegerScalar(prhs[i+1],"Header columns");
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
    if (headercolumns < 0)
        ErrMsgIdAndTxt("MATLAB:dataread:InvalidHeadercolumnsValue","Headercolumns must be a positive integer.");
}

/* 
 * Look for param/value pair of the form 'WhiteSpace','white_chars'.  Set
 * the "whitespace" global to the characters specified or the default
 * set if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetWhitespace(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    char *value;
    int i;
	
    whitespace = NULL;
	
    mxAssert(matches != NULL,"");

    /* Should we error out if the whitespace characters include +-.numbers,e,E,d,D? */
    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"whitespace",10) == 0)
            {
                value = muGetStringCC(prhs[i+1],"Whitespace characters");
                whitespace = value;
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
	
    if (whitespace == NULL) /* default when whitespace isn't set */
    {
        whitespaceIsDefault = true;
        whitespace = mxCalloc(strlen(defaultWhitespace)+1,sizeof(char));
        strcpy(whitespace,defaultWhitespace);
    }
}

PRIVATE bool getEOLFromString(const char *str)
{
    /* look for eol - this assumes \n or \r\n or \r as eol marker - this may fail on the mac ? */
    /* Fetch EOL from string */
    if (strstr(str, "\r\n") != NULL)
    {
        strcpy(endofline, "\r\n");
        endoflineLength = 2;
        return true;
    }
    else if (strstr(str, "\r") != NULL)
    {
        strcpy(endofline, "\r");
        endoflineLength = 1;
        return true;
    }
    else if (strstr(str, "\n") != NULL)
    {
        strcpy(endofline, "\n");
        endoflineLength = 1;
        return true;
    }
    return false;
}

PRIVATE void GetDefaultEndofline() {
    /* EOL chars are either 1 (\n) or 2 (\r\n) bytes, allocate 2 */
    endofline = mxCalloc(2+1,sizeof(char));

    /* if the following chunk does not find a good eol, default to this one */
    strcpy(endofline,"\n");
    endoflineLength = 1;

    if (fp != NULL)
    {
        int buffsize = 4*1024;
        char *line = mxCalloc(buffsize+1,sizeof(char));

        /* read the file in 4k chunks and look for eol */

        while (fgets(line, buffsize, fp) != NULL)
        {
            /* fgets returns null whenever we hit EOF */
            if (getEOLFromString(line))
            {
                break;
            }
        }

        doRewind();
        mxFree(line);
    }
    else
    {
        getEOLFromString(inputStart);
    }
}

/* 
 * Look for param/value pair of the form 'endofline', 'EOL'.  Set
 * the "endofline" global to the characters specified or the default
 * set if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetEndofline(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    char *value;
    int i;
	
    endofline = NULL;
	
    mxAssert(matches != NULL,"");

    /* Should we error out if the endofline characters include +-.numbers,e,E,d,D? */
    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"endofline",9) == 0)
            {
                value = muGetStringCC(prhs[i+1],"End of line character");
                /* only fetch 1st char from endofline arg */
                endoflineLength = strlen(value);
                if (!(endoflineLength == 2 && strcmp(value, "\r\n") == 0) &&
                    !(endoflineLength == 1)) {
                     ErrMsgIdAndTxt("MATLAB:dataread:InvalidEndOfLineCharacters","End of line character must be single character or \\r\\n");
                }
                endofline = value;
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
	
    /* Use default endofline characters */
    if (endofline == NULL)
    {
        GetDefaultEndofline();
    }
}

/* 
 * Look for param/value pair of the form 'ExpChars','exp_chars'.  Set
 * the "expchars" global to the characters specified or the default
 * set if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetExpchars(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    char *value;
    int i;
	
    expchars = NULL;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"expchars",10) == 0)
            {
                value = muGetStringCC(prhs[i+1],"Exponential characters");
                expchars = value;
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
	
    /* Use default exponent characters */
    if (expchars == NULL)
    {
        expchars = defaultExpchars;
    }
}


/* 
 * Look for param/value pair of the form 'delimiter','delimchars'.  Set
 * the "delimiter" global to the characters specified or the default
 * if the param/value pair isn't found.  
 */
PRIVATE void LookforAndGetDelimiter(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    char *value;
    int i;
	
    delimiter = noDelimiter;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"delimiter",10) == 0)
            {
                value = muGetStringCC(prhs[i+1],"Delimiter");
                delimiter = value;
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
}


/* 
 * Remove any delimiter characters from character list. 
 */
PRIVATE void RemoveDelimiterFromList(char *list)
{
    char *d = delimiter;
    char *p,*q;

    while (list != NULL && d != NULL && *d != '\0')
    {
        p = q = list;
        while (*p != '\0')
        {
            if (*p == *d)
                p++; /* Skip over this character */
            else
                *q++ = *p++;
        }
        *q = '\0'; /* Terminate */
		
        d++;
    }
}


PRIVATE char *comment_styles[] = {"none","matlab","c","c++","shell"};
PRIVATE char Nstyles = 5;

/* 
 * Look for param/value pair of the form 'CommentStyle','style' where
 * style is one of 'matlab','c','c++'.  Return index into
 * comment_styles[].  Return the index to the default ("none") if no
 * 'CommentStyle' parameter is found.  */
PRIVATE int LookforAndGetCommentStyle(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    char *value;
    int found = UNSPECIFIED;
    int i;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"commentstyle",12) == 0)
            {
                matches[i] = 1;
                value = muGetString(prhs[i+1],"Comment style");
                for (i=0; i<Nstyles; i++)
                {
                    if (strcmp(value,comment_styles[i])==0)
                    {
                        found = i;
                        break;
                    }
                }
                mxFree(value);
                if (found == UNSPECIFIED)
                    ErrMsgIdAndTxt("MATLAB:dataread:InvalidCommentstyleValue","Invalid comment style.");
            }
            mxFree(tmp);
			
            if (found != UNSPECIFIED)
                break;
        }
    }
    if (found == UNSPECIFIED)
        found = 0; /* Default is no comment skipping */
		
    return found;
}

/* look for boolean flag for returning on error, default to false which means
 * error out when a field fails to match */
PRIVATE bool LookforAndGetReturnOnError(
    const mxArray *prhs[],
    int start,
    int end
    )
{
    char *tmp;
    int i, j;
    bool returnonerror = false;
	
    mxAssert(matches != NULL,"");

    for (i=start; i<end; i+=2)
    {
        if (mxIsChar(prhs[i]))
        {
            tmp = muGetString(prhs[i],"Parameter string");
            if (strncmp(tmp,"returnonerror",13) == 0)
            {
                j = muGetIntegerScalar(prhs[i+1], "Return On Error");
                if (j < 0 || j > 1)
                {
                    ErrMsgIdAndTxt("MATLAB:dataread:NeedLogicalReturnOnErrorFlag","Return On Error flag must be 0 or 1.");
                }
                returnonerror = (bool) j;
                matches[i] = 1;
                mxFree(tmp);
                break;
            }
            mxFree(tmp);
        }
    }
		
    return returnonerror;
}

/********************************************************
 * Input field routines 
 ********************************************************/
 
typedef enum {LITERAL_FORMAT,D_FORMAT,U_FORMAT,F_FORMAT,NUMERIC_FORMAT,C_FORMAT,
      S_FORMAT,Q_FORMAT,SET_FORMAT,NSET_FORMAT,UNKNOWN_FORMAT} inputfieldtype;

typedef struct inputfield *inputfieldPtr;
typedef struct inputfield {
    inputfieldtype type;
    int width;	/* Format width (or UNSPECIFIED) */
    int prec;	/* Number of decimals (%f only) */
    const char *format_chars;
    int nchars; /* Number of chars in the format */
    int count;	/* Number of times this format has been used */
    bool skip;	/* True if this format doesn't generate any output */
    inputfieldPtr next;
} inputfield;

/*
 * Create inputfield node
 */
PRIVATE inputfield *CreateInputfield(void)
{
    inputfield *inputField = mxCalloc(1,sizeof(inputfield));
    inputField->type = UNKNOWN_FORMAT;
    inputField->width = UNSPECIFIED;
    inputField->prec = UNSPECIFIED;
    inputField->format_chars = NULL;
    inputField->nchars = 0;
    inputField->skip = false;
    inputField->count = 0; 
    inputField->next = NULL;
	
    return inputField;
}

/*
 * Destroy inputfield list
 */
PRIVATE void DestroyInputfieldList(inputfield *head)
{
    while (head != NULL)
    {
        inputfield *next;
		
        next = head->next;
        mxFree(head);
        head = next; 
    }
}

/* 
 * Field type string from enum.
 */
PRIVATE const char *FieldTypeStr(
    inputfieldtype t
    )
{
    switch (t)
    {
    case LITERAL_FORMAT:
        return "literal string";
    case D_FORMAT:
        return "integer";
    case U_FORMAT:
        return "unsigned integer";
    case F_FORMAT:
        return "floating point number";
    case NUMERIC_FORMAT:
        return "number";
    case C_FORMAT:
        return "characters";
    case S_FORMAT:
    case Q_FORMAT:
    case SET_FORMAT:
    case NSET_FORMAT:
        return "string";
    case UNKNOWN_FORMAT:
        return "unknown";
    }
    return "unknown";
}

/*
 * Return true if character c is one of set_chars
 */
PRIVATE bool InSet(
    char c,
    const char *set_chars
    )
{
    const char *p = set_chars;

    mxAssert(set_chars != NULL, "");

    while (*p != '\0')
    {
        if (c == *p++) return true;
    }
    return false;
}


/*
 * Return true if character c is one of the N set_chars
 */
PRIVATE bool InSetn(
    char c,
    const char *set_chars,
    int nchars
    )
{
    const char *p = set_chars;
    int i;
	
    for (i=0; i<nchars; ++i)
    {
        if (c == *p++) return true;
    }
    return false;
}


/***************************************************************
 * Linked buffer routines                                      *
 ***************************************************************/

#if defined(NDEBUG)
/* If not debugging use inline functions */
#define GetLinkSegmentFromOffset(n,offset) ((int)(offset / n))
#define GetBufferPositionFromOffset(n,offset) ((int)(offset % n))

#else
PRIVATE int GetLinkSegmentFromOffset(int n, int offset) 
{
    int result = offset / n;
    return result;
}

PRIVATE int GetBufferPositionFromOffset(int n, int offset)
{
    int result = offset % n;
    return result;
}
#endif

typedef struct LinkedBuffer *LinkedBufferPtr;
typedef struct LinkedBuffer {
    void *data; /* Pointer to data buffer */
    int n;     /* Number of elements in the data buffer */
    int size;  /* Size of the elements in the data buffer */
    int segment;  /* Position of this buffer in list of buffers */
    int currentpt; /* Used to keep state info for walk */
    int totalelements; /* On the head we keep track of the total elements so far */
    LinkedBufferPtr next; /* Pointer to next buffer */
    LinkedBufferPtr head; /* Pointer to head of buffer list */
} LinkedBuffer;


/*
 * CreateLinkedBuffer -- Create a LinkedBuffer node with n
 *                       elements of the specified size.
 *
 * The currentpt field is left uninitialized by this routine.
 */
PRIVATE LinkedBuffer *CreateLinkedBuffer(
    int n,   /* Number of elements in each buffer */
    int size /* Size of elements in the buffer */
    )
{
    LinkedBuffer *result;
	
    result = mxCalloc(1,sizeof(LinkedBuffer));
    result->data = mxCalloc(n,size);
    result->n = n;
    result->size = size;
    result->next = NULL;

    /* Assume that this is a standalone buffer */
    result->head = result;
    result->segment = 0;
    result->totalelements = n;
	
    return result;
}

/* 
 * GrowLinkedBuffer -- Add a buffer to the list that buffer is part of
 */
PRIVATE void GrowLinkedBuffer(
    LinkedBuffer **buffer
    )
{
    LinkedBuffer *p, *q;
	
    mxAssert(*buffer != NULL,"");
	
    p = *buffer;
	
	/* Find the end of the linked list */
    while (p->next != NULL)
    {
        p = p->next;
    }
    q = CreateLinkedBuffer(p->n,p->size);
	
	/* Add the new buffer to the list */
    q->segment = p->segment + 1;
    q->head = p->head;
    p->next = q;
	
    /* Add to totalelements */
    q->head->totalelements += q->n;
	
    *buffer = q;
}
	
/*
 * DestroyLinkedBuffer -- Destroy the entire linked list
 */
PRIVATE void DestroyLinkedBuffer(
    LinkedBuffer *buffer
	)
{
    LinkedBuffer *p, *q;
	
    mxAssert(buffer != NULL,"");
	
    /* Start at the head and free everything */
    p = buffer->head;
    while (p != NULL)
    {
        q = p;
        p = p->next;
		
        if (q->data != NULL)
            mxFree(q->data);
			
        mxFree(q);
    }
}
 
/*
 * GetLinkedBufferElementPtr -- Return void pointer to linked list element.
 *
 * Returns a void pointer to the memory at specified offset along linked list
 * of buffers.  Allows code to treat the linked list of buffers like a huge
 * array.  Buffer can be anywhere along the chain of buffers.  Performance is
 * improved if the data in buffer happens to the right one for the given offset.
 *
 * An assertion is thrown if the element is off the list.
 *
 * Equivalent to
 *
 *     &p[offset]
 *
 * for a normal array.  Updates buffer to point to node where element is found.
 */
PRIVATE void *GetLinkedBufferElementPtr(
    LinkedBuffer **buffer, /* One of the buffers along the chain */
    int offset /* Offset from beginning of linked buffer as if a huge array */
    )
{
    int seg;
    LinkedBuffer *p = *buffer;
	
    mxAssert(p != NULL,"");
	
    if ((seg = GetLinkSegmentFromOffset(p->n,offset)) != p->segment)
    {
        /* Look for correct segment starting from the head */
        p = p->head; 
        while (p != NULL && p->segment < seg)
        {
            p = p->next;
        }
        /* Update buffer so that next search will be faster */
        *buffer = p; 
    }
	
    mxAssert(p->segment == seg,"Segment out of range.");
	
    return (void *) (((char *)p->data) + GetBufferPositionFromOffset(p->n,offset)*p->size);
}

/* 
 * GetLinkedBufferElementPtrWithGrowth --  Return void pointer to linked list element
 *                                      Grow the buffer if necessary.
 */
PRIVATE void *GetLinkedBufferElementPtrWithGrowth(
    LinkedBuffer **buffer, /* One of the buffers along the chain */
    int offset /* Offset from beginning of linked buffer as if a huge array */
    )
{
    mxAssert(*buffer != NULL,"");
	
    if (offset >= (*buffer)->head->totalelements)
        GrowLinkedBuffer(buffer);
	
    return GetLinkedBufferElementPtr(buffer,offset);
}


/***************************************************************
 * Format parsing routines                                     *
 ***************************************************************/

/* 
 * Parse format spec.  Return number of characters parsed.
 */
PRIVATE int ParseFormatSpec(
    inputfield *inputField,  /* input field to fill in */
    const char *p     /* pointer into format string where format spec starts */
    )
{
    bool done;
    int count = 1;
	
    /* Skip over leading % */
    mxAssert(*p=='%',"All formats start with '%'");
    ++p;
	
    done = false;
    while (!done)
    {
        /* Parse %<-><width>.<prec><format> */
        if (*p == '-') /* Ignore justification on reading */ 
        {
            ++p;
            ++count;
        }
        else if (*p == '*') /* '*' is the skip indicator */
        {
            inputField->skip = true;
            ++p;
            ++count;
        }
        else if (isdigit(*p)) /* Get width value */
        {
            inputField->width = 0;
            while (*p != '\0' && isdigit(*p))
            {
                inputField->width = inputField->width * 10 + ((int)(*p - '0'));
                ++p;
                ++count;
            }
        }
        else if (*p == '.') /* Get precision value */
        {
            ++p;
            ++count;
            inputField->prec = 0;
            while (*p != '\0' && isdigit(*p))
            {
                inputField->prec = inputField->prec * 10 + ((int)(*p - '0'));
                ++p;
                ++count;
            }
        }
        else if (*p == OPEN_SET)
        {
            ++p;
            ++count;
            if (*p == '^') /* Check for negation character */
            {
                inputField->type = NSET_FORMAT;
                ++p;
                ++count;
            }
            else
            {
                inputField->type = SET_FORMAT;
            }
				
            inputField->format_chars = p;
            inputField->nchars = 0;
			
            /* Special case: Check for CLOSE_SET as first character.
             * If so CLOSE_SET is in the scanset.
             */
            if (*p == CLOSE_SET)
            {
                ++p;
                ++count;
                inputField->nchars++;
            }
			
            /* Search for end of set */
            while (*p != '\0' && *p != CLOSE_SET)
            {
                ++p;
                ++count;
                inputField->nchars++;
            }
			
            if (*p != CLOSE_SET)
                goto handle_error;
				
            ++count;
            done = true;
        }
        else if (*p == 'd')
        {
            inputField->type = D_FORMAT;
            ++count;
            done = true;
        }
        else if (*p == 'u')
        {
            inputField->type = U_FORMAT;
            ++count;
            done = true;
        }
        else if (*p == 'f')
        {
            inputField->type = F_FORMAT;
            ++count;
            done = true;
        }
        else if (*p == 'n')
        {
            inputField->type = NUMERIC_FORMAT;
            ++count;
            done = true;
        }
        else if (*p == 's')
        {
            inputField->type = S_FORMAT;
            ++count;
            done = true;
        }
        else if (*p == 'q')
        {
            inputField->type = Q_FORMAT;
            ++count;
            done = true;
        }
        else if (*p == 'c')
        {
            inputField->type = C_FORMAT;
            ++count;
            done = true;
        }
        else
        {
            goto handle_error;
        }
    }
	
    /* Special case: %c implies %1c */
    if (inputField->type == C_FORMAT && inputField->width == UNSPECIFIED)
        inputField->width = 1;
		
    return count;
	
 handle_error:
    inputField->type = UNKNOWN_FORMAT;
    return count;
}


/*
 * Parse format string into inputfields.  Returns a linked list of
 * inputfield definitions or NULL if format was badly formed.
 *
 * The caller is responsible for calling DestroyInputFieldList() on
 * the return argument when done with it.
 */
PRIVATE inputfield *ParseFormat(
    const char *format
    )
{
    const char *p = format;
    inputfield *head = NULL;
    inputfield *tail = NULL;
    inputfield *inputField;
	
    while (*p != '\0')
    {
        if (*p == '%' && *(p+1) != '%')
        {
            int n;
			
            /* Begin parsing format */
            inputField = CreateInputfield();
            if (head == NULL)
            {
                head = inputField;
                tail = inputField;
            }
            else
            {
                tail->next = inputField;
                tail = inputField;
            }
			
            n =  ParseFormatSpec(inputField,p);
            if (inputField->type == UNKNOWN_FORMAT)
                goto handle_error;
				
            p += n;
        }
        else if (InSet(*p,defaultWhitespace)) /* skip over whitespace */
        {
            ++p;
        }
        else 
        {
            /*
             * Everything that isn't a format spec or whitespace must be a literal
             */
            inputField = CreateInputfield();
            if (head == NULL)
            {
                head = inputField;
                tail = inputField;
            }
            else
            {
                tail->next = inputField;
                tail = inputField;
            }
			
            inputField->type = LITERAL_FORMAT;
            inputField->format_chars = p;
            inputField->nchars = 0;
            inputField->skip = true; /* Always skip literals */
			
            /* Build literal from regular characters or the special %% */
            while (*p != '\0' && ((*p != '%' && !InSet(*p,defaultWhitespace)) || 
                                  (*p == '%' && *(p+1) == '%')))
            {
                if (*p == '%')
                    ++p; /* Skip over extra % */
                ++p;
                inputField->nchars++;
            }
        }
    }
	
    return head;
	
 handle_error:
    DestroyInputfieldList(head);
    return NULL;
}

/*
 * Create mxArray based on input field type.  Return NULL if field is to
 * be skipped.
 */
PRIVATE mxArray *CreateArrayFromInputField(
    const inputfield *inputField,
    int numCols               /* this is typically one. only greater
                               * than 1 when shoving all buffer
                               * entries into single output. this is
                               * only supported for numeric data.  */
    )
{
    mxArray *result = NULL;
    int dims[2];
	
    dims[0] = inputField->count;
    dims[1] = numCols;
	
    if (!(inputField->skip))
    {
        switch (inputField->type)
        {
        case LITERAL_FORMAT:
            break; /* skip literals (no output) */
        case D_FORMAT:
        case U_FORMAT:
        case F_FORMAT:
        case NUMERIC_FORMAT:
            result = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
            break;
        case C_FORMAT:
            mxAssert(dims[1] == 1,"");
            mxAssert(inputField->width != UNSPECIFIED,"");
            dims[1] = inputField->width;
            result = mxCreateCharArray(2,dims);
            break;
        case S_FORMAT:
        case Q_FORMAT:
        case SET_FORMAT:
        case NSET_FORMAT:
            mxAssert(dims[1] == 1,"");
            result = mxCreateCellMatrix(inputField->count,1);
            break;
        default:
            mxAssertS(0,"Unknown format");
            break;
        }
    }	
    return result;
}

/*
 * Create Linked Buffer based on input field type.
 */
PRIVATE LinkedBuffer *CreateBufferFromInputField(
    const inputfield *inputField,
    int nrecycle /* Number of rows or READ_WHOLE_FILE to use default */
    )
{
    LinkedBuffer *result = NULL;
    int n;
	
    if (nrecycle == READ_WHOLE_FILE)
        n = DEFAULT_LINKED_BUFFER_LENGTH;
    else
        n = nrecycle;	
	
    if (!(inputField->skip))
    {
        switch (inputField->type)
        {
        case LITERAL_FORMAT:
            break; /* skip literals (no output) */
        case D_FORMAT:
        case U_FORMAT:
        case F_FORMAT:
        case NUMERIC_FORMAT:
            result = CreateLinkedBuffer(n,sizeof(double));
            break;
        case C_FORMAT:
            mxAssert(inputField->width != UNSPECIFIED,"");
            result = CreateLinkedBuffer(n,sizeof(mxChar)*inputField->width);
            break;
        case S_FORMAT:
        case Q_FORMAT:
        case SET_FORMAT:
        case NSET_FORMAT:
            result = CreateLinkedBuffer(n,sizeof(mxArray *));
            break;
        default:
            mxAssertS(0,"Unknown format");
            break;
        }
    }	
    mxAssert(result != NULL,"");
    return result;
}


/*
 * AllocateBuffers based on format type.  
 *
 * This routine assumes that the number of unskipped input fields
 * matches nlhs.
 */
PRIVATE LinkedBuffer **AllocateBuffers(
    int nlhs,
    const inputfield *field_defs,
    int nrecycle /* Number of rows to allocate or READ_WHOLE_FILE for auto grow */
    )
{
    LinkedBuffer *tmp;
    const inputfield *inputField;
    int i = 0;
    LinkedBuffer **buffers;
	
    buffers = mxCalloc(nlhs,sizeof(LinkedBuffer *));
	
    inputField = field_defs;
    while (inputField != NULL)
    {
        if (!inputField->skip)
        {
            mxAssert(i < nlhs,"");
            tmp = CreateBufferFromInputField(inputField,nrecycle);
            buffers[i] = tmp;
            i++;
        }
        inputField = inputField->next;
    }
	
    mxAssert(i == nlhs,"");
	
    return buffers;
}


/* 
 * DestroyBuffers
 */
PRIVATE void DestroyBuffers(
    LinkedBuffer *buffers[],
    int n
    )
{
    int i;
	
    for (i=0; i<n; i++)
    {
        DestroyLinkedBuffer(buffers[i]);
    }
    mxFree(buffers);
}


/*
 * CopyBuffersIntoOutputs
 */
PRIVATE void CopyBuffersIntoOutputs(
    int count,
    int nlhs,
    mxArray *plhs[],
    const inputfield *field_defs,
    LinkedBuffer *buffers[]
    )
{
    const inputfield *inputField;
    int i = 0, j = 0;
    mxArray *tmp = NULL;
	
    mxAssert(count == nlhs || nlhs == 1, "");

    inputField = field_defs;
    while (inputField != NULL)
    {
        if (!inputField->skip)
        {
            LinkedBuffer *p;
            LinkedBuffer *buffer;
            char *q;
            mxChar *ch;
            mxChar *s;
            int ii,jj,nchars,n;
            mxArray *array, **cell;
	
            mxAssert(i < count,"");

            if (count == nlhs)
            {
                /* allocate a temp vector for each output variable */
                tmp = CreateArrayFromInputField(inputField, 1);
            }
            else if (tmp == NULL)
            {
                /* allocate an array with as many columns as there are
                * input fields and reuse it for each input field. this
                * assumes that all fields use the same format.  look
                * at each input field and make sure they are the same.
                * this also assumes that each column has the same
                * number of rows */
                const inputfield *this_field = field_defs, *max_field = NULL;
                inputfieldtype type = field_defs->type;

                while (this_field != NULL)
                {
                    if (!this_field->skip)
                    {
                        /* this type should match the previous one cuz all types
                           in an autogenerated format string should be the same 
                           we only get into the "count != nlhs" block with an
                           autogenerated format string.
                           The above statement is true only when the entire data 
                           is read from a file. Not when partial data (R,C) is read. 
                           Therefore, removing the assertion.
                        */
                        /*    mxAssert(this_field->type == type,""); */

                        /* make sure we get the field which was used mode */
                        if (max_field == NULL || max_field->count < this_field->count)
                        {
                            max_field = this_field;
                        }

                    }

                    /* get the next one */
                    this_field = this_field->next;
                }
                            
                tmp = CreateArrayFromInputField(max_field, count);
            }

            /* since we are inside a "!inputField->skip" block,
             * CreateArrayFromInput should never return NULL.  If it
             * does, an out of memory error or some other error has
             * occurred and should have been caught by someone else.
             * */
            /* this assertion (as with all mxAsserts) will only fire
             * when this file is compiled with -g.  Make sure nobody
             * defines NDEBUG. */
            mxAssert(tmp != NULL, "");

            /* CopyBufferIntoArray(tmp,buffers[i],inputField,inputField->count); */
            array  = tmp;
            buffer = buffers[i];
            /* inputField = inputField; */
            n = inputField-> count;

            mxAssert(buffer != NULL,"");
            mxAssert(mxGetM(array) >= n,"");
	
            switch (inputField->type)
            {
            case LITERAL_FORMAT:
                break; /* skip literals (no output) */
            case D_FORMAT:
            case U_FORMAT:
            case F_FORMAT:
            case NUMERIC_FORMAT:
                mxAssert(mxIsNumeric(array),"");
                p = buffer->head;
                q = (char *)mxGetData(array);

                if (count == nlhs)
                {
		    /* Copy any whole buffers into the array */
		    while (p != NULL && n > p->n)
		    {
			memcpy(q,p->data,p->n*p->size);
			q += p->n*p->size;
			n -= p->n;
			p = p->next;
		    }

		    /* Copy the data in the last buffer */
		    if (p != NULL)
		    {
			memcpy(q,p->data,n*p->size);
		    }
                }
                else
                {
                    memcpy(q+j,p->data,n*p->size);
                    j += n*p->size;
                }

                break;
            case C_FORMAT:
                /* Transpose the data during the copy so that the
                   strings come out row-wise */
                mxAssert(mxGetClassID(array) == mxCHAR_CLASS,"");
                ch = (mxChar *)mxGetData(array);
                nchars = inputField->width;
                for (ii=0; ii<n; ii++)
                {
                    s = (mxChar *)GetLinkedBufferElementPtr(&buffer,ii);
                    for (jj=0; jj<nchars; jj++)
                    {
                        ch[ii + jj*n] = s[jj];
                    }
                }
                break;
            case S_FORMAT:
            case Q_FORMAT:
            case SET_FORMAT:
            case NSET_FORMAT:
                /* For the cell array formats, set each cell
                 * individually so that the member flags are set
                 * correctly */
                mxAssert(mxGetClassID(array) == mxCELL_CLASS,"");
                for (ii=0; ii<n; ii++)
                {
                    cell = (mxArray **)GetLinkedBufferElementPtr(&buffer,ii);
                    mxSetCell(array,ii,mxDuplicateArray(*cell));
                }
                break;
            default:
                mxAssertS(0,"Unknown format");
                break;
            }

            /* assign plhs */
            if (count == nlhs)
            {
                plhs[i] = tmp;
                tmp = NULL;
            } else if (i == 0) {
                /* only assign plhs once */
                plhs[0] = tmp;
            }
                           
            i++;
        }
        inputField = inputField->next;
    }
}

PRIVATE bool IsEOL(int ch1) {
    bool result;

    if (InSet((char) ch1, endofline)) {
        /* whether or not the next char is part of the EOL string,
           we're on the way out here. */
        int ch2;
        /* if EOL is multiple chars and ch1 is the first one, get the
           next char in the file and check if it's the last in EOL.
           If the next char is not the last in EOL, put it back for
           the next guy.  this allows files with \r, \r\n, and \n as
           line endings to work nicely.  this may treat \n\r as
           multiple lines.  this should be OK.  */
        if (endoflineLength == 2 && ch1 == endofline[0] &&
            (ch2 = GetCharacter()) != EOF) {
            if (ch2 != endofline[1]) {
                /* chars don't match EOL pair but 1st is in set. this
                   file may have some lines ending in only \r or only
                   \n.  allow it to pass through unscathed */
                UngetCharacter(ch2);
            }
        }
        result = true;
    } else {
        result = false;
    }
    return result;
}

/*
 * Move ahead in file to beginning of next line
 */
PRIVATE void SkipToNextLine() {
    int ch;
	
    /* Read and skip a line - IsEOL moves file pointer */
    while ((ch = GetCharacter()) != EOF && !IsEOL(ch));
    if (ch == EOF)
        UngetCharacter(ch);
}

/*
 * SkipHeader -- Skip over lines in the file
 */
PRIVATE void SkipHeader(int n)
{
    int i;
    for (i=0; i<n; i++)
    {
        SkipToNextLine();
    }
}


/*
 * NextFieldLiteralMatchesInput -- true if the next N chars in the input stream
 *                             match the literal in the format string.
 */
PRIVATE bool NextFieldLiteralMatchesInput(inputfield *thisField)
{
    bool result = false;

    if (NULL != thisField &&
        thisField->type == LITERAL_FORMAT &&
        thisField->nchars > 0) {
        int next_ch = GetCharacter();
        UngetCharacter(next_ch); 
      
        if ( next_ch == thisField->format_chars[0] )
        {
            char *nextChars;
 
            nextChars = GetNChars(thisField->nchars);
            if (NULL != nextChars) {
                if (strncmp(nextChars, thisField->format_chars, thisField->nchars) == 0) {
                    result = true;
                }
                mxFree(nextChars);
            }
        }
    }
        
    return result;
}

PRIVATE void SkipComments(void)
{
    int ch;
    bool inComment;

    if ((ch = GetCharacter()) != EOF)
    {
        switch (commentstyle)
        {
        case 0: /* none */
            break;
        case 1: /* matlab: % <characters to end of line> are ignored */
            while (ch == '%')
            {
                SkipToNextLine();
                ch = GetCharacter();
            }
            break;
        case 2: /* C: slash-star <characters> star-slash are ignored */
            while (ch == '/')
            {
                int ch2 = ch;
                ch = GetCharacter();
                if (ch == '*')
                {
                    inComment = true;
                    while ((ch = GetCharacter()) != EOF && inComment)
                    {
                        while (ch != EOF && ch == '*' && inComment)
                        {
                            ch = GetCharacter();
                            if (ch == '/')
                                inComment = false;
                        }
                    }
                }
                else
                {
                    UngetCharacter(ch);
                    ch = ch2;
                    break;
                }
            }
            break;
        case 3: /* C++: slash-slash <characters to end of line> are ignored */
            while (ch == '/')
            {
                int ch2 = ch;
                ch = GetCharacter();
                if (ch == '/')
                {
                    SkipToNextLine();
                    ch = GetCharacter();
                }
                else
                {
                    UngetCharacter(ch);
                    ch = ch2;
                    break;
                }
            }
            break;
        case 4: /* Shell: # <characters to end of line> are ignored */
            while (ch == '#')
            {
                SkipToNextLine();
                ch = GetCharacter();
            }
            break;
        default:
            mxAssert(0,"Out of range comment style");
        }
    }
    UngetCharacter(ch);
}

PRIVATE bool IsCharWhitespace(int ch,  bool skipEOL, inputfield *thisField, bool *doneSkippingEOL)
{
    bool result = false;
    /* If user over-rode default whitespace, be sure to check for NULL */
    /* NULL whitespace means "don't skip whitespace                    */
    /* For example, create a file called data.txt with this:           */
    /*
     *	this is a ship
     *      This is a ship.
     *      Hello.
     */
    /* (Each line starts with a tab.)                                  */
    /* Read the file with this:                                        */
    /* textread('data.txt','%s','delimiter','\n','whitespace','')      */
    
    if (!whitespaceIsDefault) {
        /* User specified whitespace */
        if (InSet((char)ch, whitespace)) {
            /* This char is in that set, keep skipping */
            result = true;
        }
        if ((char)ch == ' ' && *delimiter != ' ') {
            /* This char is a literal space and not a delimiter         */
            /* *** Note: this means users cannot force textread to      */
            /*           keep spaces around delimiters.                 */
            
            /* This code will keep the whitespaces if whitespace is set to '' and  */
            /* format types are %s,%q,%[...] and %[^...]. Else they are ignored.   */
            
            if(*whitespace == 0 && thisField != NULL){
                switch(thisField->type)
                {
                case S_FORMAT:
                case Q_FORMAT:
                case SET_FORMAT:
                case NSET_FORMAT:
                    result = false;
                    break;
                default:
                    result = true;
                    break;
                    
                }
            } else {
                result = true;
            }
        }
    }
    
    /* If char is in set of default whitespace, skip it                */
    else if (InSet((char)ch, defaultWhitespace)) {
        /* This char is in the default set of whitespace */
        if (!InSet((char)ch, delimiter)) {
            /* This char is not a delimiter              */
            result = true;
        }
        if ((char)ch == ' ') {
            /* This char is a literal space              */
            /* *** Note: this means users cannot force textread to turn */
            /*           multiple spaces into multiple columns.         */
            result = true;
        }
    }
    
    /* Note: endofline can only be a single char or \r\n.  If the file contains \r
       followed by no \n (or vice versa) this is OK. */
    if (skipEOL && InSet((char)ch, endofline) && !*doneSkippingEOL) {
        result = true;
        if (delimiterIsEOL)
        {
            /* 
             * if deilimiter is EOL, EOL is (by user's request)
             * not whitespace, so don't skip it 
             */
            result = false;
        }
        /* caller asked EOLs to get skipped and we're not done yet.  set the
           done yet flag (doneSkippingEOL) only if the char is both an EOL and
           delimiter char */
        if (InSet((char)ch, delimiter)) {
            /* char is both an EOL and a delimiter, only skip once */
            *doneSkippingEOL = true;
        }
    }
    return result;
}


/*
 * SkipWhiteSpace -- Skip over whitespace characters (and EOL if necessary)
 */
PRIVATE void SkipWhitespace(bool skipEOL, inputfield *thisField)
{
    int ch;
    bool doneSkippingEOL = false;

    while(1) {
        /* If the next chunk of text matches literals in the format        */
        /* string, don't skip it.                                          */
        if (NULL != thisField) {
            if (NextFieldLiteralMatchesInput(thisField->next)) {
                break;
            }
        }

        SkipComments();
        
        if ((ch = GetCharacter()) == EOF) {
            UngetCharacter(ch);
            break;
        }
        if (IsCharWhitespace(ch, skipEOL, thisField, &doneSkippingEOL)) {
            continue;
        }
        
        /* char is either not whitespace or it's an EOL we're not supposed to skip */
        UngetCharacter(ch);
        break;
    }
}

/*
 * SkipDelimiter -- Skip over a delimiter character
 */
PRIVATE void SkipDelimiter(void)
{
    int ch = GetCharacter();

    if (InSet((char)ch, delimiter))
    {
        /* char is a delimiter, skip it */

        /* special handling when char is also EOL */
        if (InSet((char)ch,endofline))
        {
            if (delimiterIsEOL)
            {
                /* delimiter is EOL, skip at least one char */

                if (endoflineLength == 2 && ch == endofline[0])
                {
                    /* if EOL is multiple chars and this is the 1st
                     * one, skip next char only if it's the 2nd one */
                    ch = GetCharacter();
                    if (ch != endofline[1])
                    {
                        /* this char is not the 2nd eol char, put it
                         * back.  this will help prevent bogus line
                         * counts when the file has a mix of \r and \n */
                        UngetCharacter(ch);
                    }
                }
            }

            else
            {
                /* delimiter is not EOL, put char back */
                UngetCharacter(ch);
            } 
        }
    }
    else
    {
        /* char is a not a delimiter, put it back */
        UngetCharacter(ch);
    }
}

/*
 * Count number of lines and build format string.  Caller is responsable for freeing result. 
 */
PRIVATE char* BuildFormatString(int *nrecycle) {
    int ch, numEOL = 0, numEOC = 0, maxEOC = 0, colsToSkip = headercolumns;
    int previousPoint = offsetFromStart, ch2 = 0;
    bool gotSpace = false, gotChar = false; 
    
    char *result = NULL;

    /* Set flag if space is defined as a delimiter*/
    bool SpaceIsDelimiter = InSet(' ', delimiter);

    /* Skip over any header lines */
    SkipHeader(headerlines);

    /* Skip leading whitespace */
    SkipWhitespace(false, NULL);

    while (true) {

        /* Skip line if this character is the comment delimiter*/ 
        SkipComments();

        /* quit iteration if character is EOF*/
        if ((ch = GetCharacter()) == EOF)
          break;
  
        /* IsEOL may move file pointer */
        if (IsEOL(ch))
        {
            /* Skip leading whitespace in new line*/
            SkipWhitespace(false, NULL);
            numEOL ++;
            if (numEOC > maxEOC)
            {
                maxEOC = numEOC;
            }
            numEOC = 0;
            gotChar = false;

            /* Only read as many lines as asked */
            if (*nrecycle != READ_WHOLE_FILE && *nrecycle == numEOL)
            {
                break;
            }

        }
        else
        {
            previousPoint = offsetFromStart;

            SkipWhitespace(false, NULL);

            /* This lets us ignore leading spaces and count other leading delimiters */
            if (InSet((char)ch, delimiter))
            {
                if (delimiter != noDelimiter && !SpaceIsDelimiter) {
                    numEOC++;
                }
            }
            else if (previousPoint < offsetFromStart)
            {
                /* This lets us count spaces inside the line only once 
                   (delimiter effectively defaults to space). 
                   Do not count leading space in each row of text as a column, therefore,
                   check if last character was an EOL.
                   */
                if (delimiter == noDelimiter || SpaceIsDelimiter) {
                    gotSpace = true;
                }
            }
            else
            {
                gotChar = true;
            }

            if (gotSpace){
                numEOC++;
                gotSpace = false;
                gotChar = true;
            }
        }
    }

    /* Handle trailing lines without EOL */
    if (numEOC > 0) {
        numEOL ++;
        if (numEOC > maxEOC) {
            maxEOC = numEOC;
        }
    }

    /* Set actual number of columns to maxEOC + 1 */
    numEOC = maxEOC + 1;

    /* Make sure line with no delims and no EOL chars is read */
    if (numEOL == 0 && gotChar)
    {
        numEOL++;
    }

    /* Validate headercolumns */
    if (headercolumns > numEOC)
    {
        ErrMsgIdAndTxt("MATLAB:dataread:TooManyHeaderColumns","Num HeaderColumns is greater than num columns in file.");
    }

    /* Update nrecycle if it's READ_WHOLE_FILE */
    if (*nrecycle == READ_WHOLE_FILE) {
        *nrecycle = numEOL;
    }

    /* Need to allocate numEOC * 3 + 1 bytes - numEOC * 3 gives space
     * for both %n and %*n +1 gives space for trailing null */
    result = mxCalloc((numEOC * 3 + 1), sizeof(char));

    for (numEOC; numEOC > 0; numEOC--) {
        if (colsToSkip == 0)
        {
            strcat(result, "%n");
        }
        else
        {
            colsToSkip--;
            strcat(result, "%*s");
        }
    }

    /* reset the file or input string pointer and the push back buffer */
    doRewind();
    InitializePushBackBuffer();

    return result;
}

/*
 * IsComment -- decide whether character is a defined comment delimiter
 * 
 * Input character.
 * Returns boolean true if character is a defined comment delimiter
*/

  


/*
 * ReadNaNInf -- Read a NaN or INF value from the file into result.
 *
 * Returns READ_SUCCESS and the result if read was successful.  
 * Returns READ_FAILURE and the result is undefined if read did not encounter a NaN or Inf.
 */
PRIVATE readStatus ReadNaNInf(
    const inputfield *inputField,
    double *result,
    bool read_signed /* True to read signed inf */
    )
{
    char ch[4];
    int n = 0;
    bool valid = false;
    int count;
	
    count = inputField->width;
	
    /* Need at least 3 characters for a NaN or Inf */
    if (count > 0 && count < 3)
        return READ_FAILURE;
		
    ch[n++] = GetCharacter();
	
    if (read_signed && ch[n-1] == '-') /* Try to get -inf or -Inf */
    {
        if (count > 0 && count < 4) /* Need at least 4 characters or a -Inf */
            goto done;
			
        ch[n++] = GetCharacter();
        if (ch[n-1] == 'I' || ch[n-1] == 'i')
        {
            ch[n++] = GetCharacter();
            if (ch[n-1] == 'n')
            {
                ch[n++] = GetCharacter();
                if (ch[n-1] == 'f')
                {
                    *result = -mxGetInf();
                    valid = true;
                }
            }
        }
    }
    else if (ch[n-1] == 'I' || ch[n-1] == 'i') /* Try to get inf or Inf */
    {
        ch[n++] = GetCharacter();
        if (ch[n-1] == 'n')
        {
            ch[n++] = GetCharacter();
            if (ch[n-1] == 'f')
            {
                *result = mxGetInf();
                valid = true;
            }
        }
    }
    else if (ch[n-1] == 'N' || ch[n-1] == 'n') /* Try to get NaN or nan */
    {
        ch[n++] = GetCharacter();
        if (ch[n-1] == 'a')
        {
            ch[n++] = GetCharacter();
            if (ch[n-1] == 'N' || ch[n-1] == 'n')
            {
                *result = mxGetNaN();
                valid = true;
            }
        }
    }

 done:
    if (valid)
        return READ_SUCCESS;
    else
    {
        while (n>0)
            UngetCharacter(ch[--n]);
        return READ_FAILURE;
    }
}


/*
 * ReadDFormat -- Read a signed integer from the file into result.
 *
 * Returns READ_SUCCESS and the result if read was successful.  
 * Returns READ_FAILURE and the result is undefined if read encountered bad data.
 *
 * When delimiter is defined, return emptyvalue for an empty field.
 */
PRIVATE readStatus ReadDFormat(
    const inputfield *inputField,
    double *result
    )
{
    int ch;
    int n = 0;
    bool negative = false;
    int count;
    int valid = false;
	
    count = inputField->width;

    if ((ch = GetCharacter()) == EOF) {
        return READ_FAILURE;
    }
    /* If delimiter is defined, empty fields return emptyvalue */
    if (InSet((char)ch,delimiter) || InSet((char)ch,endofline))
    {
        *result = emptyvalue;
        valid = true;
    }
    else
    {
        UngetCharacter(ch);
		
        /* Look for NaNInf */
        if (ReadNaNInf(inputField,result,true) == READ_SUCCESS)
            return READ_SUCCESS;

        ch = GetCharacter();
		
        /* Look for sign */
        if (ch == '-')
        {
            negative = true;
            --count;
        }
        else if (ch == '+')
        {
            negative = false;
            --count;
        }
        else
            UngetCharacter(ch);
		
        /* Read digits */
        while ((ch = GetCharacter()) != EOF && isdigit(ch) && count--)
        {
            n = n*10 + ToNumber(ch);
            valid = true;
        }
        if (negative)
            n = -n;
			
        *result = n;		
    }
	
    UngetCharacter(ch);

    if (valid) {
        return READ_SUCCESS;
    } else {
        return READ_FAILURE;
    }
}

/*
 * ReadUFormat -- Read an unsigned integer from the file into result.
 *
 * Returns READ_SUCCESS and the result if read was successful.  
 * Returns READ_FAILURE and the result is undefined if read encountered bad data.
 *
 * When delimiter is defined, return emptyvalue for an empty field.
 */
PRIVATE readStatus ReadUFormat(
    const inputfield *inputField,
    double *result
    )
{
    int ch;
    unsigned int n = 0;
    int count;
    int valid = false;
	
    count = inputField->width;
	
    if (ReadNaNInf(inputField,result,false) == READ_SUCCESS) {
        return READ_SUCCESS;
    }

    if ((ch = GetCharacter()) == EOF) {
        return READ_FAILURE;
    }

    if (isdigit(ch))
    {
        UngetCharacter(ch);

        /* Read digits */	
        while ((ch = GetCharacter()) != EOF && isdigit(ch) && count--)
        {
            n = n*10 + ToNumber(ch);
        }
        *result = n;
        valid = true;;
    }
    /* If delimiter is defined, empty fields return emptyvalue */
    else if (InSet((char)ch,delimiter) || InSet((char)ch,endofline))
    {
        *result = emptyvalue;
        valid = true;
    } 
	
    UngetCharacter(ch);	

    if (valid) {
        return READ_SUCCESS;
    } else {
        return READ_FAILURE;
    }
}

/*
 * ReadFFormat -- Read a double from the file into result.
 *
 * A floating point number has the format <sign>[0-9].[0-9][eEdD]<sign>[0-9]
 *
 * Returns READ_SUCCESS and the result if read was successful.  
 * Returns READ_FAILURE and the result is undefined if read encountered bad data.
 *
 * When delimiter is defined, return emptyvalue for an empty field.
 */
PRIVATE readStatus ReadFFormat(
    const inputfield *inputField,
    double *result
    )
{	
    int ch;
    int i = 0;
    int count;
    int prec;
    double d = emptyvalue;
    bool valid = false;
	
    count = inputField->width;
	
    /* Limit numbers to less than bufsize characters */
    if (count < 0 || count > bufsize) {
        count = bufsize-1;
    }

    prec = inputField->prec;

    if ((ch = GetCharacter()) == EOF) {
        return READ_FAILURE;
    }

    /* If delimiter is defined, empty fields return emptyvalue */
    if (InSet((char)ch,delimiter) || InSet((char)ch,endofline))
    {
        *result = emptyvalue;
        valid = true;
        UngetCharacter(ch);
    }
    else
    {
        UngetCharacter(ch);
		
        /* Look for NaNInf */
        if (ReadNaNInf(inputField,result,true) == READ_SUCCESS) {
            return READ_SUCCESS;
        }
			
        ch = GetCharacter();
		
        /* Look for sign */
        if (ch == '-' || ch == '+')
        {
            buf[i++] = ch;
            --count;
        }
        else {
            UngetCharacter(ch);
        }
		
        if (count == 0 || ch == EOF) {
            goto done;
        }
			
        /* Read leading mantissa digits */
        while ((ch = GetCharacter()) != EOF && isdigit(ch) && count--)
        {
            buf[i++] = ch;
            valid = true;
        }
		
        if (count == 0 || ch == EOF)
        {
            UngetCharacter(ch);
            goto done;
        }

        /* Look for decimal */
        if (ch == '.' && count--)
        {
            buf[i++] = ch;

            /* Read fractional part */
            while ((ch = GetCharacter()) != EOF && isdigit(ch) && count-- && prec--)
            {
                buf[i++] = ch;
                valid = true;
            }

            if (!valid || count == 0 || prec == 0 || ch == EOF)
            {
                UngetCharacter(ch);
                if (!valid) UngetCharacter('.');
                goto done;
            }
        }

        /* If no numbers have been seen yet, this is not a valid float */
        if (!valid)
        {
            UngetCharacter(ch);
            goto done;
        }
	
        /* Look for exponent */
        if (count > 1 && InSet((char)ch,expchars))
        {
            buf[i++] = 'e';
            count--;
			
            /* Look for exponent sign */
            if (count > 1 && (ch = GetCharacter()) != EOF && (ch == '-' || ch == '+'))
            {
                buf[i++] = ch;
                count--;
            } 
            else {
                UngetCharacter(ch);
            }
			
            /* Read exponent */
            while ((ch = GetCharacter()) != EOF && isdigit(ch) && count--)
            {
                buf[i++] = ch;
            }
            UngetCharacter(ch);
        }
        else {
            UngetCharacter(ch);
        }

    done:
        buf[i] = '\0';
        if (valid) {
            *result = atof(buf);
        }
    }

    if (valid) {
        return READ_SUCCESS;
    }
    else {
        return READ_FAILURE;
    }
}


/*
 * ReadSFormat -- Read a string from the file into buffer.
 *
 * Returns READ_SUCCESS and the result if read was successful.  
 * Returns READ_FAILURE and the result is undefined if read was unsuccessful.
 *
 * It is possible to read 0 characters.
 */
PRIVATE readStatus ReadSFormat(
    const inputfield *inputField,
    char *result,		/* buffer to write result into */
    int buflen		/* maximum number of characters in buffer */
    )
{
    int ch;
    int i = 0;
    int count;
    char *delim = whitespace; /* local copy of delimiters (default to whitespace) */
	
    if (delimiter != noDelimiter && delimiter != NULL)
        delim = delimiter;

    count = inputField->width;
	
    /* Limit strings to buflen-1 */
    if (count < 0 || count > buflen-1)
        count = buflen-1;
	
    /* stop fetching chars at:
       EOF
       delim char
       end of line
       end of buffer
    */

    ;
    while ((ch = GetCharacter()) != EOF) {
        if (InSet((char)ch, delim)) {
            break;
        }
        if (InSet((char)ch,endofline)) {
            /* special handling for end of line when whitespace is empty w/no delimiter */
            if (delimiter == noDelimiter && *whitespace == '\0') {
                /* keep going, fetch it all */
            } else {
                break;
            }
        }
        if (count-- == 0) {
            break;
        }
        result[i++] = ch;
    }
    UngetCharacter(ch);

    result[i++] = '\0';
	
    if (i == buflen) {
        return READ_BUFFER_OVERFLOW;
    }
    else if (i > 0) {
        return READ_SUCCESS;
    }
    else {
        return READ_FAILURE;
    }
}


/*
 * ReadQFormat -- Read a (possibly " quoted) string from the file into buffer.
 *
 * The surrounding quotes in a quoted string are not returned.  Embedded quotes
 * must show up repeated in the string.
 *
 * Returns READ_SUCCESS and the result if read was successful.  
 * Returns READ_FAILURE and the result is undefined if read was unsuccessful.
 *
 * It is possible to read 0 characters.
 */
PRIVATE readStatus ReadQFormat(
    const inputfield *inputField,
    char *result,		/* buffer to write result into */
    int buflen		/* maximum number of characters in buffer */
    )
{
    int ch;
    int i = 0;
    int count, requestedBuflen = buflen;
    bool inQuote = false;
    char *delim = whitespace; /* local copy of delimiters (default to whitespace) */
	
    if (delimiter != noDelimiter && delimiter != NULL)
        delim = delimiter;

    count = inputField->width;
	
    /* Limit strings to buflen-1 */
    if (count < 0 || count > buflen-1)
        count = buflen-1;

    /* bump buflen back by 1 to make sure we have space for the trailing null */
    buflen--;
	
    /* stop fetching chars at:
       EOF
       delim char outside quote
       end of line
       end of requested field width
       end of space in buffer
    */
    while ((ch = GetCharacter()) != EOF        &&  /* not EOF */
           (inQuote || !InSet((char)ch,delim)) &&  /* in a quote or not a delim (break at deim outside quote) */
           !InSet((char)ch,endofline)          &&  /* not end of line */
           count                               &&  /* field width not exhausted */
           buflen--)                               /* still have space in buffer */
    {
        if (ch == '"')
        {
            /* Include quote in output unless this is the first character */
            if (i > 0 && !inQuote)
            {
                result[i++] = ch;
                count--;
            }
               
            inQuote = !inQuote;
        }
        else
        {
            result[i++] = ch;
            count--;
        }
    }
    if (ch != EOF)
        UngetCharacter(ch);

    result[i++] = '\0';
	
    if (i == requestedBuflen)
        return READ_BUFFER_OVERFLOW;
    else if (i > 0)
        return READ_SUCCESS;
    else
        return READ_FAILURE; /* No way to get here? */
}


/*
 * ReadCFormat -- Read characters from the file into buffer.
 */
PRIVATE readStatus ReadCFormat(
    const inputfield *inputField,
    char *result,		/* buffer to write result into */
    int buflen		/* maximum number of characters in buffer */
    )
{
    int ch;
    int i = 0;
    int count;
	
    count = inputField->width;
    mxAssert(count != UNSPECIFIED,"");
	
    /* Limit strings to buflen-1 */
    if (count < 0 || count > buflen-1)
        count = buflen-1;
	
    while ((ch = GetCharacter()) != EOF && count--)
    {
        result[i++] = ch;
    }
    if (ch != EOF)
        UngetCharacter(ch);

    result[i++] = '\0';
	
    if (i == buflen)
        return READ_BUFFER_OVERFLOW;
    else if (i > inputField->width)
        return READ_SUCCESS;
    else
        return READ_FAILURE;
}


/*
 * ReadSetFormat -- Read characters that match set from the file into buffer.
 */
PRIVATE readStatus ReadSetFormat(
    const inputfield *inputField,
    char *result,		/* buffer to write result into */
    int buflen		/* maximum number of characters in buffer */
    )
{
    int ch;
    int i = 0;
    int count;
    const char *set;
    int nchars;
	
    count = inputField->width;
    set = inputField->format_chars;
    nchars = inputField->nchars;
	
    /* Limit strings to buflen-1 */
    if (count < 0 || count > buflen-1)
        count = buflen-1;

    while ((ch = GetCharacter()) != EOF && InSetn((char)ch,set,nchars) && count--)
    {
        result[i++] = ch;
    }
    if (ch != EOF)
        UngetCharacter(ch);

    result[i++] = '\0';
	
    if (i == buflen)
        return READ_BUFFER_OVERFLOW;
    else if (i > 1) /* Must get at least one match */
        return READ_SUCCESS;
    else
        return READ_FAILURE;
}


/*
 * ReadNsetFormat -- Read characters not in set from the file into buffer.
 */
PRIVATE readStatus ReadNsetFormat(
    const inputfield *inputField,
    char *result,		/* buffer to write result into */
    int buflen		/* maximum number of characters in buffer */
    )
{
    int ch;
    int i = 0;
    int count;
    const char *set;
    int nchars;
	
    count = inputField->width;
    set = inputField->format_chars;
    nchars = inputField->nchars;
	
    /* Limit strings to buflen-1 */
    if (count < 0 || count > buflen-1)
        count = buflen-1;
	
    while ((ch = GetCharacter()) != EOF && !InSetn((char)ch,set,nchars) && count--)
    {
        result[i++] = ch;
    }
    if (ch != EOF)
        UngetCharacter(ch);

    /* special case for set == '\n' */
    if (set[0] == '\n')
    {
        /* user specified \n as char to stop at.  if file has \r\n,
           skip \r in result */
        if (endoflineLength == 2 && result[i-1] == '\r')
        {
            i--;
        }
    }

    result[i++] = '\0';

    if (i == buflen)
        return READ_BUFFER_OVERFLOW;
    else if (i > 1 || (i == 1 && IsEOL(ch)))
        /* Must get at least one character except at EOL */
        return READ_SUCCESS;
    else
        return READ_FAILURE;
}


/*
 * ReadLiteralFormat -- Read a literal from the file into buffer.
 */
PRIVATE readStatus ReadLiteralFormat(
    const inputfield *inputField,
    char *result,		/* buffer to write result into */
    int buflen		/* maximum number of characters in buffer */
    )
{
    int ch;
    int i = 0;
    int j = 0;
    int count;
    const char *literal;
    int nchars;
    
    count = inputField->width;
    literal = inputField->format_chars;
    nchars = inputField->nchars;
    
    /* Limit strings to buflen-1 */
    if (count < 0 || count > buflen-1)
        count = buflen-1;
    
    while ((ch = GetCharacter()) != EOF && i < nchars && ch == literal[i])
    {
        result[i++] = ch;
    }

    if (ch != EOF)
        UngetCharacter(ch);

    result[i++] = '\0';

    if (i == buflen)
        return READ_BUFFER_OVERFLOW;
    else if (i > nchars)
        return READ_SUCCESS;
    else {
        return READ_FAILURE;
    }
}

/*
 * Display helpful error message traceback
 */
PRIVATE void ErrorAndShowInfo(
    inputfieldtype t,
    int i,
    int j,
    readStatus status
    )
{
    int n;
    int ch;
    char buf[200];
    char buf_id[31];
	
    if (status == READ_BUFFER_OVERFLOW)
    {
        sprintf(buf,"Buffer overflow (bufsize = %d) while reading %s from\nfile (row %d, field %d)."
                    " Use 'bufsize' option. See HELP TEXTREAD.",
                bufsize,FieldTypeStr(t),i+1,j+1);
        sprintf(buf_id, "MATLAB:dataread:BufferOverload");
    }
    else
    {
        sprintf(buf,"Trouble reading %s from file (row %d, field %d) ==> ",
                FieldTypeStr(t),i+1,j+1);
        sprintf(buf_id,"MATLAB:dataread:TroubleReading");
    }
    n = strlen(buf);
	
    /* Append the rest of the unread line to error message */
    while ((ch = GetCharacter()) != EOF && n < 100 && ch != '\n' && ch != '\r')
    {
        buf[n++] = ch;
    }
    /* Add a trailing \n at the end of a line */
    if (ch == '\n' || ch == '\r')
    {
        buf[n++] = '\\';
        buf[n++] = 'n';
    }
    buf[n] = '\0';
    ErrMsgIdAndTxt(buf_id, buf);
}

PRIVATE void setupDefaults(void)
{
    whitespaceIsDefault = true;
    whitespace = mxCalloc(strlen(defaultWhitespace)+1,sizeof(char));
    strcpy(whitespace,defaultWhitespace);

    GetDefaultEndofline();

    delimiter = noDelimiter; /* Default is none */
    commentstyle = 0; /* Default is none */
    bufsize = DEFAULTBUFSIZE;
    headerlines = 0; /* Default is no header */
    expchars = defaultExpchars;
}

PRIVATE bool atEOF(void)
{
    if (fp != NULL)
        return feof(fp);
    else
        return (*inputCurrent == '\0');
}


PRIVATE readStatus ReadNextInputField(inputfield *inputField, LinkedBuffer *buffers[], int i, int *j)
{
    readStatus status;

    switch (inputField->type)
    {
        mxArray			**pa;
        double 			d,*pd;
        int 			n;
        mxChar 			*p;
        char 			*q;
            
    case LITERAL_FORMAT:
        status = ReadLiteralFormat(inputField,buf,bufsize);
        mxAssert(inputField->skip,"Literals are always skipped.");
        break;
    case D_FORMAT:
        status = ReadDFormat(inputField,&d);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pd = (double *)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pd = d;
        }
        break;
    case U_FORMAT:
        status = ReadUFormat(inputField,&d);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pd = (double *)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pd = d;				
        }
        break;
    case F_FORMAT:
        status = ReadFFormat(inputField,&d);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pd = (double *)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pd = d;				
        }
        break;
    case NUMERIC_FORMAT: /* read number (either float or int) */
        status = ReadFFormat(inputField,&d);
        if (status != READ_SUCCESS)
        {
            status = ReadDFormat(inputField,&d);
        }
        if (!inputField->skip && status == READ_SUCCESS) {
            pd = (double *)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pd = d;				
        }
        break;
    case C_FORMAT:
        status = ReadCFormat(inputField,buf,bufsize);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            p = (mxChar *)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            q = buf;
            n = inputField->width;
            while (*q != '\0' && n--)
            {
                *p++ = *q++;
            }
        }
        break;
    case S_FORMAT:
        status = ReadSFormat(inputField,buf,bufsize);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pa = (mxArray **)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pa = mxCreateString(buf);
        }
        break;
    case Q_FORMAT:
        status = ReadQFormat(inputField,buf,bufsize);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pa = (mxArray **)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pa = mxCreateString(buf);
        }
        break;
    case SET_FORMAT:
        status = ReadSetFormat(inputField,buf,bufsize);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pa = (mxArray **)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pa = mxCreateString(buf);
        }
        break;
    case NSET_FORMAT:
        status = ReadNsetFormat(inputField,buf,bufsize);
        if (!inputField->skip && status == READ_SUCCESS)
        {
            pa = (mxArray **)GetLinkedBufferElementPtrWithGrowth(&buffers[(*j)++],i);
            *pa = mxCreateString(buf);
        }
        break;
    case UNKNOWN_FORMAT:
        ErrMsgIdAndTxt("MATLAB:dataread:UnknownFormatInFile","Attempt to read unknown format from file.");
        break;
    }
    return status;
}


/*********************************************************
 * Main routines 
 *********************************************************/
 
/*
 * ReadFile -- Read file using inputfield definitions into buffers.
 *             The arrays are grown if necessary.
 */
PRIVATE void ReadFile(
    LinkedBuffer *buffers[],
    inputfield *field_defs,
    int nrecycle /* Number of times to reuse formats or READ_WHOLE_FILE for read whole file */
    )
{
    int i = 0;
    int column = 0;
    int field;
    inputfield *inputField;

    SkipHeader(headerlines);

    while (!atEOF() && (nrecycle == READ_WHOLE_FILE || i < nrecycle)) {
        column = 0;
        field = 0;
        inputField = field_defs;
        
        /* This will skip any EOL chars from the previous line. */
        SkipWhitespace(true, inputField);

        /* If delimiter is whitespace, SkipWhitespace will ignore it - be sure to skip leading stuff */
        if (delimiter != noDelimiter && delimiter != NULL && whitespace != NULL && *whitespace != '\0') {
            int ch;
            /* skip leading whitespace */
            while ((ch = GetCharacter()) != EOF &&
                   InSet((char)ch, defaultWhitespace) && !InSet((char)ch, delimiter));
            UngetCharacter(ch);
        }

        while (!atEOF() && inputField != NULL) {
            bool alreadySkippedWhiteSpace = false;
            readStatus status = ReadNextInputField(inputField, buffers, i, &column);
                
            if (status != READ_SUCCESS) {
                if (returnonerror) {
                    return;
                }
                ErrorAndShowInfo(inputField->type,i,field,status);
            }
            
            if ((inputField->next && inputField->next->type == LITERAL_FORMAT) || (whitespace != NULL && *whitespace != '\0')) {
                SkipWhitespace(false, inputField); /* need this to handle %d with "123 , 456" with %d,%d*/
                alreadySkippedWhiteSpace = true;
            }                    

            field++;
            inputField->count++;
            inputField = inputField->next;

            if (delimiter != noDelimiter && delimiter != NULL ) {
                if (!alreadySkippedWhiteSpace) {
                    SkipWhitespace(false, inputField); /* need this to handle %d with "123 , 456" */
                }
                SkipDelimiter();
                if (NULL != inputField) {
                    SkipWhitespace(false, inputField);
                }
            }
        }
        i++;
    }
}

/*
 * mexFunction gateway
 */
void mexFunction(int nlhs,
                 mxArray *plhs[],
                 int nrhs,
                 const mxArray *prhs[])
{
    char *fileOrString = NULL;
    char *filename = NULL;
    char *format = NULL;
    int nrecycle = READ_WHOLE_FILE;
    inputfield *field_defs = NULL;
    inputfield *inputField = NULL;
    int count, paramStart;
    LinkedBuffer **buffers;
    int i;
    bool userProvidedFormat = true;
    
    /* First time though define the AtExit fcn */
    if (firsttime)
    {
        if (mexAtExit(AtExitFcn))
            ErrMsgIdAndTxt("MATLAB:dataread:AtExitInstallFailed","Couldn't install the AtExit function.");
            firsttime = false;
    }

    /* 
     * Input argument checking 
     */
	 
    if (nrhs < 2)
        ErrMsgIdAndTxt("MATLAB:dataread:tooManyInputs","Not enough input arguments.");
		
    if (!mxIsChar(prhs[0]) || 
        (fileOrString = muGetString(prhs[0],"Source")) == NULL ||
       (strcmp(fileOrString, "file") != 0 && strcmp(fileOrString, "string") != 0))
    {
        ErrMsgIdAndTxt("MATLAB:dataread:InvalidFirstInput","First input must be 'file' or 'string'.");
    }

    if (!mxIsChar(prhs[1]))
    {
        ErrMsgIdAndTxt("MATLAB:dataread:SecondInputFilenameOrString","Second input must be a filename or string to parse.");
    }

    initGlobals();

    if (strcmp(fileOrString, "file") == 0)
    {
        filename = muGetString(prhs[1],"Filename");


        /* Close any open files */
        AtExitFcn();

        /* Try to open the file assuming we have a full path (calling M-file handles "which"). */
        /** Calling fopen with rb supresses translations involving carriage-return and linefeed. */
        /** This ensures consistent end of line handling between Win32 and Unix. */
        fp = fopen(filename,"rb");	
        if (fp == NULL)
        {
            ErrMsgIdAndTxt("MATLAB:dataread:noSuchFile","File not found or permission denied.");
        }
        InitializePushBackBuffer();
    }
    else
    {
        inputStart = muGetString(prhs[1],"Input String");
        inputCurrent = inputStart;
        inputOverrun = 0;
    }

    /*
     * Validate input args. (... == 'file' or 'string' followed by filename or string to parse
     *
     *  [a,b,c,...,z] = textread(..., format, nrecycle, p, v, ...)
     *  [a,b,c,...,z] = textread(..., format, nrecycle)
     *  [a,b,c,...,z] = textread(..., format, p, v, ...)
     *
     *  If format is empty string, nlhs must be zero, 1, or num fields.
     *
     *  a = textread(..., '', nrecycle, p, v, ...)
     *  a = textread(..., '', nrecycle)
     *  a = textread(..., '', p, v, ...)
     *
     *  No format string or args is OK too.
     *
     *  a = textread(...)
     *
     */

    if (nrhs == 2)
    {
        setupDefaults();
    }
    else
    {
        if (!mxIsChar(prhs[2]) && !mxIsEmpty(prhs[2]))
        {
            ErrMsgIdAndTxt("MATLAB:dataread:ThirdInputEmptyOrNonString","Third input must be empty or a format string.");
        }

        format = muGetStringCC(prhs[2],"Format");
        /* format string can be empty or any string */
        if (*format != '\0' && (field_defs = ParseFormat(format)) == NULL)
        {
            ErrMsgIdAndTxt("MATLAB:dataread:InvalidFormatString","Badly formed format string.");
        }
    }

    /* three args: ... and format, use defaults for all options */
    if (nrhs == 3)
    {
        setupDefaults();
    }

    else if (nrhs > 3) 
    {
        paramStart = 3;

        /* try to get nrecycle (int) */
        if (muIsDoubleScalar(prhs[3]))
        {
            /* textread(fn, fmt, nrecycle) */
            nrecycle = (int) muGetDoubleScalar(prhs[3],"Format recycle count");
            paramStart = 4;
            if (nrhs == 4)
            {
                setupDefaults();
            }
        }

        /* Consistency check:  Param/value pairs come in pairs */
        if ((nrhs - paramStart) % 2 != 0)
        {
             ErrMsgIdAndTxt("MATLAB:dataread:ParameterWithoutValue","Param/value pairs must come in pairs." );
        }
			
        matches = mxCalloc(nrhs,sizeof(int));
		
        /* Get parameter values if they exist */
        LookforAndGetEndofline(prhs,paramStart,nrhs);
        LookforAndGetDelimiter(prhs,paramStart,nrhs);  /* must occur before getWhitespace */
        LookforAndGetExpchars(prhs,paramStart,nrhs);
        LookforAndGetWhitespace(prhs,paramStart,nrhs);
        commentstyle = LookforAndGetCommentStyle(prhs,paramStart,nrhs);
        returnonerror = LookforAndGetReturnOnError(prhs,paramStart,nrhs);
        LookforAndGetBufsize(prhs,paramStart,nrhs);
        LookforAndGetEmptyValue(prhs,paramStart,nrhs);
        LookforAndGetHeaderLines(prhs,paramStart,nrhs);
        LookforAndGetHeaderColumns(prhs,paramStart,nrhs);
		
        if (delimiter != noDelimiter && delimiter != NULL)
        {
            /* if user specified \n as delimiter map it to correct EOL based on file */
            /* only do this if EOL is \r\n or \r */
            if (strlen(delimiter) == 1 && delimiter[0] == '\n')
            {
                delimiterIsEOL = true;
                mxAssert(endoflineLength > 0 && endoflineLength < 3, "Endoflinelength of of legal range");
                if ((endoflineLength == 2 && endofline[0] == '\r' && endofline[1] == '\n') ||
                    (endoflineLength == 1 && endofline[0] == '\r'))
                {
                    mxFree(delimiter);
                    delimiter = mxCalloc(endoflineLength+1, sizeof(char));
                    strcpy(delimiter, endofline);
                }
            }
            /* make sure there is no overlap between whitespace and delimiter */
            if (!whitespaceIsDefault)
            {
                int i, j;
                bool warningShown = false;
                j = (int)strlen(delimiter);
                for (i = 0; i < j; i++) {
                    if (InSet(delimiter[i], whitespace)) {
                            mexWarnMsgIdAndTxt("MATLAB:dataread:CharacterInWhitespaceAndDelimiter","Characters can not be used in both whitespace and delimiter lists.\n"
                                  "Removing delimiter chars from whitespace list.");
                        break;
                    }
                }
                RemoveDelimiterFromList(whitespace);
            }
            if (!delimiterIsEOL) {
                RemoveDelimiterFromList(endofline);
            }
        }

        /* Check for unknown param/value pairs 
         * (i.e. parameters that haven't been matched) 
         */
        for (i=paramStart; i<nrhs; i+=2)
        {
            if (matches[i] == 0)
            {
                char *option;
                char *error_message;
				
                option = muGetString(prhs[i],"Option");				
                error_message = mxCalloc(strlen(option) + 20,sizeof(char));

                sprintf(error_message,"Unknown option '%s'.",option);

                ErrMsgIdAndTxt("MATLAB:dataread:UnknownOption",error_message);
            }
        }
		
        mxFree(matches);
        matches = NULL;
    }
	
    /* Initialize buf */
    buf = mxCalloc(bufsize,sizeof(char));

    /* build format string from file if it's not been set */
    if (format == NULL || *format == '\0')
    {
        format = BuildFormatString(&nrecycle);
        userProvidedFormat = false;
    }


    /* Parse format (if it hasn't been parsed) and extract input field
       definitions */
    if (field_defs == NULL)
    {
        field_defs = ParseFormat(format);
    }
    if (field_defs == NULL)
    {
        ErrMsgIdAndTxt("MATLAB:dataread:InvalidFormatString","Badly formed format string.");
    }

    /* count number of fields in format string */
    inputField = field_defs;
    count = 0;
    while (inputField != NULL)
    {
        if (!inputField->skip) {
            ++count;
        }
        inputField = inputField->next;
    }
    
    /* Handle the zero output case (for ans) */
    if (nlhs == 0)
    {
        nlhs = 1;
    }

    /* Check to make sure there are the right number of outputs */
    if (userProvidedFormat && count != nlhs)
    {
        ErrMsgIdAndTxt("MATLAB:dataread:IncorrectNumberOfOutputs","Number of outputs must match the number of unskipped input fields.");

    }


    buffers = AllocateBuffers(count,field_defs,nrecycle);

    ReadFile(buffers,field_defs,nrecycle);

    AtExitFcn();

    CopyBuffersIntoOutputs(count,nlhs,plhs,field_defs,buffers);

    DestroyBuffers(buffers,count); 
    DestroyInputfieldList(field_defs);
    DestroyWhitespace();
    DestroyEndofline();
    DestroyDelimiter();
    DestroyExpchars();
    if (filename != NULL)
    {
        mxFree(filename);
        filename = NULL;
    }
    if (inputStart != NULL)
    {
        mxFree(inputStart);
        inputStart = NULL;
        inputCurrent = NULL;
    }
    mxFree(format);
    mxFree(buf);
	
}
