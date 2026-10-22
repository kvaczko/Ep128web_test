/* SPDX-License-Identifier: MIT
 * Original-source egg smoke test; build using README in firmware_eggs/.
 */
#include "twodfx_emu.h"
#include <stdint.h>
#include <stdio.h>
/*
 * C2h builds this exact source-ordered sequence via public twodfx_api:
 *  9  FILL_ELLIPSE     -> 6Bh
 * 11  ELLIPSE          -> 6Ah
 * 61  ROUND_RECT       -> 68h
 * 63  FILL_ELLIPSE     -> 6Bh
 * 65  FILL_ROUND_RECT  -> 69h
 *
 * A source-faithful egg can still render incorrectly if the portable API
 * adapter swaps its filled/outlined opcodes. Check the *active* table after
 * an accepted frame, not merely the C source or the pending shadow table.
 */
static int check_c2_opcodes(twodfx_emu *dev, unsigned machine) {
  static const struct { unsigned slot; uint8_t opcode; } expected[] = {
    { 9u, 0x6bu }, { 11u, 0x6au }, { 61u, 0x68u },
    { 63u, 0x6bu }, { 65u, 0x69u }
  };
  unsigned n;
  for (n = 0; n < sizeof(expected)/sizeof(expected[0]); ++n) {
    twodfx_2dpt_entry e;
    if (!twodfx_emu_get_2dpt(dev, 0u, expected[n].slot, 1, &e) ||
        e.opcode != expected[n].opcode) {
      fprintf(stderr, "C2 %s slot %u: expected %02Xh outline/fill opcode\n",
              machine ? "TVC" : "Enterprise", expected[n].slot,
              expected[n].opcode);
      return 0;
    }
  }
  return 1;
}
int main(void) {
  unsigned machine, i;
  for(machine=0;machine<2;machine++) {
    twodfx_emu *dev=twodfx_emu_create((twodfx_machine)machine);
    if(!dev)return 1;
    twodfx_emu_write_f8(dev,0x50);twodfx_emu_write_f9(dev,1);
    for(i=0;i<23;i++) {
      unsigned id=i==22?31:i;
      if(machine==0 && (id==15||id==16))continue;
      twodfx_emu_write_f8(dev,(uint8_t)(0xc0+id));
      twodfx_emu_vsync(dev);
      twodfx_emu_vsync(dev);
      twodfx_emu_vsync(dev);
      if(!twodfx_emu_egg_active(dev)) {fprintf(stderr,"Egg %02X inactive\n",0xc0+id);return 2;}
      if(id==2u && !check_c2_opcodes(dev, machine))return 3;
    }
    twodfx_emu_write_f8(dev,0x8e);
    twodfx_emu_vsync(dev);
    twodfx_emu_destroy(dev);
  }
  puts("Original-source eggs and SHOW_FW native smoke: PASS");
  return 0;
}
