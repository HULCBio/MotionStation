// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:47 $

#ifndef _BUFFER_LIST
#define _BUFFER_LIST
#include <list>
#include <crtdbg.h>

typedef tagBUFFER Buffer; 

// CLASS BUFFERLIST: defines the list of buffers to be handled by the sound card. 
//		    Empty buffers are gotten from the engine and placed in this list
//		    Full buffers are removed from this list and sent to the engine

class BufferList
{
public:
    BufferList() {}
    typedef std::list<Buffer*, std::allocator<Buffer*> > ListT;


    // Puts a empty buffer at the end of the list
    void PutBuffer(Buffer *pb) 
    {
        _list.push_back(pb);
    }


    // Gets a pointer to the front of the list
    Buffer* NextBuffer() 
    {	    
        return _list.front();
    }

    // Gets a pointer to the buffer from the front and removes it from the list
    Buffer* GetBuffer() 
    {
        if (_list.size()>0)
        {
            Buffer *t=_list.front();
            _list.pop_front();
            return t;
        }
        else 
            return NULL;
    }

    // Returns the size of the buffer list
    int size() const {return _list.size();}
    
    // NOTE: these two functions are for use together (Be careful)
    ListT& GetList() {return _list;} 
    
    void Init() // reset /cleanup list
    {
        _list.clear();
    }

private:
    BufferList(BufferList& _src); // this function does not exist is here to make inaccesable
    BufferList& operator=(BufferList& _src); // this function does not exist is here to make inaccesable
    ListT  _list;
};

#endif