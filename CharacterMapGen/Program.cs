using System;

namespace CharacterMapGen
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Generating character rom file");
            GenerateCharacterRom.Generate();
        }
    }
}
