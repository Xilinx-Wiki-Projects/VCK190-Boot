# Wiki-Projecta VCK190-Boot Repository
This repository contains Versal Example Designs related to boot on a VCK190 board. 

---
## **What to Expect**
Each Versal Example Design contains the following structure:

```
<design>
├── Hardware
│   └── constraints
│       └── constraints.xdc
├── README.md
├── Icons
├── Scripts
│   ├── <design>_bd.tcl
│   └── project_top.tcl
└── Software
    ├── PetaLinux
    └── Vitis
````
Each design's `README.md` will provide a detailed overview of the Versal Example Design.

For example:

- **Design Summary** - Brief summary of the design.

- **Required Hardware and Tools** - Listing of required hardware

- **Build Instructions** - Instructions on how to re-build the designs

- **Validation** - List of exact validation hardware, and results of validation tests run against the design

- **Known Issues** - Current known issues with the design and/or workarounds for these issues.
---
## **Troubleshooting / Assistance**
If you find you are having difficulty bringing up one of the designs, or need some additional assistance, please reach out on the [Xilinx Community Forums](https://forums.xilinx.com).

Be sure to [search](https://forums.xilinx.com/t5/forums/searchpage/tab/message?advanced=false&allow_punctuation=false&inactive=false) the forums first before posting, as someone may already have the solution!

---
