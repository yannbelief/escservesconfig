package com.thoughtworks.escape;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;
import static org.junit.matchers.JUnitMatchers.*;

import java.io.IOException;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.junit.Before;
import org.junit.Ignore;

@Ignore("not a test")
public class BaseTest {

	protected static final String HOST = "http://localhost:7000";
	protected static final String ENVIRONMENT_NAME = "default";
	protected static final String APPLICATION_NAME = "esc-client-java";

	protected static final String escapeBaseUrl = HOST + "/environments/";
	protected static final String escapeApplicationBaseUrl = escapeBaseUrl + ENVIRONMENT_NAME + "/" + APPLICATION_NAME + "/";

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
