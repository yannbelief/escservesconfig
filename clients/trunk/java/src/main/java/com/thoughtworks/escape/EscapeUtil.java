package com.thoughtworks.escape;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

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
import org.apache.commons.io.FileUtils;

public class EscapeUtil {

	private static final String ENVIRONMENTS_PATH = "environments";

	final private String host;
	final private int port;
	
	public EscapeUtil(String host, int port) {
		this.host = host;
		this.port = port;
	}

	public void assertEscapeIsRunning() {
		final String path = String.format("/%s", ENVIRONMENTS_PATH);
		final HttpURL url = escapeUrlFor(path);
		try {
			int statusCode = new HttpClient().executeMethod(new GetMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200);
		} catch (IOException e) {
			throw new EscapeException("Can't connect to Escape server at url [%s] --> " +
					"make sure that Escape is running", url.toString());
		}
	}

	public void addEnvironment(String environment) {
		try {
			final String path = String.format("/%s/%s", ENVIRONMENTS_PATH, environment);
			final HttpURL url = escapeUrlFor(path);
			int statusCode = new HttpClient().executeMethod(new PutMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200, 201);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public void removeEnvironment(String environment) {
		removeEnvironment(environment, null, null);
	}

	public void removeEnvironment(String environment, String user, String password) {
		try {
			final String path = String.format("/%s/%s", ENVIRONMENTS_PATH, environment);
			final HttpURL url = escapeUrlFor(path);
			
			HttpClient httpClient;
			if (user != null && password != null) {
				httpClient = authenticatedHttpClientFor(user, password);
			} else {
				httpClient = new HttpClient();
			}
			
			int statusCode = httpClient.executeMethod(new DeleteMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public void ownEnvironment(String environment, String user, String password) {
		try {
			final String path = String.format("/%s/%s", "owner", environment);
			final HttpURL url = escapeUrlFor(path);
			HttpClient httpClient = authenticatedHttpClientFor(user, password);
			int statusCode = httpClient.executeMethod(new PostMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public void addApplication(String environment, String application) {
		try {
			final String path = String.format("/%s/%s/%s", ENVIRONMENTS_PATH, environment, application);
			final HttpURL url = escapeUrlFor(path);
			int statusCode = new HttpClient().executeMethod(new PutMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200, 201);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public void removeApplication(String environment, String application, String user, String password) {
		try {
			final String path = String.format("/%s/%s/%s", ENVIRONMENTS_PATH, environment, application);
			final HttpURL url = escapeUrlFor(path);
			
			HttpClient httpClient;
			if (user != null && password != null) {
				httpClient = authenticatedHttpClientFor(user, password);
			} else {
				httpClient = new HttpClient();
			}
			
			int statusCode = httpClient.executeMethod(new DeleteMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200, 201);
			
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public void removeApplication(String environment, String application) {
		removeApplication(environment, application, null, null);
	}
	
	public void addProperty(String environment, String application, String key, String value) {
		try {
			final String path = String.format("/%s/%s/%s/%s", ENVIRONMENTS_PATH, environment, application, key);
			final HttpURL url = escapeUrlFor(path);
			PutMethod addPropertyMethod = new PutMethod(url.toString());
			addPropertyMethod.setRequestEntity(new StringRequestEntity(value, "text/plain", "utf-8"));
			int statusCode = new HttpClient().executeMethod(addPropertyMethod);
			checkStatusCodeIsOneOf(statusCode, 200, 201);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}
	
	public void addUser(String user, String password) {
		try {
			final String path = String.format("/user/%s", user);
			final HttpURL url = escapeUrlFor(path);
			PostMethod addUserMethod = new PostMethod(url.toString());
			addUserMethod.setParameter("password", password);
			addUserMethod.setParameter("email", "joe@tw.com");
			int statusCode = new HttpClient().executeMethod(addUserMethod);
			checkStatusCodeIsOneOf(statusCode, 201);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public void removeUser(String user, String password) {
		try {
			final String path = String.format("/user/%s", user);
			final HttpURL url = escapeUrlFor(path);
			HttpClient httpClient = authenticatedHttpClientFor(user, password);
			int statusCode = httpClient.executeMethod(new DeleteMethod(url.toString()));
			checkStatusCodeIsOneOf(statusCode, 200);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}
	
	public void addEncryptedProperty(String environment, String application, String key, String value, String user, String password) {
		try {
			final String path = String.format("/%s/%s/%s/%s", ENVIRONMENTS_PATH, environment, application, key);
			final HttpURL url = escapeUrlFor(path);
			url.setQuery("encrypt");
			HttpClient httpClient = authenticatedHttpClientFor(user, password);
			PutMethod encryptPropertyMethod = new PutMethod(url.toString());
			encryptPropertyMethod.setRequestEntity(new StringRequestEntity(value, "text/plain", "utf-8"));
			int statusCode = httpClient.executeMethod(encryptPropertyMethod);
			checkStatusCodeIsOneOf(statusCode, 200, 201);
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}
	
	public void savePrivateKey(String environment, String application, String user, String password, File privateKey) {
		try {
			final String path = String.format("/crypt/%s/private", environment);
			final HttpURL url = escapeUrlFor(path);
			HttpClient httpClient = authenticatedHttpClientFor(user, password);
			GetMethod getPrivateKeyPropertyMethod = new GetMethod(url.toString());
			int statusCode = httpClient.executeMethod(getPrivateKeyPropertyMethod);
			checkStatusCodeIsOneOf(statusCode, 200, 201);
			String privateKeyData = getPrivateKeyPropertyMethod.getResponseBodyAsString();
			FileUtils.writeStringToFile(privateKey, privateKeyData);
			
		} catch (IOException e) {
			throw new EscapeException(e);
		}
	}

	public HttpURL escapeUrlFor(final String path) {
		try {
			return new HttpURL(host, port, path);
		} catch (URIException e) {
			throw new RuntimeException(e);
		}
	}

	private HttpClient authenticatedHttpClientFor(String user, String password) {
		HttpClient httpClient = new HttpClient();
		HttpState httpState = new HttpState();
		httpState.setCredentials(new AuthScope(host, port), 
				new UsernamePasswordCredentials(user, password));
		httpClient.setState(httpState);
		return httpClient;
	}
	
	private static void checkStatusCodeIsOneOf(int statusCode, int... expectedCodes) {
		boolean isOK = false;
		
		for (int expectedCode : expectedCodes) {
			if (statusCode == expectedCode) {
				isOK = true;
				break;
			}
		}
		
		if (!isOK) {
			throw new EscapeException("returned status code didn't match expectation of one of %s", 
					Arrays.asList(expectedCodes));
		}
	}

}
