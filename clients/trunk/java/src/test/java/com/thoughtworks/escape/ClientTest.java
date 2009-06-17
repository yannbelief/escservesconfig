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

package com.thoughtworks.escape;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;
import static org.junit.matchers.JUnitMatchers.*;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.ConnectException;
import java.net.MalformedURLException;
import java.util.Properties;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.junit.Before;
import org.junit.Test;

public class ClientTest {
	
	private static final String HOST = "http://localhost:7000";
	private static final String ENVIRONMENT_NAME = "default";
	private static final String APPLICATION_NAME = "esc-client-java";

	private static final String escapeBaseUrl = HOST + "/environments/";
	private static final String escapeApplicationBaseUrl = escapeBaseUrl + ENVIRONMENT_NAME + "/" + APPLICATION_NAME;

	@Test
	public void testCanGetPropertiesFromEscapeServer() throws IOException {
		Properties properties = Client.getProperties(HOST, ENVIRONMENT_NAME, APPLICATION_NAME);

		assertTrue(properties.containsKey("key1"));
		assertTrue(properties.containsKey("key2"));
		assertTrue(properties.getProperty("key1").equals("value1"));
		assertTrue(properties.getProperty("key2").equals("value2"));
	}

	@Test(expected=ConnectException.class)
	public void testThatConnectExceptionIsThrownWhenServerIsDown() throws IOException {
		Client.getProperties("http://localhost:700", ENVIRONMENT_NAME, APPLICATION_NAME);
	}

	@Test(expected=MalformedURLException.class)
	public void testThatMalformedURLExceptionIsThrownOnBadURL() throws IOException {
		Client.getProperties("sheep://cheese", ENVIRONMENT_NAME, APPLICATION_NAME);
	}

	@Test(expected=FileNotFoundException.class)
	public void testThatBadEnvThrowsFileNotFoundException() throws IOException {
		Client.getProperties(HOST, "non-existing-env", APPLICATION_NAME);
	}

	@Test(expected=FileNotFoundException.class)
	public void testThatBadAppThrowsFileNotFoundException() throws IOException {
		Client.getProperties(HOST, ENVIRONMENT_NAME, "non-existing-app");
	}
	
	@Before
	public void setUpTestData() throws IOException {
		assertEscapeIsRunning();
		addApplication();
		addProperty("key1", "value1");
		addProperty("key2", "value2");
	}

	private void assertEscapeIsRunning() {
		try {
			assertThat(new HttpClient().executeMethod(new GetMethod(HOST)), is(200));
		} catch (IOException e) {
			fail(String.format("Can't connect to Escape server at URI [%s] --> make sure that Escape is running", HOST));
		}
	}

	private void addApplication() {
		try {
			assertThat(new HttpClient().executeMethod(new PutMethod(escapeApplicationBaseUrl)), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(String.format("Failed to add application to Escape using URI [%s]", escapeApplicationBaseUrl));
		}
	}

	private void addProperty(String key, String value) {
		final String url = escapeApplicationBaseUrl + key;

		try {
			PutMethod putMethod = new PutMethod(url);
			putMethod.setRequestEntity(new StringRequestEntity(value, "text/plain", "utf-8"));
			assertThat(new HttpClient().executeMethod(putMethod), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(String.format("Failed to add property to Escape application using URI [%s]", url));
		}
	}

}
