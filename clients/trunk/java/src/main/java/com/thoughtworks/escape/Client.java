/*
 *   Copyright 2009 ThoughtWorks
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 */

package com.thoughtworks.escape;

import java.io.IOException;
import java.net.URL;
import java.util.Properties;

/**
 * A client for Escape.
 */
public class Client {

	/**
	 * <p>Retrieve a {@link java.util.Properties} object that contains the properties 
	 * for a particular application running in a particular environment.</p>
	 * 
	 * <p>Typical use:</p>
	 * 
	 * <pre>
	 * Properties properties = Client.getProperties("http://escape-host:7000", "my_environment", "my_application");
	 * properties.getProperty("my.property");</pre>
	 * 
	 * @param escapeBaseUri	the Escape server's base URI, e.g. http://escape-server:7000 
	 * @param environmentName	the name of the environment  
	 * @param applicationName	the name of the application
	 * @return	the <code>Properties</code> object for environment <code>environmentName</code>
	 * and application <code>applicationName</code> 
	 * @throws IOException
	 */
	public static Properties getProperties(String escapeBaseUri, String environmentName, String applicationName) 
			throws IOException {
		return getProperties(new URL(escapeBaseUri + "/environments/" + environmentName + "/" + applicationName));
	}

	private static Properties getProperties(URL url) throws IOException {
		Properties properties = new Properties();
		properties.load(url.openStream());
		return properties;
	}
}
