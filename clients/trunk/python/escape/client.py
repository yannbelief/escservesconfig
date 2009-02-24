#!/usr/bin/env python
#   Copyright 2009 ThoughtWorks
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""escape.client

"""

import urllib2

class Client:
    """A very simple client to get a configuration dictionary from ESCAPE

    """

    def getConfig(self, host, env, app):
        """Get the configuration for Application 'app' in Environment 'env' from 'host'

            host: URL of Escape server (http://escape)
            env:  Name of the environment
            app:  Name of the application

            This returns a dictionary containing the configuration, throws exceptions if there are problems
        """
        config = {}
        data = urllib2.urlopen("%s/environments/%s/%s" % (host, env, app))
        for line in data.readlines():
            (key, val) = line.split('=', 1)
            config[key] = val.strip()
    
        return config



import unittest
import httplib

class ClientTests(unittest.TestCase):
    HOST = "http://localhost:7000"
    ENV = "default"
    APP = "esc-client-python"

    def setUp(self):
        conn = httplib.HTTPConnection(self.HOST.replace("http://", ""))
        conn.request("GET", "/")
        res = conn.getresponse()
        self.assertEqual(res.status, 200)

        conn.request("PUT", "/environments/%s/%s" % (self.ENV, self.APP))
        res = conn.getresponse()
        self.assertTrue(res.status in [200, 201])

        conn.request("PUT", "/environments/%s/%s/key1" % (self.ENV, self.APP), "value1")
        res = conn.getresponse()
        self.assertTrue(res.status in [200, 201])

        conn.request("PUT", "/environments/%s/%s/key2" % (self.ENV, self.APP), "value2")
        res = conn.getresponse()
        self.assertTrue(res.status in [200, 201])


    def testCanGetPropertiesFromEscapeServer(self):
        cfg = Client().getConfig(self.HOST, self.ENV, self.APP)

        self.assertTrue(cfg.has_key("key1"))
        self.assertTrue(cfg.has_key("key2"))
        self.assertEquals(cfg["key1"], "value1")
        self.assertEquals(cfg["key2"], "value2")

    def testThatExceptionIsThrownWhenServerIsDown(self):
        ex = 0
        try:
            cfg = Client().getConfig(self.HOST.replace("7000", "7001"), self.ENV, self.APP)
        except urllib2.URLError, e:
            ex = 1
        finally:
            self.assertTrue(ex) 

    def testThatExceptionIsThrownOnBadURL(self):
        ex = 0
        try:
            cfg = Client().getConfig(self.HOST.replace("http://", "sheep://"), self.ENV, self.APP)
        except urllib2.URLError, e:
            ex = 1
        finally:
            self.assertTrue(ex) 

    def testThatBadEnvThrowsException(self):
        ex = 0
        try:
            cfg = Client().getConfig(self.HOST, "non-existing-env", self.APP)
        except urllib2.HTTPError, e:
            if e.code == 404:
                ex = 1
        finally:
            self.assertTrue(ex) 
    
    def testThatBadAppThrowsException(self):
        ex = 0
        try:
            cfg = Client().getConfig(self.HOST, "non-existing-env", self.APP)
        except urllib2.HTTPError, e:
            if e.code == 404:
                ex = 1
        finally:
            self.assertTrue(ex) 

    def testThatWeCanPassAnEqualsSignInAValue(self):
        conn = httplib.HTTPConnection(self.HOST.replace("http://", ""))
        conn.request("PUT", "/environments/%s/%s/equals" % (self.ENV, self.APP), "1=2")
        res = conn.getresponse()
        self.assertTrue(res.status in [200, 201])

        cfg = Client().getConfig(self.HOST, self.ENV, self.APP)

        self.assertEquals(cfg["equals"], "1=2")


if __name__ == "__main__":
    # We've been run from the command line - let's test!
    unittest.main()
    
