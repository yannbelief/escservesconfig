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

import static org.junit.Assert.*;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.ConnectException;
import java.net.MalformedURLException;
import java.util.Properties;

import org.junit.Test;

public class ClientTest extends BaseTest {
	
	private final String baseUrl = ESCAPE.escapeUrlFor("/").toString();

	@Test
	public void testCanGetPropertiesFromEscapeServer() throws IOException {
		Properties properties = Client.getProperties(baseUrl, DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);

		assertTrue(properties.containsKey("key1"));
		assertTrue(properties.containsKey("key2"));
		assertTrue(properties.getProperty("key1").equals("value1"));
		assertTrue(properties.getProperty("key2").equals("value2"));
	}

	@Test(expected=ConnectException.class)
	public void testThatConnectExceptionIsThrownWhenServerIsDown() throws IOException {
		Client.getProperties("http://localhost:700", DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);
	}

	@Test(expected=MalformedURLException.class)
	public void testThatMalformedURLExceptionIsThrownOnBadURL() throws IOException {
		Client.getProperties("sheep://cheese", DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);
	}

	@Test(expected=FileNotFoundException.class)
	public void testThatBadEnvThrowsFileNotFoundException() throws IOException {
		Client.getProperties(baseUrl, "non-existing-env", EXAMPLE_APPLICATION);
	}

	@Test(expected=FileNotFoundException.class)
	public void testThatBadAppThrowsFileNotFoundException() throws IOException {
		Client.getProperties(baseUrl, DEFAULT_ENVIRONMENT, "non-existing-app");
	}
	
}
