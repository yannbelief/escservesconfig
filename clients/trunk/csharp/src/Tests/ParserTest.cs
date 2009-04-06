using System.Collections;
using NUnit.Framework;
using Thoughtworks.Escape;

namespace Thoughtworks.Escape.Tests
{
    [TestFixture]
    public class ParserTest
    {
        [Test]
        public void ShouldGetEmptyCollectionIfInputIsEmpty()
        {
            string input = @"";
            Hashtable output = Parser.Parse(input);
            Assert.AreEqual(0, output.Count);
        }

        [Test]
        public void ShouldParseStringToNameValuePares_ByCarriageReturnAndNewLine()
        {
            string input = "setting1=value 1\r\nsetting2= value 2\r\n\r\nsetting3=value = 3\r\nsetting4=";
            Hashtable output = Parser.Parse(input);
            Assert.AreEqual(4, output.Count);
            Assert.AreEqual("value 1", output["setting1"]);
            Assert.AreEqual(" value 2", output["setting2"]);
            Assert.AreEqual("value = 3", output["setting3"]);
            Assert.AreEqual(string.Empty, output["setting4"]);
        }

        [Test]
        public void ShouldParseStringToNameValuePares_ByNewLineOnly()
        {
            string input = "setting1=value 1\nsetting2= value 2\n\nsetting3=value = 3\nsetting4=";
            Hashtable output = Parser.Parse(input);
            Assert.AreEqual(4, output.Count);
            Assert.AreEqual("value 1", output["setting1"]);
            Assert.AreEqual(" value 2", output["setting2"]);
            Assert.AreEqual("value = 3", output["setting3"]);
            Assert.AreEqual(string.Empty, output["setting4"]);
        }


    }
}