using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using NUnit.Framework;

namespace Thoughtworks.Escape.Tests
{
    [TestFixture]
    [Category("FunctionalTests")]
    public class ClientTest
    {
        private const string HOST = "http://localhost:7000";
        private const string ENV = "default";
        private const string APP = "esc-client-csharp";

        private  string Url {get{return HOST + "/environments/" + ENV + "/" + APP;}
        }

        [SetUp]
        public void SetUp()
        {
 
            ExecutePutMethod(Url);
            ExecutePutMethod(Url + "/key1", "value1");
            ExecutePutMethod(Url + "/key2", "value2");
        }

        
       

        [Test]
        public void ShouldGetConfigureSettings()
        {
            Client client = new Client();
            Hashtable settings = client.GetSettings(HOST, ENV, APP);
            Assert.AreEqual("value1", settings["key1"]);
            Assert.AreEqual("value2", settings["key2"]);
        }




        private void ExecutePutMethod(string url)
        {
            ExecutePutMethod(url, string.Empty);
        }

        private void ExecutePutMethod(string url, string value)
        {
            HttpWebRequest request = (HttpWebRequest)HttpWebRequest.Create(url);
            request.Method = "PUT";
            using (Stream stream = request.GetRequestStream())
            {
                request.ContentType = "application/x-www-form-urlencoded; charset=UTF-8";

                UTF8Encoding encoding = new UTF8Encoding();
                byte[] content = encoding.GetBytes(value);
                request.ContentLength = content.Length;
                stream.Write(content, 0, content.Length);
                stream.Close();
            }
            HttpStatusCode status = ((HttpWebResponse)request.GetResponse()).StatusCode;

            Assert.IsTrue(status == HttpStatusCode.OK || status == HttpStatusCode.Created);
        }

    }
}
