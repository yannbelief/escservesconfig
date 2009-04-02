using System.Collections;
using System.IO;
using System.Net;
using System.Text;

namespace Thoughtworks.Escape
{
    public class Client
    {
        /// <summary>
        /// Get configure settings of the application under the environment from Escape server.
        /// </summary>
        /// <param name="host">The Url of Escape server</param>
        /// <param name="environment">The Environment name</param>
        /// <param name="application">The Application name</param>
        /// <returns></returns>
        public Hashtable GetSettings(string host, string environment, string application)
        {
            string input = string.Empty;
            WebRequest request = WebRequest.Create(host + "/environments/" + environment + "/" + application);
            WebResponse response = request.GetResponse();
            using (Stream stream = response.GetResponseStream())
            {
                byte[] buffer = ReadFully(stream);
                UTF8Encoding encoding = new UTF8Encoding();
                if (buffer.Length > 0) input = encoding.GetString(buffer);
            }
            return Parser.Parse(input);
        }

        private  byte[] ReadFully(Stream stream)
        {
            byte[] buffer = new byte[32768];
            using (MemoryStream ms = new MemoryStream())
            {
                while (true)
                {
                    int read = stream.Read(buffer, 0, buffer.Length);
                    if (read <= 0)
                        return ms.ToArray();
                    ms.Write(buffer, 0, read);
                }
            }
        }
    }
}