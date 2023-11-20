# Drop-In-Testing-Design-Project
Open Source Silicon Development Testing Unit - Senior Design Project
Oklahoma State University


Links to reference material:

https://github.com/sscs-ose/sscs-ose-chipathon.github.io

https://github.com/riscv/riscv-debug-spec

https://riscv.org/wp-content/uploads/2018/05/15.55-16-30-UL-001906-PT-C-RISCV-Debug-Specification-Update-and-Tutorial-for-Barcelona-Workshop.pdf

http://www.grandideastudio.com/jtagulator/

https://www.youtube.com/watch?v=lV3DECTwTCQ


# Potential optimizations:

Various data registers could share the same shift register circuitry, with different values being loaded @captureDR depending on the selected instruction:

1149.1-2013p167: provided rule f) of 12.1.1 is met, the shift-register stages may be shared resources used by several of
the registers defined by this standard and also by any design-specific test data register.

ex: device id could share space with ......?


# Demo design ideas:

https://www.asset-intertech.com/wp-content/uploads/2020/09/svf-serial-vector-format-specification-jtag-boundary-scan-revision-e.pdf
