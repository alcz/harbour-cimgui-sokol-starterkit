/*
    cimplot/hbhlp.c    -- callbacks from ImPlot are (or will be)
                          handled here

    license is MIT, see ../LICENSE

    Copyright (c) 2021 Aleksander Czajczynski
*/

// ImPlotPoint (void* data, int i)

ImPlotPoint hb_implot_getter(void* data, int i)
{
    float f = *(float*)data;
    return ImPlotPoint(i,sinf(f*i));
}
