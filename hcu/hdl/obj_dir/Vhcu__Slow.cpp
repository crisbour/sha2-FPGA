// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vhcu.h for the primary calling header

#include "Vhcu.h"
#include "Vhcu__Syms.h"

//==========

VL_CTOR_IMP(Vhcu) {
    Vhcu__Syms* __restrict vlSymsp = __VlSymsp = new Vhcu__Syms(this, name());
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    VL_CELL(__PVT____024unit, Vhcu___024unit);
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vhcu::__Vconfigure(Vhcu__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
    Verilated::timeunit(-9);
    Verilated::timeprecision(-12);
}

Vhcu::~Vhcu() {
    VL_DO_CLEAR(delete __VlSymsp, __VlSymsp = nullptr);
}

void Vhcu::_settle__TOP__2(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_settle__TOP__2\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->hcu__DOT__maj = (((vlTOPp->hcu__DOT__Reg
                               [0U] & vlTOPp->hcu__DOT__Reg
                               [1U]) ^ (vlTOPp->hcu__DOT__Reg
                                        [0U] & vlTOPp->hcu__DOT__Reg
                                        [2U])) ^ (vlTOPp->hcu__DOT__Reg
                                                  [1U] 
                                                  & vlTOPp->hcu__DOT__Reg
                                                  [2U]));
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
    vlTOPp->hcu__DOT__ch = ((vlTOPp->hcu__DOT__Reg[4U] 
                             & vlTOPp->hcu__DOT__Reg
                             [5U]) ^ ((~ vlTOPp->hcu__DOT__Reg
                                       [4U]) & vlTOPp->hcu__DOT__Reg
                                      [6U]));
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
    vlTOPp->hcu__DOT____Vcellinp__wt_kt__b = ((0x4fU 
                                               >= (IData)(vlTOPp->hcu__DOT__word_count))
                                               ? vlSymsp->TOP____024unit.Kt
                                              [vlTOPp->hcu__DOT__word_count]
                                               : 0ULL);
    if ((2U & (IData)(vlTOPp->hcu__DOT__sha_type_reg))) {
        vlTOPp->hcu__DOT__T2 = (vlTOPp->hcu__DOT__sigma0 
                                + vlTOPp->hcu__DOT__maj);
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
        vlTOPp->hcu__DOT__sig_ch_sum = (vlTOPp->hcu__DOT__sigma1 
                                        + vlTOPp->hcu__DOT__ch);
    } else {
        vlTOPp->hcu__DOT__T2 = ((QData)((IData)(((IData)(
                                                         (vlTOPp->hcu__DOT__sigma0 
                                                          >> 0x20U)) 
                                                 + (IData)(
                                                           (vlTOPp->hcu__DOT__maj 
                                                            >> 0x20U))))) 
                                << 0x20U);
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
        vlTOPp->hcu__DOT__sig_ch_sum = ((QData)((IData)(
                                                        ((IData)(
                                                                 (vlTOPp->hcu__DOT__sigma1 
                                                                  >> 0x20U)) 
                                                         + (IData)(
                                                                   (vlTOPp->hcu__DOT__ch 
                                                                    >> 0x20U))))) 
                                        << 0x20U);
    }
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
    if ((2U & (IData)(vlTOPp->hcu__DOT__sha_type_reg))) {
        vlTOPp->hcu__DOT__wt_kt_sum = (vlTOPp->s_axis_tdata 
                                       + vlTOPp->hcu__DOT____Vcellinp__wt_kt__b);
        vlTOPp->hcu__DOT__wt_kt_h_sum = (vlTOPp->hcu__DOT__wt_kt_sum 
                                         + vlTOPp->hcu__DOT__Reg
                                         [7U]);
        vlTOPp->hcu__DOT__T1 = (vlTOPp->hcu__DOT__sig_ch_sum 
                                + vlTOPp->hcu__DOT__wt_kt_h_sum);
        vlTOPp->hcu__DOT__E_new = (vlTOPp->hcu__DOT__Reg
                                   [3U] + vlTOPp->hcu__DOT__T1);
    } else {
        vlTOPp->hcu__DOT__wt_kt_sum = ((QData)((IData)(
                                                       ((IData)(
                                                                (vlTOPp->s_axis_tdata 
                                                                 >> 0x20U)) 
                                                        + (IData)(
                                                                  (vlTOPp->hcu__DOT____Vcellinp__wt_kt__b 
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

void Vhcu::_eval_initial(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_eval_initial\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP____024unit._initial__TOP____024unit__1(vlSymsp);
    vlTOPp->__Vclklast__TOP__axi_aclk = vlTOPp->axi_aclk;
}

void Vhcu::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::final\n"); );
    // Variables
    Vhcu__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vhcu::_eval_settle(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_eval_settle\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__2(vlSymsp);
}

void Vhcu::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vhcu::_ctor_var_reset\n"); );
    // Body
    axi_aclk = VL_RAND_RESET_I(1);
    axi_resetn = VL_RAND_RESET_I(1);
    sha_type = VL_RAND_RESET_I(2);
    en = VL_RAND_RESET_I(1);
    s_axis_tdata = VL_RAND_RESET_Q(64);
    s_axis_tvalid = VL_RAND_RESET_I(1);
    s_axis_tready = VL_RAND_RESET_I(1);
    s_axis_tlast = VL_RAND_RESET_I(1);
    VL_RAND_RESET_W(512, m_axis_tdata);
    m_axis_tvalid = VL_RAND_RESET_I(1);
    m_axis_tready = VL_RAND_RESET_I(1);
    m_axis_tlast = VL_RAND_RESET_I(1);
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        hcu__DOT__Reg[__Vi0] = VL_RAND_RESET_Q(64);
    }
    hcu__DOT__E_new = VL_RAND_RESET_Q(64);
    hcu__DOT__T1 = VL_RAND_RESET_Q(64);
    hcu__DOT__T2 = VL_RAND_RESET_Q(64);
    hcu__DOT__sig_ch_sum = VL_RAND_RESET_Q(64);
    hcu__DOT__wt_kt_sum = VL_RAND_RESET_Q(64);
    hcu__DOT__wt_kt_h_sum = VL_RAND_RESET_Q(64);
    hcu__DOT__word_count = VL_RAND_RESET_I(7);
    hcu__DOT__sha_type_reg = VL_RAND_RESET_I(2);
    hcu__DOT__sigma0 = VL_RAND_RESET_Q(64);
    hcu__DOT__sigma1 = VL_RAND_RESET_Q(64);
    hcu__DOT__maj = VL_RAND_RESET_Q(64);
    hcu__DOT__ch = VL_RAND_RESET_Q(64);
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        hcu__DOT__H[__Vi0] = VL_RAND_RESET_Q(64);
    }
    hcu__DOT__finish = VL_RAND_RESET_I(1);
    hcu__DOT__state = VL_RAND_RESET_I(3);
    hcu__DOT__state_next = VL_RAND_RESET_I(3);
    hcu__DOT__s_axis_tready_next = VL_RAND_RESET_I(1);
    hcu__DOT__m_axis_tvalid_next = VL_RAND_RESET_I(1);
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        hcu__DOT____Vcellout__per_block__H[__Vi0] = VL_RAND_RESET_Q(64);
    }
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        hcu__DOT____Vcellinp__per_block__AH[__Vi0] = VL_RAND_RESET_Q(64);
    }
    hcu__DOT____Vcellinp__wt_kt__b = VL_RAND_RESET_Q(64);
    for (int __Vi0=0; __Vi0<8; ++__Vi0) {
        hcu__DOT__per_block__DOT__Sums[__Vi0] = VL_RAND_RESET_Q(64);
    }
}
