/* $Revision: 1.1.6.1 $  $Date: 2003/07/11 15:52:41 $ */

#include <windows.h>
#include <vfw.h>

#ifdef __cplusplus
extern "C"
{
#endif

extern CRITICAL_SECTION AVI_NODE_ACCESS_SECTION;

typedef struct node
{
	int number;              /* Unique identifier */
	PAVIFILE pfile;          /* File handle */
	PAVISTREAM psCompressed; /* Stream handle */
	struct node *next;
	struct node *previous;
    CRITICAL_SECTION section; /* Used to prevent multiple thread entries. */
} NodeType;

void cleanList(void);

void InitNode(void);

int addNodetoList(PAVIFILE,PAVISTREAM);

NodeType *FindNodeInList(int);

void deleteNodeFromList(int);

int openFile(const char *filename);

void writeFrame(int identifier, char *StreamName, int FrameNumber, unsigned char *frameData, char* compression, long width, long height, int bitcount, int ImageSize, int ClrUsed, unsigned char *colormap, int Quality, int FramesPerSecond, int KeyFrameRate);

void closeFile(int identifier);

void exitAVI(void);

char ** getVidCodecs(void);

int getNumVidCodecs(void);

#ifdef __cplusplus
} /* extern "C" */
#endif

