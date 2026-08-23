# Parameterized Synchronous FIFO

A synthesizable parameterized synchronous FIFO implemented in Verilog HDL.

The FIFO uses a single clock for both read and write operations and supports configurable data width and FIFO depth.

## Features

- Parameterized data width
- Parameterized FIFO depth
- Single-clock synchronous operation
- Synchronous read
- Write enable and read enable
- `full` and `empty` status flags
- Circular read/write pointers
- Synchronous active-high reset
- ModelSim/Questa simulation support
- Verilog testbench included

## Directory Structure

```text
parameterized-sync-fifo/
│
├── rtl/
│   └── sync_fifo.v
│
├── tb/
│   └── tb_sync_fifo.v
│
├── sim/
│   └── fifo.do
