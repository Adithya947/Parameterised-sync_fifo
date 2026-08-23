# ---------------------------------------
# Parameterized Synchronous FIFO
# ModelSim / Questa Simulation Script
# ---------------------------------------

# Create work library
if {[file exists work]} {
    vdel -lib work -all
}

vlib work
vmap work work

# Compile RTL
vlog sync_fifo.v

# Compile Testbench
vlog tb_sync_fifo.v

# Start simulation
vsim -voptargs=+acc work.tb_sync_fifo

# Add important signals
add wave -divider "CLOCK / RESET"
add wave sim:/tb_sync_fifo/clk
add wave sim:/tb_sync_fifo/rst

add wave -divider "FIFO CONTROL"
add wave sim:/tb_sync_fifo/wr_en
add wave sim:/tb_sync_fifo/rd_en
add wave sim:/tb_sync_fifo/full
add wave sim:/tb_sync_fifo/empty

add wave -divider "FIFO DATA"
add wave sim:/tb_sync_fifo/din
add wave sim:/tb_sync_fifo/dout

add wave -divider "FIFO INTERNAL"
add wave sim:/tb_sync_fifo/dut/wr_ptr
add wave sim:/tb_sync_fifo/dut/rd_ptr
add wave sim:/tb_sync_fifo/dut/count

# Run simulation
run -all

# Zoom waveform
wave zoom full