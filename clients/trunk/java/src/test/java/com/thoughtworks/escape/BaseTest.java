package com.thoughtworks.escape;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;
import static org.junit.matchers.JUnitMatchers.*;

import java.io.IOException;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpState;
import org.apache.commons.httpclient.HttpURL;
import org.apache.commons.httpclient.URIException;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;

@Ignore("not a test")
public class BaseTest {

	private static final String ENVIRONMENTS_PATH = "environments";
	
	protected static final String HOST = "localhost";
	protected static final int PORT = 7000;
	protected static final String DEFAULT_ENVIRONMENT = "default";
	protected static final String EXAMPLE_APPLICATION = "esc-client-java";

	@Before
	public void setUpTestData() throws IOException {
		assertEscapeIsRunning();
		addApplication(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);
		addProperty(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION, "key1", "value1");
		addProperty(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION, "key2", "value2");
	}

	@After
	public void tearDown() {
		removeApplication(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);
	}
	
	protected void assertEscapeIsRunning() {
		final String path = String.format("/%s", ENVIRONMENTS_PATH);
		final HttpURL url = escapeUrlFor(path);
		try {
			assertThat(new HttpClient().executeMethod(new GetMethod(url.toString())), is(200));
		} catch (IOException e) {
			fail(String.format("Can't connect to Escape server at url [%s] --> " +
					"make sure that Escape is running", url.toString()));
		}
	}

	protected void addEnvironment(String environment) {
		try {
			final String path = String.format("/%s/%s", ENVIRONMENTS_PATH, environment);
			final HttpURL url = escapeUrlFor(path);
			assertThat(new HttpClient().executeMethod(new PutMethod(url.toString())), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected void removeEnvironment(String environment) {
		try {
			final String path = String.format("/%s/%s", ENVIRONMENTS_PATH, environment);
			final HttpURL url = escapeUrlFor(path);
			assertThat(new HttpClient().executeMethod(new DeleteMethod(url.toString())), is(200));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected void ownEnvironment(String environment, String name, String password) {
		try {
			final String path = String.format("/%s/%s", "owner", environment);
			final HttpURL url = escapeUrlFor(path);
			HttpClient httpClient = authenticatedHttpClientFor(name, password);
			assertThat(httpClient.executeMethod(new DeleteMethod(url.toString())), is(200));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected void addApplication(String environment, String application) {
		try {
			final String path = String.format("/%s/%s/%s", ENVIRONMENTS_PATH, environment, application);
			final HttpURL url = escapeUrlFor(path);
			assertThat(new HttpClient().executeMethod(new PutMethod(url.toString())), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected void removeApplication(String environment, String application) {
		try {
			final String path = String.format("/%s/%s/%s", ENVIRONMENTS_PATH, environment, application);
			final HttpURL url = escapeUrlFor(path);
			assertThat(new HttpClient().executeMethod(new DeleteMethod(url.toString())), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected void addProperty(String environment, String application, String key, String value) {
		try {
			final String path = String.format("/%s/%s/%s/%s", ENVIRONMENTS_PATH, environment, application, key);
			final HttpURL url = escapeUrlFor(path);
			PutMethod addPropertyMethod = new PutMethod(url.toString());
			addPropertyMethod.setRequestEntity(new StringRequestEntity(value, "text/plain", "utf-8"));
			assertThat(new HttpClient().executeMethod(addPropertyMethod), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(e.toString());
		}
	}
	
	protected void addUser(String name, String password) {
		try {
			final String path = String.format("/user/%s", name);
			final HttpURL url = escapeUrlFor(path);
			PostMethod addUserMethod = new PostMethod(url.toString());
			addUserMethod.setParameter("password", password);
			addUserMethod.setParameter("email", "joe@tw.com");
			assertThat(new HttpClient().executeMethod(addUserMethod), is(201));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected void removeUser(String name, String password) {
		try {
			final String path = String.format("/user/%s", name);
			final HttpURL url = escapeUrlFor(path);
			HttpClient httpClient = authenticatedHttpClientFor(name, password);
			assertThat(httpClient.executeMethod(new DeleteMethod(url.toString())), is(200));
		} catch (IOException e) {
			fail(e.toString());
		}
	}
	
	protected void addEncryptedProperty(String environment, String application, String key, String value, String name, String password) {
		try {
			final String path = String.format("/%s/%s/%s/%s", ENVIRONMENTS_PATH, environment, application, key);
			final HttpURL url = escapeUrlFor(path);
			url.setQuery("encrypted=true");
			HttpClient httpClient = authenticatedHttpClientFor(name, password);
			PutMethod encryptPropertyMethod = new PutMethod(url.toString());
			encryptPropertyMethod.setRequestEntity(new StringRequestEntity(value, "text/plain", "utf-8"));
			assertThat(httpClient.executeMethod(encryptPropertyMethod), either(is(200)).or(is(201)));
		} catch (IOException e) {
			fail(e.toString());
		}
	}

	protected HttpURL escapeUrlFor(final String path) {
		try {
			return new HttpURL(HOST, PORT, path);
		} catch (URIException e) {
			throw new RuntimeException(e);
		}
	}

	private HttpClient authenticatedHttpClientFor(String name, String password) {
		HttpClient httpClient = new HttpClient();
		HttpState httpState = new HttpState();
		httpState.setCredentials(new AuthScope("localhost", 7000), 
				new UsernamePasswordCredentials(name, password));
		httpClient.setState(httpState);
		return httpClient;
	}
}
