package com.thoughtworks.escape;

import java.io.IOException;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;

@Ignore("not a test")
public class BaseTest {

	protected static final String HOST = "localhost";
	protected static final int PORT = 7000;
	protected static final EscapeUtil ESCAPE = new EscapeUtil(HOST, PORT);

	protected static final String DEFAULT_ENVIRONMENT = "default";
	protected static final String EXAMPLE_APPLICATION = "esc-client-java";


	@Before
	public void setUpTestData() throws IOException {
		ESCAPE.assertEscapeIsRunning();
		ESCAPE.addApplication(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);
		ESCAPE.addProperty(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION, "key1", "value1");
		ESCAPE.addProperty(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION, "key2", "value2");
	}

	@After
	public void tearDown() {
		ESCAPE.removeApplication(DEFAULT_ENVIRONMENT, EXAMPLE_APPLICATION);
	}
	
}
