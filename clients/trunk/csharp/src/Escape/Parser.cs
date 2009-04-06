using System;
using System.Collections;

namespace Thoughtworks.Escape
{
    public class Parser
    {
        public static Hashtable Parse(string input)
        {
            string[] seperates = new string[1];
            input = input.Replace("\r", "");
            seperates[0] = "\n";
            string[] settings = input.Split(seperates, StringSplitOptions.RemoveEmptyEntries);
            Hashtable output = new Hashtable();
            foreach (string setting in settings)
            {
                int delimeterIndex = setting.IndexOf('=');
                output.Add(setting.Substring(0, delimeterIndex), setting.Substring(delimeterIndex + 1));
            }
            return output;
        }
    }
}