/* SPDX-License-Identifier: MIT
 * Original-source egg smoke test; build using README in firmware_eggs/.
 */
#include "twodfx_emu.h"
#include <stdint.h>
#include <stdio.h>
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
    }
    twodfx_emu_write_f8(dev,0x8e);
    twodfx_emu_vsync(dev);
    twodfx_emu_destroy(dev);
  }
  puts("Original-source eggs and SHOW_FW native smoke: PASS");
  return 0;
}
