// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _VHCU_H_
#define _VHCU_H_  // guard

#include "verilated.h"

//==========

class Vhcu__Syms;
class Vhcu___024unit;


//----------

VL_MODULE(Vhcu) {
  public:
    // CELLS
    // Public to allow access to /*verilator_public*/ items;
    // otherwise the application code can consider these internals.
    Vhcu___024unit* __PVT____024unit;
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(axi_aclk,0,0);
    VL_IN8(axi_resetn,0,0);
    VL_IN8(sha_type,1,0);
    VL_IN8(en,0,0);
    VL_IN8(s_axis_tvalid,0,0);
    VL_OUT8(s_axis_tready,0,0);
    VL_IN8(s_axis_tlast,0,0);
    VL_OUT8(m_axis_tvalid,0,0);
    VL_IN8(m_axis_tready,0,0);
    VL_OUT8(m_axis_tlast,0,0);
    VL_OUTW(m_axis_tdata,511,0,16);
    VL_IN64(s_axis_tdata,63,0);
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    CData/*6:0*/ hcu__DOT__word_count;
    CData/*1:0*/ hcu__DOT__sha_type_reg;
    CData/*0:0*/ hcu__DOT__finish;
    CData/*2:0*/ hcu__DOT__state;
    CData/*2:0*/ hcu__DOT__state_next;
    CData/*0:0*/ hcu__DOT__s_axis_tready_next;
    CData/*0:0*/ hcu__DOT__m_axis_tvalid_next;
    QData/*63:0*/ hcu__DOT__E_new;
    QData/*63:0*/ hcu__DOT__T1;
    QData/*63:0*/ hcu__DOT__T2;
    QData/*63:0*/ hcu__DOT__sig_ch_sum;
    QData/*63:0*/ hcu__DOT__wt_kt_sum;
    QData/*63:0*/ hcu__DOT__wt_kt_h_sum;
    QData/*63:0*/ hcu__DOT__sigma0;
    QData/*63:0*/ hcu__DOT__sigma1;
    QData/*63:0*/ hcu__DOT__maj;
    QData/*63:0*/ hcu__DOT__ch;
    QData/*63:0*/ hcu__DOT__Reg[8];
    QData/*63:0*/ hcu__DOT__H[8];
    QData/*63:0*/ hcu__DOT__per_block__DOT__Sums[8];
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    CData/*0:0*/ __Vclklast__TOP__axi_aclk;
    QData/*63:0*/ hcu__DOT____Vcellinp__wt_kt__b;
    QData/*63:0*/ hcu__DOT____Vcellout__per_block__H[8];
    QData/*63:0*/ hcu__DOT____Vcellinp__per_block__AH[8];
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    Vhcu__Syms* __VlSymsp;  // Symbol table
    
    // CONSTRUCTORS
  private:
    VL_UNCOPYABLE(Vhcu);  ///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible with respect to DPI scope names.
    Vhcu(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vhcu();
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
    static void _eval_initial_loop(Vhcu__Syms* __restrict vlSymsp);
    void __Vconfigure(Vhcu__Syms* symsp, bool first);
  private:
    static QData _change_request(Vhcu__Syms* __restrict vlSymsp);
    static QData _change_request_1(Vhcu__Syms* __restrict vlSymsp);
  public:
    static void _combo__TOP__3(Vhcu__Syms* __restrict vlSymsp);
  private:
    void _ctor_var_reset() VL_ATTR_COLD;
  public:
    static void _eval(Vhcu__Syms* __restrict vlSymsp);
  private:
#ifdef VL_DEBUG
    void _eval_debug_assertions();
#endif  // VL_DEBUG
  public:
    static void _eval_initial(Vhcu__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _eval_settle(Vhcu__Syms* __restrict vlSymsp) VL_ATTR_COLD;
    static void _sequent__TOP__1(Vhcu__Syms* __restrict vlSymsp);
    static void _settle__TOP__2(Vhcu__Syms* __restrict vlSymsp) VL_ATTR_COLD;
} VL_ATTR_ALIGNED(VL_CACHE_LINE_BYTES);

//----------


#endif  // guard
