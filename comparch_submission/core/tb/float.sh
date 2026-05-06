#!/bin/bash

iverilog -o tb.vvp FCVT_fp.v FCVT_int.v FPAdder.v FPDiv.v FPSub.v FPMul.v FSQRT.v fpu_cntrl.v fpu.v leading_1.v normalize.v quake3.v shift_amount.v single.v feq.v flt.v fge.v FPMin.v FPMax.v fsgnj.v fsgnjn.v fsgnjx.v
vvp tb.vvp

