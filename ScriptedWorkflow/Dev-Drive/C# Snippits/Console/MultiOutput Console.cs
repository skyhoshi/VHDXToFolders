using System;
using System.IO;

class Program
{
    static void Main()
    {
        // Create a StreamWriter to write to a file
        using (StreamWriter writer = new StreamWriter("output.txt"))
        {
            // Create a custom TextWriter that writes to both the console and the file
            MultiTextWriter multiWriter = new MultiTextWriter(Console.Out, writer);

            // Redirect console output to the custom TextWriter
            Console.SetOut(multiWriter);

            // Write to the console (which now writes to both the console and the file)
            Console.WriteLine("This will be written to both the console and the file.");

            // You can still write to the console directly if needed
            Console.Error.WriteLine("This will be written only to the console.");
        }
    }
}

// Custom TextWriter that writes to multiple TextWriters
public class MultiTextWriter : TextWriter
{
    private readonly TextWriter _consoleWriter;
    private readonly TextWriter _fileWriter;

    public MultiTextWriter(TextWriter consoleWriter, TextWriter fileWriter)
    {
        _consoleWriter = consoleWriter;
        _fileWriter = fileWriter;
    }

    public override Encoding Encoding => _consoleWriter.Encoding;

    public override void Write(char value)
    {
        _consoleWriter.Write(value);
        _fileWriter.Write(value);
    }

    public override void WriteLine(string value)
    {
        _consoleWriter.WriteLine(value);
        _fileWriter.WriteLine(value);
    }

    public override void Flush()
    {
        _consoleWriter.Flush();
        _fileWriter.Flush();
    }
}
