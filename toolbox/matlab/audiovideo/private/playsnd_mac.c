/* $Revision: 1.1.6.1 $ */
/*
 *  PlaySound - A MATLAB MEX-file to play sound on the Macintosh
 *
 *  By Malcolm Slaney (ATG Perception Systems, Apple Computer) March 1991.
 *      Adapted to Mac OS X by Scott French, March 2002.
 *
 *  This is experimental software.  There is no warranty.
 *
 *  Warranty Information
 *  Even though Apple has reviewed this software, Apple makes no warranty
 *  or representation, either express or implied, with respect to this
 *  software, its quality, accuracy, merchantability, or fitness for a
 *  particular purpose.  As a result, this software is provided "as is,"
 *  and you, its user, are assuming the entire risk as to its quality
 *  and accuracy.
 *
 * Copyright (c) 1991-1994  Apple Computer Inc.
 * This program may be used, copied, modified, and redistributed freely
 * so long as this notice (authorship, warranty and copyright) remains intact.
 *
 * Copyright (c) 1994 Interval Research, Inc.
 * This program may be used, copied, modified, and redistributed freely
 * so long as this notice (authorship, warranty and copyright) remains intact.
 *
 *  To test, try:
        clear c d
        a=sin((1:10000)/2);
        b=sin((1:10000)/4);
        c(2,:) = a;
        d(2,:) = b;
        playsound([c d/256 flipud(d) flipud(c/256)],22254)
        playsound([c d/256 flipud(d) flipud(c/256)]',22254)
 */

#include <stdio.h>
#include <math.h>
#include <ctype.h>
#include <Carbon.h>
#include <string.h>

#include "mex.h"

#define MAX_TEXT    100     /* Maximum size of string option */

#define PLAYSND_COMPONENT "MATLAB:playsnd:"

static Boolean Has16BitSound(void)
{
    OSErr       iErr;
    long        theSoundBits;

    iErr = Gestalt(gestaltSoundAttr, &theSoundBits);

    if ((iErr == noErr) &&
        (theSoundBits & (long) (1 << gestalt16BitSoundIO)) &&
        (theSoundBits & (long) (1 << gestalt16BitAudioSupport)))
    {
        return 1;
    }
    else
        return 0;
}

static void ConvertToByte(double *fp, unsigned char *bp, long n)
{
    double maximum, minimum, *p, *end, scale;

    p = fp;
    end = fp + n;

    maximum = minimum = *fp;

    while (p < end)
    {
        if (*p < minimum)
            minimum = *p;
        else if (*p > maximum)
            maximum = *p;
        p++;
    }

    if (-minimum > maximum)
        maximum = -minimum;
    else if (-maximum < minimum)
        minimum = -maximum;

    if (minimum < -1 || maximum > 1)
        scale = 255.0 / (maximum-minimum);
    else
        scale = 255.0 / 2;

    while (fp < end)
        *bp++ = (int) ((*fp++ - minimum) * scale);
}

static void ConvertToShort(double *fp, unsigned char *bp, long n)
{
    double      maximum, minimum, *p, *end, scale;
    short       *sp;

    sp = (short *) bp;

    p = fp;
    end = fp + n;

    maximum = minimum = *fp;

    while (p < end)
    {
        if (*p < minimum)
            minimum = *p;
        else if (*p > maximum)
            maximum = *p;

        p++;
    }

    if (-minimum > maximum)
        maximum = -minimum;
    else if (-maximum < minimum)
        minimum = -maximum;

    if (minimum < -1 || maximum > 1)
        scale = 32767.0 / maximum;
    else
        scale = 32767.0;

    while (fp < end)
        *sp++ = (int) (*fp++ * scale);
}

static void TransposeByteArray(unsigned char *data, long frames)
{
    unsigned char   *ip, *ip2, *op;
    unsigned char   *Buffer;
    long            i;

    Buffer = (unsigned char *) utMalloc(frames);

    i = frames;             /* Copy second half into temp buffer */
    op = Buffer;
    ip = data+frames;
    while (i-- > 0)
        *op++ = *ip++;

    i = frames;
    op = data + frames + frames - 1;
    ip = data + frames - 1;
    ip2 = Buffer + frames - 1;
    while (i-- > 0)
    {
        *op-- = *ip2--;
        *op-- = *ip--;
    }

    utFree(Buffer);
}

static void TransposeShortArray(short *data, long frames)
{
    short       *ip, *ip2, *op;
    short       *Buffer;
    long        i;

    Buffer = (short *) utMalloc(sizeof(short) * frames);

    i = frames;             /* Copy second half into temp buffer */
    op = Buffer;
    ip = data+frames;
    while (i-- > 0)
        *op++ = *ip++;

    i = frames;
    op = data + frames + frames - 1;
    ip = data + frames - 1;
    ip2 = Buffer + frames - 1;
    while (i-- > 0)
    {
        *op-- = *ip2--;
        *op-- = *ip--;
    }

    utFree(Buffer);
}

static void PlaySound(unsigned char *data, unsigned long MacSoundSize, 
                      unsigned long MacSampleRate,
                      int channels, int bitsPerSample)
{
    long            SndResourceNumber = 0;
    int             err;
    SndCommand      Command;
    SndChannelPtr   ChannelP;
    ExtSoundHeader  Header;
    Boolean         donePlaying;

    ChannelP = NULL;

    if (channels == 1)
        err = SndNewChannel(&ChannelP, sampledSynth, initMono, NULL);
    else
        err = SndNewChannel(&ChannelP, sampledSynth, initStereo, NULL);

    if (err == badChannel)
    {
        mexErrMsgIdAndTxt(PLAYSND_COMPONENT "badChannel", 
                          "Bad channel after new channel.");
    }
    else if (err == resProblem)
    {
        mexErrMsgIdAndTxt(PLAYSND_COMPONENT "resProblem", "Res problem.");
    }
    else if (err)
    {
        mexErrMsgIdAndTxt(PLAYSND_COMPONENT "couldNotCreateChannel", 
                          "Couldn't create new sound channel (%d).", err);
    }

    Header.samplePtr = (Ptr) data;
    Header.sampleRate = MacSampleRate;
    Header.loopStart = 0;
    Header.loopEnd = MacSoundSize - 1;
    Header.encode = extSH;
    Header.numChannels = channels;

    Header.baseFrequency = kMiddleC;
    Header.numFrames = MacSoundSize;
    Header.markerChunk = Header.instrumentChunks = Header.AESRecording = 0;
    Header.sampleSize = bitsPerSample;

    Command.cmd = bufferCmd;
    Command.param2 = (long) &Header;

    err = SndDoCommand(ChannelP, &Command, false);
    if (err)
    {
        mexErrMsgIdAndTxt(PLAYSND_COMPONENT "SndDoCommandError",
                          "SndDoCommand returned error %d.", err);
    }

    donePlaying = false;
    while (!donePlaying)
    {
        SCStatus status;
        err = SndChannelStatus(ChannelP, sizeof(status), &status);
        donePlaying = !status.scChannelBusy || err != noErr;
    }

    SndDisposeChannel(ChannelP, true);
}

void usageError(void)
{
    mexErrMsgIdAndTxt(PLAYSND_COMPONENT "usage",
                      "Syntax: playsnd(data [,sample_rate] [,bits_per_sample])");
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int            channels, bitsPerSample;
    unsigned char *byteData;
    unsigned long  SampleRate, frameLength;
    const mxArray *SoundMatrix, *SampleRateMatrix;
    double        *bitsD, *sampleRateD;

    if (Has16BitSound())
        bitsPerSample = 16;
    else
        bitsPerSample = 8;

    if (nrhs < 1)
    {
        usageError();
    }

    SoundMatrix = prhs[0];

    if (mxGetM(SoundMatrix) == 1)
    {
        frameLength = mxGetN(SoundMatrix);
        channels = 1;
    }
    else if (mxGetM(SoundMatrix) == 2)
    {
        frameLength = mxGetN(SoundMatrix);
        channels = 2;
    }
    else if (mxGetN(SoundMatrix) == 1)
    {
        frameLength = mxGetM(SoundMatrix);
        channels = 1;
    }
    else if (mxGetN(SoundMatrix) == 2)
    {
        frameLength = mxGetM(SoundMatrix);
        channels = 2;
    }
    else
    {
        mexErrMsgIdAndTxt(PLAYSND_COMPONENT "improperSoundInput",
                          "Sound array must have either one or two rows or columns "
                          "(%d x %d).", mxGetM(SoundMatrix), mxGetN(SoundMatrix));
    }

    if (nrhs == 1)
    {
        SampleRate = 22050 * (unsigned long) 65536L;
    }
    else if (nrhs == 2)
    {
        SampleRateMatrix = prhs[1];
        sampleRateD = mxGetPr(SampleRateMatrix);
        if (sampleRateD[0] < 1000.0 || sampleRateD[0] > 65535.0)
            SampleRate = 22050 * (unsigned long) 65536L;
        else
            SampleRate = sampleRateD[0] * (unsigned long) 65536L;
    }
    else if (nrhs == 3)
    {
        SampleRateMatrix = prhs[1];
        sampleRateD = mxGetPr(SampleRateMatrix);
        if (sampleRateD[0] < 1000.0 || sampleRateD[0] > 65535.0)
            SampleRate = 22050 * (unsigned long) 65536L;
        else
            SampleRate = sampleRateD[0] * (unsigned long) 65536L;
        bitsD = mxGetPr(prhs[2]);

        // If they specify 8 bits samples, then do it; otherwise let
        // the code above come up with the best sampling rate.
        if (bitsD[0] == 8)
            bitsPerSample = 8;
    }
    else
    {
        usageError();
    }

    if (bitsPerSample > 8)
    {
        byteData = (unsigned char *) utMalloc(sizeof(short) * frameLength * channels);
        ConvertToShort(mxGetPr(SoundMatrix), byteData, frameLength * channels);
    }
    else
    {
        byteData = (unsigned char *) utMalloc(frameLength * channels);
        ConvertToByte(mxGetPr(SoundMatrix), byteData, frameLength * channels);
    }

    if (channels > 1 && mxGetM(SoundMatrix) > mxGetN(SoundMatrix))
    {
        if (bitsPerSample > 8)
            TransposeShortArray((short *) byteData, frameLength);
        else
            TransposeByteArray(byteData, frameLength);
    }

    PlaySound(byteData, frameLength, SampleRate, channels, bitsPerSample);

    utFree(byteData);
}
