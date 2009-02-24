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

import org.junit.Test;
import org.junit.Before;
import static org.junit.matchers.JUnitMatchers.*;
import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.PostMethod;

import java.util.Properties;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.net.MalformedURLException;
import java.net.ConnectException;

public class ClientTest {
    private static final String HOST = "http://localhost:7000";
    private static final String ENV = "default";
    private static final String APP = "esc-client-java";

    private static String getUrl() {
        return HOST + "/environments/" + ENV + "/" + APP;
    }

    @Before
    public void setUpTestData() throws IOException {
        HttpClient client = new HttpClient();
        HttpMethod method = new GetMethod(HOST);
        int code = client.executeMethod(method);
        assertEquals(200, code);

        method = new PutMethod(getUrl());
        code = client.executeMethod(method);
        assertThat(code, either(is(200)).or(is(201)));

        PutMethod put = new PutMethod(getUrl() + "/key1");
        put.setRequestBody("value1");
        code = client.executeMethod(put);
        assertThat(code, either(is(200)).or(is(201)));

        put = new PutMethod(getUrl() + "/key2");
        put.setRequestBody("value2");
        code = client.executeMethod(put);
        assertThat(code, either(is(200)).or(is(201)));
    }

    @Test
    public void testCanGetPropertiesFromEscapeServer() throws IOException {
        Properties properties = Client.getProperties(HOST, ENV, APP);

        assertTrue(properties.containsKey("key1"));
        assertTrue(properties.containsKey("key2"));
        assertTrue(properties.getProperty("key1").equals("value1"));
        assertTrue(properties.getProperty("key2").equals("value2"));
    }

    @Test
    public void testThatConnectExceptionIsThrownWhenServerIsDown() throws IOException {
        Boolean exception = false;

        try {
            Client.getProperties("http://localhost:700", ENV, APP);
        } catch (ConnectException e) {
            exception = true;
        }

        assertTrue(exception);
    }

    @Test
    public void testMalformedURLExceptionIsThrownOnBadURL() throws IOException {
        Boolean exception = false;
        try {
            Client.getProperties("sheep://cheese", ENV, APP);
        } catch (MalformedURLException e) {
            exception = true;
        }

        assertTrue(exception);
    }

    @Test
    public void testBadAppOrEnvThrowsFileNotFoundException() throws IOException {
        Boolean exception = false;
        try {
            Client.getProperties(HOST, "non-existing-env", APP);
        } catch (FileNotFoundException e) {
            exception = true;
        }
        
        assertTrue(exception);

        exception = false;
        try {
            Client.getProperties(HOST, ENV, "non-existing-app");
        } catch (FileNotFoundException e) {
            exception = true;
        }

        assertTrue(exception);
    }
}
