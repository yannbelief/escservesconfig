package com.thoughtworks.escape;

import static org.hamcrest.CoreMatchers.*;
import static org.junit.Assert.*;

import java.io.File;

import org.junit.Test;

public class EscapeCrypterTest {

	@Test
	public void shouldDecryptValue() throws Exception {
		final File privateKey = new File("src/test/resources/private_key.pem");
		final String encrypted = "I/mpOyNrnDf4kjDa5+EnAD0Ys3OwHnp1ZJXVD1kkCci6aIK2SZYg6htZb/iwwzuXoy/OcI83/VMVCU4uDXdCFQ=="; 
		final String expectedDecrypted = "secret"; 
		
		EscapeCrypter cipher = new EscapeCrypter(privateKey);
		assertThat(cipher.decrypt(encrypted), is(expectedDecrypted));
	}
}
