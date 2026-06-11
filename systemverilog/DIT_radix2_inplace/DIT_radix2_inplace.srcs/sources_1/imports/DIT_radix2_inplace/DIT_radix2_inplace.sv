package DIT_radix2_inplace;
  // FSM states
  typedef enum logic [2:0] {
    IDLE,  // dont do anything
    LOAD,  // load data to mem
    COMPUTE,  // write computed c,d data to mem
    XS,  // write computed c,d data to mem
    DONE  // all computes done
  } state_t;

endpackage : DIT_radix2_inplace
