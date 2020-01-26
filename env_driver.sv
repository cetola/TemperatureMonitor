/*
Module: env_driver.sv
Authors:
Stephano Cetola <cetola@pdx.edu>
SPDX-License-Identifier: MIT
*/

//TODO: make this a class and use the tmon_bus
module env_driver;

    covergroup op_cov;
        all_ops: coverpoint op_set {
            bins set_cmds[] = {SET_FRQ, SET_HIGH_TEMP, SET_LOW_TEMP};
            bins get_cmds[] = {OUT_MIN, OUT_MAX, OUT_ADDR, OUT_AVG};
        }
    endgroup
endmodule