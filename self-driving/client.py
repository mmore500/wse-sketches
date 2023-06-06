from glob import glob

import numpy as np

from cerebras.elf.cs_elf_runner import CSELFRunner

# Path to ELF and simulation output files
elf_paths = glob("out/bin/out_*.elf")
sim_out_path = "out-core.out"

# Simulate ELF file and produce the simulation output
runner = CSELFRunner(elf_paths)

# Proceed with simulation
runner.connect_and_run(sim_out_path)

# Read a single u16 value from the address of the variable called "cycle".
rectangle = ((0, 0), (2, 2))
data = runner.get_symbol_rect(rectangle, "cycle", np.uint16)

# Ensure that the result matches our expectation
print(data)
print("SUCCESS!")
