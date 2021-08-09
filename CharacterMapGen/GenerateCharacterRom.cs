using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace CharacterMapGen
{
    public class GenerateCharacterRom
    {
        public static void Generate()
        {
            byte[] rom = File.ReadAllBytes("CGACHAR.BIN");
            List<string> asmLines = new List<string>();
            List<string> incLines = new List<string>();
            asmLines.Add("stm8/");
            asmLines.Add(";=============================================");
            asmLines.Add("; Generated file from a CGA character ROM");
            asmLines.Add(";=============================================");
            asmLines.Add("\tWORDS\t; The following addresses are 16 bits long");
            asmLines.Add("\tsegment byte at 8100-88FF \'charset\'");
            asmLines.Add(".characterrom.w");
            incLines.Add("\tEXTERN characterrom");
            for (int j = 0; j < 8; j++)
            {
                asmLines.Add(";==============");
                asmLines.Add(String.Format("; Line {0}", j));
                asmLines.Add(";==============");
                for (int i = 0; i < 256; i += 8)
                {
                    asmLines.Add(String.Format("\tDC.B ${0:X2},${1:X2},${2:X2},${3:X2},${4:X2},${5:X2},${6:X2},${7:X2}  ; ${8:X2} - ${9:X2}",
                    rom[(i + 0) * 8 + j + 0x1800],
                    rom[(i + 1) * 8 + j + 0x1800],
                    rom[(i + 2) * 8 + j + 0x1800],
                    rom[(i + 3) * 8 + j + 0x1800],
                    rom[(i + 4) * 8 + j + 0x1800],
                    rom[(i + 5) * 8 + j + 0x1800],
                    rom[(i + 6) * 8 + j + 0x1800],
                    rom[(i + 7) * 8 + j + 0x1800],
                        i, i + 7));
                }
            }
            asmLines.Add("\tend");
            File.WriteAllLines("characterrom.asm", asmLines);
            File.WriteAllLines("characterrom.inc", incLines);
        }
    }
}
