package com.thoughtworks.escape;

/*
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
*/

import java.util.Properties;
import java.net.URL;
import java.io.IOException;

public class Client {
    public static Properties getProperties(String host, String env, String app) throws IOException {
        URL url = new URL(host + "/environments/" + env + "/" + app);
        Properties props = new Properties();
        props.load(url.openStream());
        return props;
    }
}