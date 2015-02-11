---------------------------------------------------------------------------
--
--  (c) Copyright 2011 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES.
--
---------------------------------------------------------------------------
-- Description:
-- This is an example testbench for the FIR Compiler LogiCORE module.
-- The testbench has been generated by the Xilinx CORE Generator software
-- to accompany the netlist you have generated.
--
-- This testbench is for demonstration purposes only.  See note below for
-- instructions on how to use it with the netlist created for your core.
--
-- See the FIR Compiler datasheet for further information about this core.
--
---------------------------------------------------------------------------
-- Using this testbench
--
-- This testbench instantiates your generated FIR Compiler core
-- named "half_band_interp".
--
-- There are two versions of your core that you can use in this testbench:
-- the XilinxCoreLib behavioral model or the generated netlist.
--
-- 1. XilinxCoreLib behavioral model
--    Compile half_band_interp.vhd into the work library.  See your
--    simulator documentation for more information on how to do this.
--
-- 2. Generated netlist
--    Execute the following command in the directory containing your CORE
--    Generator output files, to create a VHDL netlist:
--
--      netgen -sim -ofmt vhdl half_band_interp.ngc half_band_interp_netlist.vhd
--
--    Compile half_band_interp_netlist.vhd into the work library.  See your
--    simulator documentation for more information on how to do this.
--
---------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_half_band_interp is
end tb_half_band_interp;

architecture tb of tb_half_band_interp is

  -----------------------------------------------------------------------
  -- Timing constants
  -----------------------------------------------------------------------
  constant CLOCK_PERIOD : time := 100 ns;
  constant T_HOLD       : time := 10 ns;
  constant T_STROBE     : time := CLOCK_PERIOD - (1 ns);

  -----------------------------------------------------------------------
  -- DUT signals
  -----------------------------------------------------------------------

  -- General signals
  signal aclk                            : std_logic := '0';  -- the master clock

  -- Data slave channel signals
  signal s_axis_data_tvalid              : std_logic := '0';  -- payload is valid
  signal s_axis_data_tready              : std_logic := '1';  -- slave is ready
  signal s_axis_data_tdata               : std_logic_vector(31 downto 0) := (others => '0');  -- data payload

  -- Data master channel signals
  signal m_axis_data_tvalid              : std_logic := '0';  -- payload is valid
  signal m_axis_data_tready              : std_logic := '1';  -- slave is ready
  signal m_axis_data_tdata               : std_logic_vector(31 downto 0) := (others => '0');  -- data payload

  -----------------------------------------------------------------------
  -- Aliases for AXI channel TDATA and TUSER fields
  -- These are a convenience for viewing data in a simulator waveform viewer.
  -- If using ModelSim or Questa, add "-voptargs=+acc=n" to the vsim command
  -- to prevent the simulator optimizing away these signals.
  -----------------------------------------------------------------------

  -- Data slave channel alias signals
  signal s_axis_data_tdata_path0       : std_logic_vector(15 downto 0) := (others => '0');
  signal s_axis_data_tdata_path1       : std_logic_vector(15 downto 0) := (others => '0');

  -- Data master channel alias signals
  signal m_axis_data_tdata_path0       : std_logic_vector(15 downto 0) := (others => '0');
  signal m_axis_data_tdata_path1       : std_logic_vector(15 downto 0) := (others => '0');


begin

  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------

  dut : entity work.half_band_interp
    port map (
      aclk                            => aclk,
      s_axis_data_tvalid              => s_axis_data_tvalid,
      s_axis_data_tready              => s_axis_data_tready,
      s_axis_data_tdata               => s_axis_data_tdata,
      m_axis_data_tvalid              => m_axis_data_tvalid,
      m_axis_data_tready              => m_axis_data_tready,
      m_axis_data_tdata               => m_axis_data_tdata
      );

  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------

  clock_gen : process
  begin
    aclk <= '0';
    wait for CLOCK_PERIOD;
    loop
      aclk <= '0';
      wait for CLOCK_PERIOD/2;
      aclk <= '1';
      wait for CLOCK_PERIOD/2;
    end loop;
  end process clock_gen;

  -----------------------------------------------------------------------
  -- Generate inputs
  -----------------------------------------------------------------------

  stimuli : process

    -- Procedure to drive a number of input samples with specific data
    -- data is the data value to drive on the tdata signal
    -- samples is the number of zero-data input samples to drive
    procedure drive_data ( data    : std_logic_vector(31 downto 0);
                           samples : natural := 1 ) is
      variable ip_count : integer := 0;
    begin
      ip_count := 0;
      loop
        s_axis_data_tvalid <= '1';
        s_axis_data_tdata  <= data;
        loop
          wait until rising_edge(aclk);
          exit when s_axis_data_tready = '1';
        end loop;
        ip_count := ip_count + 1;
        wait for T_HOLD;
      -- Input rate is 1 input each 2 clock cycles: drive valid inputs at this rate
        s_axis_data_tvalid <= '0';
        wait for CLOCK_PERIOD * 1;
        exit when ip_count >= samples;
      end loop;
    end procedure drive_data;

    -- Procedure to drive a number of zero-data input samples
    -- samples is the number of zero-data input samples to drive
    procedure drive_zeros ( samples : natural := 1 ) is
    begin
      drive_data((others => '0'), samples);
    end procedure drive_zeros;

    -- Procedure to drive an impulse and let the impulse response emerge on the data master channel
    -- samples is the number of input samples to drive; default is enough for impulse response output to emerge
    procedure drive_impulse ( samples : natural := 21 ) is
      variable impulse : std_logic_vector(31 downto 0);
    begin
      impulse := (others => '0');  -- initialize unused bits to zero
      impulse(15 downto 0) := "0100000000000000";
      drive_data(impulse);
      if samples > 1 then
        drive_zeros(samples-1);
      end if;
    end procedure drive_impulse;

    -- Local variables
    variable data : std_logic_vector(31 downto 0);

  begin

    -- Drive inputs T_HOLD time after rising edge of clock
    wait until rising_edge(aclk);
    wait for T_HOLD;

    -- Drive a single impulse and let the impulse response emerge
    drive_impulse;

    -- Drive another impulse, during which demonstrate use and effect of AXI handshaking signals
    drive_impulse(2);  -- start of impulse; data is now zero
    s_axis_data_tvalid <= '0';
    wait for CLOCK_PERIOD * 10;  -- provide no data for 5 input samples worth
    drive_zeros(2);  -- 2 normal input samples
    s_axis_data_tvalid <= '1';
    wait for CLOCK_PERIOD * 10;  -- provide data as fast as the core can accept it for 5 input samples worth
    drive_zeros(2);  -- 2 normal input samples
    m_axis_data_tready <= '0';
    drive_zeros(10);  -- stop accepting outputs for 10 input samples worth
    m_axis_data_tready <= '1';
    drive_zeros(0);  -- back to normal operation

    -- Drive a set of impulses of different magnitudes on each path
    -- Path inputs are provided in parallel, in different fields of s_axis_data_tdata
    data := (others => '0');  -- initialize unused bits to zero
    data(15 downto 0) := "0100000000000000";  -- path 0: impulse >> 0
    data(31 downto 16) := "0010000000000000";  -- path 1: impulse >> 1
    drive_data(data);
    drive_zeros(20);

    -- End of test
    report "Not a real failure. Simulation finished successfully." severity failure;
    wait;

  end process stimuli;

  -----------------------------------------------------------------------
  -- Check outputs
  -----------------------------------------------------------------------

  check_outputs : process
    variable check_ok : boolean := true;
    -- Previous values of master DATA channel signals
    variable data_tvalid_prev : std_logic := '0';
    variable data_tready_prev : std_logic := '0';
    variable data_tdata_prev  : std_logic_vector(31 downto 0) := (others => '0');
  begin

    -- Check outputs T_STROBE time after rising edge of clock
    wait until rising_edge(aclk);
    wait for T_STROBE;

    -- Do not check the output payload values, as this requires the behavioral model
    -- which would make this demonstration testbench unwieldy.
    -- Instead, check the protocol of the master DATA channel:
    -- check that the payload is valid (not X) when TVALID is high
    -- and check that the payload does not change while TVALID is high until TREADY goes high

    if m_axis_data_tvalid = '1' then
      if is_x(m_axis_data_tdata) then
        report "ERROR: m_axis_data_tdata is invalid when m_axis_data_tvalid is high" severity error;
        check_ok := false;
      end if;

      if data_tvalid_prev = '1' and data_tready_prev = '0' then  -- payload must be the same as last cycle
        if m_axis_data_tdata /= data_tdata_prev then
          report "ERROR: m_axis_data_tdata changed while m_axis_data_tvalid was high and m_axis_data_tready was low" severity error;
          check_ok := false;
        end if;
      end if;

    end if;

    assert check_ok
      report "ERROR: terminating test with failures." severity failure;

    -- Record payload values for checking next clock cycle
    if check_ok then
      data_tvalid_prev := m_axis_data_tvalid;
      data_tready_prev := m_axis_data_tready;
      data_tdata_prev  := m_axis_data_tdata;
    end if;

  end process check_outputs;

  -----------------------------------------------------------------------
  -- Assign TDATA / TUSER fields to aliases, for easy simulator waveform viewing
  -----------------------------------------------------------------------

  -- Data slave channel alias signals
  s_axis_data_tdata_path0       <= s_axis_data_tdata(15 downto 0);
  s_axis_data_tdata_path1       <= s_axis_data_tdata(31 downto 16);

  -- Data master channel alias signals: update these only when they are valid
  m_axis_data_tdata_path0       <= m_axis_data_tdata(15 downto 0) when m_axis_data_tvalid = '1';
  m_axis_data_tdata_path1       <= m_axis_data_tdata(31 downto 16) when m_axis_data_tvalid = '1';

end tb;

