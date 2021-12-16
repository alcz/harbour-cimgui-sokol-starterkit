/*
    sokol/stb/stb_image.c      -- stb_image inclusion setup

    license is MIT, see ../LICENSE

    Copyright (c) 2020 Andre Weissflog
*/

#define STB_IMAGE_IMPLEMENTATION
#define STBI_NO_STDIO
#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-function"
#endif
#include "stb_image.h"
#if defined(__clang__)
#pragma clang diagnostic pop
#endif
