// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vhcu.h for the primary calling header

#include "Vhcu___024unit.h"
#include "Vhcu__Syms.h"

//==========

VL_CTOR_IMP(Vhcu___024unit) {
    // Reset internal values
    // Reset structure values
    _ctor_var_reset();
}

void Vhcu___024unit::__Vconfigure(Vhcu__Syms* vlSymsp, bool first) {
    if (false && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
    if (false && this->__VlSymsp) {}  // Prevent unused
}

Vhcu___024unit::~Vhcu___024unit() {
}

void Vhcu___024unit::_initial__TOP____024unit__1(Vhcu__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+        Vhcu___024unit::_initial__TOP____024unit__1\n"); );
    Vhcu* const __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlSymsp->TOP____024unit.Kt[0U] = 0x428a2f98d728ae22ULL;
    vlSymsp->TOP____024unit.Kt[1U] = 0x7137449123ef65cdULL;
    vlSymsp->TOP____024unit.Kt[2U] = 0xb5c0fbcfec4d3b2fULL;
    vlSymsp->TOP____024unit.Kt[3U] = 0xe9b5dba58189dbbcULL;
    vlSymsp->TOP____024unit.Kt[4U] = 0x3956c25bf348b538ULL;
    vlSymsp->TOP____024unit.Kt[5U] = 0x59f111f1b605d019ULL;
    vlSymsp->TOP____024unit.Kt[6U] = 0x923f82a4af194f9bULL;
    vlSymsp->TOP____024unit.Kt[7U] = 0xab1c5ed5da6d8118ULL;
    vlSymsp->TOP____024unit.Kt[8U] = 0xd807aa98a3030242ULL;
    vlSymsp->TOP____024unit.Kt[9U] = 0x12835b0145706fbeULL;
    vlSymsp->TOP____024unit.Kt[0xaU] = 0x243185be4ee4b28cULL;
    vlSymsp->TOP____024unit.Kt[0xbU] = 0x550c7dc3d5ffb4e2ULL;
    vlSymsp->TOP____024unit.Kt[0xcU] = 0x72be5d74f27b896fULL;
    vlSymsp->TOP____024unit.Kt[0xdU] = 0x80deb1fe3b1696b1ULL;
    vlSymsp->TOP____024unit.Kt[0xeU] = 0x9bdc06a725c71235ULL;
    vlSymsp->TOP____024unit.Kt[0xfU] = 0xc19bf174cf692694ULL;
    vlSymsp->TOP____024unit.Kt[0x10U] = 0xe49b69c19ef14ad2ULL;
    vlSymsp->TOP____024unit.Kt[0x11U] = 0xefbe4786384f25e3ULL;
    vlSymsp->TOP____024unit.Kt[0x12U] = 0xfc19dc68b8cd5b5ULL;
    vlSymsp->TOP____024unit.Kt[0x13U] = 0x240ca1cc77ac9c65ULL;
    vlSymsp->TOP____024unit.Kt[0x14U] = 0x2de92c6f592b0275ULL;
    vlSymsp->TOP____024unit.Kt[0x15U] = 0x4a7484aa6ea6e483ULL;
    vlSymsp->TOP____024unit.Kt[0x16U] = 0x5cb0a9dcbd41fbd4ULL;
    vlSymsp->TOP____024unit.Kt[0x17U] = 0x76f988da831153b5ULL;
    vlSymsp->TOP____024unit.Kt[0x18U] = 0x983e5152ee66dfabULL;
    vlSymsp->TOP____024unit.Kt[0x19U] = 0xa831c66d2db43210ULL;
    vlSymsp->TOP____024unit.Kt[0x1aU] = 0xb00327c898fb213fULL;
    vlSymsp->TOP____024unit.Kt[0x1bU] = 0xbf597fc7beef0ee4ULL;
    vlSymsp->TOP____024unit.Kt[0x1cU] = 0xc6e00bf33da88fc2ULL;
    vlSymsp->TOP____024unit.Kt[0x1dU] = 0xd5a79147930aa725ULL;
    vlSymsp->TOP____024unit.Kt[0x1eU] = 0x6ca6351e003826fULL;
    vlSymsp->TOP____024unit.Kt[0x1fU] = 0x142929670a0e6e70ULL;
    vlSymsp->TOP____024unit.Kt[0x20U] = 0x27b70a8546d22ffcULL;
    vlSymsp->TOP____024unit.Kt[0x21U] = 0x2e1b21385c26c926ULL;
    vlSymsp->TOP____024unit.Kt[0x22U] = 0x4d2c6dfc5ac42aedULL;
    vlSymsp->TOP____024unit.Kt[0x23U] = 0x53380d139d95b3dfULL;
    vlSymsp->TOP____024unit.Kt[0x24U] = 0x650a73548baf63deULL;
    vlSymsp->TOP____024unit.Kt[0x25U] = 0x766a0abb3c77b2a8ULL;
    vlSymsp->TOP____024unit.Kt[0x26U] = 0x81c2c92e47edaee6ULL;
    vlSymsp->TOP____024unit.Kt[0x27U] = 0x92722c851482353bULL;
    vlSymsp->TOP____024unit.Kt[0x28U] = 0xa2bfe8a14cf10364ULL;
    vlSymsp->TOP____024unit.Kt[0x29U] = 0xa81a664bbc423001ULL;
    vlSymsp->TOP____024unit.Kt[0x2aU] = 0xc24b8b70d0f89791ULL;
    vlSymsp->TOP____024unit.Kt[0x2bU] = 0xc76c51a30654be30ULL;
    vlSymsp->TOP____024unit.Kt[0x2cU] = 0xd192e819d6ef5218ULL;
    vlSymsp->TOP____024unit.Kt[0x2dU] = 0xd69906245565a910ULL;
    vlSymsp->TOP____024unit.Kt[0x2eU] = 0xf40e35855771202aULL;
    vlSymsp->TOP____024unit.Kt[0x2fU] = 0x106aa07032bbd1b8ULL;
    vlSymsp->TOP____024unit.Kt[0x30U] = 0x19a4c116b8d2d0c8ULL;
    vlSymsp->TOP____024unit.Kt[0x31U] = 0x1e376c085141ab53ULL;
    vlSymsp->TOP____024unit.Kt[0x32U] = 0x2748774cdf8eeb99ULL;
    vlSymsp->TOP____024unit.Kt[0x33U] = 0x34b0bcb5e19b48a8ULL;
    vlSymsp->TOP____024unit.Kt[0x34U] = 0x391c0cb3c5c95a63ULL;
    vlSymsp->TOP____024unit.Kt[0x35U] = 0x4ed8aa4ae3418acbULL;
    vlSymsp->TOP____024unit.Kt[0x36U] = 0x5b9cca4f7763e373ULL;
    vlSymsp->TOP____024unit.Kt[0x37U] = 0x682e6ff3d6b2b8a3ULL;
    vlSymsp->TOP____024unit.Kt[0x38U] = 0x748f82ee5defb2fcULL;
    vlSymsp->TOP____024unit.Kt[0x39U] = 0x78a5636f43172f60ULL;
    vlSymsp->TOP____024unit.Kt[0x3aU] = 0x84c87814a1f0ab72ULL;
    vlSymsp->TOP____024unit.Kt[0x3bU] = 0x8cc702081a6439ecULL;
    vlSymsp->TOP____024unit.Kt[0x3cU] = 0x90befffa23631e28ULL;
    vlSymsp->TOP____024unit.Kt[0x3dU] = 0xa4506cebde82bde9ULL;
    vlSymsp->TOP____024unit.Kt[0x3eU] = 0xbef9a3f7b2c67915ULL;
    vlSymsp->TOP____024unit.Kt[0x3fU] = 0xc67178f2e372532bULL;
    vlSymsp->TOP____024unit.Kt[0x40U] = 0xca273eceea26619cULL;
    vlSymsp->TOP____024unit.Kt[0x41U] = 0xd186b8c721c0c207ULL;
    vlSymsp->TOP____024unit.Kt[0x42U] = 0xeada7dd6cde0eb1eULL;
    vlSymsp->TOP____024unit.Kt[0x43U] = 0xf57d4f7fee6ed178ULL;
    vlSymsp->TOP____024unit.Kt[0x44U] = 0x6f067aa72176fbaULL;
    vlSymsp->TOP____024unit.Kt[0x45U] = 0xa637dc5a2c898a6ULL;
    vlSymsp->TOP____024unit.Kt[0x46U] = 0x113f9804bef90daeULL;
    vlSymsp->TOP____024unit.Kt[0x47U] = 0x1b710b35131c471bULL;
    vlSymsp->TOP____024unit.Kt[0x48U] = 0x28db77f523047d84ULL;
    vlSymsp->TOP____024unit.Kt[0x49U] = 0x32caab7b40c72493ULL;
    vlSymsp->TOP____024unit.Kt[0x4aU] = 0x3c9ebe0a15c9bebcULL;
    vlSymsp->TOP____024unit.Kt[0x4bU] = 0x431d67c49c100d4cULL;
    vlSymsp->TOP____024unit.Kt[0x4cU] = 0x4cc5d4becb3e42b6ULL;
    vlSymsp->TOP____024unit.Kt[0x4dU] = 0x597f299cfc657e2aULL;
    vlSymsp->TOP____024unit.Kt[0x4eU] = 0x5fcb6fab3ad6faecULL;
    vlSymsp->TOP____024unit.Kt[0x4fU] = 0x6c44198c4a475817ULL;
}

void Vhcu___024unit::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+        Vhcu___024unit::_ctor_var_reset\n"); );
    // Body
}
