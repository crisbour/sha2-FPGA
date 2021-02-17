// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vhcu.h for the primary calling header

#ifndef _VHCU___024UNIT_H_
#define _VHCU___024UNIT_H_  // guard

#include "verilated.h"

//==========

class Vhcu__Syms;

//----------

VL_MODULE(Vhcu___024unit) {
  public:
    
    // INTERNAL VARIABLES
  private:
    Vhcu__Syms* __VlSymsp;  // Symbol table
  public:
    
    // PARAMETERS
    QData/*63:0*/ Kt[80];
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vhcu___024unit);  ///< Copying not allowed
  public:
    Vhcu___024unit(const char* name = "TOP");
    ~Vhcu___024unit();
    
    // INTERNAL METHODS
    void __Vconfigure(Vhcu__Syms* symsp, bool first);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _initial__TOP____024unit__1(Vhcu__Syms* __restrict vlSymsp) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
