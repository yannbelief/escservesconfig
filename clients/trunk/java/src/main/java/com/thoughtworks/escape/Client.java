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
 * Escape client 
 */
public class Client {

	/**
	 * @param escapeBaseUrl	the Escape server's base URL, e.g. http://escape-server:7000 
	 * @param environmentName	the name of the environment  
	 * @param applicationName	the name of the application
	 * @return	the <code>Properties</code> object for environment <code>environmentName</code>
	 * and application <code>applicationName</code> 
	 * @throws IOException
	 */
	public static Properties getProperties(String escapeBaseUrl, String environmentName, String applicationName) 
			throws IOException {
		return getProperties(new URL(escapeBaseUrl + "/environments/" + environmentName + "/" + applicationName));
	}

	private static Properties getProperties(URL url) throws IOException {
		Properties props = new Properties();
		props.load(url.openStream());
		return props;
	}
}
