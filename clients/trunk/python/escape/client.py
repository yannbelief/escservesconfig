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

class Client:
    """The sample client.
    """

    def __init__(self, host, env, app):
        print "Hello World - need to get %s/%s/%s" % (host, env, app)



import unittest

class ClientTests(unittest.TestCase):
    HOST = "http://localhost:7000"
    ENV = "default"
    APP = "myapp"

    def setUp(self):
        # TODO: Set up our test data
        pass

    def testCanGetPropertiesFromEscapeServer(self):
        cfg = Client(self.HOST, self.ENV, self.APP)

if __name__ == "__main__":
    # We've been run from the command line - let's test!
    unittest.main()
    
