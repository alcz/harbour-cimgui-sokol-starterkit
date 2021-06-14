// The MIT License (MIT)

// Copyright (c) 2020 Fredrik A. Kristiansen

//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.

#include "Hexe/AutoHandle.h"
#ifndef WIN32
#include <unistd.h>
#endif

Hexe::AutoHandle::AutoHandle()
    : m_hHandle(invalid_value())
{
}
Hexe::AutoHandle::AutoHandle(AutoHandle &&other)
    : m_hHandle(other.m_hHandle)
{
    other.m_hHandle = invalid_value();
}
Hexe::AutoHandle::~AutoHandle()
{
    Release();
}

#ifdef WIN32
Hexe::AutoHandle::AutoHandle(HANDLE handle)
    : m_hHandle(handle)
{
}

void Hexe::AutoHandle::Release() const
{
    if (m_hHandle != INVALID_HANDLE_VALUE)
    {
        CloseHandle(m_hHandle);
        m_hHandle = INVALID_HANDLE_VALUE;
    }
}
#else
Hexe::AutoHandle::AutoHandle(int fd)
    : m_hHandle(fd)
{
}

void Hexe::AutoHandle::Release() const
{
    if (m_hHandle != -1)
    {
        close(m_hHandle);
    }
}

#endif
