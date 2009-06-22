package com.thoughtworks.escape;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.junit.Test;

public class EscapeConfigurationTest extends BaseTest {

	@Test
	public void shouldGetPropertiesCorrectly() throws Exception {
		EscapeConfiguration configuration = new EscapeConfiguration(
				"localhost", 7000, "default", "esc-client-java");
		assertThat(configuration.getString("key1"), is("value1"));
		assertThat(configuration.getString("key2"), is("value2"));
	}

	@Test
	public void shouldContainKeys() throws Exception {
		EscapeConfiguration configuration = new EscapeConfiguration(
				"localhost", 7000, "default", "esc-client-java");
		assertThat(configuration.containsKey("key1"), is(true));
		assertThat(configuration.containsKey("key2"), is(true));
		assertThat(configuration.containsKey("key3"), is(false));
	}

	@Test
	@SuppressWarnings("unchecked")
	public void shouldGetKeys() throws Exception {
		EscapeConfiguration configuration = new EscapeConfiguration(
				"localhost", 7000, "default", "esc-client-java");
		Set<String> expectedKeys = new HashSet<String>();
		expectedKeys.add("key1");
		expectedKeys.add("key2");
		Iterator<String> expectedKeysIterator = expectedKeys.iterator();
		Iterator<String> keysIterator = configuration.getKeys();

		while (keysIterator.hasNext()) {
			assertThat(keysIterator.next(), is(expectedKeysIterator.next()));
		}
	}

	@Test
	public void shouldAddProperty() throws Exception {
		EscapeConfiguration configuration = new EscapeConfiguration(
				"localhost", 7000, "default", "esc-client-java");
		assertThat(configuration.containsKey("addedKey"), is(false));
		configuration.addProperty("addedKey", "addedKeyValue");
		assertThat(configuration.containsKey("addedKey"), is(true));
		assertThat(configuration.getString("addedKey"), is("addedKeyValue"));
	}

	@Test
	public void shouldClearProperties() throws Exception {
		EscapeConfiguration configuration = new EscapeConfiguration(
				"localhost", 7000, "default", "esc-client-java");
		assertThat(configuration.isEmpty(), is(false));
		configuration.clear();
		assertThat(configuration.isEmpty(), is(true));
	}
	
	@Test
	public void shouldDecryptEncryptedPropertiesAutomatically() throws Exception {
		final String environment =  "joes";
		final String application =  "myapp";
		final String user =  "joe";
		final String password =  "joe";
		final String key =  "secret";
		final String value =  "secret";
		
		addEnvironment(environment);
		addUser(user, password);
		ownEnvironment(environment, user, password);
		addApplication(environment, application);
		addProperty(environment, application, key, value);

		EscapeConfiguration configuration = new EscapeConfiguration(
				"localhost", 7000, environment, application);

		assertThat(configuration.getString(key), is(value));
		addEncryptedProperty(environment, application, key, value, user, password);
		assertThat(configuration.getString(key), is(not(value)));
		
		removeApplication(environment, application);
		removeApplication(DEFAULT_ENVIRONMENT, application);
		removeUser(user, password);
		removeEnvironment(environment);
	}
}
