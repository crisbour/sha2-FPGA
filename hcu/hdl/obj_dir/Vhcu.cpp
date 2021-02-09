// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vhcu.h for the primary calling header

#include "Vhcu.h"
#include "Vhcu__Syms.h"

//==========

void Vhcu::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vhcu::eval\n"); );
    Vhcu__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("hcu.sv", 23, "",
                "Verilated model didn't converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

void Vhcu::_eval_initial_loop(Vhcu__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
        _eval_settle(vlSymsp);
        _eval(vlSymsp);
        if (VL_UNLIKELY(++__VclockLoop > 100)) {
            // About to fail, so enable debug to see what's not settling.
            // Note you must run make with OPT=-DVL_DEBUG for debug prints.
            int __Vsaved_debug = Verilated::debug();
            Verilated::debug(1);
            __Vchange = _change_request(vlSymsp);
            Verilated::debug(__Vsaved_debug);
            VL_FATAL_MT("hcu.sv", 23, "",
                "Verilated model didn't DC converge\n"
                "- See DIDNOTCONVERGE in the Verilator manual");
        } else {
            __Vchange = _change_request(vlSymsp);
        }
    } while (VL_UNLIKELY(__Vchange));
}

VL_INLINE_OPT void Vhcu::_sequent__TOP__1(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_sequent__TOP__1\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    CData/*6:0*/ __Vdly__hcu__DOT__word_count;
    CData/*0:0*/ __Vdlyvset__hcu__DOT__Reg__v0;
    CData/*0:0*/ __Vdlyvset__hcu__DOT__Reg__v8;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v0;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v1;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v1;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v2;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v3;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v4;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v4;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v5;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v6;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v7;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v7;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v8;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v9;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v10;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v10;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v11;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v12;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v13;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v13;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v14;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v15;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v16;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v16;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v17;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v18;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v19;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v19;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v20;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v21;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v22;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v22;
    CData/*5:0*/ __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v23;
    CData/*0:0*/ __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v24;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v1;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v4;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v7;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v10;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v13;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v16;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v19;
    IData/*31:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v22;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v0;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v1;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v2;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v3;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v4;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v5;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v6;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v7;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v8;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v9;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v10;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v11;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v12;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v13;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v14;
    QData/*63:0*/ __Vdlyvval__hcu__DOT__Reg__v15;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v0;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v3;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v6;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v9;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v12;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v15;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v18;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v21;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v24;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v25;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v26;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v27;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v28;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v29;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v30;
    QData/*63:0*/ __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v31;
    // Body
    __Vdly__hcu__DOT__word_count = vlTOPp->hcu__DOT__word_count;
    __Vdlyvset__hcu__DOT__Reg__v0 = 0U;
    __Vdlyvset__hcu__DOT__Reg__v8 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v0 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v1 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v3 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v4 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v6 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v7 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v9 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v10 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v12 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v13 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v15 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v16 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v18 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v19 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v21 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v22 = 0U;
    __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v24 = 0U;
    if ((1U & (~ (IData)(vlTOPp->axi_resetn)))) {
        vlTOPp->m_axis_tlast = 0U;
    }
    if (vlTOPp->axi_resetn) {
        if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
            vlTOPp->m_axis_tlast = 0U;
        }
    }
    vlTOPp->m_axis_tvalid = ((IData)(vlTOPp->axi_resetn) 
                             & (IData)(vlTOPp->hcu__DOT__m_axis_tvalid_next));
    if (vlTOPp->axi_resetn) {
        if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
            vlTOPp->m_axis_tvalid = 0U;
        }
    }
    vlTOPp->s_axis_tready = ((IData)(vlTOPp->axi_resetn) 
                             & (IData)(vlTOPp->hcu__DOT__s_axis_tready_next));
    if (vlTOPp->axi_resetn) {
        if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
            vlTOPp->s_axis_tready = 0U;
        }
    }
    if ((1U & (~ (IData)(vlTOPp->axi_resetn)))) {
        vlTOPp->hcu__DOT__finish = 0U;
    }
    if (vlTOPp->axi_resetn) {
        if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
            vlTOPp->hcu__DOT__finish = 0U;
        } else {
            if ((1U != (IData)(vlTOPp->hcu__DOT__state))) {
                if ((2U == (IData)(vlTOPp->hcu__DOT__state))) {
                    if (vlTOPp->s_axis_tvalid) {
                        if (vlTOPp->s_axis_tlast) {
                            vlTOPp->hcu__DOT__finish = 1U;
                        }
                    }
                }
            }
        }
    }
    if ((1U & (~ (IData)(vlTOPp->axi_resetn)))) {
        __Vdly__hcu__DOT__word_count = 0U;
    }
    if (vlTOPp->axi_resetn) {
        if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
            __Vdly__hcu__DOT__word_count = 0U;
        } else {
            if ((1U != (IData)(vlTOPp->hcu__DOT__state))) {
                if ((2U == (IData)(vlTOPp->hcu__DOT__state))) {
                    if (vlTOPp->s_axis_tvalid) {
                        __Vdly__hcu__DOT__word_count 
                            = (0x7fU & ((IData)(1U) 
                                        + (IData)(vlTOPp->hcu__DOT__word_count)));
                    }
                } else {
                    if ((3U == (IData)(vlTOPp->hcu__DOT__state))) {
                        __Vdly__hcu__DOT__word_count = 0U;
                    }
                }
            }
        }
    }
    if (vlTOPp->axi_resetn) {
        if ((0U != (IData)(vlTOPp->hcu__DOT__state))) {
            if ((1U == (IData)(vlTOPp->hcu__DOT__state))) {
                __Vdlyvval__hcu__DOT__Reg__v0 = vlTOPp->hcu__DOT__H
                    [0U];
                __Vdlyvset__hcu__DOT__Reg__v0 = 1U;
                __Vdlyvval__hcu__DOT__Reg__v1 = vlTOPp->hcu__DOT__H
                    [1U];
                __Vdlyvval__hcu__DOT__Reg__v2 = vlTOPp->hcu__DOT__H
                    [2U];
                __Vdlyvval__hcu__DOT__Reg__v3 = vlTOPp->hcu__DOT__H
                    [3U];
                __Vdlyvval__hcu__DOT__Reg__v4 = vlTOPp->hcu__DOT__H
                    [4U];
                __Vdlyvval__hcu__DOT__Reg__v5 = vlTOPp->hcu__DOT__H
                    [5U];
                __Vdlyvval__hcu__DOT__Reg__v6 = vlTOPp->hcu__DOT__H
                    [6U];
                __Vdlyvval__hcu__DOT__Reg__v7 = vlTOPp->hcu__DOT__H
                    [7U];
            } else {
                if ((2U == (IData)(vlTOPp->hcu__DOT__state))) {
                    if (vlTOPp->s_axis_tvalid) {
                        __Vdlyvval__hcu__DOT__Reg__v8 
                            = ((2U & (IData)(vlTOPp->hcu__DOT__sha_type_reg))
                                ? (vlTOPp->hcu__DOT__T1 
                                   + vlTOPp->hcu__DOT__T2)
                                : ((QData)((IData)(
                                                   ((IData)(
                                                            (vlTOPp->hcu__DOT__T1 
                                                             >> 0x20U)) 
                                                    + (IData)(
                                                              (vlTOPp->hcu__DOT__T2 
                                                               >> 0x20U))))) 
                                   << 0x20U));
                        __Vdlyvset__hcu__DOT__Reg__v8 = 1U;
                        __Vdlyvval__hcu__DOT__Reg__v9 
                            = vlTOPp->hcu__DOT__Reg
                            [0U];
                        __Vdlyvval__hcu__DOT__Reg__v10 
                            = vlTOPp->hcu__DOT__Reg
                            [1U];
                        __Vdlyvval__hcu__DOT__Reg__v11 
                            = vlTOPp->hcu__DOT__Reg
                            [2U];
                        __Vdlyvval__hcu__DOT__Reg__v12 
                            = vlTOPp->hcu__DOT__E_new;
                        __Vdlyvval__hcu__DOT__Reg__v13 
                            = vlTOPp->hcu__DOT__Reg
                            [4U];
                        __Vdlyvval__hcu__DOT__Reg__v14 
                            = vlTOPp->hcu__DOT__Reg
                            [5U];
                        __Vdlyvval__hcu__DOT__Reg__v15 
                            = vlTOPp->hcu__DOT__Reg
                            [6U];
                    }
                }
            }
        }
    }
    if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v0 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x6a09e667f3bcc908ULL : 0xcbbb9d5dc1059ed8ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v0 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v1 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x6a09e667U : 0xc1059ed8U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v1 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v1 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v2 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v3 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0xbb67ae8584caa73bULL : 0x629a292a367cd507ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v3 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v4 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0xbb67ae85U : 0x367cd507U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v4 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v4 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v5 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v6 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x3c6ef372fe94f82bULL : 0x9159015a3070dd17ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v6 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v7 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x3c6ef372U : 0x3070dd17U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v7 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v7 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v8 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v9 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0xa54ff53a5f1d36f1ULL : 0x152fecd8f70e5939ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v9 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v10 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0xa54ff53aU : 0xf70e5939U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v10 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v10 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v11 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v12 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x510e527fade682d1ULL : 0x67332667ffc00b31ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v12 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v13 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x510e527fU : 0xffc00b31U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v13 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v13 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v14 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v15 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x9b05688c2b3e6c1fULL : 0x8eb44a8768581511ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v15 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v16 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x9b05688cU : 0x68581511U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v16 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v16 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v17 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v18 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x1f83d9abfb41bd6bULL : 0xdb0c2e0d64f98fa7ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v18 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v19 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x1f83d9abU : 0x64f98fa7U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v19 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v19 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v20 = 0U;
        }
        if ((2U & (IData)(vlTOPp->sha_type))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v21 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x5be0cd19137e2179ULL : 0x47b5481dbefa4fa4ULL);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v21 = 1U;
        } else {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v22 
                = ((1U & (IData)(vlTOPp->sha_type))
                    ? 0x5be0cd19U : 0xbefa4fa4U);
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v22 = 1U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v22 = 0x20U;
            __Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v23 = 0U;
        }
    } else {
        if ((3U == (IData)(vlTOPp->hcu__DOT__state))) {
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v24 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [0U];
            __Vdlyvset__hcu__DOT____Vcellout__per_block__H__v24 = 1U;
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v25 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [1U];
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v26 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [2U];
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v27 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [3U];
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v28 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [4U];
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v29 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [5U];
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v30 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [6U];
            __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v31 
                = vlTOPp->hcu__DOT__per_block__DOT__Sums
                [7U];
        }
    }
    vlTOPp->hcu__DOT__word_count = __Vdly__hcu__DOT__word_count;
    if (__Vdlyvset__hcu__DOT__Reg__v0) {
        vlTOPp->hcu__DOT__Reg[0U] = __Vdlyvval__hcu__DOT__Reg__v0;
        vlTOPp->hcu__DOT__Reg[1U] = __Vdlyvval__hcu__DOT__Reg__v1;
        vlTOPp->hcu__DOT__Reg[2U] = __Vdlyvval__hcu__DOT__Reg__v2;
        vlTOPp->hcu__DOT__Reg[3U] = __Vdlyvval__hcu__DOT__Reg__v3;
        vlTOPp->hcu__DOT__Reg[4U] = __Vdlyvval__hcu__DOT__Reg__v4;
        vlTOPp->hcu__DOT__Reg[5U] = __Vdlyvval__hcu__DOT__Reg__v5;
        vlTOPp->hcu__DOT__Reg[6U] = __Vdlyvval__hcu__DOT__Reg__v6;
        vlTOPp->hcu__DOT__Reg[7U] = __Vdlyvval__hcu__DOT__Reg__v7;
    }
    if (__Vdlyvset__hcu__DOT__Reg__v8) {
        vlTOPp->hcu__DOT__Reg[0U] = __Vdlyvval__hcu__DOT__Reg__v8;
        vlTOPp->hcu__DOT__Reg[1U] = __Vdlyvval__hcu__DOT__Reg__v9;
        vlTOPp->hcu__DOT__Reg[2U] = __Vdlyvval__hcu__DOT__Reg__v10;
        vlTOPp->hcu__DOT__Reg[3U] = __Vdlyvval__hcu__DOT__Reg__v11;
        vlTOPp->hcu__DOT__Reg[4U] = __Vdlyvval__hcu__DOT__Reg__v12;
        vlTOPp->hcu__DOT__Reg[5U] = __Vdlyvval__hcu__DOT__Reg__v13;
        vlTOPp->hcu__DOT__Reg[6U] = __Vdlyvval__hcu__DOT__Reg__v14;
        vlTOPp->hcu__DOT__Reg[7U] = __Vdlyvval__hcu__DOT__Reg__v15;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v0) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[0U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v0;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v1) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[0U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v1))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [0U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v1)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v1)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[0U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v2))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [0U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v3) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[1U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v3;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v4) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[1U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v4))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [1U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v4)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v4)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[1U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v5))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [1U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v6) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[2U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v6;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v7) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[2U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v7))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [2U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v7)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v7)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[2U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v8))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [2U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v9) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[3U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v9;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v10) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[3U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v10))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [3U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v10)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v10)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[3U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v11))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [3U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v12) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[4U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v12;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v13) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[4U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v13))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [4U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v13)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v13)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[4U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v14))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [4U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v15) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[5U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v15;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v16) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[5U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v16))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [5U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v16)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v16)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[5U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v17))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [5U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v18) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[6U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v18;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v19) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[6U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v19))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [6U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v19)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v19)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[6U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v20))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [6U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v21) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[7U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v21;
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v22) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[7U] 
            = (((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v22))) 
                & vlTOPp->hcu__DOT____Vcellout__per_block__H
                [7U]) | ((QData)((IData)(__Vdlyvval__hcu__DOT____Vcellout__per_block__H__v22)) 
                         << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v22)));
        vlTOPp->hcu__DOT____Vcellout__per_block__H[7U] 
            = ((~ (0xffffffffULL << (IData)(__Vdlyvlsb__hcu__DOT____Vcellout__per_block__H__v23))) 
               & vlTOPp->hcu__DOT____Vcellout__per_block__H
               [7U]);
    }
    if (__Vdlyvset__hcu__DOT____Vcellout__per_block__H__v24) {
        vlTOPp->hcu__DOT____Vcellout__per_block__H[0U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v24;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[1U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v25;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[2U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v26;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[3U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v27;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[4U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v28;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[5U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v29;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[6U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v30;
        vlTOPp->hcu__DOT____Vcellout__per_block__H[7U] 
            = __Vdlyvval__hcu__DOT____Vcellout__per_block__H__v31;
    }
    vlTOPp->hcu__DOT____Vcellinp__wt_kt__b = ((0x4fU 
                                               >= (IData)(vlTOPp->hcu__DOT__word_count))
                                               ? vlSymsp->TOP____024unit.Kt
                                              [vlTOPp->hcu__DOT__word_count]
                                               : 0ULL);
    if (vlTOPp->axi_resetn) {
        if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
            if (vlTOPp->en) {
                vlTOPp->hcu__DOT__sha_type_reg = vlTOPp->sha_type;
            }
        }
    }
    vlTOPp->hcu__DOT__maj = (((vlTOPp->hcu__DOT__Reg
                               [0U] & vlTOPp->hcu__DOT__Reg
                               [1U]) ^ (vlTOPp->hcu__DOT__Reg
                                        [0U] & vlTOPp->hcu__DOT__Reg
                                        [2U])) ^ (vlTOPp->hcu__DOT__Reg
                                                  [1U] 
                                                  & vlTOPp->hcu__DOT__Reg
                                                  [2U]));
    vlTOPp->hcu__DOT__ch = ((vlTOPp->hcu__DOT__Reg[4U] 
                             & vlTOPp->hcu__DOT__Reg
                             [5U]) ^ ((~ vlTOPp->hcu__DOT__Reg
                                       [4U]) & vlTOPp->hcu__DOT__Reg
                                      [6U]));
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[0U] 
        = vlTOPp->hcu__DOT__Reg[7U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[1U] 
        = vlTOPp->hcu__DOT__Reg[6U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[2U] 
        = vlTOPp->hcu__DOT__Reg[5U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[3U] 
        = vlTOPp->hcu__DOT__Reg[4U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[4U] 
        = vlTOPp->hcu__DOT__Reg[3U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[5U] 
        = vlTOPp->hcu__DOT__Reg[2U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[6U] 
        = vlTOPp->hcu__DOT__Reg[1U];
    vlTOPp->hcu__DOT____Vcellinp__per_block__AH[7U] 
        = vlTOPp->hcu__DOT__Reg[0U];
    vlTOPp->hcu__DOT__H[0U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [0U];
    vlTOPp->hcu__DOT__H[1U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [1U];
    vlTOPp->hcu__DOT__H[2U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [2U];
    vlTOPp->hcu__DOT__H[3U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [3U];
    vlTOPp->hcu__DOT__H[4U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [4U];
    vlTOPp->hcu__DOT__H[5U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [5U];
    vlTOPp->hcu__DOT__H[6U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [6U];
    vlTOPp->hcu__DOT__H[7U] = vlTOPp->hcu__DOT____Vcellout__per_block__H
        [7U];
    vlTOPp->hcu__DOT__state = ((IData)(vlTOPp->axi_resetn)
                                ? (IData)(vlTOPp->hcu__DOT__state_next)
                                : 0U);
    if ((2U & (IData)(vlTOPp->hcu__DOT__sha_type_reg))) {
        vlTOPp->m_axis_tdata[0U] = (IData)(vlTOPp->hcu__DOT__H
                                           [7U]);
        vlTOPp->m_axis_tdata[1U] = (IData)((vlTOPp->hcu__DOT__H
                                            [7U] >> 0x20U));
        vlTOPp->m_axis_tdata[2U] = (IData)(vlTOPp->hcu__DOT__H
                                           [6U]);
        vlTOPp->m_axis_tdata[3U] = (IData)((vlTOPp->hcu__DOT__H
                                            [6U] >> 0x20U));
        vlTOPp->m_axis_tdata[4U] = (IData)(vlTOPp->hcu__DOT__H
                                           [5U]);
        vlTOPp->m_axis_tdata[5U] = (IData)((vlTOPp->hcu__DOT__H
                                            [5U] >> 0x20U));
        vlTOPp->m_axis_tdata[6U] = (IData)(vlTOPp->hcu__DOT__H
                                           [4U]);
        vlTOPp->m_axis_tdata[7U] = (IData)((vlTOPp->hcu__DOT__H
                                            [4U] >> 0x20U));
        vlTOPp->m_axis_tdata[8U] = (IData)(vlTOPp->hcu__DOT__H
                                           [3U]);
        vlTOPp->m_axis_tdata[9U] = (IData)((vlTOPp->hcu__DOT__H
                                            [3U] >> 0x20U));
        vlTOPp->m_axis_tdata[0xaU] = (IData)(vlTOPp->hcu__DOT__H
                                             [2U]);
        vlTOPp->m_axis_tdata[0xbU] = (IData)((vlTOPp->hcu__DOT__H
                                              [2U] 
                                              >> 0x20U));
        vlTOPp->m_axis_tdata[0xcU] = (IData)(vlTOPp->hcu__DOT__H
                                             [1U]);
        vlTOPp->m_axis_tdata[0xdU] = (IData)((vlTOPp->hcu__DOT__H
                                              [1U] 
                                              >> 0x20U));
        vlTOPp->m_axis_tdata[0xeU] = (IData)(vlTOPp->hcu__DOT__H
                                             [0U]);
        vlTOPp->m_axis_tdata[0xfU] = (IData)((vlTOPp->hcu__DOT__H
                                              [0U] 
                                              >> 0x20U));
    } else {
        vlTOPp->m_axis_tdata[0U] = 0U;
        vlTOPp->m_axis_tdata[1U] = 0U;
        vlTOPp->m_axis_tdata[2U] = 0U;
        vlTOPp->m_axis_tdata[3U] = 0U;
        vlTOPp->m_axis_tdata[4U] = 0U;
        vlTOPp->m_axis_tdata[5U] = 0U;
        vlTOPp->m_axis_tdata[6U] = 0U;
        vlTOPp->m_axis_tdata[7U] = 0U;
        vlTOPp->m_axis_tdata[8U] = (IData)((vlTOPp->hcu__DOT__H
                                            [7U] >> 0x20U));
        vlTOPp->m_axis_tdata[9U] = (IData)((vlTOPp->hcu__DOT__H
                                            [6U] >> 0x20U));
        vlTOPp->m_axis_tdata[0xaU] = (IData)((vlTOPp->hcu__DOT__H
                                              [5U] 
                                              >> 0x20U));
        vlTOPp->m_axis_tdata[0xbU] = (IData)((vlTOPp->hcu__DOT__H
                                              [4U] 
                                              >> 0x20U));
        vlTOPp->m_axis_tdata[0xcU] = (IData)((vlTOPp->hcu__DOT__H
                                              [3U] 
                                              >> 0x20U));
        vlTOPp->m_axis_tdata[0xdU] = (IData)((vlTOPp->hcu__DOT__H
                                              [2U] 
                                              >> 0x20U));
        vlTOPp->m_axis_tdata[0xeU] = (IData)((((QData)((IData)(
                                                               (vlTOPp->hcu__DOT__H
                                                                [0U] 
                                                                >> 0x20U))) 
                                               << 0x20U) 
                                              | (QData)((IData)(
                                                                (vlTOPp->hcu__DOT__H
                                                                 [1U] 
                                                                 >> 0x20U)))));
        vlTOPp->m_axis_tdata[0xfU] = (IData)(((((QData)((IData)(
                                                                (vlTOPp->hcu__DOT__H
                                                                 [0U] 
                                                                 >> 0x20U))) 
                                                << 0x20U) 
                                               | (QData)((IData)(
                                                                 (vlTOPp->hcu__DOT__H
                                                                  [1U] 
                                                                  >> 0x20U)))) 
                                              >> 0x20U));
    }
}

VL_INLINE_OPT void Vhcu::_combo__TOP__3(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_combo__TOP__3\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->hcu__DOT__sigma0 = ((((2U & (IData)(vlTOPp->sha_type))
                                   ? ((vlTOPp->hcu__DOT__Reg
                                       [0U] >> 2U) 
                                      | (vlTOPp->hcu__DOT__Reg
                                         [0U] << 0x3eU))
                                   : ((vlTOPp->hcu__DOT__Reg
                                       [0U] >> 2U) 
                                      | (vlTOPp->hcu__DOT__Reg
                                         [0U] << 0x1eU))) 
                                 ^ ((2U & (IData)(vlTOPp->sha_type))
                                     ? ((vlTOPp->hcu__DOT__Reg
                                         [0U] >> 0xdU) 
                                        | (vlTOPp->hcu__DOT__Reg
                                           [0U] << 0x33U))
                                     : ((vlTOPp->hcu__DOT__Reg
                                         [0U] >> 0xdU) 
                                        | (vlTOPp->hcu__DOT__Reg
                                           [0U] << 0x13U)))) 
                                ^ ((2U & (IData)(vlTOPp->sha_type))
                                    ? ((vlTOPp->hcu__DOT__Reg
                                        [0U] >> 0x16U) 
                                       | (vlTOPp->hcu__DOT__Reg
                                          [0U] << 0x2aU))
                                    : ((vlTOPp->hcu__DOT__Reg
                                        [0U] >> 0x16U) 
                                       | (vlTOPp->hcu__DOT__Reg
                                          [0U] << 0xaU))));
    vlTOPp->hcu__DOT__sigma1 = ((((2U & (IData)(vlTOPp->sha_type))
                                   ? ((vlTOPp->hcu__DOT__Reg
                                       [4U] >> 6U) 
                                      | (vlTOPp->hcu__DOT__Reg
                                         [4U] << 0x3aU))
                                   : ((vlTOPp->hcu__DOT__Reg
                                       [4U] >> 6U) 
                                      | (vlTOPp->hcu__DOT__Reg
                                         [4U] << 0x1aU))) 
                                 ^ ((2U & (IData)(vlTOPp->sha_type))
                                     ? ((vlTOPp->hcu__DOT__Reg
                                         [4U] >> 0xbU) 
                                        | (vlTOPp->hcu__DOT__Reg
                                           [4U] << 0x35U))
                                     : ((vlTOPp->hcu__DOT__Reg
                                         [4U] >> 0xbU) 
                                        | (vlTOPp->hcu__DOT__Reg
                                           [4U] << 0x15U)))) 
                                ^ ((2U & (IData)(vlTOPp->sha_type))
                                    ? ((vlTOPp->hcu__DOT__Reg
                                        [4U] >> 0x19U) 
                                       | (vlTOPp->hcu__DOT__Reg
                                          [4U] << 0x27U))
                                    : ((vlTOPp->hcu__DOT__Reg
                                        [4U] >> 0x19U) 
                                       | (vlTOPp->hcu__DOT__Reg
                                          [4U] << 7U))));
    if ((2U & (IData)(vlTOPp->sha_type))) {
        vlTOPp->hcu__DOT__per_block__DOT__Sums[0U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [0U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [0U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[1U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [1U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [1U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[2U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [2U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [2U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[3U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [3U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [3U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[4U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [4U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [4U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[5U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [5U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [5U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[6U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [6U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [6U]);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[7U] 
            = (vlTOPp->hcu__DOT____Vcellout__per_block__H
               [7U] + vlTOPp->hcu__DOT____Vcellinp__per_block__AH
               [7U]);
    } else {
        vlTOPp->hcu__DOT__per_block__DOT__Sums[0U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [0U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [0U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[1U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [1U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [1U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[2U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [2U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [2U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[3U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [3U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [3U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[4U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [4U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [4U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[5U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [5U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [5U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[6U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [6U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [6U] >> 0x20U))))) 
               << 0x20U);
        vlTOPp->hcu__DOT__per_block__DOT__Sums[7U] 
            = ((QData)((IData)(((IData)((vlTOPp->hcu__DOT____Vcellout__per_block__H
                                         [7U] >> 0x20U)) 
                                + (IData)((vlTOPp->hcu__DOT____Vcellinp__per_block__AH
                                           [7U] >> 0x20U))))) 
               << 0x20U);
    }
    vlTOPp->hcu__DOT__wt_kt_sum = ((2U & (IData)(vlTOPp->hcu__DOT__sha_type_reg))
                                    ? (vlTOPp->s_axis_tdata 
                                       + vlTOPp->hcu__DOT____Vcellinp__wt_kt__b)
                                    : ((QData)((IData)(
                                                       ((IData)(
                                                                (vlTOPp->s_axis_tdata 
                                                                 >> 0x20U)) 
                                                        + (IData)(
                                                                  (vlTOPp->hcu__DOT____Vcellinp__wt_kt__b 
                                                                   >> 0x20U))))) 
                                       << 0x20U));
    vlTOPp->hcu__DOT__m_axis_tvalid_next = vlTOPp->m_axis_tvalid;
    if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
        vlTOPp->hcu__DOT__m_axis_tvalid_next = 0U;
    } else {
        if ((1U != (IData)(vlTOPp->hcu__DOT__state))) {
            if ((2U != (IData)(vlTOPp->hcu__DOT__state))) {
                if ((3U == (IData)(vlTOPp->hcu__DOT__state))) {
                    if (vlTOPp->hcu__DOT__finish) {
                        vlTOPp->hcu__DOT__m_axis_tvalid_next = 1U;
                    }
                } else {
                    if ((4U == (IData)(vlTOPp->hcu__DOT__state))) {
                        if (vlTOPp->m_axis_tready) {
                            vlTOPp->hcu__DOT__m_axis_tvalid_next = 0U;
                        }
                    }
                }
            }
        }
    }
    vlTOPp->hcu__DOT__s_axis_tready_next = vlTOPp->s_axis_tready;
    if ((0U != (IData)(vlTOPp->hcu__DOT__state))) {
        if ((1U == (IData)(vlTOPp->hcu__DOT__state))) {
            vlTOPp->hcu__DOT__s_axis_tready_next = 1U;
        } else {
            if ((2U == (IData)(vlTOPp->hcu__DOT__state))) {
                if (((IData)(vlTOPp->hcu__DOT__sha_type_reg) 
                     == (IData)(vlTOPp->sha_type))) {
                    if (vlTOPp->s_axis_tvalid) {
                        if (((((IData)(vlTOPp->hcu__DOT__sha_type_reg) 
                               >> 1U) & (0x4fU == (IData)(vlTOPp->hcu__DOT__word_count))) 
                             | ((~ ((IData)(vlTOPp->hcu__DOT__sha_type_reg) 
                                    >> 1U)) & (0x3fU 
                                               == (IData)(vlTOPp->hcu__DOT__word_count))))) {
                            vlTOPp->hcu__DOT__s_axis_tready_next = 0U;
                        }
                    }
                }
            }
        }
    }
    vlTOPp->hcu__DOT__state_next = vlTOPp->hcu__DOT__state;
    if ((0U == (IData)(vlTOPp->hcu__DOT__state))) {
        if (vlTOPp->en) {
            vlTOPp->hcu__DOT__state_next = 1U;
        }
    } else {
        if ((1U == (IData)(vlTOPp->hcu__DOT__state))) {
            vlTOPp->hcu__DOT__state_next = 2U;
        } else {
            if ((2U == (IData)(vlTOPp->hcu__DOT__state))) {
                if (((IData)(vlTOPp->hcu__DOT__sha_type_reg) 
                     != (IData)(vlTOPp->sha_type))) {
                    vlTOPp->hcu__DOT__state_next = 0U;
                } else {
                    if (vlTOPp->s_axis_tvalid) {
                        if (((((IData)(vlTOPp->hcu__DOT__sha_type_reg) 
                               >> 1U) & (0x4fU == (IData)(vlTOPp->hcu__DOT__word_count))) 
                             | ((~ ((IData)(vlTOPp->hcu__DOT__sha_type_reg) 
                                    >> 1U)) & (0x3fU 
                                               == (IData)(vlTOPp->hcu__DOT__word_count))))) {
                            vlTOPp->hcu__DOT__state_next = 3U;
                        }
                    }
                }
            } else {
                if ((3U == (IData)(vlTOPp->hcu__DOT__state))) {
                    vlTOPp->hcu__DOT__state_next = 
                        ((IData)(vlTOPp->hcu__DOT__finish)
                          ? 4U : 1U);
                } else {
                    if ((4U == (IData)(vlTOPp->hcu__DOT__state))) {
                        if (vlTOPp->m_axis_tready) {
                            vlTOPp->hcu__DOT__state_next = 0U;
                        }
                    }
                }
            }
        }
    }
    if ((2U & (IData)(vlTOPp->hcu__DOT__sha_type_reg))) {
        vlTOPp->hcu__DOT__T2 = (vlTOPp->hcu__DOT__sigma0 
                                + vlTOPp->hcu__DOT__maj);
        vlTOPp->hcu__DOT__sig_ch_sum = (vlTOPp->hcu__DOT__sigma1 
                                        + vlTOPp->hcu__DOT__ch);
        vlTOPp->hcu__DOT__wt_kt_h_sum = (vlTOPp->hcu__DOT__wt_kt_sum 
                                         + vlTOPp->hcu__DOT__Reg
                                         [7U]);
        vlTOPp->hcu__DOT__T1 = (vlTOPp->hcu__DOT__sig_ch_sum 
                                + vlTOPp->hcu__DOT__wt_kt_h_sum);
        vlTOPp->hcu__DOT__E_new = (vlTOPp->hcu__DOT__Reg
                                   [3U] + vlTOPp->hcu__DOT__T1);
    } else {
        vlTOPp->hcu__DOT__T2 = ((QData)((IData)(((IData)(
                                                         (vlTOPp->hcu__DOT__sigma0 
                                                          >> 0x20U)) 
                                                 + (IData)(
                                                           (vlTOPp->hcu__DOT__maj 
                                                            >> 0x20U))))) 
                                << 0x20U);
        vlTOPp->hcu__DOT__sig_ch_sum = ((QData)((IData)(
                                                        ((IData)(
                                                                 (vlTOPp->hcu__DOT__sigma1 
                                                                  >> 0x20U)) 
                                                         + (IData)(
                                                                   (vlTOPp->hcu__DOT__ch 
                                                                    >> 0x20U))))) 
                                        << 0x20U);
        vlTOPp->hcu__DOT__wt_kt_h_sum = ((QData)((IData)(
                                                         ((IData)(
                                                                  (vlTOPp->hcu__DOT__wt_kt_sum 
                                                                   >> 0x20U)) 
                                                          + (IData)(
                                                                    (vlTOPp->hcu__DOT__Reg
                                                                     [7U] 
                                                                     >> 0x20U))))) 
                                         << 0x20U);
        vlTOPp->hcu__DOT__T1 = ((QData)((IData)(((IData)(
                                                         (vlTOPp->hcu__DOT__sig_ch_sum 
                                                          >> 0x20U)) 
                                                 + (IData)(
                                                           (vlTOPp->hcu__DOT__wt_kt_h_sum 
                                                            >> 0x20U))))) 
                                << 0x20U);
        vlTOPp->hcu__DOT__E_new = ((QData)((IData)(
                                                   ((IData)(
                                                            (vlTOPp->hcu__DOT__Reg
                                                             [3U] 
                                                             >> 0x20U)) 
                                                    + (IData)(
                                                              (vlTOPp->hcu__DOT__T1 
                                                               >> 0x20U))))) 
                                   << 0x20U);
    }
}

void Vhcu::_eval(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_eval\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->axi_aclk) & (~ (IData)(vlTOPp->__Vclklast__TOP__axi_aclk)))) {
        vlTOPp->_sequent__TOP__1(vlSymsp);
    }
    vlTOPp->_combo__TOP__3(vlSymsp);
    // Final
    vlTOPp->__Vclklast__TOP__axi_aclk = vlTOPp->axi_aclk;
}

VL_INLINE_OPT QData Vhcu::_change_request(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_change_request\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    return (vlTOPp->_change_request_1(vlSymsp));
}

VL_INLINE_OPT QData Vhcu::_change_request_1(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_change_request_1\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vhcu::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((axi_aclk & 0xfeU))) {
        Verilated::overWidthError("axi_aclk");}
    if (VL_UNLIKELY((axi_resetn & 0xfeU))) {
        Verilated::overWidthError("axi_resetn");}
    if (VL_UNLIKELY((sha_type & 0xfcU))) {
        Verilated::overWidthError("sha_type");}
    if (VL_UNLIKELY((en & 0xfeU))) {
        Verilated::overWidthError("en");}
    if (VL_UNLIKELY((s_axis_tvalid & 0xfeU))) {
        Verilated::overWidthError("s_axis_tvalid");}
    if (VL_UNLIKELY((s_axis_tlast & 0xfeU))) {
        Verilated::overWidthError("s_axis_tlast");}
    if (VL_UNLIKELY((m_axis_tready & 0xfeU))) {
        Verilated::overWidthError("m_axis_tready");}
}
#endif  // VL_DEBUG
