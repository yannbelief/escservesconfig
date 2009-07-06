package com.thoughtworks.escape;

public class EscapeException extends RuntimeException {

	private static final long serialVersionUID = 1021683443607084464L;

	public EscapeException() {
		super();
	}

	public EscapeException(String message, Throwable cause) {
		super(message, cause);
	}

	public EscapeException(String message) {
		super(message);
	}

	public EscapeException(Throwable cause) {
		super(cause);
	}

	public EscapeException(String format, Object... args) {
		this(String.format(format, args));
	}
	
}
