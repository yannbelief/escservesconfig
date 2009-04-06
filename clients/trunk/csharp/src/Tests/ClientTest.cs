using System.Collections;
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
        #region Setup/Teardown

        [SetUp]
        public void SetUp()
        {
            ExecutePutMethod(Url);
            ExecutePutMethod(Url + "/key1", "value1");
            ExecutePutMethod(Url + "/key2", "value2");
        }

        #endregion

        private const string HOST = "http://localhost:7000";
        private const string ENV = "default";
        private const string APP = "esc-client-csharp";

        private string Url
        {
            get { return HOST + "/environments/" + ENV + "/" + APP; }
        }


        private void ExecutePutMethod(string url)
        {
            ExecutePutMethod(url, string.Empty);
        }

        private void ExecutePutMethod(string url, string value)
        {
            HttpWebRequest request = (HttpWebRequest) WebRequest.Create(url);
            request.Method = "PUT";
            request.ContentType = "application/x-www-form-urlencoded; charset=UTF-8";
            UTF8Encoding encoding = new UTF8Encoding();
            byte[] content = encoding.GetBytes(value);
            request.ContentLength = content.Length;
            using (Stream stream = request.GetRequestStream())
            {
                stream.Write(content, 0, content.Length);
                stream.Close();
            }
            HttpWebResponse response = (HttpWebResponse) request.GetResponse();
            HttpStatusCode status = response.StatusCode;
            response.Close();
            
            Assert.IsTrue(status == HttpStatusCode.OK || status == HttpStatusCode.Created);
        }

        [Test]
        public void ShouldGetConfigureSettings()
        {
            Client client = new Client();
            Hashtable settings = client.GetSettings(HOST, ENV, APP);
            Assert.AreEqual("value1", settings["key1"]);
            Assert.AreEqual("value2", settings["key2"]);
        }
    }
}