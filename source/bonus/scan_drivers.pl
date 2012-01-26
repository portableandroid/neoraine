#!/usr/bin/perl

# It's a quick and dirty script to generate makefiles + include files to
# build a minimal executable when given a list of drivers. The dependancies
# handling was slightly more complicated than what I thought, so the script
# is much longer that what I wanted, but it works (tested for gunbird, bublbobl
# mcatadv, and a few others).

use strict;

my ($use_68k, $use_z80, $use_6502, $use_020,$use_68705, # cpus
  $use_2151,$use_2203,$use_2413,$use_2610,$use_3812,$use_adpcm,$use_ay8910,
  $use_dac, $use_dxsmp, $use_ensoniq, $use_m6585, $use_msm5205, $use_namco,
  $use_qsound,$use_smp16bit,$use_toaplan2,$use_x1_010,$use_ymf278b,
  $use_ymz280b,
  $use_f3system,$use_nichi,$use_taitosnd,$use_tchnosnd,
  %tc,$use_gun,$use_emudx,$use_cat93c46,$use_decode, $use_cps2crpt) = undef;
my @obj = ();

unlink "source/games/drivers.h";
while ($_ = shift @ARGV) {
  my @drivers = ();
  open(F,"<$_") || die "open $_\n";
  s/^.+\///; # remove path
  my $file = $_;
  my $name = uc($_);
  $name =~ s/\..*//; # strip extension

  while (<F>) {
    next if (/\\\r?$/); # macro definition
    if (/^(GAME|CLONE|CLONE_ROMSW|CLONE_LOAD|CLONE_DSW|GME|GME_ROMSW|cps1_gameb?|cps1_game_270b?|cps1_cloneb?|cps1b4_game|cps1b4_clone|sfzch_game|cps1_clone_270b?|forgottn_game|forgottn_clone|cps2_game|cps2_region|cps2_clone|cps2_clone_no_parent|cps2_clone_reg|cps2_game_270|qsound_game|qsound_clone|sf2_game|sf2_clone)\( ?([a-z0-9A-Z_]+)/) {
      push @drivers,$2;
    } elsif (/(AddRead|AddWrite)/) {
      $use_68k = 1
    } elsif (/R24\[/) {
      $use_020 = 1;
    } elsif (/m68705.h/) {
      $use_68705 = 1;
    } elsif (/cat93c46.h/) {
      $use_cat93c46 = 1;
    } elsif (/decode.h/) {
      $use_decode = 1;
    } elsif (/cps2crpt.h/) {
      $use_cps2crpt = 1;
    } elsif (/f3system.h/) {
      $use_020 = 1;
      $use_ensoniq = 1;
      $use_68k = 1;
      $use_f3system = 1;
    } elsif (/emudx.h/) {
      $use_emudx = 1;
    } elsif (/AddZ80/) {
      $use_z80 = 1;
    } elsif (/AddM6502/) {
      $use_6502 = 1;
    } elsif (/tchnosnd.h/) {
      $use_2610 = 1;
      $use_2151 = 1;
      $use_2203 = 1;
      $use_adpcm = 1;
      $use_tchnosnd = 1;
    } elsif (/taitosnd.h/) {
      $use_taitosnd = 1;
      $use_2610 = 1;
      $use_2151 = 1;
      $use_2203 = 1;
      $use_adpcm = 1;
    } elsif (/2151intf.h/) {
      $use_2151 = 1;
    } elsif (/2203intf.h/) {
      $use_2203 = 1;
    } elsif (/2413intf.h/) {
      $use_2413 = 1;
    } elsif (/2610intf.h/) {
      $use_2610 = 1;
    } elsif (/(3812intf.h)/) {
      $use_3812 = 1;
    } elsif (/nichisnd.h/) {
      $use_3812 = 1;
      $use_nichi = 1;
    } elsif (/adpcm.h/) {
      $use_adpcm = 1;
    } elsif (/ay8910.h/) {
      $use_ay8910 = 1;
    } elsif (/dac.h/) {
      $use_dac = 1;
    } elsif (/dxsmp.h/) {
      $use_dxsmp = 1;
    } elsif( /es5506.h/) {
      $use_ensoniq = 1;
    } elsif (/m6585.h/) {
      $use_m6585 = 1;
    } elsif (/msm5205.h/) {
      $use_msm5205 = 1;
    } elsif (/namco.h/) {
      $use_namco = 1;
    } elsif (/qsound.h/) {
      $use_qsound = 1;
    } elsif (/smp16bit.h/) {
      $use_smp16bit = 1;
    } elsif (/ymz280b.h/) {
      $use_ymz280b = 1;
    } elsif (/ymf278b.h/) {
      $use_ymf278b = 1;
    } elsif (/x1_010.h/) {
      $use_x1_010 = 1;
    } elsif (/toaplan2.h/) {
      $use_toaplan2 = 1;
    } elsif (/tc(\d.+?)\.h/) {
      $tc{"tc$1.o"} = 1;
    } elsif (/gun.h/) {
      $use_gun = 1;
    } elsif (/taito_z.h/) {
      $tc{"taito_z.o"} = 1;
    }
  } # while
  close(F);
  next if (!@drivers);
#   open(F,">>conf.h") || die "can't write to conf.h\n";
#   print F "#define DRIVER_$name\n";
#   close(F);
  open(F,">>source/games/drivers.h") || die "can't write to drivers.h\n";
  # print F "#ifdef DRIVER_$name\n";
  print F "// $file\n";
  foreach (@drivers) {
    print F "  DRV($_)\n";
  }
#   print F "#endif\n";
  print F "\n";
  close(F);
  my $object = $file;
  $object =~ s/\.c/.o/;
  $use_ay8910 = 1 if ($use_2203 || $use_2610);
  push @obj,$object;
  if ($file eq "bublbobl.c") {
    push @obj,"bubl_mcu.o";
    $use_68705 = 1;
  }
  push @obj,"nmk004.o" if ($file eq "nmk.c");
  if ($file =~ /cps.drv/) {
    $tc{"cps1.o"} = 1;
  } elsif ($file eq "ksystem.c") {
    $tc{"kick_mcu.o"} = 1;
    $tc{"kiki_mcu.o"} = 1;
  } elsif ($file eq "seta.c" || $file eq "xsystem1.c") {
    $tc{"setax1.o"} = 1;
  }
}
push @obj,"f3system.o" if ($use_f3system);
push @obj, "nichisnd.o" if ($use_nichi);
if ($use_taitosnd) {
  push @obj, "taitosnd.o"; 
  $tc{"tc140syt.o"} = 1;
}
$tc{"tc101scn.o"} = 1 if ($tc{"tc100scn.o"});
push @obj, "tchnosnd.o" if ($use_tchnosnd);
foreach (keys %tc) {
  push @obj, $_;
}
push @obj, "gun.o" if ($use_gun);

open(G,">source/sound/conf-sound.h") || die "open conf-sound.h\n";
open(F,">games.mak") || die "can't write to games.mak\n";
#   print F "ifdef DRIVER_$name\n";
print F "ifdef NEO\n";
print F "\nOBJS += \\\n";
print F "\t\$(SC000) \\\n";
print F "\t\$(MZ80) \\\n";
print F "\t\$(2610) \\\n"; 
print G "#ifdef NEO\n";
print G "#define HAS_YM2610  1\n";
print G "#define HAS_YM2610B  1\n";
print F "\t\$(AY8910) \\\n";
print G "#define HAS_AY8910 1\n";
print F "\t\$(NEOCD) \n";
print F "else\n";
print G "#else\n";

print F "OBJS += \\\n";
foreach (@obj) {
  print F "\t\$(OBJDIR)/games/$_ \\\n";
}
print F "\nOBJS += \\\n";
print F "\t\$(SC000) \\\n" if ($use_68k);
print F "\t\$(ASM020) \\\n" if ($use_020);
print F "\t\$(MZ80) \\\n" if ($use_z80);
print F "\t\$(M6502) \\\n" if ($use_6502);
print F "\t\$(M68705) \\\n" if ($use_68705);
print F "\t\$(2151) \\\n" if ($use_2151);
print G "#define HAS_YM2151_ALT 1\n" if ($use_2151);
print F "\t\$(2203) \\\n" if ($use_2203);
print G "#define HAS_YM2203  1\n" if ($use_2203);
print F "\t\$(2413) \\\n" if ($use_2413);
print G "#define HAS_YM2413 1\n" if ($use_2413);
if ($use_2610) {
  print F "\t\$(2610) \\\n"; 
  print G "#define HAS_YM2610  1\n";
  print G "#define HAS_YM2610B  1\n";
}
if ($use_emudx) {
  print F "\t\$(OBJDIR)/emudx.o \\\n"; 
  print G "#define HAS_EMUDX 1\n"; # it should probably be placed elsewhere...
}
print F "\t\$(OBJDIR)/cat93c46.o \\\n"if ($use_cat93c46);
print F "\t\$(OBJDIR)/decode.o \\\n"if ($use_decode);
print F "\t\$(OBJDIR)/cps2crpt.o \\\n"if ($use_cps2crpt);
print F "\t\$(3812) \\\n" if ($use_3812);
print G "#define HAS_YM3812 1\n" if ($use_3812);
print F "\t\$(ADPCM) \\\n" if ($use_adpcm);
print G "#define HAS_ADPCM 1\n" if ($use_adpcm);
print F "\t\$(AY8910) \\\n" if ($use_ay8910);
print G "#define HAS_AY8910 1\n" if ($use_ay8910);
print F "\t\$(DAC) \\\n" if ($use_dac);
print G "#define HAS_DAC 1\n" if ($use_dac);
print F "\t\$(DXSMP) \\\n" if ($use_dxsmp);
print G "#define HAS_DXSMP 1\n" if ($use_dxsmp);
print F "\t\$(ENSONIQ) \\\n" if ($use_ensoniq);
print G "#define HAS_ES5505 1\n" if ($use_ensoniq);
print F "\t\$(M6585) \\\n" if ($use_m6585);
print G "#define HAS_M6585 1\n" if ($use_m6585);
print F "\t\$(MSM5205) \\\n" if ($use_msm5205);
print G "#define HAS_MSM5205_BUFF 1\n" if ($use_msm5205);
print F "\t\$(NAMCO) \\\n" if ($use_namco);
print G "#define HAS_NAMCO 1\n" if ($use_namco);
print F "\t\$(QSOUND) \\\n" if ($use_qsound);
print G "#define HAS_QSOUND 1\n" if ($use_qsound);
print F "\t\$(SMP16BIT) \\\n" if ($use_smp16bit);
print G "#define HAS_SMP16 1\n" if ($use_smp16bit);
print F "\t\$(YMZ280B) \\\n" if ($use_ymz280b);
print G "#define HAS_YMZ280B 1\n" if ($use_ymz280b);
print F "\t\$(YMF278B) \\\n" if ($use_ymf278b);
print G "#define HAS_YMF278B 1\n" if ($use_ymf278b);
print F "\t\$(X1_010) \\\n" if ($use_x1_010);
print G "#define HAS_X1_010 1\n" if ($use_x1_010);
print F "\t\$(TOAPLAN2) \\\n" if ($use_toaplan2);
print F "\nendif\n";
print G "#endif\n";
close(F);
close(G);
open(F,">source/conf-cpu.h") || die "conf-cpu.h";
print F "#ifdef NEO\n";
print F "#define NO020 1\n";
print F "#define HAVE_68000 1\n";
print F "#define HAVE_Z80 1\n";
print F "#else\n";
print F "#define NO020 1\n" if (!$use_020);
print F "#define HAVE_6502 1\n" if ($use_6502);
print F "#define HAVE_68000 1\n" if ($use_68k);
print F "#define HAVE_Z80 1\n" if ($use_z80);
print F "#endif\n";
close(F);
