/* $Revision: 1.1.2.2 $ */
#ifndef _udpcom
#define _udpcom

#include <winsock.h>

typedef struct win_udp {
    SOCKET sock;
    unsigned short int sockStatus;
    SOCKADDR_IN sockSend;
    SOCKADDR_IN sockServer;
    SOCKADDR_IN sockFrom;
    int VariablePort;
} WINUDP;

typedef enum {
    UNUSED      = 0x0000,
    SEND_SOCKET = 0x0001,
    REC_SOCKET  = 0x0002
} SOCKET_STATUS;


typedef enum {
    ERR_FIFO_EMPTY   =  -1,
    ERR_FIFO_FULL    =  -2,
    ERR_INVALID_DESC =  -3,
    ERR_MEM_ALLOC    =  -4,
    ERR_NO_FREE_PORT =  -5,
    ERR_NO_IP_STACK  =  -6,
    ERR_PORT_IN_USE  =  -7,
    ERR_RECEIVING    =  -8,
    ERR_SENDING      =  -9,
    ERR_SOCKET_IOCTL = -10,
    ERR_SOCKET_INIT  = -11,
    ERR_SOCKET_BIND  = -12,
    ERR_SOCKET_BROAD = -13
} UDP_ERRORS;

typedef unsigned char uchar_t;

#define UDP_MAX_CHANNELS 32

static int udpOpenSend(const char *Address, int localPort, int remotePort,
                       int Broadcast, int bufferSize);

static int udpOpenReceive(int Port, const char *From, int bufferSize);

static int udpSend(int udpDesc, const uchar_t *what, int length);

static int udpReceive(int udpDesc, uchar_t *what, int length,
                      unsigned long *from);

static void udpClose(int udpDesc);

#endif  /*_udpcom*/
