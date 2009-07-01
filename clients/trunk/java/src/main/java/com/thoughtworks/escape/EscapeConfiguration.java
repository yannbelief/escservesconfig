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

import java.io.File;
import java.io.IOException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.configuration.AbstractConfiguration;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.methods.DeleteMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.apache.commons.httpclient.methods.PutMethod;
import org.apache.commons.httpclient.methods.StringRequestEntity;
import org.apache.commons.io.IOUtils;

/**
 * <p>An Escape client which implements the Apache commons configuration {@link Configuration} 
 * interface and allows both reading and writing to Escape.</p>
 * 
 * <p>Typical use:</p>
 * 
 * <pre>
 * EscapeConfiguration configuration = new EscapeConfiguration("escape-host", 7000, "my_environment", "my_application");
 * String myProperty = configuration.getString("my.property");</pre>
 * 
 */
public class EscapeConfiguration extends AbstractConfiguration {

	private static final Pattern KEY_REGEX_PATTERN = Pattern.compile("^([^=]*).*$");

	private final String baseUri;
	private File privateKey;

	/**
	 * <p>Build a configuration from Escape by specifying the following arguments.</p>
	 * 
	 * @param host	the host where Escape is running
	 * @param port	the port on which Escape is running
	 * @param environment	the name of the environment
	 * @param application	the name of the application
	 * @param privateKey	the file containing the RSA private key to 
	 * 						decrypt encrypted properties
	 */
	public EscapeConfiguration(String host, int port, String environment, String application, File privateKey) {
		this(host, port, environment, application);
		this.privateKey = privateKey;
	}

	/**
	 * <p>Build a configuration from Escape by specifying the following arguments.</p>
	 * 
	 * @param host	the host where Escape is running
	 * @param port	the port on which Escape is running
	 * @param environment	the name of the environment
	 * @param application	the name of the application
	 */
	public EscapeConfiguration(String host, int port, String environment, String application) {
		this.baseUri = String.format("http://%s:%s/environments/%s/%s/", 
				host, port, environment, application);
	}

	/**
	 * @see org.apache.commons.configuration.Configuration#containsKey(java.lang.String)
	 */
	public boolean containsKey(String key) {
		GetMethod getPropertyMethod = new GetMethod(baseUri + key);
		
		try {
			int responseCode = new HttpClient().executeMethod(getPropertyMethod);
			return responseCode == 200;
			
		} catch (IOException e) {
			throw new RuntimeException(e);

		} finally {
			getPropertyMethod.releaseConnection();
		}
	}

	/**
	 * @see org.apache.commons.configuration.Configuration#getKeys()
	 */
	@SuppressWarnings("unchecked")
	public Iterator getKeys() {
		GetMethod getPropertiesMethod = new GetMethod(baseUri);
		
		try {
			new HttpClient().executeMethod(getPropertiesMethod);
			List<String> lines = IOUtils.readLines(getPropertiesMethod.getResponseBodyAsStream());
			Set<String> keys = new HashSet<String>();
			for (String line : lines) {
				Matcher matcher = KEY_REGEX_PATTERN.matcher(line);
				if (matcher.matches()) {
					keys.add(matcher.group(1));
				} else {
					throw new RuntimeException(String.format("no keys found in line [%s]", line));
				}
			}
			return keys.iterator();
		
		} catch (IOException e) {
			throw new RuntimeException(e);

		} finally {
			getPropertiesMethod.releaseConnection();
		}
	}

	/**
	 * @see org.apache.commons.configuration.Configuration#getProperty(java.lang.String)
	 */
	public Object getProperty(String key) {
		GetMethod getPropertyMethod = new GetMethod(baseUri + key);
		
		try {
			new HttpClient().executeMethod(getPropertyMethod);
			String body = getPropertyMethod.getResponseBodyAsString();
			
			if (!isEncryptedProperty(getPropertyMethod) || privateKey == null) {
				return body;
			} else {
				return new EscapeCrypter(privateKey).decrypt(body);
			}
			
		} catch (IOException e) {
			throw new RuntimeException(e);

		} finally {
			getPropertyMethod.releaseConnection();
		}
	}

	/**
	 * @see org.apache.commons.configuration.Configuration#isEmpty()
	 */
	public boolean isEmpty() {
		return !getKeys().hasNext();
	}

	@Override
	protected void addPropertyDirect(String key, Object value) {
		PutMethod addPropertyMethod = new PutMethod(baseUri + key);
		
		try {
			addPropertyMethod.setRequestEntity(new StringRequestEntity(value.toString(), "text/plain", "utf-8"));
			new HttpClient().executeMethod(addPropertyMethod);
			
		} catch (IOException e) {
			throw new RuntimeException(e);

		} finally {
			addPropertyMethod.releaseConnection();
		}
	}
	
	@Override
	protected void clearPropertyDirect(String key) {
		DeleteMethod clearPropertyMethod = new DeleteMethod(baseUri + key);
		
		try {
			new HttpClient().executeMethod(clearPropertyMethod);
			
		} catch (IOException e) {
			throw new RuntimeException(e);

		} finally {
			clearPropertyMethod.releaseConnection();
		}
	}

	private boolean isEncryptedProperty(GetMethod getPropertyMethod) {
		final Header encryptionContentType = new Header("Content-Type", "application/octet-stream");
		final Header encryptionContentTransferEncoding = new Header("Content-Transfer-Encoding", "base64");
		
		Header contentType = getPropertyMethod.getResponseHeader("Content-Type");
		Header contentTransferEncoding = getPropertyMethod.getResponseHeader("Content-Transfer-Encoding");
		return (contentType.equals(encryptionContentType) && 
				contentTransferEncoding.equals(encryptionContentTransferEncoding));
	}
	
}
