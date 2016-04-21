/* $Revision: 1.1.2.1 $ */

#include "udpcom.h"

static WINUDP udp[UDP_MAX_CHANNELS + 1];
static int DescArray[UDP_MAX_CHANNELS] = { 0, 0 };

static void WSAexit();
static int WSAinit();
static int waitSelect(SOCKET * waitsock, int waittime);
static int createDesc();
static int closeDesc(int Desc);

static int reuseSocket(SOCKET sock) {
    BOOL reuse = 1;
    int err;

    err = setsockopt(sock, SOL_SOCKET, SO_REUSEADDR,
                     (char *) &reuse, sizeof(reuse));
    if (err == SOCKET_ERROR) {
        printf("Error setting reuse socket: %d\n", WSAGetLastError());
    }
    return err;
}

static int bindSocket(SOCKET sock, int Port, SOCKADDR_IN * sockAddr) {
    int err;

    sockAddr->sin_port        = htons((unsigned short) Port);
    sockAddr->sin_family      = AF_INET;
    sockAddr->sin_addr.s_addr = INADDR_ANY;
    err = bind(sock, (SOCKADDR *) sockAddr, sizeof(SOCKADDR_IN));
    if (err)
        printf("Error %d binding socket to port %u\n", WSAGetLastError(),
               (unsigned int) Port);
    return err;
}

/**
 * Address:    IP Address to send to.
 * localPort:  Local Port (-1 if auto-assign).
 * remotePort: Remote Port (Port to send to)
 * Broadcast:  Boolean, yes or no.
 * BufferSize: # bytes in each q element.
 *
 * Returns: A descriptor (>= 0), or an appropriate error.
 */
static int udpOpenSend(const char *Address, int localPort, int remotePort,
                       int Broadcast, int bufferSize) {
    int Desc = -1;
    int Error = 0;

    if (WSAinit() != 0)
        return ERR_NO_IP_STACK;
    Desc = createDesc();
    if (Desc < 0)
        return ERR_NO_FREE_PORT;

    /* Open the socket */
    udp[Desc].sock = socket(PF_INET, SOCK_DGRAM, 0);
    if (udp[Desc].sock == INVALID_SOCKET) {
        printf("Invalid Socket Error %i   %i\n", udp[Desc].sock,
               WSAGetLastError());
        udpClose(Desc);
        return ERR_SOCKET_INIT;
    }
    if (reuseSocket(udp[Desc].sock)) {
        return ERR_SOCKET_INIT;
    }
    if (localPort != -1 &&
        bindSocket(udp[Desc].sock, localPort, &udp[Desc].sockServer)) {
        return ERR_SOCKET_BIND;
    }
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //  Init the send struct
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    udp[Desc].sockSend.sin_family      = PF_INET;
    udp[Desc].sockSend.sin_port        = htons(remotePort);
    udp[Desc].sockSend.sin_addr.s_addr = inet_addr(Address);
    if (Broadcast) {
        int x = 1;
        int err;

        //Broadcast Packet max 512Byte;
        udp[Desc].sockSend.sin_addr.s_addr = INADDR_BROADCAST;
        err = setsockopt(udp[Desc].sock, SOL_SOCKET, SO_BROADCAST,
                         (char *) &x, sizeof(int));
        if (err == SOCKET_ERROR) {
            udpClose(Desc);
            return ERR_SOCKET_BROAD;
        }
    }
    udp[Desc].sockStatus = SEND_SOCKET;
    return Desc;
}

/**
 * Port:       IP Port to receive From
 * From:       IP Address to restrict received packets to, NULL for no
 *             restrictions.
 * BufferSize: How many bytes in each packet (size of each data set).
 *
 * Returns descriptor if ok, appropriate error if not.
 */
static int udpOpenReceive(int Port, const char *From, int bufferSize) {
    int Desc;

    if (WSAinit() != 0)
        return ERR_NO_IP_STACK;
    Desc = createDesc();
    if (Desc < 0)
        return ERR_NO_FREE_PORT;
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // Open a Socket
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    udp[Desc].sock = socket(PF_INET, SOCK_DGRAM, 0);
    if (udp[Desc].sock == INVALID_SOCKET) {
        printf("Invalid Socket Error %i   %i\n", udp[Desc].sock,
               WSAGetLastError());
        udpClose(Desc);
        return ERR_SOCKET_INIT;
    }
    if (reuseSocket(udp[Desc].sock)) {
        return ERR_SOCKET_INIT;
    }
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //  Init the receive struct
    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if (bindSocket(udp[Desc].sock, Port, &udp[Desc].sockServer)) {
        return ERR_SOCKET_BIND;
    }

    udp[Desc].sockSend.sin_addr.s_addr =
        (From == NULL) ? INADDR_ANY : inet_addr(From);
    udp[Desc].sockStatus = REC_SOCKET;
    return Desc;
}

/////////////////////////////////////////////////////////////////////////////
static void udpClose(int udpDesc) {
    if (closeDesc(udpDesc) == 1) {
        closesocket(udp[udpDesc].sock);
        WSAexit();
    }
}

/**
 * what:   Data to send.
 * length: How long the data is.
 *
 * Returns 0 if success, ERR_INVALID_DESC or ERR_FIFO_FULL otherwise.
 */
static int udpSend(int udpDesc, const unsigned char *what, int length) {
    int err;
    int len = sizeof(SOCKADDR);

    if ((udpDesc < 0) || (udpDesc >= UDP_MAX_CHANNELS)) {
        return ERR_INVALID_DESC;
    }
    err = sendto(udp[udpDesc].sock, (void *) what, length, 0,
                 (LPSOCKADDR) & udp[udpDesc].sockSend, len);
    if (err == SOCKET_ERROR) {
        printf("Error: send %i   %i\n", err, WSAGetLastError());
        return ERR_SENDING;
    }
    return 0;
}

/**
 * what:   Put the received data is.
 * length: How long the "what" array is.
 *
 * Returns 0 if new data, ERR_FIFO_EMPTY if no new data. ERR_INVALID_DESC
 * is obvious.
 */
static int udpReceive(int udpDesc, unsigned char *what,
                      int length, unsigned long *from) {
    unsigned long mes = 0;

    //unsigned long mess=0;
    int err;
    int len = sizeof(SOCKADDR);
    int turn = 0;

    if (udpDesc < 0 || udpDesc >= UDP_MAX_CHANNELS)
        return ERR_INVALID_DESC;

    err = ioctlsocket(udp[udpDesc].sock, FIONREAD, &mes);
    if (err == SOCKET_ERROR) {
        printf("Error checking socket I/O status: %d\n", WSAGetLastError());
        return ERR_SOCKET_IOCTL;
    }
    if (mes == 0)                       /* nothing to read */
        return ERR_FIFO_EMPTY;
    err = recvfrom(udp[udpDesc].sock, (void *) what, length, 0,
                   (LPSOCKADDR) & udp[udpDesc].sockFrom, &len);

    if (udp[udpDesc].sockSend.sin_addr.s_addr != htonl(INADDR_ANY)) {
        if (udp[udpDesc].sockSend.sin_addr.s_addr !=
            udp[udpDesc].sockFrom.sin_addr.s_addr) {
            return ERR_FIFO_EMPTY;
        }
    }
    if (from != NULL)
        /* Return the sender's ip address in from */
        *from = udp[udpDesc].sockFrom.sin_addr.s_addr;
    return 0;
}

/////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------
static void WSAexit() {
    int err;

    err = WSACleanup();
}

//----------------------------------------------------
static int WSAinit()            // Return:  ok: 0     Error: -1
{
    int err;
    WORD wVersionRequested;
    WSADATA wsaData;

    wVersionRequested = MAKEWORD(1, 1);
    err = WSAStartup(wVersionRequested, &wsaData);
    if (err != 0) {
        printf("Error: Winsock not found");
        return -1;
    }
    return 0;
}

//-------------------------------------------------------------
static int createDesc() {
    int counter;

    for (counter = 0; counter < UDP_MAX_CHANNELS; counter++) {
        if (udp[counter].sockStatus == UNUSED) {
            return counter;
        }
    }
    return -1;
}

//-------------------------------------------------------------
static int closeDesc(int Desc) {
    if (Desc >= 0 && Desc < UDP_MAX_CHANNELS) {
        if (udp[Desc].sockStatus != UNUSED) {
            udp[Desc].sockStatus = UNUSED;
            return 1;
        }
    }
    return 0;
}

//-------------------------------------------------------------
