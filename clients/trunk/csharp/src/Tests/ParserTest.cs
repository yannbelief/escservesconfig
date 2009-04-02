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
        public void ShouldParseStringToNameValuePares()
        {
            string input = @"setting1=value 1
setting2= value 2

setting3=value = 3
setting4=";
            Hashtable output = Parser.Parse(input);
            Assert.AreEqual(4, output.Count);
            Assert.AreEqual("value 1", output["setting1"]);
            Assert.AreEqual(" value 2", output["setting2"]);
            Assert.AreEqual("value = 3", output["setting3"]);
            Assert.AreEqual(string.Empty, output["setting4"]);
        }
    }
}